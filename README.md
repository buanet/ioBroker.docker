# docker-iobroker
Docker image for ioBroker (http://iobroker.net) based on debian:latest (http://hub.docker.com/_/debian/)

This project creates a Docker image for running ioBroker in a Docker container. It is made for and tested on a Synology Disk Station 1515+ with DSM 6 and Docker-package installed. But it should also work on other systems with Docker (Normally I do a small additional test on my Debian-VM with Docker CE)!

## Important

Switching an existing installation from docker-iobroker-image v1 to v2 or greater means switching iobroker itself from node6 to node8! This requires additional steps inside ioBroker! After upgrading iobroker-container you have to call "reinstall.sh" for recompiling your installation for the use with node8. For Details see official ioBroker-documentation (http://www.iobroker.net/docu/?page_id=8323&lang=de). Make backup first!!!

At the moment v3.0.0 does no longer support running in host-mode on Synology-devices because of a kernel issue in actual DSM-kernel! Please use bridged or macvlan mode. For details see new tutorial linked in the following.

## Installation & Usage

A detailed tutorial (german, based on new v3.0.0) can be found here: [https://buanet.de](https://buanet.de/2019/05/iobroker-unter-docker-auf-der-synology-diskstation-v3/). Please notice that the old tutorial does no longer work!

For discussion and support please visit [ioBroker-forum-thread](http://forum.iobroker.net/viewtopic.php?f=17&t=5089) or use the comments section at the linked tutorial. Please do not contact me directly for any support-reasons. Every support-question should be answered in a public place. Thank you.

## Special Settings

In v3.0.0 I added some new features. The following will give some short information about that.

### Environment Variables

|env|value|description|
|---|---|---|
|PACKAGES|package1 package2 package2|seperateed by whitespace; will install the listed packages on startup<br>(be paitient, this may take some time!)|
|AVAHI|true|will install and activate avahi-daemon for supporting yahka-adapter|
|LANGUAGE|de_DE:de|following locales are pre-generated: de_DE:de, en_US:en|
|LANG|de_DE.UTF-8|following locales are pre-generated: de_DE.UTF-8, en_US.UTF-8|
|LC_ALL|de_DE|following locales are pre-generated: de_DE.UTF-8, en_US.UTF-8|
|TZ|Europe/Berlin|all valid Linux-timezones|
|HOSTUID|1000|any new UID you need to match from host|

### Mounting Folder/ Volume

It is now possible to mount an empty folder to /opt/iobroker during first startup of the container. The Startupscript will check this folder and restore content if empty.

It is absolutely recommended to use a mounted folder or persistent volume for /opt/iobroker folder!

This also works with mounting a folder containing an existing ioBroker-installation (e.g. when moving an existing installation to docker). 

### Permission Fixer

I added some code for fixing permissions for new iobroker-user. Permission-fixing is called on first start of the container. This might take a few minutes. Please be patient!

## Changelog

### v3.0.3beta (2019-08-20)
* you can provide a userid from your host system. permissions will be applied.

### v3.0.2beta (2019-06-13)
* using gosu instead of sudo
* changing output of ioBroker logging

### v3.0.1beta (2019-05-18)
* ~~switching back to iobroker-daemon for startup~~

### v3.0.0 (2019-05-09)
* bringing changes since v2.0.0 to stable
* new tutorial available

### v2.0.6beta (2019-04-14)
* added some additional logging
* fixing some issues for languag env
* added permission fixing on first start

### v2.0.5beta (2019-02-09)
* added ENV to dockerfile
* added EXPOSE for admin 
* final testing

### v2.0.4beta (2019-01-28)
* added support for env variables "avahi" and "packages"
* moving avahi-daemon installation into avahi startup script
* added script for installing optional packages
* optimizing logging output

### v2.0.3beta (2019-01-24)
* added support for running ioBroker under iobroker user
* optimizing logging output
* optimizing scripts

### v2.0.2beta (2019-01-23)
* optimizing and rearraged dockerfile
* changes for new ioBroker install script
* added restoring for empty mounted /opt/iobroker folder
* some more small fixes

### v2.0.1beta (2019-01-07)
* some changes for supporting other docker-environments than synology ds

### v2.0.0 (2018-12-05)
* using node8 instead of node6 
* changes for new iobroker setup

### v1.2.1beta (2018-09-12)
* added support for firetv-adapter

### v1.2.0 (2018-08-21)
* after testing making 1.1.3beta to latest stable release 

### v1.1.3beta (2018-08-21)
* added ffmpeg-package for yahka to support webcams

### v1.1.2beta (2018-04-04)
* added ENV for timezone issue

### v1.1.1beta (2018-03-29)
* added wget package
* updated readme.md

### v1.1.0 (2017-12-10)
* changed startup call to fix restart issue
* fixed avahi startup issue
* fixed hostname issue
* added z-wave support
* added logging to /opt/scripts/docker_iobroker_log.txt

### v1.0.1beta (2017-08-25)
* fixed locales issue

### v1.0.0 (2017-08-22)
* moved and renamed iobroker startup script
* disabled iobroker deamon to (hopefully) fix restart issue
* added some maintenance scripts

### v0.2.1 (2017-08-16)
* added libfontconfig package (for iobroker.phantomjs)
* added gnupg2 package as prerequisite for installing node version 6

### v0.2.0 (2017-06-04)
* fixed startup issue in startup.sh
* changed node version from 4 to 6

### v0.1.2 (2017-03-14)
* added libpcap-dev package (for iobroker.amazon-dash)

### v0.1.1 (2017-03-10)
* added git package

### v0.1.0 (2017-03-08)
* moved avahi-start.sh to seperate directory
* fixed timezone issue (sets now timezone to Europe/Berlin)

### v0.0.2 (2017-03-06)
* added support for avahi-daemon (installation and autostart)

### v0.0.1 (2017-01-31)
* project started / initial release

## License

MIT License

Copyright (c) 2017 Andre Germann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Credits

Inspired by https://github.com/MehrCurry/docker-iobroker
