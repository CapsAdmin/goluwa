#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

svn checkout svn://svn.code.sf.net/p/opende/code/trunk opende-code
cd opende-code

./bootstrap
./configure --enable-shared
make

mv src/.libs/libode.so.3.1.0 ../../../linux_x64/libode.so