#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/diegonehab/luasocket
cd luasocket
make MYCFLAGS=$(pkg-config --cflags luajit) MYLDFLAGS=$(pkg-config --libs luajit)

mkdir ../../linux_x64/socket
mkdir ../../linux_x64/mime
mv src/socket-3.0-rc1.so ../../linux_x64/socket/core.so
mv src/mime-1.0.3.so ../../linux_x64/mime/core.so