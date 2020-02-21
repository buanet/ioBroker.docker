#!/bin/bash

# Version output for logging
echo 'Version: 3.0.0'
echo 'Startupscript running...'

cd /opt/iobroker

# Checking for first run and renaming ioBroker
if [ -f /opt/iobroker/.install_host ]
then
  echo 'First run preparation! Used Hostname:' $(hostname)
  echo 'Renaming ioBroker...'
  iobroker host $(cat /opt/iobroker/.install_host)
  sudo rm -f /opt/iobroker/.install_host
  echo 'First run preparation done...'
fi

# Starting ioBroker
echo 'Starting ioBroker...'
sudo node node_modules/iobroker.js-controller/controller.js > /opt/iobroker/iobroker-daemon.log 2>&1 &
echo 'Starting ioBroker done...'

# Preventing container restart
tail -f /dev/null
