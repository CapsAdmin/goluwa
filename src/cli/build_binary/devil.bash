#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/bcampbell/DevIL
cd DevIL/DevIL
mkdir build
cd build
cmake ..
make

mv src-IL/libDevIL.so ../../../../linux_x64/libIL.so
mv src-ILU/libILU.so ../../../../linux_x64/libILU.so
mv src-ILUT/libILUT.so ../../../../linux_x64/libILUT.so