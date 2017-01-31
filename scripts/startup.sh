#!/bin/bash

if [ -f .install_host ];
then
	sed -i "s/$(cat .install_host)/$(hostname)/g" iobroker-data/objects.json
	rm .install_host
fi

node node_modules/iobroker.js-controller/controller.js
