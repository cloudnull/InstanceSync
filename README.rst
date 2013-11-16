InstanceSync, Resource Cloning
##############################
:date: 2013-11-12 10:20
:tags: migrate, clone, sync, rackspace, aws, hpcloud
:category: \*nix


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
  There are two issues I have found while migrating instances around. However, the most important caveat was related to the instance type.  **You Must Have a Similar Instance to Migrate Too**. 
  Additionally to migrate a linux server from one place to another you must also have setup the instance to use a Single partition for installation.  
  If you are using a multi-partition virtual instance, you will have to manually migrate the partitions accordingly.  Which can be successfully accomplished by migrating the instance by hand. 
  Other than the one caveat, of having Similar Instance, I have not had this process fail.

  
Testament that It Works :
  I know that this method works for a variety of situations, I have even had this process complete successfully when migrating an instance that uses **Amazon AMI Linux**. 

  
Available Options
^^^^^^^^^^^^^^^^^

All options can be set as exports in the environment which the script will use with attempting to perform the Sync Operation.


Enable More Verbosity in the script, Default is "False":
  VERBOSE="False or True"

Enable Debug Mode in the Script, Default is "False":
  DEBUG="False or True"

Add Additional Excludes to the script when Performing the Sync. This is a Space separated list, if you have files with spaces in the name you MUST escape them.
  USER_EXCLUDES=""

Change the Retry Max, Default is 5. This is useful on systems with High Load averages, which can cause the Sync Process to die.
  MAX_RETRIES="5"

Enable Inflammatory mode, Default is "False":
  INFLAMMATORY="False or True"
  
  
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


Do you want to see the script in Action:
  I have a screen cast of a migration for a Live Instance to another instance. `You can check it out here`_\.

  
.. _You can check it out here: http://ascii.io/a/1063


Foot Notes
^^^^^^^^^^

When Performing a sync you should attempt to minimize load on your "Source" machine. The Sync script works great on a live system though if the load is too high it could cause the sync process to die.

When performing a sync on a system with a database, be aware that if you are writing a lot of data to the database you may want to shutdown the database engine while the sync is in process. By shutting down the database you can be sure that all of the data in the database was cloned without any sharding.
