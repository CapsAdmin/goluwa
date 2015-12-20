#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone git://git.sv.nongnu.org/freetype/freetype2.git

cd freetype2
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS=ON
make

mv libfreetype.so.2.6.2 ../../../linux_x64/libfreetype.so
#for file in *; do
#    if [ ! -L $file && $file == *".so"* ]
#        echo $file
#    fi
#done