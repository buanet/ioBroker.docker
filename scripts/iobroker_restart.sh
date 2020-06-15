#!/bin/sh
cd /opt/iobroker
pkill io
sleep 5
node node_modules/iobroker.js-controller/controller.js
exit 0
