#!/bin/sh

cd /opt/iobroker

echo 'Startupscript running...'

if [ `ls -1a|wc -l` -lt 3 ];
then
  echo 'Directory /opt/iobroker is empty!'
  echo 'Restoring...'
	tar -xf /opt/initial_iobroker.tar -C /
	echo 'Restoring done...'
fi

if [ -f /opt/iobroker/.install_host ];
then
  echo 'First run preparation! Used Hostname:' $(hostname)
	echo 'Renaming ioBroker...'
        iobroker host $(cat /opt/iobroker/.install_host)
        rm /opt/iobroker/.install_host
	echo 'First run preparation done...'
fi

echo 'Initializing Avahi-Daemon...'
sudo sh /opt/scripts/avahi_startup.sh
echo 'Initializing Avahi-Daemon done...'

sleep 5

echo 'Starting ioBroker...'
node node_modules/iobroker.js-controller/controller.js >/opt/scripts/docker_iobroker_log.txt 2>&1 &
echo 'Starting ioBroker done...'

tail -f /dev/null
