#!/bin/sh

cd /opt/iobroker

if [ -f /opt/scripts/.install_host ];
then
        echo 'First run preparation! Used Hostname:' $(hostname)
	echo 'STEP 1 of 2: Restoring if folder empty...'
	if [ `ls -1a|wc -l` -lt 3 ];
	then
		tar -xf /opt/initial_iobroker.tar -C /
	fi
	echo 'STEP 2 of 2: Renaming ioBroker...'
        iobroker host $(cat /opt/scripts/.install_host)
        rm /opt/scripts/.install_host
	echo 'First run preparation done...'
fi

echo 'Initializing Avahi-Daemon...'
sh /opt/scripts/avahi_startup.sh
echo 'Initializing Avahi-Daemon done...'

sleep 5

echo 'Starting ioBroker...'
node node_modules/iobroker.js-controller/controller.js >/opt/scripts/docker_iobroker_log.txt 2>&1 &
echo 'Starting ioBroker done...'

tail -f /dev/null
