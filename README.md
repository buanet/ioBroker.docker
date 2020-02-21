# docker-iobroker
Docker image for ioBroker (http://iobroker.net) based on node:10-slim.

This project creates a Docker image for running ioBroker in a Docker container. 

## Tested configuration and modules
iobroker.js-controller
  + iobroker.admin
  + iobroker.alexa2
  + iobroker.daswetter
  + iobroker.feiertage
  + iobroker.ical
  + iobroker.info
  + iobroker.javascript
  + iobroker.lovelace
  + iobroker.maxcube
  + iobroker.mqtt
  + iobroker.nina
  + iobroker.node-red
  + iobroker.octoprint
  + iobroker.openuv
  + iobroker.openweathermap
  + iobroker.pihole
  + iobroker.pimatic
  + iobroker.ping
  + iobroker.shelly
  + iobroker.sql
  + iobroker.systeminfo
  + iobroker.tankerkoenig
  + iobroker.telegram
  + iobroker.tr-064-community
  + iobroker.trashschedule
  + iobroker.upnp
  + iobroker.vw-connect

## Changelog

1.1 Modified startup scripts, removed unused scripts und linked logfile to stdout for docker logs

1.0 Initial Edit and Release
