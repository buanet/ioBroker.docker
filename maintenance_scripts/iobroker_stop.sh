#!/bin/sh

# Einfaches Script zum Stoppen von ioBroker. 
# Kann zum Beispiel aus ioBroker heraus aufgerufen werden um ioBroker zu stoppen. 

cd /opt/iobroker
pkill io

exit 0
