#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/assimp/assimp
cd assimp
cmake .
make
mv lib/libassimp.so.3.2.0 ../../linux_x64/libassimp.so