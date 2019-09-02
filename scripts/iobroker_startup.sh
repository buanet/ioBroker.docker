#!/bin/bash

# Reading env-variables
packages=$PACKAGES
avahi=$AVAHI
uid=$SETUID
gid=$SETGID

# Getting date and time for logging 
dati=`date '+%Y-%m-%d %H:%M:%S'`

# Information
echo ''
echo '----------------------------------------'
echo '-----   Image-Version: 3.1.1beta   -----'
echo '-----      '$dati'     -----'
echo '----------------------------------------'
echo ''
echo 'Startupscript running...'

# Checking and installing additional packages
if [ "$packages" != "" ]
then
  echo ''
  echo 'Installing additional packages...'
  echo 'The following packages will be installed:' $packages
  echo $packages > /opt/scripts/.packages
  sh /opt/scripts/setup_packages.sh > /opt/scripts/setup_packages.log 2>&1
  echo 'Done.'
fi

cd /opt/iobroker

# Checking and restoring ioBroker to empty mounted folder
if [ `ls -1a|wc -l` -lt 3 ]
then
  echo ''
  echo 'Directory /opt/iobroker is empty!'
  echo 'Restoring data from image...'
	tar -xf /opt/initial_iobroker.tar -C /
	echo 'Done.'
fi

# Checking for first run and set uid/gid and permissions
if [ -f /opt/.firstrun ]
then 
  echo ''
  echo 'Changing UID/GID and permissions upon first run...'
  echo 'Setting UID to '$uid' and GID to '$gid'...'
  usermod -u $uid iobroker
  groupmod -g $gid iobroker
  echo 'Done.'
  echo 'Setting folder permissions (This might take a while! Please be patient!)...'
  chown -R $uid:$gid /opt/iobroker
  chown -R $uid:$gid /opt/scripts
  rm -f /opt/.firstrun
  echo 'Done.'
fi

# Backing up original iobroker-file and changing sudo to gosu
cp -a /opt/iobroker/iobroker /opt/iobroker/iobroker.bak
chmod 755 /opt/iobroker/iobroker
sed -i 's/sudo -H -u/gosu/g' /opt/iobroker/iobroker

# Checking for first run of a new installation and renaming ioBroker
if [ -f /opt/iobroker/.install_host ]
then
  echo ''
  echo 'This is the first run of an new installation...'
  echo 'Hostname given is' $(hostname)'...'
  echo 'Renaming ioBroker...'
  sh /opt/iobroker/iobroker host $(cat /opt/iobroker/.install_host)
  rm -f /opt/iobroker/.install_host
  echo 'Done.'
fi

# Checking for and setting up avahi-daemon
if [ "$avahi" = "true" ]
then
  echo ''
  echo 'Initializing Avahi-Daemon...'
  chmod 764 /opt/scripts/setup_avahi.sh
  sh /opt/scripts/setup_avahi.sh
  echo 'Done.'
fi

sleep 5

# Starting ioBroker
echo ''
echo 'Starting ioBroker...'
echo ''
echo '----------------------------------------'
echo '-------     ioBroker Logging     -------'
echo '----------------------------------------'
echo ''

#touch /opt/iobroker/iobroker.log
#gosu iobroker node --trace-warnings node_modules/iobroker.js-controller/controller.js > /opt/iobroker/iobroker.log 2>&1 &
gosu iobroker node node_modules/iobroker.js-controller/controller.js

# Preventing container restart by keeping a process alive even if iobroker will be stopped
tail -f /dev/null
