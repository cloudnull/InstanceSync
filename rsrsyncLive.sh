#!/bin/bash
# ==============================================================================
# - title        : Migrating Servers Using RSYNC
# - description  : This Script Will Migrate Data From one Instance to another
# - License      : GPLv3
# - author       : Kevin Carter
# - date         : 2013-10-26
# - version      : 2.0.0
# - usage        : bash rsrsyncLive.sh
# - OS Supported : Ubuntu, Debian, SUSE, Gentoo, RHEL, CentOS, Scientific, Arch
# ==============================================================================



# Trap Errors and or Exits
trap "CONTROL_C" SIGINT
trap "EXIT_ERROR Line Number: ${LINENO} Exit Code: $?" ERR

# Set modes
set -u
set -e

# Root user check for install 
# ==============================================================================
function CHECKFORROOT() {
  USERCHECK=$( whoami  )
  if [ "$(id -u)" != "0" ]; then
    echo -e "This script must be run as ROOT
You have attempted to run this as ${USERCHECK}
use sudo $0 or change to root.
"
    exit 1
  fi
}


# Trap a CTRL-C Command 
# ==============================================================================
function CONTROL_C() {
  set +e
  echo -e "
\033[1;31mAAHAHAAHH! FIRE! CRASH AND BURN! \033[0m
\033[1;36mYou Pressed [ CTRL C ] \033[0m
"
  QUIT
  if [ "${INFLAMMATORY}" == "True" ];then 
    echo -e "You obviously screwed something up or you got cold feet..."
  fi

  echo "I quit, and deleted all of the temp files I made."
  EXIT_ERROR
}


# Tear down
# ==============================================================================
function QUIT() {
  set +e
  set -v

  echo 'Removing Temp Files'
  GENFILES="/tmp/intsalldeps.sh /tmp/known_hosts /tmp/postopfix.sh"

  for temp_file in ${EXCLUDE_FILE} ${GENFILES} ${SSH_KEY_TEMP};do 
    [ -f ${temp_file} ] && rm ${temp_file}
  done

  set +v
}

function EXIT_ERROR() {
  # Print Messages
  echo -e "ERROR! Sorry About that... 
Here is what I know: $@
"
  QUIT
  exit 1
}


# Say  something nice and exit
# ==============================================================================
function ALLDONE() {
  echo "all Done."

  if [ "${INFLAMMATORY}" == "True" ];then 
    echo -e "I hope you enjoyed all of my hard work..."
  fi

  GITHUBADDR="\033[1;36mhttps://github.com/cloudnull\033[0m"
  WEBADDR="\033[1;36mhttp://cloudnull.io\033[0m"
  
  echo -e "
Stop by ${GITHUBADDR} or ${WEBADDR} for other random tidbits...
"

  if [ "${INFLAMMATORY}" == "True" ];then 
    echo -e "And if you feel so Inclined you can buy me a \033[1;33mBeer\033[0m,
I perfer cold \033[1;33mBeer\033[0m But I will normally drink anything.  :)
"
  fi
}


# Check to see if this is an Amazon Server Migrating to the Rackspace Cloud
# ==============================================================================
function ISTHISAMAZON() {
  KERNELTYPE=$(uname -r | head -n 1)
  if [ "$(echo "${KERNELTYPE}" | grep -i amzn)" ];then
    AK="YES"
  else
    AK="FALSE"
  fi

  # Check for known Amazon BOTO Python Modules
  AB=$(echo -e "
try:
  import boto.roboto.awsqueryservice
except ImportError:
  print 'FAIL'
else:
  print 'YES'
" | python)

  # Check for known BOTO Python Modules
  CB=$(echo -e "
try:
  import boto
except ImportError, e:
  print 'FAIL'
else:
  print 'YES'
" | python)

  if [ "${AK}" == "YES" ] || [ "${AB}" == "YES" ] || [ "${CB}" == "YES" ];then
    echo -e "It seems you are currently on an Amazon Server using 
The \033[1;33mAmazon AMI\033[0m Linux Distribution.
"

    if [ "${INFLAMMATORY}" == "True" ];then 
      echo -e "Which must really suck..."
    fi

    echo -e "Is this instance coming from \033[1;33mAmazon EC2\033[0m?"
    read -p "Please Answer yes or no : " MIGRATEEC2
    MIGRATEEC2=${MIGRATEEC2:-"no"}
    case ${MIGRATEEC2} in
      yes)
        echo -e "Due to \033[1;33mAmazon EC2\033[0m SSH Security already in 
place. Access to your Instance POST migration will use your current Amazon
Method. Which may involve PEM files, keys or other assorted means.
"

        if [ "${INFLAMMATORY}" == "True" ];then 
          echo -e "Bottom Line, If it worked before it should work again..."
        fi

        # Adding additional Excludes, for Amazon
        echo -e "We are adding additional Excludes to accommodate
\033[1;33mAmazon EC2\033[0m Instances.
"

        if [ "${INFLAMMATORY}" == "True" ];then 
          echo -e "Which by the way are junk..."
        fi

        AMAZONEXCLUDEVAR=$(echo ${AMAZONEXCLUDE_LIST} | sed 's/\ /\\n/g')
        echo -e ${AMAZONEXCLUDEVAR} | tee -a ${EXCLUDE_FILE}
        find / -name '*cloudinit*' | tee -a ${EXCLUDE_FILE}
        find / -name '*cloud-init*' | tee -a ${EXCLUDE_FILE}
        find / -name '*amazon*' | tee -a ${EXCLUDE_FILE}

        sleep 5

        if [ "${AK}" == "YES" ];then
          echo -e "Based on the \033[1;33m${KERNELTYPE}\033[0m Kernel. You 
seem to be using an Instance of \033[1;33mAmazon AMI Linux\033[0m. If you want 
to continue you can, but there may be complications. Your best bet for 
guaranteed success is to manually migrate your data.
"

          if [ "${INFLAMMATORY}" == "True" ];then 
            echo -e "The reason for this is that you have chosen a terrible 
distribution of Linux which really is nothing more than a clone of another 
terrible Linux Distribution... RHEL...but rest assured I did test this action 
thoroughly... even if I did hate every minute of it.
"
          fi

          echo -e "I have Great success in migrating \033[1;33mAmazon AMI
Linux\033[0m to \033[1;31mCentOS/RHEL\033[0m If your Target Server is a
\033[1;31mCentOS/RHEL\033[0m you should be fine. While I have had a lot of 
Success moving these types of Instances around, You should also be aware that
\033[1;33mAmazon AMI Linux\033[0m is proprietary and it could have issues moving
to a more Open Source Platform.
"

          read -p "Press [Enter] to Continue or [ CTRL -C ] to quit."
        fi
      ;;

      no)
        echo -e "Sounds Good, I don't like \033[1;33mAmazon\033[0m anyway."
      ;;

      *)
        echo "Please Enter \"yes\" or \"no\" in lower case letters."
        unset MIGRATEEC2
        ISTHISAMAZON 
      ;;
    esac
  fi
}

# Amazon Specific Processes 
# ==============================================================================
function AMAZONPROCESSES() {
  if [ "${AK}" == "YES" ];then
    echo -e "\033[1;36mNow performing Amazon Specific Processes\033[0m"
    T_HOST=$(ssh -i ${SSH_KEY_TEMP} -o UserKnownHostsFile=/dev/null \
                                    -o StrictHostKeyChecking=no root@${TIP} \
                                    "echo \$( head -1 /etc/issue )")

    ssh -i ${SSH_KEY_TEMP} -o UserKnownHostsFile=/dev/null \
                           -o StrictHostKeyChecking=no root@${TIP} \
                           "bash postopfix.sh";

    ssh -i ${SSH_KEY_TEMP} -o UserKnownHostsFile=/dev/null \
                           -o StrictHostKeyChecking=no root@${TIP} \
                           "yum -y install initscripts"

    if [ "$(echo ${T_HOST} | grep -i centos)" ];then
      TARGET_OS_TYPE="centos"
      ssh -i ${SSH_KEY_TEMP} -o UserKnownHostsFile=/dev/null \
                             -o StrictHostKeyChecking=no root@${TIP} \
                             "yum -y install ${TARGET_OS_TYPE}-release"
    elif [ "$(echo ${T_HOST} | grep -i redhat)" ];then
      TARGET_OS_TYPE="redhat"
      ssh -i ${SSH_KEY_TEMP} -o UserKnownHostsFile=/dev/null \
                             -o StrictHostKeyChecking=no root@${TIP} \
                             "yum -y install ${TARGET_OS_TYPE}-release"
    else
      TARGET_OS_TYPE="YOUR-TARGET-DISTRO"
      echo -e "The Target Distro did not match what I was looking for
You need to login to the Target Instance and run :
yum install ${TARGET_OS_TYPE}-release"
    fi
  fi
}

# Post Migration script for Amazon AMI Linux
# ==============================================================================
function AMAZONPOSTPROCESSES() {
  if [ "${AK}" == "YES" ];then
    echo -e "# Post Migration Script
REL=\"/etc/yum/vars/releasever\"
VER=\"\$( cat /etc/issue | head -n 1 | awk '{print \$3}' )\"
echo \"\$( echo \${VER} | awk -F '.' '{print \$1}' )\" | tee \${REL}
PKS=\"epel-release system-release sysvinit perl-io perl-file perl-http \"
PKS+=\"perl-lwp perl-net aws perl-libwww\"
for pkg in \${PKS};do
  if [ \"\$(rpm -qa | grep -iE \$pkg )\" ];then
    rpm -e --nodeps \$pkg
  fi
done" | tee /tmp/postopfix.sh
    scp -i ${SSH_KEY_TEMP} /tmp/postopfix.sh root@${TIP}:/root/
  fi
}

function AMAZONWARNING() {
  if [ "${AK}" == "YES" ];then
    echo -e "Being that this instance was migrating from an 
\033[1;33mAmazon EC2\033[0m You should login to the Target Server and make any
configuration changes that are needed. I have tried to be thorough but some
times things happen which can cause incompatibilities.
"
    if [ "${INFLAMMATORY}" == "True" ];then 
      echo -e "In short if its broke, don't cry...\n"
    fi
  fi
}

# Set the Source and Origin Drives
# ==============================================================================
function GETDRIVE1() {
  read -p "
Press [Enter] to Continue accepting the normal Rackspace Defaults 
or you may Specify a Source Directory: " DRIVE1
  DRIVE1=${DRIVE1:-"/"}

  if [ ! -d "${DRIVE1}" ];then
    echo "The path or Device you specified does not exist."
    read -p "Specify \033[1;33mYOUR\033[0m Source Mount Point : " DRIVE1
    DRIVE1=${DRIVE1:-"/"}
    GETDRIVE1
  fi
}

function GETDRIVE2() {
  echo -e "
Here you Must Specify the \033[1;33mTarget\033[0m mount point.  This is 
\033[1;33mA MOUNT\033[0m Point. Under Normal Rackspace Circumstances this drive
would be \"/\" or \"/dev/xvdb1\". Remember, there is no way to check that the 
directory or drive exists. This means we are relying on \033[1;33mYOU\033[0m to
type correctly.
"
  read -p "Specify Destination Drive or press [Enter] for the Default : " DRIVE2
  DRIVE2=${DRIVE2:-"/dev/xvdb1"}
}


# Get the Target IP
# ==============================================================================
function GETTIP() {
  MAX_RETRIES=${MAX_RETRIES:-5}
  RETRY_COUNT=0
  read -p "If you are ready to proceed enter your Target IP address : " TIP
  TIP=${TIP:-""}
  if [ -z "${TIP}" ];then
    echo "No IP was provided, please try again"
    unset TIP
    RETRY_COUNT=$((${RETRY_COUNT}+1))
    if [ ${RETRY_COUNT} -ge ${MAX_RETRIES} ];then
      EXIT_ERROR "Hit maximum number of retries, giving up."
    else
      GETTIP
    fi
  else
    unset MAX_RETRIES
  fi
}


# When RHEL-ish Distros are detected
# ==============================================================================
function WHENRHEL() {
  echo -e "\033[1;31mRHEL Based System Detected\033[0m Installing rsync."

  yum -y install rsync

  echo "# RHEL Dep Script
yum -y install rsync
" | tee /tmp/intsalldeps.sh

  if [ "${INFLAMMATORY}" == "True" ];then 
    echo -e "It seems that you may be victim of poor life decisions, judging by 
your use of RHEL. While I hate having to do this, I am going ahead with the 
sync and so don't worry I tested on RHEL even if I hated every moment of it.
"
  fi
}

# When Debian based distros
# ==============================================================================
function WHENDEBIAN() {
  echo -e "\033[1;31mDebian Based System Detected\033[0m"

  echo "Performing Package Update"
  apt-get update > /dev/null 2>&1

  echo "Installing rsync Package."
  apt-get -y install rsync > /dev/null 2>&1

  echo -e "# Debian Dep Script
apt-get update > /dev/null 2>&1
apt-get -y install rsync > /dev/null 2>&1
" | tee /tmp/intsalldeps.sh

if [ "${INFLAMMATORY}" == "True" ];then 
    echo -e "Great choice by choosing a Debian Based Distro. 
The Debian way is by far the best way."; 
    sleep 1
  fi
}

# When SUSE
# ==============================================================================
function WHENSUSE() {
  echo -e "\033[1;31mSUSE Based System Detected\033[0m"
  zypper in rsync
  echo "# SUSE Dep Script
zypper -n in rsync
" | tee /tmp/intsalldeps.sh

  if [ "${INFLAMMATORY}" == "True" ];then 
    echo -e "I like SUSE Linux, and you should too.
Its not as good as Debian But WAY  better than ANYTHING RHEL.
"
    sleep 2
  fi
}

# When Gentoo
# ==============================================================================
function WHENGENTOO() {
  echo -e "\033[1;31mGentoo Based System Detected\033[0m"
  if [ "${INFLAMMATORY}" == "True" ];then 
    echo -e "Gentoo is nice if you are into that sort of thing. But I have to 
ask, WHY THE HELL are you using this script to move a Gentoo image? As a Gentoo 
User, you should have more pride and do it all by hand...
"
  sleep 2
  fi
}

# When Arch
# ==============================================================================
function WHENARCH() {
  echo -e "\033[1;31mArch Based System Detected\033[0m"
  if [ "${INFLAMMATORY}" == "True" ];then 
    echo -e "I have never meet anyone who ram a production ready Arch Linux 
Anything... And you think your different...
"
    sleep 2
  fi
}

# When UNKNOWN
# ==============================================================================
function WHENUNKNOWN() {
  echo "Because I could not determine the OS type you will have to"
  echo -e "\033[1;31mLogin to the target OS while in rescue mode, and fix the 
IP address or preserve your networking .\033[0m
"
  if [ "${INFLAMMATORY}" == "True" ];then 
      echo -e "Basically I have no IDEA what to do with you..."
      sleep 2
  fi
}

# Do Distro Check
# ==============================================================================
function DISTROCHECK() {
  # Check the Source Distro
  if [ -f /etc/issue ];then
    if [ "$(grep -i '\(centos\)\|\(red\)|\(scientific\)' /etc/issue)"  ]; then
      WHENRHEL
    elif [ "$(grep -i '\(fedora\)\|\(amazon\)' /etc/issue)"  ]; then
      WHENRHEL
    elif [ "$(grep -i '\(debian\)\|\(ubuntu\)' /etc/issue)" ];then
      WHENDEBIAN
    elif [ "$(grep -i '\(suse\)' /etc/issue)" ];then
      WHENSUSE
    elif [ "$(grep -i '\(arch\)')" ];then
      WHENARCH
    fi
  elif [ -f /etc/gentoo-release ];then
    WHENARCH
  else 
    echo -e "WARNING!! I could not determine your OS Type. This Application has 
only been tested on : 
\033[1;31mDebian, Ubuntu, Fedora, CentOS, RHEL, SUSE, Gentoo, and Arch\033[0m
"
    WHENUNKNOWN
  fi
}


# RSYNC Check for Version and Set Flags
# ==============================================================================
function RSYNCCHECKANDSET() {
  if [ ! $(which rsync) ];then
    echo -e "The \033[1;36m\"rsync\"\033[0m command was not found. The automatic 
  Installation of rsync failed so that means you NEED to install it."
    exit 1
  else
    RSYNC_VERSION_LINE=$(rsync --version | grep -E "version\ [0-9].[0-9].[0-9]")
    RSYNC_VERSION_NUM=$(echo ${RSYNC_VERSION_LINE} | awk '{print $3}')
    RSYNC_VERSION=$(echo ${RSYNC_VERSION_NUM} | awk -F'.' '{print $1}')
    if [ "${RSYNC_VERSION}" -ge "3" ];then
      RSYNC_VERSION_COMP="yes"
    fi
  fi
  
  # Set RSYNC Flags
  if [ "${RSYNC_VERSION_COMP}" == "yes" ];then 
    RSYNC_FLAGS='aHEAXSzx'
    echo "Using RSYNC <= 3.0.0 Flags."
  else 
    RSYNC_FLAGS='aHSzx'
    echo "Using RSYNC >= 2.0.0 but < 3.0.0 Flags."
  fi
}


function KEYANDDEPSEND() {
  echo -e "\033[1;36mBuilding Key Based Access for the target host\033[0m"
  ssh-keygen -t rsa -f ${SSH_KEY_TEMP} -N ''

  # Making backup of known_host
  cp /root/.ssh/known_hosts /root/.ssh/known_hosts.${DATE}.bak

  echo -e "Please Enter the Password of the \033[1;33mTARGET\033[0m Server."
  ssh-copy-id -i ${SSH_KEY_TEMP} root@${TIP}

  if [ -f /tmp/intsalldeps.sh ];then
    echo -e "Passing RSYNC Dependencies to the \033[1;33mTARGET\033[0m Server."
    scp -i ${SSH_KEY_TEMP} /tmp/intsalldeps.sh root@${TIP}:/root/
  fi
}

function RUNRSYNCCOMMAND() {
  set +e
  MAX_RETRIES=${MAX_RETRIES:-5}
  RETRY_COUNT=0

  # Set the initial return value to failure
  false

  while [ $? -ne 0 -a ${RETRY_COUNT} -lt ${MAX_RETRIES} ];do
    RETRY_COUNT=$((${RETRY_COUNT}+1))
    ${RSYNC} -e "${RSSH}" -${RSYNC_FLAGS} --progress \
                                          --exclude-from="${EXCLUDE_FILE}" \
                                          --exclude "${SSHAUTHKEYFILE}" \
                                          / root@${TIP}:/
    echo "Resting for 5 seconds..."
    sleep 5
  done
  
  if [ ${RETRY_COUNT} -ge ${MAX_RETRIES} ];then
    EXIT_ERROR "Hit maximum number of retries, giving up."
  fi

  unset MAX_RETRIES
  set -e
}

function RUNMAINPROCESS() {

  echo -e "\033[1;36mNow performing the Copy\033[0m"

  RSYNC="$(which rsync)"
  RSSH_OPTIONS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  RSSH="ssh -i ${SSH_KEY_TEMP} ${RSSH_OPTIONS}"

  RUNRSYNCCOMMAND

  echo -e "\033[1;36mNow performing Final Sweep\033[0m"

  RSYNC_FLAGS="${RSYNC_FLAGS} --checksum"
  RUNRSYNCCOMMAND
}

# Run Script
# ==============================================================================
INFLAMMATORY=${INFLAMMATORY:-"False"}
VERBOSE=${VERBOSE:-"False"}
DEBUG=${DEBUG:-"False"}

# The Date as generated by the Source System
DATE=$(date +%y%m%d%H)

# The Temp Working Directory
TEMPDIR='/tmp'

# Name of the Temp SSH Key we will be using.
SSH_KEY_TEMP="${TEMPDIR}/tempssh.${DATE}"

# ROOT SSH Key File
SSHAUTHKEYFILE='/root/.ssh/authorized_keys'

# General Exclude List; The exclude list is space Seperated
EXCLUDE_LIST='/boot /dev/ /etc/conf.d/net /etc/fstab /etc/hostname 
/etc/HOSTNAME /etc/hosts /etc/issue /etc/init.d/nova-agent* /etc/mdadm* 
/etc/mtab /etc/network* /etc/network/* /etc/networks* /etc/network.d/*
/etc/rc.conf /etc/resolv.conf /etc/selinux/config /etc/sysconfig/network* 
/etc/sysconfig/network-scripts/* /etc/ssh/ssh_host_dsa_key 
/etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key.pub 
/etc/ssh/ssh_host_rsa_key.pub /etc/udev/rules.d/* /lock /net /sys /tmp 
/usr/sbin/nova-agent* /usr/share/nova-agent* /var/cache/yum/* '

# Allow the user to add excludes to the general Exclude list
USER_EXCULDES=${USER_EXCULDES:-""}

# Amazon Exclude List; The exclude list is space Seperated
AMAZONEXCLUDE_LIST='/etc/sysctl.conf /etc/yum.repos.d/amzn-*'

# Extra Exclude File 
EXCLUDE_FILE='/tmp/excludeme.file'

# Building Exclude File - DONT TOUCH UNLESS YOU KNOW WHAT YOU ARE DOING
# ==============================================================================
if [ "${VERBOSE}" == "True" ];then
  set -v
fi

if [ "${DEBUG}" == "True" ];then
  set -x
fi

EXCLUDEVAR=$(echo ${EXCLUDE_LIST} | sed 's/\ /\\n/g')
if [ "${USER_EXCULDES}" ];then
  EXCLUDE_LIST+=${USER_EXCULDES}
fi

if [ -f ${EXCLUDE_FILE} ];then
  rm ${EXCLUDE_FILE}
fi

echo -e "${EXCLUDEVAR}" | tee -a ${EXCLUDE_FILE}

# Check that we are the root User
CHECKFORROOT

# Clear the screen to get ready for work
clear

if [ "${INFLAMMATORY}" == "True" ];then 
  echo -e "Inflammatory mode has been enabled... 
The application will now be really opinionated...
\033[1;33mYOU\033[0m have been warned...
" 
fi

  echo -e "This Utility Moves a \033[1;36mLIVE\033[0m System to an other System.
This application will work on \033[1;36mAll\033[0m Linux systems using RSYNC.
Before performing this action you \033[1;35mSHOULD\033[0m be in a screen
session.
"

sleep 1

echo -e "This Utility does an \033[1;32mRSYNC\033[0m copy of instances over the 
network. As such, I recommend that you perform this Migration Action on SNET 
(Internal IP), however any Network will work. 

Here is why I make this recommendation:
Service Net = \033[1;32mFREE\033[0m Bandwidth.
Public Net  = \033[1;35mNOT FREE\033[0m Bandwidth
" 

# Run the Amazon Check
ISTHISAMAZON

# If the Target IP is not set, ask for it
GETTIP

# Allow the user to specify the source drive
GETDRIVE1
GETDRIVE2

# check what distro we are running on
DISTROCHECK

# Check RSYNC version and set the in use flags
RSYNCCHECKANDSET

# Create a Key for target access and send over a dependency script
KEYANDDEPSEND

# If this is an amazon AMI linux Distro send over a post processing script
AMAZONPOSTPROCESSES

# Removing known_host entry made by script
cp /root/.ssh/known_hosts /tmp/known_hosts
sed '$ d' /tmp/known_hosts > /root/.ssh/known_hosts
rm -f /tmp/known_hosts

echo -e "Running Dependency Script on the \033[1;33mTARGET\033[0m Server."
ssh -i ${SSH_KEY_TEMP} -o UserKnownHostsFile=/dev/null \
                       -o StrictHostKeyChecking=no root@${TIP} \
                       "bash intsalldeps.sh" > /dev/null 2>&1

RUNMAINPROCESS

AMAZONPROCESSES

echo -e "\033[1;36mThe target Instance is being rebooted\033[0m"

ssh -i ${SSH_KEY_TEMP} -o UserKnownHostsFile=/dev/null \
                       -o StrictHostKeyChecking=no root@${TIP} \
                       "shutdown -r now"

echo -e "If you were copying something that was not a Rackspace Cloud Server, 
You may need to ensure that your setting are correct, and the target is healthy
"

AMAZONWARNING

echo -e "Other wise you are good to go, and the target server should have been 
rebooted. If all is well, you should now be able to enjoy your newly cloned 
Virtual Instance.
"

# Say something nice
ALLDONE

# Teardown what I setup on the source node and exit
QUIT

exit 0
