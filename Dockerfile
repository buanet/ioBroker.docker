FROM debian:latest

MAINTAINER Andre Germann <https://buanet.de>

ENV DEBIAN_FRONTEND noninteractive

# Install prerequisites
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        acl \
        apt-utils \
        build-essential \
        curl \
        git \
        gnupg2 \
        libavahi-compat-libdnssd-dev \
        libcap2-bin \
        libpam0g-dev \
        libudev-dev \
        locales \
        procps \
        python \
        sudo \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Install node8
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash \
    && apt-get update && apt-get install -y \
        nodejs \
    && rm -rf /var/lib/apt/lists/*

# Generating locales
RUN sed -i 's/^# *\(de_DE.UTF-8\)/\1/' /etc/locale.gen \
	&& sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
	&& locale-gen

# Create scripts directory and copy scripts
RUN mkdir -p /opt/scripts/ \
    && chmod 777 /opt/scripts/
WORKDIR /opt/scripts/
COPY scripts/iobroker_startup.sh iobroker_startup.sh
COPY scripts/setup_avahi.sh setup_avahi.sh
COPY scripts/setup_packages.sh setup_packages.sh
RUN chmod +x iobroker_startup.sh \
	&& chmod +x setup_avahi.sh \
    && chmod +x setup_packages.sh

# Install ioBroker
WORKDIR /
RUN apt-get update \
    && curl -sL https://raw.githubusercontent.com/ioBroker/ioBroker/stable-installer/installer.sh | bash - \
    && echo $(hostname) > /opt/iobroker/.install_host \
    && echo $(hostname) > /opt/.firstrun \
    && rm -rf /var/lib/apt/lists/*

# Install node-gyp
WORKDIR /opt/iobroker/
RUN npm install -g node-gyp

# Backup initial ioBroker-folder
RUN tar -cf /opt/initial_iobroker.tar /opt/iobroker

# Setting up iobroker-user
RUN chsh -s /bin/bash iobroker

# Setting up ENVs
ENV DEBIAN_FRONTEND="teletype" \
	LANG="de_DE.UTF-8" \
	LANGUAGE="de_DE:de" \
	LC_ALL="de_DE.UTF-8" \
	TZ="Europe/Berlin" \
	PACKAGES="nano" \
	AVAHI="false"

# Setting up EXPOSE for Admin
EXPOSE 8081/tcp	
	
# Run startup-script
ENTRYPOINT ["/opt/scripts/iobroker_startup.sh"]
