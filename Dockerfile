FROM debian:latest

MAINTAINER Andre Germann <https://buanet.de>

ENV DEBIAN_FRONTEND noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
        apt-utils \
        build-essential \
        curl \
        git \
        gnupg2 \
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
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN apt-get update && apt-get install -y \
        nodejs \
    && rm -rf /var/lib/apt/lists/*

# Configure avahi-daemon 
# RUN sed -i '/^rlimit-nproc/s/^\(.*\)/#\1/g' /etc/avahi/avahi-daemon.conf

# Configure locales/ language/ timezone
RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && \dpkg-reconfigure --frontend=noninteractive locales \
    && \update-locale LANG=de_DE.UTF-8
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Create scripts directory and copy scripts
RUN mkdir -p /opt/scripts/ \
    && chmod 777 /opt/scripts/
WORKDIR /opt/scripts/
COPY scripts/avahi_startup.sh avahi_startup.sh
COPY scripts/iobroker_startup.sh iobroker_startup.sh
COPY scripts/packages_install.sh packages_install.sh
RUN chmod +x avahi_startup.sh \
    && chmod +x iobroker_startup.sh \
	&& chmod +x packages_install.sh

# Install ioBroker
WORKDIR /
RUN apt-get update \
    && curl -sL https://raw.githubusercontent.com/ioBroker/ioBroker/stable-installer/installer.sh | bash - \
    && echo $(hostname) > /opt/iobroker/.install_host \
    && rm -rf /var/lib/apt/lists/*

# Install node-gyp
WORKDIR /opt/iobroker/
RUN npm install node-gyp -g

# Backup initial ioBroker-folder
RUN tar -cf /opt/initial_iobroker.tar /opt/iobroker

# Giving iobroker-user sudo rights
RUN echo 'iobroker ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo \
    && echo "iobroker:iobroker" | chpasswd \
    && adduser iobroker sudo
USER iobroker

# Setting up ENV
ENV DEBIAN_FRONTEND="teletype" \
	LANG="de_DE.UTF-8" \
	TZ="Europe/Berlin" \
	PACKAGES="nano" \
	AVAHI="false"

# Setting up EXPOSE for Admin
EXPOSE 8081/tcp	
	
# Run startup-script
CMD ["sh", "/opt/scripts/iobroker_startup.sh"]
