#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

#autogen libflac-dev libogg-dev libvorbis-dev

git clone https://github.com/erikd/libsndfile
cd libsndfile
./autogen.sh
./configure
make

mv src/.libs/libsndfile.so.1.0.27 ../../linux_x64/libsndfile.so