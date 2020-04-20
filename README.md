# ioBroker for Docker

[![Build Status](https://travis-ci.org/buanet/docker-iobroker.svg?branch=master)](https://travis-ci.org/buanet/docker-iobroker)

Source: https://github.com/buanet/docker-iobroker

IoBroker for Docker is an Dockerimage for ioBroker IoT platform (http://www.iobroker.net).

Since version 4 it is available for the following architectures: amd64, armv7hf, aarch64.
You need another architecture? Let me know by opening an github issue. Thx.

## Important notice

The new v4 comes again with a new major node version (node10)!
If you are updating an existing installation you have to perform some additional steps inside ioBroker!
After upgrading your iobroker container you have to call "npm rebuild" or "reinstall.sh" (when js-controller > v1.5 "reinstall.js") for recompileing your installation for the use with node10!
For more details please see official ioBroker documentation: [EN](https://www.iobroker.net/#en/documentation/install/updatenode.md) | [DE](https://www.iobroker.net/#de/documentation/install/updatenode.md).
Make backup first!

By the way, a more comfortable way is to use "iobroker backup" to create a full backup of your existing installation and copy it into a empty folder which you will mount to /opt/iobroker when setting up a new container. The startup script will automatically detect the backup file and restore it to the new container. For more details see "Mounting folder/ volume" section of this readme.md file.

## Getting started

A detailed tutorial (german, based on v3.0.0) can be found here: [https://buanet.de](https://buanet.de/2019/05/iobroker-unter-docker-auf-der-synology-diskstation-v3/). Please notice that the old tutorial is outdated and does no longer work!

For discussion and support please visit [ioBroker forum thread](http://forum.iobroker.net/viewtopic.php?f=17&t=5089) or use the comments section at the linked tutorial. Please do not contact me directly for any support-reasons. Every support question should be answered in a public place. Thanks in advance.
If you think you found a bug or simply want to request a new feature please open an issue on Github.

The following ways to get iobroker-container running are only examples. Maybe you have to change, add or replace parameters to configure ioBroker for fitting your needs.

### Running from commandline

For taking a first look at the iobroker docker container it would be enough to simply run the following basic docker run command:

```
docker run -p 8081:8081 --name iobroker -v iobrokerdata:/opt/iobroker buanet/iobroker:latest
```

### Running with docker-compose

You can also run iobroker by using docker-compose. Here is an example:

```
version: '2'

services:
  iobroker:
    restart: always
    image: buanet/iobroker:latest
    container_name: iobroker
    hostname: iobroker
    ports:
      - "8081:8081"
    volumes:
      - iobrokerdata:/opt/iobroker
```

## Special settings and features

The following will give a short overview.

### Environment variables

To configure the ioBroker container on startup it is possible to set some environment variables.
You do not have to declare every single variable when stting up your container. Variables you do not set will come up with their default value.

**Important: In v4.2.0 the ENVs "ADMINPORT" and "REDIS" were renamed/ reorganized. For Details see the following table!**

|env|default|description|
|---|---|---|
|AVAHI|false|Installs and activates avahi-daemon for supporting yahka-adapter, can be "true" or "false"|
|IOB_ADMINPORT|8081|Sets ioBroker adminport on startup|
|IOB_OBJECTSDB_HOST|127.0.0.1|Sets hostname for ioBroker objects db|
|IOB_OBJECTSDB_PORT|9001|Sets port for ioBroker objects db|
|IOB_OBJECTSDB_TYPE|file|Sets type of ioBroker objects db, cloud be "file", "redis" or "couch"|
|IOB_STATESDB_HOST|127.0.0.1|Sets hostname for ioBroker states db|
|IOB_STATESDB_PORT|9000|Sets port for ioBroker states db|
|IOB_STATESDB_TYPE|file|Sets type of ioBroker states db, could be "file" or "redis"|
|LANG|de_DE.UTF&#x2011;8|The following locales are pre-generated: de_DE.UTF-8, en_US.UTF-8|
|LANGUAGE|de_DE:de|The following locales are pre-generated: de_DE:de, en_US:en|
|LC_ALL|de_DE.UTF-8|The following locales are pre-generated: de_DE.UTF-8, en_US.UTF-8|
|PACKAGES|vi|Installs additional packages to your container needed by some adapters, packages should be seperated by whitespace like "package1 package2 package3"|
|SETGID|1000|For security reasons it might be useful to specify the gid of the containers iobroker user to match an existing group on the docker host|
|SETUID|1000|For security reasons it might be useful to specify the uid of the containers iobroker user to match an existing user on the docker host|
|TZ|Europe/Berlin|All valid Linux-timezones|
|USBDEVICES|none|Sets relevant permissions on mounted devices like "/dev/ttyACM0", for more than one device separate with ";" like "/dev/ttyACM0;/dev/ttyACM1"|
|ZWAVE|false|Will install openzwave to support zwave-adapter, can be "true" or "false"|

### Mounting folder/ volume

It is possible to mount an empty folder to /opt/iobroker during first startup of the container. The Startupscript will check this folder and restore content if it is empty.
Since v4.1.0 it is also possible mount a folder filled up with an iobroker backup file (for example created with backitup adapter) named like this: "iobroker_2020_01_06-01_09_10_backupiobroker.tar.gz".
The startup script will detect this backup and restore it during the start of the container. Plese see container logs when starting the container for more details!

Note: It is absolutely recommended to use a mounted folder or persistent volume for /opt/iobroker folder!

You can also mount a folder containing an existing ioBroker-installation (e.g. when moving an existing installation to docker).
But watch for the used node version. If the existing installation runs with another major version of node you have do perform additional steps. For more Details see the "Important notice" on top of this readme.md file.

**Important: If the folder you mount to /opt/iobroker in your container is placed on a mounted device, partition or other storage, the mountpoint on your host should NOT have the "noexec" flag activated. Otherwise you may get problems executing ioBroker inside the container!**   

### Mounting USB device 

If you want to use a USB device within ioBroker inside your container don´t forget to [mount the device](https://docs.docker.com/engine/reference/commandline/run/#add-host-device-to-container---device) on container startup and use the environment variable "USBDEVICES".

### Userdefined startup scripts

In some cases it migth be helpful to add some script code to the startup script of the container. This is now possible by mounting an additional folder to the container and place a userscript in there.
The folder containing your userscripts must be mounted under /opt/userscripts inside the container. If you mount an empty folder you will get two example scripts to be restored in that folder. Just try it out.

Basically there are two different scripts which will be read and called by the startup script. One that will only be called once at the first start of the container (userscript_firststart.sh) and one which will be called for every start of the container (userscript_everystart.sh).

Hint:
To get familiar with that feature try the following: Create a Container, mount an empty folder to /opt/userscripts, start your container. Two scripts will be restored into the empty folder. Rename the example scripts by simply removing "\_example". Restart your container and take a look at the Log. In "Step 4 of 5: Applying special settings" you will see the messages generated by the example userscripts.

## Miscellaneous

### Subscribe to updates

If you want the newest updates about the image and my tutorials at https://buanet.de/tutorials you can simply subscribe to my new "news and updates" channel (only in german) on Telegram.
You will find the channel here: https://t.me/buanet_tutorials

### Support the project

The easiest way to support this project is to leave me some likes/ stars on github and docker hub!<br>
If you want to give something back, feel free to take a look into the [open issues](https://github.com/buanet/docker-iobroker/issues) or the [ioBroker forum thread](http://forum.iobroker.net/viewtopic.php?f=17&t=5089) and helping me answering questions, fixing bugs or adding new features!<br>
And if you want to buy me a beer instead, you can do this here: <a href="https://www.paypal.me/buanet" target="_blank"><img src="https://buanet.de/wp-content/uploads/2017/08/pp128.png" height="20" width="20"></a><br>
Thank you!

## Changelog

### v4.2.0 (2020-04-14)
* v4.1.4beta (2020-04-07)
  * switching base image to buster
  * optimizing installation of packages defined by ENV "PACKAGES"
* v4.1.3beta (2020-02-08)
  * renamed ENV for adminport (new "IOB_ADMINPORT)")
  * added new ENVs for "iobroker setup custom" (replacing "REDIS")
  * enhancements in startupscript logging
* v4.1.2beta (2020-02-02)
  * added feature for running userdefined scripts on startup
  * small fix for permissions issues on some systems
* v4.1.1beta (2020-01-17)
  * updated openzwave to version 1.6.1007

### v4.1.0 (2020-01-17)
* improved readme.md
* v4.0.3beta (2020-01-06)
  * added support to restore backup on startup
  * small fixes according to "docker best practices"
* v4.0.2beta (2019-12-10)
  * ~~added env for activating redis~~
  * enhancements in startupscript and dockerfile
* v4.0.1beta (2019-11-25)
  * added env for iobroker admin port
  * added env for usb-devices (setting permissions)
  * updateing prerequisites for iobroker installation
  * some small codefixes

### v4.0.0 (2019-10-25)
* v3.1.4beta (2019-10-23)
  * added env for zwave support
* v3.1.3beta (2019-10-17)
  * enhanced logging of startup-script
  * multiarch support (amd64, aarch64, armv7hf)
* v3.1.2beta (2019-09-03)
  * using node 10 instead of node 8
* v3.1.1beta (2019-09-02)
  * adding env for setting uid/ gid for iobroker-user

### v3.1.0 (2019-08-21)
* v3.0.3beta (2019-08-21)
  * switching base image from "debian:latest" to "debian:stretch"
* v3.0.2beta (2019-06-13)
  * using gosu instead of sudo
  * changing output of ioBroker logging
* v3.0.1beta (2019-05-18)
  * ~~switching back to iobroker-daemon for startup~~

### v3.0.0 (2019-05-09)
* v2.0.6beta (2019-04-14)
  * added some additional logging
  * fixing some issues for languag env
  * added permission fixing on first start
* v2.0.5beta (2019-02-09)
  * added ENV to dockerfile
  * added EXPOSE for admin
  * final testing
* v2.0.4beta (2019-01-28)
  * added support for env variables "avahi" and "packages"
  * moving avahi-daemon installation into avahi startup script
  * added script for installing optional packages
  * optimizing logging output
* v2.0.3beta (2019-01-24)
  * added support for running ioBroker under iobroker user
  * optimizing logging output
  * optimizing scripts
* v2.0.2beta (2019-01-23)
  * optimizing and rearraged dockerfile
  * changes for new ioBroker install script
  * added restoring for empty mounted /opt/iobroker folder
  * some more small fixes
* v2.0.1beta (2019-01-07)
  * some changes for supporting other docker-environments than synology ds

### v2.0.0 (2018-12-05)
* v1.2.2beta (2018-12-05)  
  * using node8 instead of node6
  * changes for new iobroker setup
* v1.2.1beta (2018-09-12)
  * added support for firetv-adapter

### v1.2.0 (2018-08-21)
* v1.1.3beta (2018-08-21)
  * ~~added ffmpeg-package for yahka to support webcams~~
* v1.1.2beta (2018-04-04)
  * added ENV for timezone issue
* v1.1.1beta (2018-03-29)
  * added wget package
  * updated readme.md

###  v1.1.0 (2017-12-10)
* v1.0.2beta (2017-12-10)
  * changed startup call to fix restart issue
  * fixed avahi startup issue
  * fixed hostname issue
  * added z-wave support
  * added logging to /opt/scripts/docker_iobroker_log.txt
* v1.0.1beta (2017-08-25)
  * fixed locales issue

### v1.0.0 (2017-08-22)
* moved and renamed iobroker startup script
* disabled iobroker deamon to (hopefully) fix restart issue
* added some maintenance scripts

### v0.2.1 (2017-08-16)
* ~~added libfontconfig package (for iobroker.phantomjs)~~
* added gnupg2 package as prerequisite for installing node version 6

### v0.2.0 (2017-06-04)
* fixed startup issue in startup.sh
* changed node version from 4 to 6

### v0.1.2 (2017-03-14)
* ~~added libpcap-dev package (for iobroker.amazon-dash)~~

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

Copyright (c) 2017 [André Germann]

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
