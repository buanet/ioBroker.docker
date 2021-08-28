#!/bin/bash

# function to display help text
display_help() {
  echo "This script is build to manage your ioBroker container!"
  echo "Usage: maintenance [ COMMAND ] [ OPTIONS ]"
  echo "       maint [ COMMAND ] [ OPTIONS ]"
  echo ''
  echo "COMMANDS"
  echo "------------------"
  echo "       status     > gives the current state of maintenance mode"
  echo "       on         > switches mantenance mode ON"
  echo "       off        > switches mantenance mode OFF and shuts down/ restarts container"
  echo "       upgrade    > will put container to maintenance mode and upgrade iobroker"
  echo ''
  echo "OPTIONS"
  echo "------------------"
  echo "       -h|--help  > shows this help"  
  echo "       -y|--yes   > confirms the used command without asking"
  echo ''  
  exit 0
}

while getopts h opt
do
  case $opt in
    h | --help)
      display_help ;;
  esac
exit 0;
done

if [ "$1" == "status" ]
then
  if [ $(cat /opt/scripts/.docker_config/.healthcheck) == 'maintenance' ]
  then
    echo 'Maintenance mode is ON.'
    exit 0
  elif [ $(cat /opt/scripts/.docker_config/.healthcheck) != 'maintenance' ]
  then
    echo 'Maintenance mode is OFF.'
    exit 0
  fi
elif [ "$1" == "on" ]
then
  echo 'You are now going to stop ioBroker and activating maintenance mode for this container.'
  read -p 'Do you want to continue [yes/no]? ' A
  if [ "$A" == "y" ] || [ "$A" == "Y" ] || [ "$A" == "yes" ]
  then
    echo 'Activating maintenance mode...'
    echo "maintenance" > /opt/scripts/.docker_config/.healthcheck
    sleep 1
    echo 'Done.'
    echo 'Stopping ioBroker...'
    pkill -u iobroker
    sleep 1
    echo 'Done.'
    exit 0
  else
    exit 0
  fi
elif [ "$1" == "off" ]
then
  echo 'You are now going to deactivate maintenance mode for this container.'
  echo 'Depending on the restart policy, your container will be stopped/ restarted immediately.'
  read -p 'Do you want to continue [yes/no]? ' A
  if [ "$A" == "y" ] || [ "$A" == "Y" ] || [ "$A" == "yes" ]
  then
    echo 'Deactivating maintenance mode and forcing container to stop/ restart...'
    echo "stopping" > /opt/scripts/.docker_config/.healthcheck
    pkill -u root
    exit 0
  else
    exit 0
  fi
elif [ "$1" == "upgrade" ]
then
  echo 'You are now going to upgrade your js-controller.'
  echo 'As this will change data in /opt/iobroker, make sure you have a backup!'
  echo 'During the upgrade process the container will automatically switch into maintenance mode and stop ioBroker.'
  echo 'Depending of the restart policy, you container will be stoped/ restarted automatically after the upgrade.'
  read -p 'Do you want to continue [yes/no]? ' A
  if [ "$A" == "y" ] || [ "$A" == "Y" ] || [ "$A" == "yes" ]
  then
    echo 'Activating maintenance mode...'
    echo "maintenance" > /opt/scripts/.docker_config/.healthcheck
    sleep 1
    echo 'Done.'
    echo 'Stopping ioBroker...'
    pkill -u iobroker
    sleep 1
    echo 'Done.'
    echo 'Upgrading js-controller...'
    iobroker update
    iobroker upgrade self
    sleep 1
    echo 'Done.'
    echo 'Container will be stopped/ restarted in 5 seconds...'
    sleep 5
    echo "stopping" > /opt/scripts/.docker_config/.healthcheck
    pkill -u root
    exit 0
  else
    exit 0
  fi
else
  echo 'Invalid command. Please try again.'
fi

exit 0
