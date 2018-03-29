# docker-iobroker
Docker image for ioBroker (http://iobroker.net) based on debian:latest (http://hub.docker.com/_/debian/)

This project creates a Docker image for running ioBroker in a Docker container. It is made for and tested on a Synology Disk Station 1515+ with DSM 6 and Docker-Package installed. But it should also work on other systems with Docker!<br>
Cause the container ist based on debian:latest, it acts nearly like a full virtual machine. That makes it possible to easily add some additional dependies for some ioBroker-Adapters.

## Installation & Usage

A detailed tutorial (german) can be found on my Website (https://buanet.de/2017/09/iobroker-unter-docker-auf-der-synology-diskstation/).<br>
For discussion and support please visit ioBroker-forum-thread (http://forum.iobroker.net/viewtopic.php?f=17&t=5089) or use the comments section at the linked tutorial. Please do not contact me directly for any support-reasons. Every support-question should be answered in a public place. Thank you.


## Changelog

### v1.1.1 (2018-03-29)
* added wget package
* updated readme.md

### v1.1.0 (2017-12-10)
* changed startup call to fix restart issue
* fixed avahi startup issue
* fixed hostname issue
* added z-wave support
* added logging to /opt/scripts/docker_iobroker_log.txt

### v1.0.1 (2017-08-25)
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
