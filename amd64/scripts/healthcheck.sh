#!/bin/bash

# Script checks health of running container

if [ "$(cat /opt/iobroker/.docker_config/.healthcheck)" == "starting" ] || [ "$(cat /opt/iobroker/.docker_config/.healthcheck)" == "maintenance" ]
then
  exit 0
else
  if [ "ps -fe|grep "[i]obroker.js-controller"|awk '{print $2}'" != "" ]
  then
    exit 0
  fi
fi

exit 1
