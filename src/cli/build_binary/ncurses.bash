#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

url=${1:-http://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz}

echo "downloading $url"

rm -r ncurses

wget -qO- -O ncurses.tar.gz $url
tar -zxvf ncurses.tar.gz
rm ncurses.tar.gz

cd ncurses-6.0
./configure --with-shared --without-normal --without-debug
make

mv lib/libncurses.so.6.0 ../../linux_x64/libncurses.so