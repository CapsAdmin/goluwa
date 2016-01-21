#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

url=${1:-http://freeimage.cvs.sourceforge.net/viewvc/freeimage/?view=tar}

echo "downloading $url"

rm -r freeimage

wget -qO- -O freeimage.tar.gz $url && unzip freeimage.tar.gz -d luajit/ && rm freeimage.tar.gz

tar xvzf freeimage.tar.gz
cd freeimage/FreeImage
make
mv libfreeimage-3.18.0.so ../../../linux_x64/libfreeimage.so