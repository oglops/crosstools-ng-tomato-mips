
FROM docker.io/library/ubuntu:14.04
MAINTAINER oglop
ARG user=tomato

RUN buildDeps='bison flex gperf libncurses5-dev texinfo help2man asciidoc xmlto tree autoconf wget gawk make libtool tar git vim g++ expat' \
    && apt-get update \
    && apt-get install -y $buildDeps \
    && useradd -ms /bin/bash $user \
    && /usr/sbin/usermod -aG sudo $user \
    && echo $user:$user | /usr/sbin/chpasswd \
    && echo $user ALL=NOPASSWD: ALL > /etc/sudoers.d/${user}sudo

USER $user
WORKDIR /home/$user

RUN git clone https://github.com/crosstool-ng/crosstool-ng \
	&& cd crosstool-ng \
	&& git checkout crosstool-ng-1.21.0 \
	&& ./bootstrap \
	&& ./configure \
	&& make \
	&& sudo make install \
	&& cd $HOME \
	&& mkdir config && cd config \
	&& ct-ng mips-unknown-linux-uclibc

WORKDIR /home/$user/config
COPY ./ctng.config .config 
COPY ./uclibc.config ./

RUN ct-ng build.4

ENV PATH="$HOME/x-tools/mipsel-unknown-linux-uclibc/bin:$PATH"
