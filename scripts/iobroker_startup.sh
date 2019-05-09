#!/bin/bash

# Reading env-variables
packages=$PACKAGES
avahi=$AVAHI

# Getting date and time for logging 
dati=`date '+%Y-%m-%d %H:%M:%S'`

# Information
echo ''
echo '----------------------------------------'
echo '-----     Image-Version: 3.0.0     -----'
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
  echo 'Installing additional packages done...'
fi

cd /opt/iobroker

# Checking and restoring ioBroker to empty mounted folder
if [ `ls -1a|wc -l` -lt 3 ]
then
  echo ''
  echo 'Directory /opt/iobroker is empty!'
  echo 'Restoring data from image...'
	tar -xf /opt/initial_iobroker.tar -C /
	echo 'Restoring done...'
fi

# Checking for first run of a new installation and renaming ioBroker
if [ -f /opt/iobroker/.install_host ]
then
  echo ''
  echo 'This is the first run of an new installation...'
  echo 'Hostname given is' $(hostname)'...'
  echo 'Renaming ioBroker...'
  iobroker host $(cat /opt/iobroker/.install_host)
  rm -f /opt/iobroker/.install_host
  echo 'Renaming ioBroker done...'
fi

# Checking for first run and change permissions
if [ -f /opt/.firstrun ]
then 
  echo ''
  echo 'Changing permissions upon first run (This might take a while! Please be patient!)...'
  chown -R iobroker /opt/iobroker
  chown -R iobroker /opt/scripts
  rm -f /opt/.firstrun
  echo 'Changing permissions done...'
fi

# Checking for and setting up avahi-daemon
if [ "$avahi" = "true" ]
then
  echo ''
  echo 'Initializing Avahi-Daemon...'
  sh /opt/scripts/setup_avahi.sh
  echo 'Initializing Avahi-Daemon done...'
fi

sleep 5

# Starting ioBroker
echo ''
echo 'Starting ioBroker...'
sudo -u iobroker node node_modules/iobroker.js-controller/controller.js > /opt/scripts/iobroker.log 2>&1 &
echo 'Starting ioBroker done...'

# Preventing container restart by keeping a process alive
tail -f /dev/null
