# docker-iobroker
Docker image for ioBroker (http://iobroker.net) based on node:12-slim.

This project creates a Docker image for running ioBroker in a Docker container. 


## Changelog

1.4 fixed installer version and dependencies and added healthcheck

1.3 Removed iobroker_startup.sh and iobroker_backup.sh from scripts and removed logfile from iobroker_restart.sh

1.2 Added iputils-ping to packages for iobroker.ping, added more scripts into image and merged startup script into Dockerfile

1.1 Modified startup scripts, removed unused scripts und linked logfile to stdout for docker logs

1.0 Initial Edit and Release
