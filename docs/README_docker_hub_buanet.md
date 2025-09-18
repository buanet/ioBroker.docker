<img src="https://github.com/buanet/ioBroker.docker/raw/main/docs/img/iobroker_logo.png" width="600" title="ioBroker Logo">

[![Release](https://img.shields.io/github/v/release/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/releases)
[![Pre-Release)](https://img.shields.io/github/v/tag/buanet/ioBroker.docker?include_prereleases&label=pre-release)](https://github.com/buanet/ioBroker.docker/releases)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/buanet/ioBroker.docker/build-debian12-latest_sep.yml?branch=main)](https://github.com/buanet/ioBroker.docker/actions/workflows/build-debian12-latest_sep.yml)
[![Github Issues](https://img.shields.io/github/issues/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/issues)
[![Github Pull Requests](https://img.shields.io/github/issues-pr/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/pulls)
[![GitHub Discussions](https://img.shields.io/github/discussions/buanet/ioBroker.docker)](https://github.com/buanet/ioBroker.docker/discussions)<br>
[![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm32v7%20%7C%20arm64v8-blue)](https://hub.docker.com/repository/docker/buanet/iobroker)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/buanet/iobroker/latest?style=flat)](https://hub.docker.com/repository/docker/buanet/iobroker)
[![Docker Pulls](https://img.shields.io/docker/pulls/buanet/iobroker?style=flat)](https://hub.docker.com/repository/docker/buanet/iobroker)
[![Docker Stars](https://img.shields.io/docker/stars/buanet/iobroker?style=flat)](https://hub.docker.com/repository/docker/buanet/iobroker)<br>
[![Source](https://img.shields.io/badge/source-github-blue?style=flat)](https://github.com/buanet/ioBroker.docker)
[![GitHub forks](https://img.shields.io/github/forks/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/network)
[![GitHub stars](https://img.shields.io/github/stars/buanet/ioBroker.docker?style=flat)](https://github.com/buanet/ioBroker.docker/stargazers)
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

### Node 22 versions
* [`v11.0.0`](https://github.com/buanet/ioBroker.docker/blob/v11.0.0/debian12/Dockerfile), [`latest-v11`](https://github.com/buanet/ioBroker.docker/blob/v11.0.0/debian12/Dockerfile), [`latest`](https://github.com/buanet/ioBroker.docker/blob/v11.0.0/debian12/Dockerfile)

### Node 20 versions
* [`v10.0.0`](https://github.com/buanet/ioBroker.docker/blob/v10.0.0/debian12/Dockerfile), [`latest-v10`](https://github.com/buanet/ioBroker.docker/blob/v10.0.0/debian12/Dockerfile), [`latest`](https://github.com/buanet/ioBroker.docker/blob/v10.0.0/debian12/Dockerfile)

# What is ioBroker?

IoBroker is an open source IoT platform written in JavaScript that easily connects smarthome components from different manufactures. With the help of plugins (called: "adapters") ioBroker is able to communicate with a big variety of IoT hardware and services using different protocols and APIs.<br>
All data is stored in a central database that all adapters can access. With this it is very easy to build up logical connections, automation scripts and beautiful visualizations.<br>
For further details please check out [iobroker.net](https://www.iobroker.net).

# How to use this image?

## Quick Start (for testing)

To quickly try out ioBroker in Docker, simply run:

```
docker run -p 8081:8081 --name iobroker -h iobroker buanet/iobroker
```

**Note:**  
All data and settings will be lost when the container is removed or recreated. For production use, always use persistent storage (see below).

## Production Setup with Docker Compose

For a persistent and production-ready setup, use Docker Compose and mount a volume for your data:

```yaml
services:
  iobroker:
    container_name: iobroker
    image: buanet/iobroker
    hostname: iobroker
    restart: always
    ports:
      - "8081:8081"
    volumes:
      - iobrokerdata:/opt/iobroker
    environment:
      - TZ=Europe/Berlin

volumes:
  iobrokerdata:
```

### Docker Manager Support

To use the [ioBroker.docker-manager](https://github.com/ioBroker/ioBroker.docker-manager) adapter for managing Docker containers from within ioBroker, add the Docker socket mount and enable the Docker socket feature:

```yaml
services:
  iobroker:
    container_name: iobroker
    image: buanet/iobroker
    hostname: iobroker
    restart: always
    ports:
      - "8081:8081"
    volumes:
      - iobrokerdata:/opt/iobroker
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - TZ=Europe/Berlin
      - DOCKER_SOCK=true

volumes:
  iobrokerdata:
```

**Tip:**  
Depending on your adapters, you may need to expose additional ports or use a different network mode (e.g. `network_mode: host`).  
See the [Networking section](#notes-about-docker-networks) for more details.

## Persistent Data

To keep your ioBroker configuration and data, always mount a volume or path to `/opt/iobroker`:

**Command-line:**
```
-v iobrokerdata:/opt/iobroker
```
**Docker Compose:**
```yaml
volumes:
  - iobrokerdata:/opt/iobroker
```

## Configuration via Environment Variables

You can use environment variables to automatically configure your ioBroker container at startup.

### Application Configuration

- `IOB_ADMINPORT` (optional, default: 8081) – Set ioBroker admin port on startup
- `IOB_BACKITUP_EXTDB` (optional) – Set `true` to enable external database backup in the Backitup adapter ([see docs](https://docs.buanet.de/iobroker-docker-image/docs/#backup))
- `IOB_MULTIHOST` (optional) – Set to "master" or "slave" for multihost support (requires additional config for objectsdb and statesdb)
- `IOB_OBJECTSDB_TYPE` (optional, default: jsonl) – Type of objects DB: "jsonl", "file" (deprecated), or "redis"
- `IOB_OBJECTSDB_HOST` (optional, default: 127.0.0.1) – Host for objects DB (comma-separated for Redis Sentinel)
- `IOB_OBJECTSDB_PORT` (optional, default: 9001) – Port for objects DB (comma-separated for Redis Sentinel)
- `IOB_OBJECTSDB_PASS` (optional) – Password for Redis DB
- `IOB_OBJECTSDB_NAME` (optional, default: mymaster) – Redis Sentinel DB name
- `IOB_STATESDB_TYPE` (optional, default: jsonl) – Type of states DB: "jsonl", "file" (deprecated), or "redis"
- `IOB_STATESDB_HOST` (optional, default: 127.0.0.1) – Host for states DB (comma-separated for Redis Sentinel)
- `IOB_STATESDB_PORT` (optional, default: 9000) – Port for states DB (comma-separated for Redis Sentinel)
- `IOB_STATESDB_PASS` (optional) – Password for Redis DB
- `IOB_STATESDB_NAME` (optional, default: mymaster) – Redis Sentinel DB name

### Special Features

- `AVAHI` (optional) – Set `true` to install and activate avahi-daemon (for yahka adapter support)
- `DOCKER_SOCK` (optional) – Set `true` to add iobroker user to docker group for Docker API access (requires mounting `/var/run/docker.sock:/var/run/docker.sock`)

### Environment Configuration

- `DEBUG` (optional) – Set `true` for extended logging on container startup
- `LANG` (optional, default: de_DE.UTF-8) – Pre-generated: de_DE.UTF-8, en_US.UTF-8
- `LANGUAGE` (optional, default: de_DE:de) – Pre-generated: de_DE:de, en_US:en
- `LC_ALL` (optional, default: de_DE.UTF-8) – Pre-generated: de_DE.UTF-8, en_US.UTF-8
- `OFFLINE_MODE` (optional) – Set `true` if your container has no or limited internet connection
- `PACKAGES` (optional) – Install additional Linux packages (space-separated list)
- `PACKAGES_UPDATE` (optional) – Set `true` to update Linux packages on first start
- `PERMISSION_CHECK` (optional, default: true) – Set "false" to skip permission checks/corrections (use at your own risk)
- `SETGID` (default: 1000) – Set the GID for the iobroker user (to match a group on the host)
- `SETUID` (default: 1000) – Set the UID for the iobroker user (to match a user on the host)
- `TZ` (optional, default: Europe/Berlin) – Set the timezone (any valid Linux timezone)
- `USBDEVICES` (optional) – Set permissions for mounted devices (e.g. `/dev/ttyACM0`, separate multiple devices with ";")

## Notes about Docker Networks

The above examples use Docker's default bridge network. In many cases, it is better to use a user-defined bridge network.  
See [Docker docs: bridge differences](https://docs.docker.com/network/bridge/#differences-between-user-defined-bridges-and-the-default-bridge).

A bridge network works for most adapters if you map all required ports.  
However, some adapters require [Multicast](https://en.wikipedia.org/wiki/Multicast) or [Broadcast](https://en.wikipedia.org/wiki/Broadcasting_(networking)) for device discovery.  
In these cases, consider using [host](https://docs.docker.com/network/host/) or [MACVLAN](https://docs.docker.com/network/macvlan/) networking.

For more information, see the [official Docker networking documentation](https://docs.docker.com/network/).

# Support the Project

If you like what you see please leave us stars and likes on our repos and join our growing community.<br>
See you soon. :)
