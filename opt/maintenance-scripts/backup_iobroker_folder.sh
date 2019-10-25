#!/bin/bash

# Backupscript fuer ein Backup von ioBroker unter Docker auf einer Synology Disk Station (Sicherung des ioBroker-Verzeichnises).
# Vorhaltezeit der letzten Backups: 90 Tage, Ã¤ltere Backups werden automatisch geloescht.
# 
# By Andre Germann
# Version 1.1 (22.09.2017)
#
# ACHTUNG: Dieses Script muss vorher auf die Synology Disk Station kopiert und dann auch dort ausgefuehrt werden!
# Fuer die geplante, regelmaessige Ausfuehrung bietet sich der Aufgabenplaner der Disk Station an.
#
# ACHTUNG: Dieses Script stoppt vor der Sicherung des Verzeichnises den ioBroker Container!
# Zur Sicherheit wird empfohlen ioBroker vor dem Backup innerhalb des Containers zu stoppen.
# Dieses kann zum Beispiel ueber den vorherigen Aufruf des Scripts iobroker_stop.sh aus ioBroker heraus erledigt werden.


# Deklaration der Variablen. Pfade und Bezeichnungen muessen ggf. entsprechend angepasst werden.

iobrokerPATH='/volume1/docker/iobroker_mount' # Pfad des gemounteten ioBroker-Verzeichnises (zu sicherndes Verzeichnis) auf der Synology Disk Station
backupPATH='/volume1/docker/iobroker_backup/archiv' # Pfad zum Speichern des Backups
iobrokerCONTAINERNAME='iobroker' # Name des ioBroker-Containers in Docker


# Start Script - Ab hier muss nichts mehr geaendert werden!

echo "#####################################################"
echo "############## Backupscript gestartet. ##############"
echo "#####################################################"


### Backup ioBroker-Verzeichnis


# ioBroker-Container stoppen

echo ""
echo "Der ioBroker-Container ($iobrokerCONTAINERNAME) in Docker wird gestoppt..."

docker stop $iobrokerCONTAINERNAME > /dev/null

echo "Container in Docker gestoppt."
echo ""
echo "######################################################"
sleep 5


# Backupdatei erstellen

echo ""
echo "Der Ordner $iobrokerPATH wird gesichert..."

tar -C "$iobrokerPATH" -czf "$backupPATH/backup-$(date +%Y-%m-%d_%H-%M).tar.gz" .

echo "Sicherung des Ordners erstellt."
echo ""
echo "######################################################"
sleep 5


# Alte Backups loeschen (Loescht per "rm" alle "*.tar.gz"-Dateien im Ordner, die aelter als 90 Tage sind)

echo ""
echo "Entfernen alter Backups aus dem Verzeichnis $backupPATH..."

find -P "$backupPATH/" -maxdepth 1 -type f \( -name '*.tar.gz' \) -ctime +90 -exec rm {} \;

echo "Alte Backups wurden entfernt."
echo ""
echo "######################################################"
sleep 5


# ioBroker-Container starten

echo ""
echo "Der ioBroker-Container ($iobrokerCONTAINERNAME) in Docker wird gestartet..."

docker start $iobrokerCONTAINERNAME > /dev/null

echo "Container in Docker gestartet."
echo ""
echo "################### Script Ende ######################"

exit 0
