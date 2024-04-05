##### Note: The image provided as [iobroker/iobroker](https://hub.docker.com/r/iobroker/iobroker) is a mirror of [buanet/iobroker](https://hub.docker.com/r/buanet/iobroker) 
 
<img src="https://github.com/buanet/ioBroker.docker/raw/main/docs/img/iobroker_logo.png" width="600" title="ioBroker Logo">

[![Release](https://img.shields.io/github/v/release/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/releases)
[![Pre-Release)](https://img.shields.io/github/v/tag/buanet/ioBroker.docker?include_prereleases&label=pre-release)](https://github.com/buanet/ioBroker.docker/releases)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/buanet/ioBroker.docker/build-debian12-latest.yml?branch=main)](https://github.com/buanet/ioBroker.docker/actions/workflows/build-debian12-latest.yml)
[![Github Issues](https://img.shields.io/github/issues/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/issues)
[![Github Pull Requests](https://img.shields.io/github/issues-pr/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/pulls)
[![GitHub Discussions](https://img.shields.io/github/discussions/buanet/ioBroker.docker)](https://github.com/buanet/ioBroker.docker/discussions)<br>
[![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm32v7%20%7C%20arm64v8-blue)](https://hub.docker.com/repository/docker/buanet/iobroker)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/buanet/iobroker/latest?style=flat)](https://hub.docker.com/repository/docker/buanet/iobroker)
[![Docker Pulls](https://img.shields.io/docker/pulls/buanet/iobroker?style=flat)](https://hub.docker.com/repository/docker/buanet/iobroker)
[![Docker Stars](https://img.shields.io/docker/stars/buanet/iobroker?style=flat)](https://hub.docker.com/repository/docker/buanet/iobroker)<br>
[![Source](https://img.shields.io/badge/source-github-blue?style=flat)](https://github.com/buanet/ioBroker.docker)
[![GitHub forks](https://img.shields.io/github/forks/buanet/ioBroker.docker)](https://github.com/buanet/ioBroker.docker/network)
[![GitHub stars](https://img.shields.io/github/stars/buanet/ioBroker.docker)](https://github.com/buanet/ioBroker.docker/stargazers)
[![License](https://img.shields.io/github/license/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/blob/master/LICENSE.md)
[![Donate](https://img.shields.io/badge/donate-paypal-blue?style=flat)](https://paypal.me/buanet)

# Important note

New major image versions (e.g. v6, v7, v8) usually include a new major version of node! Although js-controller should handle this kind of upgrade fine, in some cases this still results in problems with some adapters. To avoid having trouble with this major version upgrades, it is always a good move to upgrade your container manually with backup and restore procedure. For more details please see the maintenance part of the [ioBroker Docker image docs](https://docs.buanet.de/iobroker-docker-image/docs/#maintenance).

# Quick reference

* Maintained by: [buanet](https://github.com/buanet) and [ioBroker](https://github.com/ioBroker)
* Where to get support: [ioBroker forum](https://forum.iobroker.net/), [Discord channel](https://discord.gg/5jGWNKnpZ8), [Facebook group](https://www.facebook.com/groups/440499112958264)
* Where to report issues: [Github Repository Issues](https://github.com/buanet/ioBroker.docker/issues)
* Supported architectures: amd64, arm32v7, arm64v8
* Changelog: [Github Repository Changelog](https://github.com/buanet/ioBroker.docker/blob/main/CHANGELOG.md)
* Source code: [Github Repository](https://github.com/buanet/ioBroker.docker)
* All other questions should be answered here: [ioBroker Docker image docs](https://docs.buanet.de/iobroker-docker-image/docs/) or [iobroker.net](https://www.iobroker.net/)

# Supported tags

It is highly recommended not to use the `latest` tag for production, especially when using any kind of automated update procedure like watchtower. Please use the `latest-v[major_version]` tag instead.

### Node 18 versions
* [`v9.1.2`](https://github.com/buanet/ioBroker.docker/blob/v9.1.2/debian12/Dockerfile), [`latest-v9`](https://github.com/buanet/ioBroker.docker/blob/v9.1.2/debian12/Dockerfile), [`latest`](https://github.com/buanet/ioBroker.docker/blob/v9.1.2/debian12/Dockerfile)
* [`v9.1.1`](https://github.com/buanet/ioBroker.docker/blob/v9.1.1/debian12/Dockerfile)
* [`v9.1.0`](https://github.com/buanet/ioBroker.docker/blob/v9.1.0/debian12/Dockerfile)
* [`v9.0.1`](https://github.com/buanet/ioBroker.docker/blob/v9.0.1/debian12/Dockerfile)
* [`v9.0.0`](https://github.com/buanet/ioBroker.docker/blob/v9.0.0/debian12/Dockerfile)
* [`v8.1.0`](https://github.com/buanet/ioBroker.docker/blob/v8.1.0/debian/node18/Dockerfile), [`latest-v8`](https://github.com/buanet/ioBroker.docker/blob/v8.1.0/debian/node18/Dockerfile), 
* [`v8.0.1`](https://github.com/buanet/ioBroker.docker/blob/v8.0.1/debian/node18/Dockerfile)
* [`v8.0.0`](https://github.com/buanet/ioBroker.docker/blob/v8.0.0/debian/node18/Dockerfile)

### Node 16 versions
* [`v7.2.0`](https://github.com/buanet/ioBroker.docker/blob/v7.2.0/debian/node16/Dockerfile), [`latest-v7`](https://github.com/buanet/ioBroker.docker/blob/v7.2.0/debian/node16/Dockerfile)
* [`v7.1.2`](https://github.com/buanet/ioBroker.docker/blob/v7.1.2/debian/node16/Dockerfile), [`v7.1.2-amd64`](https://github.com/buanet/ioBroker.docker/blob/v7.1.2/debian/node16/Dockerfile), [`v7.1.2-arm32v7`](https://github.com/buanet/ioBroker.docker/blob/v7.1.2/debian/node16/Dockerfile), [`v7.1.2-arm64v8`](https://github.com/buanet/ioBroker.docker/blob/v7.1.2/debian/node16/Dockerfile)
* [`v7.0.1`](https://github.com/buanet/ioBroker.docker/blob/v7.0.1/debian/node16/Dockerfile), [`v7.0.1-amd64`](https://github.com/buanet/ioBroker.docker/blob/v7.0.1/debian/node16/Dockerfile), [`v7.0.1-arm32v7`](https://github.com/buanet/ioBroker.docker/blob/v7.0.1/debian/node16/Dockerfile), [`v7.0.1-arm64v8`](https://github.com/buanet/ioBroker.docker/blob/v7.0.1/debian/node16/Dockerfile)

# What is ioBroker?

IoBroker is a open source IoT platform written in JavaScript that easily connects smarthome components from different manufactures. With the help of plugins (called: "adapters") ioBroker is able to communicate with a big variety of IoT hardware and services using different protocols and APIs.<br>
All data is stored in a central database that all adapters can access. With this it is very easy to build up logical connections, automation scripts and beautiful visualizations.<br>
For further details please check out [iobroker.net](https://www.iobroker.net).

# How to use this image?

## Running from command-line

For taking a first look at iobroker on docker it would be enough to simply run the following basic docker run command:

```
docker run -p 8081:8081 --name iobroker -h iobroker buanet/iobroker
```

## Running with docker-compose

When using docker-compose define the iobroker service like this:

```
version: '2'

services:
  iobroker:
    container_name: iobroker
    image: buanet/iobroker
    hostname: iobroker
    restart: always
    ports:
      - "8081:8081"
```

## Persistent data

To make your ioBroker configuration persistent it is recommended to mount a volume or path to `/opt/iobroker`.

On command-line add 
```
-v iobrokerdata:/opt/iobroker
```
On docker-compose add
```
    volumes:
      - iobrokerdata:/opt/iobroker
```

## Configuration via environment variables

You could use environment variables to auto configure your ioBroker container on startup. 

### Configure ioBroker application:

* `IOB_ADMINPORT` (optional, default: 8081) Set ioBroker adminport on startup
* `IOB_BACKITUP_EXTDB` (optional) Set `true` for backing up external databases in ioBroker backitup adapter (Make sure your have read the [docs](https://docs.buanet.de/iobroker-docker-image/docs/#backup))
* `IOB_MULTIHOST` (optional) Set "master" or "slave" for multihost support (needs additional config for objectsdb and statesdb!)
* `IOB_OBJECTSDB_TYPE` (optional, default: jsonl) Set type of ioBroker objects db, could be "jsonl", "file" (deprecated) or "redis"
* `IOB_OBJECTSDB_HOST` (optional, default: 127.0.0.1) Set host for ioBroker objects db, supports comma separated list for Redis Sentinel Cluster
* `IOB_OBJECTSDB_PORT` (optional, default: 9001) Set port for ioBroker objects db, supports comma separated list for Redis Sentinel Cluster
* `IOB_OBJECTSDB_PASS` (optional) Set authentication for Redis db connection
* `IOB_OBJECTSDB_NAME` (optional, default: mymaster) Set name for Redis Sentinel CLuster db
* `IOB_STATESDB_TYPE` (optional, default: jsonl) Set type of ioBroker states db, could be "jsonl", "file" (deprecated) or "redis"
* `IOB_STATESDB_HOST` (optional, default: 127.0.0.1) Set host for ioBroker states db, supports comma separated list for Redis Sentinel Cluster
* `IOB_STATESDB_PORT` (optional, default: 9000) Set port for ioBroker states db, supports comma separated list for Redis Sentinel Cluster
* `IOB_STATESDB_PASS` (optional, default: 9000) Set authentication for Redis db connection
* `IOB_STATESDB_NAME` (optional, default: mymaster) Set name for Redis Sentinel cluster db

### Activate special features: 

* `AVAHI` (optional) Set `true` to install and activate avahi-daemon for supporting yahka adapter

### Configure environment:

* `DEBUG` (optional) Set `true` to get extended logging messages on container startup
* `LANG` (optional, default: de_DE.UTF-8) The following locales are pre-generated: de_DE.UTF-8, en_US.UTF-8
* `LANGUAGE` (optional, default: de_DE:de) The following locales are pre-generated: de_DE:de, en_US:en
* `LC_ALL` (optional, default: de_DE.UTF-8) The following locales are pre-generated: de_DE.UTF-8, en_US.UTF-8
* `OFFLINE_MODE` (optional) Set `true` if your container has no or limited internet connection
* `PACKAGES` (optional) Install additional Linux packages to your container, packages should be separated by whitespace like this: `package1 package2 package3`.
* `PACKAGES_UPDATE` (optional) Set `true` if you want to apply Linux package updates at the first start of a new container.
* `PERMISSION_CHECK` (optional, default: true) Set "false" to skip checking and correcting all relevant permissions on container startup (Use at own risk!!!)
* `SETGID` (default: 1000) In some cases it might be useful to specify the gid of the containers iobroker user to match an existing group on the docker host
* `SETUID` (default: 1000) In some cases it might be useful to specify the uid of the containers iobroker user to match an existing user on the docker host
* `TZ` (optional, default: Europe/Berlin) Specifies the time zone, could be all valid Linux timezones
* `USBDEVICES` (optional) Set relevant permissions on mounted devices like `/dev/ttyACM0` (inside the container), for more than one device separate with ";"

## Notes about Docker networks

The examples above are dealing with the Docker default bridge network. In general there are [some reasons](https://docs.docker.com/network/bridge/#differences-between-user-defined-bridges-and-the-default-bridge) why it might be the better choice to use a user-defined bridge network. 

Using a Docker bridge network works fine for taking a first look and with most of the ioBroker adapters (if you don't forget to redirect the ports your adapters use).<br>
But some ioBroker adapters are using techniques like [Multicast](https://en.wikipedia.org/wiki/Multicast) or [Broadcast](https://en.wikipedia.org/wiki/Broadcasting_(networking)) for automatic detection of IoT devices<br>
In this case it may be useful to switch to [host](https://docs.docker.com/network/host/) or [MACVLAN](https://docs.docker.com/network/macvlan/) network. 

For more information about networking with Docker please refer to the [official Docker docs](https://docs.docker.com/network/). 

# Support the Project

If you like what you see please leave us stars and likes on our repos and join our growing community.
See you soon. :)
