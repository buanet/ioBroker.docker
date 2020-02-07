# docker-iobroker
Docker image for ioBroker (http://iobroker.net) based on node:10.

This project creates a Docker image for running ioBroker in a Docker container. 


## Installation & Usage


## Special Settings

### Environment Variables

|env|value|description|
|---|---|---|
|PACKAGES|package1 package2 package2|seperateed by whitespace; will install the listed packages on startup<br>(be paitient, this may take some time!)|

### Mounting Folder/ Volume

It is now possible to mount an empty folder to /opt/iobroker during first startup of the container. The Startupscript will check this folder and restore content if empty.

It is absolutely recommended to use a mounted folder or persistent volume for /opt/iobroker folder!

This also works with mounting a folder containing an existing ioBroker-installation (e.g. when moving an existing installation to docker). 

