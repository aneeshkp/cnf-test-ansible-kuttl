#!/bin/sh

# A script that takes the output of an Ansible run and generates XML
# similar to the output of JUnit so that Jenkins can parse it.
#
# Usage: ansible2JUnitXML ansible.out

# Copyright (c) 2015 The Regents of the University of California.
# All rights reserved.
#
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this #
# software and its documentation for any purpose, provided that the
# above copyright notice and the following two paragraphs appear in
# all copies of this software.
#
# IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY
# PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
# DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
# DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#
# THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
# PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
# CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
# ENHANCEMENTS, OR MODIFICATIONS.

if [ $# -ne 1 ]; then
    echo "Usage: $0 ansible.out"
    exit 2
fi

ansibleOutput=$1

if [ ! -r $ansibleOut ]; then
    echo "$0: $ansibleOut is not readable?"
    exit 3
fi

failures=`cat $ansibleOutput | awk '{
    # Print everything after "PLAY RECAP"
    if ($0 ~ /^PLAY RECAP/) {
        sawPlayRecap=1
    } 
    if (sawPlayRecap == 1) {
	 if ($6 ~ /failed/) {
	     split($6, f, "=");

	     failed+=f[1] + 0
	 }
    }
}
END {print failed}'`

skipped=`cat $ansibleOutput | awk '{
    # Print everything after "PLAY RECAP"
    if ($0 ~ /^PLAY RECAP/) {
        sawPlayRecap=1
    } 
    if (sawPlayRecap == 1) {
	 if ($5 ~ /unreachable/) {
	     split($5, f, "=");
	     unreachable+=f[1]
	 }
    }
}
END {print unreachable}'`

name=ansible2JUnitXML
tests=`egrep "^TASK: " $ansibleOutput | wc -l`


echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
echo "<testsuite errors=\"0\" failures=\"$failures\" hostname=\"`hostname`\" name=\"$name\" skipped=\"$skipped\" tests=\"$tests\" time=\"0.001\" timestamp=\"`date +%Y-%M-%dT%H:%M:%S`\">"
  #Sample Output
  #<testcase classname="ptolemy.util.test.junit.TclTests" name="[0] ThereAreNoTclTests (RunTclFile)" time="0.001" />
  cat $ansibleOutput | awk '{
    if ( $0 ~ /^TASK: / || $0 ~ /^GATHERING FACTS/ ) {
        if (number >0 ) {
            print "    </testcase>"
        }
        number++;
        if ($0 ~ /^GATHERING FACTS/ ) {
            name="GATHERING FACTS"
        } else {
            name=substr($0, 8, index($0, "]") -8)
        }
        if (length(name) > 80) {
           name=substr(name, 1, 80) "..."
        }
        if (name ~/debug msg=/) {
           prefix=length("debug msg=") + 1
           name=substr(name, prefix, length(message)-prefix-1);
        }
        gsub(/"/, "\\&quot;", name)
        gsub(/\|/, " bar ;", name)
        print "    <testcase classname=\"ansible\" name=\"[" number "] " name "\" time=\"0.001\" >"
    }
    if ( $0 ~ /^fatal: /) {
        # FIXME: accumulate the failure text
        if (length($0) > 80) {
           message=substr($0, 1, 80) "..."
        } else {
           message=$0
        }
        if (message ~/debug msg=/) {
           prefix=length("debug msg=") + 1
           message=substr(message, prefix, length(message)-prefix-1);
        }
        gsub(/"/, "\\&quot;", message)
        gsub(/\|/, " bar ", message)
        print "        <failure message=\""$0"\" />"
    }
}
END { if (number > 0) {
          print "    </testcase>"
      }
}'

echo "</testsuite>"