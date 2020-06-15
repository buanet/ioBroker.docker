FROM node:12-slim

LABEL maintainer="info@thorstenreichelt.de"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    curl \
    locales \ 
    tzdata \ 
    net-tools \
    ca-certificates \
    && sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && \dpkg-reconfigure --frontend=noninteractive locales \
    && \update-locale LANG=de_DE.UTF-8 \
    && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && apt-get autoremove -y \    
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN npm install node-gyp@7.0.0 -g

RUN apt-get update -qq \
    && curl -sL https://iobroker.net/install.sh | bash - \
    && rm -rf /var/lib/apt/lists/*

RUN iobroker repo set latest 

RUN echo 'iobroker ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo \
    && echo "iobroker:iobroker" | chpasswd \
    && adduser iobroker sudo

ENV DEBIAN_FRONTEND="teletype" \
    LANG="de_DE.UTF-8" \
    TZ="Europe/Berlin" 

USER iobroker
EXPOSE 8081/tcp
VOLUME /opt/iobroker 
CMD ["node", "/opt/iobroker/node_modules/iobroker.js-controller/controller.js"]
HEALTHCHECK --interval=60s --timeout=10s --start-period=60s --retries=3 CMD ["curl -f http://localhost:8081/ || exit 1"]