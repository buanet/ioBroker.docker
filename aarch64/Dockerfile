FROM balenalib/aarch64-debian:buster

LABEL maintainer="Andre Germann" \
      url="https://buanet.de"

ENV DEBIAN_FRONTEND noninteractive

# Install prerequisites (as listed in iobroker installer.sh)
RUN apt-get update && apt-get install -y \
    acl \
    apt-utils \
    build-essential \
    curl \
    git \
    gnupg2 \
    gosu \
    jq \
    libavahi-compat-libdnssd-dev \
    libcap2-bin \
    libpam0g-dev \
    libudev-dev \
    locales \
    pkg-config \
    procps \
    python \
    python-dev \
    sudo \
    udev \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Generating locales
RUN sed -i 's/^# *\(de_DE.UTF-8\)/\1/' /etc/locale.gen \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen

# Create scripts directorys and copy scripts
RUN mkdir -p /opt/scripts/ \
    && mkdir -p /opt/userscripts/ \
    && chmod 777 /opt/scripts/ \
    && chmod 777 /opt/userscripts/
WORKDIR /opt/scripts/
COPY scripts/iobroker_startup.sh iobroker_startup.sh
COPY scripts/setup_avahi.sh setup_avahi.sh
COPY scripts/setup_packages.sh setup_packages.sh
COPY scripts/setup_zwave.sh setup_zwave.sh
COPY scripts/healthcheck.sh healthcheck.sh
COPY scripts/maintenance.sh maintenance.sh
RUN chmod +x iobroker_startup.sh \
    && chmod +x setup_avahi.sh \
    && chmod +x setup_packages.sh \
    && chmod +x setup_zwave.sh \
    && chmod +x healthcheck.sh \
    && chmod +x maintenance.sh
WORKDIR /opt/userscripts/
COPY scripts/userscript_firststart_example.sh userscript_firststart_example.sh
COPY scripts/userscript_everystart_example.sh userscript_everystart_example.sh

# Install ioBroker
WORKDIR /
RUN apt-get update \
    && curl -sL https://iobroker.net/install.sh | bash - \
    && mkdir -p /opt/iobroker/.docker_config/ \
    && echo $(hostname) > /opt/iobroker/.docker_config/.install_host \
    && echo "starting" > /opt/iobroker/.docker_config/.healthcheck \
    && echo $(hostname) > /opt/.firstrun \
    && rm -rf /var/lib/apt/lists/*

# Install node-gyp
WORKDIR /opt/iobroker/
RUN npm install -g node-gyp

# Backup initial ioBroker and userscript folder
RUN tar -cf /opt/initial_iobroker.tar /opt/iobroker \
    && tar -cf /opt/initial_userscripts.tar /opt/userscripts

# Setting up iobroker-user (shell and home directory)
RUN chsh -s /bin/bash iobroker \
    && usermod --home /opt/iobroker iobroker \
    && usermod -u 1000 iobroker \
    && groupmod -g 1000 iobroker

# Setting up ENVs
ENV DEBIAN_FRONTEND="teletype" \
    LANG="de_DE.UTF-8" \
    LANGUAGE="de_DE:de" \
    LC_ALL="de_DE.UTF-8" \
    SETGID=1000 \
    SETUID=1000 \
    TZ="Europe/Berlin"

# Healthcheck
HEALTHCHECK --interval=15s --timeout=5s --retries=5 \
    CMD ["/bin/bash", "-c", "/opt/scripts/healthcheck.sh"]

# Run startup-script
ENTRYPOINT ["/bin/bash", "-c", "/opt/scripts/iobroker_startup.sh"]
