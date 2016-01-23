#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/brunoos/luasec
cd luasec
export INC_PATH=-I/usr/include/luajit-2.0/
make linux
mv src/ssl.so ../../linux_x64/ssl.so