#!/bin/sh

# Einfaches Script zum Stoppen von ioBroker.
# Kann zum Beispiel aus ioBroker heraus aufgerufen werden um ioBroker neu zu starten.

cd /opt/iobroker
pkill io
sleep 5
gosu iobroker node node_modules/iobroker.js-controller/controller.js
exit 0
