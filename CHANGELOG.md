## Changelog

### v8.0.1 (17.04.2023)
* fix calling of "iob setup first" on slaves ([#335](https://github.com/buanet/ioBroker.docker/issues/335)) 

### v8.1.0-beta.1 (14.04.2023)
* enhance github actions
* enhance log output of maintenance script on restore ([#333](https://github.com/buanet/ioBroker.docker/issues/333))
* allow iobroker admin to be disabled at startup ([#332](https://github.com/buanet/ioBroker.docker/issues/332))
* allow deletion of objects and states db password with value "none" ([#306](https://github.com/buanet/ioBroker.docker/issues/306))

### v8.0.0 (20.03.2023)
* update readme and docs
* remove manifests
* enhance dockerfile, reduce image size ([#323](https://github.com/buanet/ioBroker.docker/issues/323))
* v8.0.0-beta.1 (20.02.2023)
  * upgrade node version to recommended node18  
  * rewrite of multihost setup handling
  * rewrite of custom objects and states db setup handling
  * enhance initial packages install/ update
  * enhance logging and error handling
  * add volume instruction to dockerfile
  * add support for password protected custom objects and states db ([#306](https://github.com/buanet/ioBroker.docker/issues/306))
  * add support for redis sentinel ([#311](https://github.com/buanet/ioBroker.docker/issues/311))
  * add restore command to maintenance script
  * add database connection check at startup 
  * remove initial restore feature

### v7.2.0 (12.12.2022)
* update docs
* v7.2.0-beta.1 (30.11.2022)
  * fix restart option in maintenance script
  * add error handling for usb devices
  * add aliases to maintenance script
  * add env PERMISSION_CHECK ([#251](https://github.com/buanet/ioBroker.docker/issues/251))
  * add some more DEBUG messages to log
  * add env IOB_BACKITUP_EXTDB to unlock external db backups in backitup adapter
  * reorder dockerfile steps to fulfill ioBroker Docker check

### v7.1.2 (08.11.2022)
* fix hostname check ([#293](https://github.com/buanet/ioBroker.docker/issues/293))

### v7.1.1 (01.11.2022)
* fix setting gid of iobroker group ([#289](https://github.com/buanet/ioBroker.docker/issues/289))

### v7.1.0 (31.10.2022)
* fix [build action node issue](https://forum.iobroker.net/topic/59518/docker-image-7-0-1-auf-node-js-14/14?_=1667244004952) for iobroker/iobroker repo
* v7.1.0-beta.1 (12.10.2022)
  * add env DEBUG for extended debugging log
  * enhance logging in iobroker-startup.sh
  * enhance build process
  * add restart option to maintenance script
  * add strict mode for iobroker-startup.sh
  * fix "unary operator expected" error

### v7.0.1 (05.07.2022)
* backitup restore patch

### v7.0.0 (21.06.2022)
* update docs & ci
* v7.0.0-beta.1 (16.06.2022)
  * upgrade node version to recommended node16 
  * rewrite maintenance script ([#243 by @agross](https://github.com/buanet/ioBroker.docker/pull/243))
  * enhance container shutdown on SIGTERM ([as requested with #264 by @buzz0r](https://github.com/buanet/ioBroker.docker/pull/264))
  * enhance startup script logging
  * enhance logging for avahi & zwave install scripts
  * add new env for offline mode (fixes [#255](https://github.com/buanet/ioBroker.docker/issues/255))

### v6.1.0 (2022-03-01)
* v6.1.0-beta.2 (2022-02-11)
  * fix -kbn option in maintenance script
  * enhance shutdown/ prevent warnings on upgrade
  * remove hostname check for multihost slave
  * enhance startup script logging
  * add breaks and enhance maintenance script (fixes [#233](https://github.com/buanet/ioBroker.docker/issues/233))
* v6.1.0-beta.1 (2021-12-23)
  * some more corrections in maintenance script ([#232 by @agross](https://github.com/buanet/ioBroker.docker/pull/232)) 
  * add auto confirm parameter to upgrade function in maintenance script ([#229 by @thost96](https://github.com/buanet/ioBroker.docker/pull/229))
  * add alias "m" for maintenance script

### v6.0.0 (2021-12-09)
* move docs/ restructuring readme
* v6.0.0-beta1 (2021-10-07)
  * upgrade node version to recommended node14 
  * add beta-node16 tag for beta testing node16
  * update documentation
* v5.3.0-beta1 (2021-10-07)
  * add check (installed) PACKAGES on startup (fixes [#201](https://github.com/buanet/ioBroker.docker/issues/201))
  * add packages for discovery adapter
  * add packages for backitup adapter
  * reorganize Dockerfile

### v5.2.0 (2021-09-30)
* v5.2.0-beta4 (2021-09-10)
  * adding iobroker user rights for "gosu"
  * adding more labels in OCI standard format
  * fixing workdir bug
  * adding backitup compatibility 
* v5.2.0-beta3 (2021-09-04)
  * reducing layers in dockerfile
  * making hostname check mandatory for startup
  * enhance startup log
* v5.2.0-beta2 (2021-08-28)
  * redesign maintenance script
  * switching amd64 base image to debian bullseye slim 
  * optimizing log output
  * adding labels in OCI standard format
  * adding packages update on first start
  * adding file for docker detection by ioBroker adapters
  * adding best practice for states db migration in readme
  * removing couchdb option for states db (no longer supported)
* v5.2.0-beta1 (2021-05-04)
  * added upgrade parameter to maintenance script
  * added expose for default admin ui port (fixes [#172](https://github.com/buanet/ioBroker.docker/issues/172))
  * added short form for maintenance script
* v5.2.0-beta (2021-04-02)
  * some renaming to enhance automated build
  * changes in versioning
  * delete travis for automated build

### v5.1.0 (2020-11-05)
* v5.0.2-beta (2020-07-28)
  * added docker tag for majorversion latest
  * extend readme.md docu
  * added maintenance script
  * added container healthcheck
  * fixed configuration procedure and logging for objects and states db setup
* v5.0.1-beta (2020-07-01)
  * fixing backup detection in startup script
  * fixing permission issue on iobroker restored
  * extended Logging
  * enhance multihost support

### v5.0.0 (2020-06-29)
* v4.2.4-beta (2020-06-23)
  * added graceful shutdown
  * small fix for GID/UID handling
  * adding new ENV "IOB_MULTIHOST" for multihost support
  * small syntax fixes in iobroker_startup.sh
* v4.2.3-beta (2020-06-05)
  * ~~updating js-controller to not stable version 3.1.5 to fix renaming issue~~ (is stable now)
* v4.2.2-beta (2020-06-03)
  * ~~workaround for renaming issues on startup~~ (fixed in js-controller)
* v4.2.1-beta (2020-05-10)
  * using node 12 instead of 10
  * updated documentation in readme.md

### v4.2.0 (2020-04-14)
* v4.1.4-beta (2020-04-07)
  * switching base image to buster
  * optimizing installation of packages defined by ENV "PACKAGES"
* v4.1.3-beta (2020-02-08)
  * renamed ENV for adminport (new "IOB_ADMINPORT)")
  * added new ENVs for "iobroker setup custom" (replacing "REDIS")
  * enhancements in startup script logging
* v4.1.2-beta (2020-02-02)
  * added feature for running user defined scripts on startup
  * small fix for permissions issues on some systems
* v4.1.1-beta (2020-01-17)
  * updated openzwave to version 1.6.1007

### v4.1.0 (2020-01-17)
* improved readme.md
* v4.0.3-beta (2020-01-06)
  * added support to restore backup on startup ([#56 by @duffbeer2000](https://github.com/buanet/ioBroker.docker/pull/56))
  * small fixes according to "docker best practices"
* v4.0.2-beta (2019-12-10)
  * ~~added env for activating redis~~
  * enhancements in startup script and docker file
* v4.0.1-beta (2019-11-25)
  * added env for iobroker admin port
  * added env for usb-devices (setting permissions)
  * updateing prerequisites for iobroker installation
  * some small code fixes

### v4.0.0 (2019-10-25)
* v3.1.4-beta (2019-10-23)
  * added env for zwave support
* v3.1.3-beta (2019-10-17)
  * enhanced logging of startup-script
  * multi arch support (amd64, aarch64, armv7hf)
* v3.1.2-beta (2019-09-03)
  * using node 10 instead of node 8
* v3.1.1-beta (2019-09-02)
  * adding env for setting uid/ gid for iobroker-user ([#33 by @mplogas](https://github.com/buanet/ioBroker.docker/pull/33))

### v3.1.0 (2019-08-21)
* v3.0.3-beta (2019-08-21)
  * switching base image from "debian:latest" to "debian:stretch"
* v3.0.2-beta (2019-06-13)
  * using gosu instead of sudo ([#26 by @SchumyHao](https://github.com/buanet/ioBroker.docker/pull/26))
  * changing output of ioBroker logging
* v3.0.1-beta (2019-05-18)
  * ~~switching back to iobroker-daemon for startup~~

### v3.0.0 (2019-05-09)
* v2.0.6-beta (2019-04-14)
  * added some additional logging
  * fixing some issues for language env
  * added permission fixing on first start
* v2.0.5-beta (2019-02-09)
  * added ENV to docker file
  * added EXPOSE for admin
  * final testing
* v2.0.4-beta (2019-01-28)
  * added support for env variables "avahi" and "packages"
  * moving avahi-daemon installation into avahi startup script
  * added script for installing optional packages
  * optimizing logging output
* v2.0.3-beta (2019-01-24)
  * added support for running ioBroker under iobroker user
  * optimizing logging output
  * optimizing scripts
* v2.0.2-beta (2019-01-23)
  * optimizing and rearranged docker file
  * changes for new ioBroker install script
  * added restoring for empty mounted /opt/iobroker folder
  * some more small fixes
* v2.0.1-beta (2019-01-07)
  * some changes for supporting other docker-environments than synology ds

### v2.0.0 (2018-12-05)
* v1.2.2-beta (2018-12-05)  
  * using node8 instead of node6
  * changes for new iobroker setup
* v1.2.1-beta (2018-09-12)
  * added support for firetv-adapter

### v1.2.0 (2018-08-21)
* v1.1.3-beta (2018-08-21)
  * ~~added ffmpeg-package for yahka to support webcams~~
* v1.1.2-beta (2018-04-04)
  * added ENV for timezone issue
* v1.1.1-beta (2018-03-29)
  * added wget package
  * updated readme.md

###  v1.1.0 (2017-12-10)
* v1.0.2-beta (2017-12-10)
  * changed startup call to fix restart issue
  * fixed avahi startup issue
  * fixed hostname issue
  * added z-wave support
  * added logging to /opt/scripts/docker_iobroker_log.txt
* v1.0.1-beta (2017-08-25)
  * fixed locales issue

### v1.0.0 (2017-08-22)
* moved and renamed iobroker startup script
* disabled iobroker daemon to (hopefully) fix restart issue
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
