FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

RUN apt-get update 
RUN apt-get install wget tmux lib32gcc-s1 lib32stdc++6 -y

COPY core /app/core
COPY framework /app/framework
COPY engine /app/engine
COPY game /app/game
COPY gserv /app/gserv

COPY goluwa /app/goluwa

RUN touch /app/core/bin/linux_x64/keep_local_binaries
RUN touch /app/framework/bin/linux_x64/keep_local_binaries

WORKDIR /app

ENTRYPOINT [ "./goluwa" ]

