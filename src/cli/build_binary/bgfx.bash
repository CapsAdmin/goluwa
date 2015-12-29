#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

mkdir bgfx
cd bgfx

git clone https://github.com/bkaradzic/bgfx
git clone https://github.com/bkaradzic/bx

cd bx
make config=release64
cd ../bgfx
make config=release64

cd .build/projects/gmake-linux/
make config=release64
mv ../../linux64_gcc/bin/libbgfx-shared-libRelease.so ../../../../../../linux_x64/libbgfx.so