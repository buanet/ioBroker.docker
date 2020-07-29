#!/bin/bash

# Script checks health of running container

if [ "$(cat /opt/scripts/.docker_config/.healthcheck)" == "starting" ]
then
  echo 'Health status: OK - Startup script is still running.'
  exit 0
elif [ "$(cat /opt/scripts/.docker_config/.healthcheck)" == "maintenance" ]
then
  echo 'Health status: OK - Container is running in maintenance mode.'
  exit 0
elif [ "$(ps -fe|grep "[i]obroker.js-controller"|awk '{print $2}')" != "" ]
then
  echo 'Health status: OK - Main process (js-controller) is running.'
  exit 0
fi

echo 'Health status: !!! NOT OK !!! - Something went wrong. Please see container logs for more details and/or try restarting the container.'
exit 1
