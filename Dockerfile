FROM node:14-slim

LABEL maintainer="info@thorstenreichelt.de"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
	locales=2.28-10 \
        tzdata=2020a-0+deb10u1 \
        build-essential \
        net-tools \
        curl \
        git \
        gnupg2 \
        libpam0g-dev \
        libudev-dev \
        procps \
        python \
        sudo \
        unzip \
        wget \
        iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && \dpkg-reconfigure --frontend=noninteractive locales \
    && \update-locale LANG=de_DE.UTF-8
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

ENV LANG="de_DE.UTF-8" \
    TZ="Europe/Berlin"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /
RUN curl -sL "https://raw.githubusercontent.com/ioBroker/ioBroker/stable-installer/installer.sh" | bash - \
    && echo $(hostname) > /opt/iobroker/.install_host \
    && rm -rf /var/lib/apt/lists/*

RUN npm install node-gyp -g

RUN echo 'iobroker ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo \
    && echo "iobroker:iobroker" | chpasswd \
    && adduser iobroker sudo

ENV DEBIAN_FRONTEND="teletype" \
	LANG="de_DE.UTF-8" \
	TZ="Europe/Berlin"

RUN mkdir -p /opt/scripts/ && chmod -R 777 /opt/scripts/
WORKDIR /opt/scripts/
COPY scripts/iobroker_stop.sh scripts/iobroker_restart.sh /opt/scripts/
RUN chmod +x iobroker_stop.sh iobroker_restart.sh

#RUN iobroker host $(cat /opt/iobroker/.install_host) \
#    && rm -f /opt/iobroker/.install_host

USER iobroker
EXPOSE 8081/tcp
VOLUME ["/opt/iobroker"]	
CMD ["node", "/opt/iobroker/node_modules/iobroker.js-controller/controller.js"]
