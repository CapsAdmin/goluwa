#!/bin/sh

if [ "$1" = "build" ]; then
    git clone https://github.com/PAC3-Server/gserv
    
    ./goluwa build luajit
    ./goluwa build libressl
    ./goluwa build openal
    ./goluwa build libsndfile

    docker build -t goluwa-srcds -f run.dockerfile .
    
    exit 0
fi

docker run --mount type=bind,source="$(pwd)"/storage/,target=/app/storage -it -t goluwa-srcds