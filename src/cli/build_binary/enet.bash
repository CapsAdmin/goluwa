#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/lsalzman/enet
cd enet
autoreconf -vfi
./configure
make

mv .libs/libenet.so.7.0.1 ../../linux_x64/libenet.so