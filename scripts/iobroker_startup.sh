#!/bin/sh

cd /opt/iobroker

if [ -f .install_host ];
then
        echo 'First run preparation! Used Hostname:' $(hostname)
        echo $(hostname) > .install_host && ./iobroker host $(cat .install_host)
		iobroker del admin.0 && iobroker del discovery.0
		iobroker add admin && iobroker add discovery
        rm .install_host
	echo 'First run Preparation done...'
fi

echo 'Initializing Avahi-Daemon...'
sh /opt/scripts/avahi_startup.sh
echo 'Initializing Avahi-Daemon done...'

sleep 5

echo 'Starting ioBroker...'
node node_modules/iobroker.js-controller/controller.js >/opt/scripts/docker_iobroker_log.txt 2>&1 &
echo 'Starting ioBroker done...

/bin/bash
