FROM debian:latest

MAINTAINER Andre Germann <info@buanet.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y build-essential python apt-utils curl avahi-daemon git libpcap-dev libavahi-compat-libdnssd-dev libfontconfig gnupg2 locales procps libudev-dev unzip sudo wget ffmpeg android-tools-adb android-tools-fastboot

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash
RUN apt-get install -y nodejs

RUN sed -i '/^rlimit-nproc/s/^\(.*\)/#\1/g' /etc/avahi/avahi-daemon.conf
RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \dpkg-reconfigure --frontend=noninteractive locales && \update-locale LANG=de_DE.UTF-8
ENV LANG de_DE.UTF-8 
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
ENV TZ Europe/Berlin

RUN mkdir -p /opt/iobroker/ && chmod 777 /opt/iobroker/
RUN mkdir -p /opt/scripts/ && chmod 777 /opt/scripts/

WORKDIR /opt/scripts/

ADD scripts/avahi_startup.sh avahi_startup.sh
RUN chmod +x avahi_startup.sh
RUN mkdir /var/run/dbus/

ADD scripts/iobroker_startup.sh iobroker_startup.sh
RUN chmod +x iobroker_startup.sh

WORKDIR /opt/iobroker/

RUN npm install iobroker --unsafe-perm && echo $(hostname) > .install_host
RUN update-rc.d iobroker.sh remove
RUN npm install node-gyp -g

CMD ["sh", "/opt/scripts/iobroker_startup.sh"]

ENV DEBIAN_FRONTEND teletype
