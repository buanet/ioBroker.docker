#!/bin/bash

# Reading env-variables
packages=$PACKAGES
avahi=$AVAHI

# Version output for logging
echo 'Version: 2.0.5beta'
echo 'Startupscript running...'

# Checking and installing additional packages
if [ "$packages" != "" ]
then
  echo 'Installing additional packages...'
  echo 'The following packages will be installed:' $packages
  sudo echo $packages > /opt/scripts/.packages
  sudo sh /opt/scripts/packages_install.sh > /opt/scripts/packages_install.log 2>&1
  echo 'Installing additional packages done...'
fi

cd /opt/iobroker

# Checking and restoring ioBroker to mounted folder
if [ `ls -1a|wc -l` -lt 3 ]
then
  echo 'Directory /opt/iobroker is empty!'
  echo 'Restoring...'
	sudo tar -xf /opt/initial_iobroker.tar -C /
	echo 'Restoring done...'
fi

# Checking for first run and renaming ioBroker
if [ -f /opt/iobroker/.install_host ]
then
  echo 'First run preparation! Used Hostname:' $(hostname)
	echo 'Renaming ioBroker...'
  iobroker host $(cat /opt/iobroker/.install_host)
  sudo rm -f /opt/iobroker/.install_host
	echo 'First run preparation done...'
fi

# Checking and setting up avahi-daemon
if [ "$avahi" = "true" ]
then
  echo 'Initializing Avahi-Daemon...'
  sudo sh /opt/scripts/avahi_startup.sh
  echo 'Initializing Avahi-Daemon done...'
fi

sleep 5

# Starting ioBroker
echo 'Starting ioBroker...'
sudo node node_modules/iobroker.js-controller/controller.js > /opt/scripts/iobroker.log 2>&1 &
echo 'Starting ioBroker done...'

# Preventing container restart
tail -f /dev/null
