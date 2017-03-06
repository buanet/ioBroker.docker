#!/bin/sh

if [ -f .install_host ];
then
	sed -i "s/$(cat .install_host)/$(hostname)/g" iobroker-data/objects.json
	rm .install_host
fi

./avahi-start.sh
./iobroker start
cd /
/bin/bash
