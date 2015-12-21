#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/libarchive/libarchive
cd libarchive

cmake .

mv libarchive/libarchive.so.14 ../../../linux_x64/libarchive.so