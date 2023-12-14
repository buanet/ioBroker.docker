#!/usr/bin/env bash

welcome () {
  whiptail --title "ioBroker Docker Container Maintenance Script" --ok-button "OK" --msgbox " \
╔═══════════════════════════════════════════════════════════════════════╗\
\n ║ ██╗  ██████╗  ██████╗  ██████╗   ██████╗  ██╗  ██╗ ███████╗  ██████╗  ║\
\n ║ ██║ ██╔═══██╗ ██╔══██╗ ██╔══██╗ ██╔═══██╗ ██║ ██╔╝ ██╔════╝  ██╔══██╗ ║\
\n ║ ██║ ██║   ██║ ██████╔╝ ██████╔╝ ██║   ██║ █████╔╝  █████╗    ██████╔╝ ║\
\n ║ ██║ ██║   ██║ ██╔══██╗ ██╔══██╗ ██║   ██║ ██╔═██╗  ██╔══╝    ██╔══██╗ ║\
\n ║ ██║ ╚██████╔╝ ██████╔╝ ██║  ██║ ╚██████╔╝ ██║  ██╗ ███████╗  ██║  ██║ ║\
\n ║ ╚═╝  ╚═════╝  ╚═════╝  ╚═╝  ╚═╝  ╚═════╝  ╚═╝  ╚═╝ ╚══════╝  ╚═╝  ╚═╝ ║\
\n ╚═══════════════════════════════════════════════════════════════════════╝\
\n   This script will help you to maintain your ioBroker Docker container!\
\n" 19 79
}

if welcome; then
  TO_RUN=$(whiptail --title "ioBroker Docker Container Maintenance Script" --menu "What do you want to do?" 25 78 5 \
  "maintenance" "Turn Maintenance Mode on or off" \
  "upgrade" "Upgrade js-controller" \
  "restore" "Restore ioBroker from backup" 3>&1 1>&2 2>&3)
else
  exit 0
fi

if [[ $TO_RUN = "maintenance" ]]; then
  echo "You selected maintenance"
elif [[ $TO_RUN = "upgrade" ]]; then
  echo "You selected upgrade"
elif [[ $TO_RUN = "restore" ]]; then
  echo "You selected restore"
fi
