FROM ubuntu:18.04

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

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash 

RUN apt-get update -qq && apt-get install -y \
        nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/scripts/ \
    && mkdir -p /opt/iobroker/ \
    && chmod 777 /opt/scripts/

WORKDIR /opt/scripts/

COPY scripts/iobroker_startup.sh iobroker_startup.sh

COPY scripts/packages_install.sh packages_install.sh

RUN chmod +x iobroker_startup.sh \
	&& chmod +x packages_install.sh

WORKDIR /

#RUN npm config set registry http://registry.npmjs.org/ \
#	&& npm install node-gyp -g

RUN npm install node-gyp -g

RUN apt-get update -qq \
    && curl -sL https://iobroker.net/install.sh | bash - \
    && echo $(hostname) > /opt/iobroker/.install_host \
    && rm -rf /var/lib/apt/lists/*

RUN iobroker repo set latest

RUN echo 'iobroker ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo \
    && echo "iobroker:iobroker" | chpasswd \
    && adduser iobroker sudo

USER iobroker

ENV DEBIAN_FRONTEND="teletype" \
    LANG="de_DE.UTF-8" \
    TZ="Europe/Berlin" 

#RUN apt-get purge -y \
#	apt-utils \
#	tzdata 

EXPOSE 8081/tcp

CMD ["sh", "/opt/scripts/iobroker_startup.sh"]
