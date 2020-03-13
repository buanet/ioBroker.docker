#!/bin/sh
cd /opt/iobroker
pkill io
sleep 5
node node_modules/iobroker.js-controller/controller.js > /opt/iobroker/iobroker-daemon.log 2>&1 &
exit 0
