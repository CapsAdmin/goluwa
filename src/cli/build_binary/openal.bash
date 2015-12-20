#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/kcat/openal-soft.git
cd openal-soft
mkdir build
cd build
cmake ..
make

mv libopenal.so.1.17.1 ../../../linux_x64/libopenal.so

