##################################################################################
FROM ubuntu:21.10 as luajit

RUN apt-get update
RUN apt-get install -y git make gcc 

WORKDIR /src
RUN git clone https://github.com/LuaJIT/LuaJIT --depth 1 . && git checkout v2.1
RUN make -j32 CCDEBUG=-g XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT

##################################################################################
FROM ubuntu:21.10 as libressl

RUN apt-get update 
RUN apt-get install -y git make gcc 
RUN apt-get install -y autogen autoconf automake libtool perl

WORKDIR /src
RUN git clone https://github.com/libressl-portable/portable.git --depth 1 .
RUN ./autogen.sh && ./configure && make -j32

##################################################################################
FROM ubuntu:21.10 as goluwa-core

RUN apt-get update 
RUN apt-get install -y git make gcc 
RUN apt-get install -y autogen autoconf automake libtool perl

WORKDIR /goluwa

COPY goluwa ./goluwa
COPY core ./core

COPY --from=luajit src/src/luajit /golwua/core/bin/linux_x64/luajit
COPY --from=luajit src/src/libluajit.so /golwua/framework/bin/linux_x64/libluajit.so
COPY --from=libressl src/crypto/.libs/libcrypto.so core/bin/linux_x64/libcrypto.so
COPY --from=libressl src/ssl/.libs/libssl.so core/bin/linux_x64/libssl.so
COPY --from=libressl src/tls/.libs/libtls.so core/bin/linux_x64/libtls.so

RUN mkdir -p storage/shared/

RUN apt-get install -y wget
RUN wget -O storage/shared/cert.pem https://raw.githubusercontent.com/libressl-portable/openbsd/master/src/lib/libcrypto/cert.pem
RUN touch storage/shared/keep_local_binaries

RUN ./goluwa build luajit
RUN ./goluwa build libressl

RUN rm storage/shared/copy_binaries_instructions
RUN rm storage/shared/library_crashes.lua
RUN rm -rf storage/temp/

##################################################################################
FROM goluwa-core as goluwa-framework-enet

WORKDIR /goluwa
COPY framework ./framework

RUN ./goluwa build enet

##################################################################################
FROM goluwa-core as goluwa-framework-freeimage

WORKDIR /goluwa
COPY framework ./framework

RUN apt-get install -y subversion g++
RUN ./goluwa build freeimage

##################################################################################
FROM goluwa-core as goluwa-framework-freetype
WORKDIR /goluwa
COPY framework ./framework

# https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image 
# because of autogen
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# https://gitlab.freedesktop.org/freetype/docker-images/-/blob/master/.gitlab-ci.yml
RUN apt-get install -y cmake libx11-dev libpng-dev zlib1g-dev libbz2-dev libharfbuzz-dev tree libbrotli-dev
RUN ./goluwa build freetype

##################################################################################
FROM goluwa-core as goluwa-framework-libarchive

WORKDIR /goluwa
COPY framework ./framework

# https://github.com/libarchive/libarchive/blob/master/.github/workflows/ci.yml
RUN apt-get install -y autoconf automake bsdmainutils build-essential cmake ghostscript git groff libssl-dev libacl1-dev libbz2-dev liblzma-dev liblz4-dev libzstd-dev lzop pkg-config zip zlib1g-dev
RUN ./goluwa build libarchive

##################################################################################
FROM goluwa-core as goluwa-framework-mpg123

WORKDIR /goluwa
COPY framework ./framework

RUN ./goluwa build mpg123

##################################################################################
FROM goluwa-core as goluwa-framework-libsndfile

WORKDIR /goluwa
COPY framework ./framework

# https://github.com/libsndfile/libsndfile/blob/master/.github/workflows/action.yml
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN apt-get install -y autogen ninja-build libogg-dev libvorbis-dev libflac-dev libopus-dev libasound2-dev libsqlite3-dev libspeex-dev libmp3lame-dev libmpg123-dev cmake g++ python3
RUN ./goluwa build libsndfile

##################################################################################
FROM goluwa-core as goluwa-framework-openal

WORKDIR /goluwa
COPY framework ./framework

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# https://github.com/kcat/openal-soft/blob/master/.github/workflows/ci.yml
RUN apt-get install -y libpulse-dev portaudio19-dev libasound2-dev libjack-dev qtbase5-dev libdbus-1-dev cmake g++ 
RUN ./goluwa build openal

##################################################################################
FROM goluwa-core as goluwa-framework-sdl2

WORKDIR /goluwa
COPY framework ./framework

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

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

##################################################################################
FROM goluwa-core as goluwa-framework-vtflib

WORKDIR /goluwa
COPY framework ./framework

RUN apt-get install -y cmake g++
RUN ./goluwa build vtflib

##################################################################################
FROM goluwa-core as goluwa-framework

WORKDIR /goluwa
COPY framework ./framework

COPY --from=goluwa-framework-enet goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/
COPY --from=goluwa-framework-freeimage goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/
COPY --from=goluwa-framework-freetype goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/
COPY --from=goluwa-framework-libarchive goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/
COPY --from=goluwa-framework-mpg123 goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/
COPY --from=goluwa-framework-libsndfile goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/
COPY --from=goluwa-framework-openal goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/
COPY --from=goluwa-framework-sdl2 goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/
COPY --from=goluwa-framework-vtflib goluwa/framework/bin/linux_x64/ ./framework/bin/linux_x64/

RUN rm -rf storage/temp/

##################################################################################
FROM goluwa-framework as goluwa-engine

WORKDIR /goluwa

COPY engine ./engine

##################################################################################
FROM goluwa-engine as goluwa-game

WORKDIR /goluwa

COPY game ./game

##################################################################################
FROM ubuntu:21.10

WORKDIR /goluwa

COPY --from=goluwa-game /goluwa/core ./core
COPY --from=goluwa-game /goluwa/framework ./framework
COPY --from=goluwa-game /goluwa/engine ./engine
COPY --from=goluwa-game /goluwa/game ./game
COPY --from=goluwa-game /goluwa/storage ./storage
COPY --from=goluwa-game /goluwa/goluwa ./goluwa

RUN ./goluwa test