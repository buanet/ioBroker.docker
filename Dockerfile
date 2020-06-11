FROM node:12-slim

LABEL maintainer="info@thorstenreichelt.de"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y \
	apt-utils \
        build-essential \
	net-tools \
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
	locales \ 
        tzdata \ 
    && sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && \dpkg-reconfigure --frontend=noninteractive locales \
    && \update-locale LANG=de_DE.UTF-8 \
    && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN npm install node-gyp -g

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

CMD ["node", "/opt/iobroker/node_modules/iobroker.js-controller/controller.js"]

HEALTHCHECK --interval=60s --timeout=10s --start-period=120s --retries=3 CMD ["curl -f http://localhost:8081 || exit 1"]
