#!/bin/bash

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
  echo 'You are going to stop ioBroker and activating maintenance mode for this container.'
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
  echo 'You are going to deactivate maintenance mode for this container.'
  echo 'Depending of the restart policy of this container, this will stop/ restart your container immediately.'
  read -p 'Do you want to continue [yes/no]? ' A
  if [ "$A" == "y" ] || [ "$A" == "Y" ] || [ "$A" == "yes" ]
  then
    echo 'Deactivating maintenance mode and forcing container to stop/ restart...'
    echo "maintenance" > /opt/scripts/.docker_config/.healthcheck
    pkill -u root
    exit 0
  else
    exit 0
  fi
else
  echo 'Invalid command. Please try again.'
fi

exit 0
