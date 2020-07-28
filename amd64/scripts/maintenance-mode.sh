#!/bin/bash

if [ "$1" == "status" ]
then
  if [ "$cat /opt/iobroker/.docker_config/.healthcheck" == "maintenance" ]
  then
    echo 'Maintenance mode is ON.'
    exit 0
  elif [ "$cat /opt/iobroker/.docker_config/.healthcheck" != "maintenance" ]
  then
    echo 'Maintenance mode is OFF.'
    exit 0
  fi
elif [ "$1" == "on" ]
then
  echo 'This will stop ioBroker and enable maintenance mode for this container.'
  read -p 'Continue? Type yes or no: ' A
  if [ "$A" == "y" ] || [ "$A" == "yes" ]
  then
    echo 'Enabling maintenance mode...'
    echo "maintenance" > /opt/iobroker/.docker_config/.healthcheck
    echo 'Done.'
    sleep 2
    echo 'Stopping ioBroker...'
    pkill -u iobroker
    echo 'Done.'
    exit 0
  else
    exit 0
  fi
elif [ "$1" == "off" ]
then
  echo 'Depending of the restart policy of this container, this will force it to stop (and restart) immediately.'
  echo 'Maintenance mode will be disabled after the restart.'
  read -p 'Continue? Type yes or no: ' A
  if [ "$A" == "y" ] || [ "$A" == "yes" ]
  then
    echo "Disabling maintenance mode and forcing container to stop/ restart..."
    echo "maintenance" > /opt/iobroker/.docker_config/.healthcheck
    pkill -u root
    exit 0
  else
    exit 0
  fi
else
  echo 'Invalid command. Please try again.'
fi

exit 0
