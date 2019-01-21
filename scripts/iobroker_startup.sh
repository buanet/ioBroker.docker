#!/bin/sh

cd /opt/iobroker

if [ -f .install_host ];
then
        echo 'First run preparation! Used Hostname:' $(hostname)
	echo 'STEP 1 of 2: Renaming...'
        iobroker host $(cat .install_host)
        rm .install_host
	echo 'STEP 2 of 2: Backup...'
	tar -cf /opt/initial_iobroker.tar /opt/iobroker
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
