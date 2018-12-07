#!/bin/sh

cd /opt/iobroker

if [ -f .install_host ];
then
        echo $(hostname) > .install_host && ./iobroker host $(cat .install_host)
		iobroker del admin.0 && iobroker del discovery.0
		iobroker add admin && iobroker add discovery
        rm .install_host
fi

/opt/scripts/avahi_startup.sh
sleep 5
node node_modules/iobroker.js-controller/controller.js >/opt/scripts/docker_iobroker_log.txt 2>&1 &
/bin/bash
