#!/bin/sh

# Einfaches Script zum Stoppen von ioBroker. 
# Kann zum Beispiel aus ioBroker heraus aufgerufen werden um ioBroker neu zu starten. 

cd /opt/iobroker
pkill io
sleep 5
node node_modules/iobroker.js-controller/controller.js >/opt/scripts/docker_iobroker_log.txt 2>&1 &

exit 0
