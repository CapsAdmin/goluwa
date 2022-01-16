FROM ubuntu:20.04

WORKDIR /goluwa

RUN apt-get update

# https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image 
# because of autogen
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

RUN apt-get install -y \
    wget \
    git \
    make \
    gcc \
    autogen \
    autoconf \
    automake \
    libtool \
    perl

# luajit v2.1
WORKDIR /goluwa/storage/temp/ffibuild/luajit
RUN git clone https://github.com/LuaJIT/LuaJIT . && git checkout v2.1
RUN \
    make \
    amalg CCDEBUG=-g \
    XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT \
    MACOSX_DEPLOYMENT_TARGET=10.6 \
    && make install && \
    ln -sf luajit-2.1.0-beta3 /usr/local/bin/luajit
WORKDIR /goluwa

# libressl
WORKDIR /goluwa/storage/temp/ffibuild/libtls
RUN git clone https://github.com/libressl-portable/portable.git .
RUN ./autogen.sh && ./configure && make
WORKDIR /goluwa

COPY storage/temp/ffibuild/luajit/src/luajit core/bin/linux_x64/luajit
COPY storage/temp/ffibuild/luajit/src/libluajit.so core/bin/linux_x64/libluajit.so
COPY storage/temp/ffibuild/libtls/crypto/.libs/libcrypto.so core/bin/linux_x64/libcrypto.so
COPY storage/temp/ffibuild/libtls/ssl/.libs/libssl.so core/bin/linux_x64/libssl.so
COPY storage/temp/ffibuild/libtls/tls/.libs/libtls.so core/bin/linux_x64/libtls.so

RUN touch core/bin/linux_x64/lua_downloaded_and_validated

COPY goluwa ./goluwa
COPY core ./core

# rebuild libressl and luajit again, but this time it will also generate the cdef files
RUN ./goluwa build libressl
RUN ./goluwa build luajit

COPY framework ./framework

RUN ./goluwa build enet

RUN apt-get install -y subversion g++
RUN ./goluwa build freeimage

# https://gitlab.freedesktop.org/freetype/docker-images/-/blob/master/.gitlab-ci.yml
RUN apt-get install -y cmake libx11-dev libpng-dev zlib1g-dev libbz2-dev libharfbuzz-dev tree libbrotli-dev
RUN ./goluwa build freetype

# https://github.com/libarchive/libarchive/blob/master/.github/workflows/ci.yml
RUN apt-get install -y autoconf automake bsdmainutils build-essential cmake ghostscript git groff libssl-dev libacl1-dev libbz2-dev liblzma-dev liblz4-dev libzstd-dev lzop pkg-config zip zlib1g-dev
RUN ./goluwa build libarchive

RUN ./goluwa build mpg123

# https://github.com/libsndfile/libsndfile/blob/master/.github/workflows/action.yml
RUN apt-get install -y autogen ninja-build libogg-dev libvorbis-dev libflac-dev libopus-dev libasound2-dev libsqlite3-dev libspeex-dev libmp3lame-dev libmpg123-dev
RUN ./goluwa build libsndfile

# https://github.com/kcat/openal-soft/blob/master/.github/workflows/ci.yml
RUN apt-get install -y libpulse-dev portaudio19-dev libasound2-dev libjack-dev qtbase5-dev libdbus-1-dev
RUN ./goluwa build openal

# https://github.com/libsdl-org/SDL/blob/main/.github/workflows/main.yml
RUN apt-get install -y \
    wayland-protocols \
    pkg-config \
    ninja-build \
    libasound2-dev \
    libdbus-1-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libglu1-mesa-dev \
    libibus-1.0-dev \
    libpulse-dev \
    libsdl2-2.0-0 \
    libsndio-dev \
    libudev-dev \
    libwayland-dev \
    libwayland-client++0 \
    wayland-scanner++ \
    libwayland-cursor++0 \
    libx11-dev \
    libxcursor-dev \
    libxext-dev \
    libxi-dev \
    libxinerama-dev \
    libxkbcommon-dev \
    libxrandr-dev \
    libxss-dev \
    libxt-dev \
    libxv-dev \
    libxxf86vm-dev \
    libdrm-dev \
    libgbm-dev\
    libpulse-dev \
    libpango1.0-dev
RUN ./goluwa build sdl2

RUN ./goluwa build vtflib
RUN ./goluwa build vtflib

COPY engine ./engine
COPY game ./game

RUN rm -rf storage/temp/ffibuild

CMD ["ls"]