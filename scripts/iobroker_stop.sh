#!/bin/sh

# Einfaches Script zum Stoppen von ioBroker. 
# Wird zum Beispiel genutzt zum automatischen Beenden von ioBroker bevor das Backupscript auf der Synology Disk Station startet. 

cd /opt/iobroker
./iobroker stop
