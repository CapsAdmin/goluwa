#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

hg clone http://hg.libsdl.org/SDL
cd SDL
mkdir build
cd build
../configure
make

mv build/.libs/libSDL2-2.0.so.0.4.0 ../../../linux_x64/libSDL2.so