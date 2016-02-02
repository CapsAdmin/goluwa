#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/brunoos/luasec
cd luasec
make linux INC_PATH=$(pkg-config --cflags luajit) LIB_PATH=$(pkg-config --libs luajit)
mv src/ssl.so ../../linux_x64/ssl.so