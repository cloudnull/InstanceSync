InstanceSync
============

The use cases
^^^^^^^^^^^^^

* Migrating from one provider to another
* Cloning an instance 
* Upgrading Infrastructures
* Setting up Geographic Redundancies 

What I have tested
^^^^^^^^^^^^^^^^^^

* Rackspace Instances from XenClassic To XenServer
* Rackspace Instances from XenServer to Open Cloud powered by OpenStack
* Rackspace Instances from XenClassic To Open Cloud powered by OpenStack 
* Amazon EC2 to the Rackspace Cloud
* KVM to Rackspace Cloud

Caveats :
  There are two issues I have found while migrating instances around. However, the most important caveat was related to the instance type.  **You Must Have a Similar Instance to Migrate Too**. Additionally to migrate a linux server from one place to another you must also have setup the instance to use a Single partition for installation.  If you are using a multi-partition virtual instance, you will have to manually migrate the partitions accordingly.  Which can be successfully accomplished by migrating the instance by hand. Other than the one caveat, of having Similar Instance, I have not had this process fail.

Testament that It Works :
  I know that this method works for a variety of situations, I have even had this process complete successfully when migrating an instance that uses **Amazon AMI Linux**. 

Estimated time of Completion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**The Estimated time to completion based on Gigabytes of Consumed Space**
**Computations have been made using an average transfer rate of 20 Megabytes a second.**

============  ============
    The Estimated time
--------------------------
 Space Used     EST Time
============  ============
 10G          9    Minutes
 20G          17   Minutes
 40G          34   Minutes
 80G          68   Minutes
 160G         136  Minutes
 320G         272  Minutes
 620G         544  Minutes
 1200G        1088 Minutes
============  ============

