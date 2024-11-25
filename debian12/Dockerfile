FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="Official ioBroker Docker Image" \
      org.opencontainers.image.description="Official Docker image for ioBroker smarthome software (https://www.iobroker.net)" \
      org.opencontainers.image.documentation="https://github.com/buanet/ioBroker.docker#readme" \
      org.opencontainers.image.authors="André Germann <info@buanet.de>" \
      org.opencontainers.image.url="https://github.com/buanet/ioBroker.docker" \
      org.opencontainers.image.source="https://github.com/buanet/ioBroker.docker" \
      org.opencontainers.image.base.name="debian:bookworm-slim" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${DATI}"

ENV DEBIAN_FRONTEND="noninteractive"

# Copy files
COPY scripts /opt/scripts
COPY userscripts /opt/userscripts

# Set up ioBroker
RUN apt-get update && apt-get upgrade -y \
    # Install prerequisites
    && apt-get install -q -y --no-install-recommends \
    apt-utils \
    ca-certificates \
    cifs-utils \
    curl \
    gnupg \
    gosu \
    iputils-ping \
    jq \
    libatomic1 \
    locales \
    nfs-common \
    procps \
    python3 \
    python3-dev \
    tar \
    tzdata \
    udev \
    wget \
    # Generating locales
    && sed -i 's/^# *\(de_DE.UTF-8\)/\1/' /etc/locale.gen \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    # Prepare .docker_config
    && mkdir /opt/.docker_config \
    && echo "starting" > /opt/.docker_config/.healthcheck \
    && echo "${VERSION}" > /opt/.docker_config/.thisisdocker \
    && echo "${DATI}" > /opt/.docker_config/.build \
    && echo "true" > /opt/.docker_config/.first_run \
    # Prepare old .docker_config (needed until changed in iobroker)
    && mkdir /opt/scripts/.docker_config \
    && echo "${VERSION}" > /opt/scripts/.docker_config/.thisisdocker \
    # Run iobroker installer
    && curl -sL https://iobroker.net/install.sh -o install.sh \
    && sed -i 's/NODE_MAJOR=[0-9]\+/NODE_MAJOR=${NODE}/' install.sh \
    && sed -i 's|NODE_JS_BREW_URL=.*|NODE_JS_BREW_URL="https://nodejs.org"|' install.sh \
    && bash install.sh \
    # Deleting UUID from build
    && iobroker unsetup -y \
    && echo "true" > /opt/iobroker/.fresh_install \
    # Backup initial ioBroker and userscript folder
    && tar -cf /opt/initial_iobroker.tar /opt/iobroker \
    && tar -cf /opt/initial_userscripts.tar /opt/userscripts \
    # Setting up iobroker-user
    && chsh -s /bin/bash iobroker \
    && usermod --home /opt/iobroker iobroker \
    && usermod -u 1000 iobroker \
    && groupmod -g 1000 iobroker \
    && chown root:iobroker /usr/sbin/gosu \
    # Set permissions and ownership
    && chown -R iobroker:iobroker /opt/scripts /opt/userscripts \
    && chmod 755 /opt/scripts/*.sh \
    && chmod 755 /opt/userscripts/*.sh \
    # register maintenance command
    && ln -s /opt/scripts/maintenance.sh /bin/maintenance \
    && ln -s /opt/scripts/maintenance.sh /bin/maint \
    && ln -s /opt/scripts/maintenance.sh /bin/m \
    # Clean up installation cache
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoclean -y \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /root/.cache/* /root/.npm/* /var/lib/apt/lists/*

# Default environment variables
ENV BUILD="${BUILD}" \
    DEBIAN_FRONTEND="teletype" \
    LANG="de_DE.UTF-8" \
    LANGUAGE="de_DE:de" \
    LC_ALL="de_DE.UTF-8" \
    SETGID=1000 \
    SETUID=1000 \
    TZ="Europe/Berlin"

# Default admin ui port
EXPOSE 8081

# Change work dir
WORKDIR /opt/iobroker/

# Healthcheck
HEALTHCHECK --interval=15s --timeout=5s --retries=5 \
    CMD ["/bin/bash", "-c", "/opt/scripts/healthcheck.sh"]

# Volume for persistent data
VOLUME ["/opt/iobroker"]

# Run startup-script
ENTRYPOINT ["/bin/bash", "-c", "/opt/scripts/iobroker_startup.sh"]
