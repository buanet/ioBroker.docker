#!/bin/sh

# Einfaches Script zum Stoppen von ioBroker. 
# Kann zum Beispiel aus ioBroker heraus aufgerufen werden um ioBroker neu zu starten. 

cd /opt/iobroker
./iobroker stop
sleep 5
./iobroker start

exit 0
