An Ansible project for running CNF testing on existing operator with KUTTL 
=========

~~~ ansible-playbook -i inventory/hosts cnf-test-playbook.yaml -e csv_name="etcdoperator.v0.9.4" -e operator_namespace="my-etcd"~~~ 

The output will create KUTTL files to run test on your operators.

TODO:
----
 Create cnf-operator-test image which will  run ansible and generate KUTTL asserts and execute kuttle test suite on those reports.


Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.
To install it use: ansible-galaxy collection install community.kubernetes.
Read for more requirement.


Example Playbook
----------------

ansible-playbook -i inventory/hosts cnf-test-playbook.yaml -e csv_name="etcdoperator.v0.9.4" -e operator_namespace="my-etcd"

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
