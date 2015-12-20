#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

url=${1:-https://github.com/LuaJIT/LuaJIT/archive/v2.1.zip}

echo "downloading $url"

rm -r luajit

wget -qO- -O luajit.zip $url && unzip luajit.zip -d luajit/ && rm luajit.zip

if [ "$(ls luajit/ | wc -l)" == 1 ]; then
  subdir="$(ls luajit/)"
  mv luajit/$subdir/* luajit/
  rm -r luajit/$subdir
fi

cp Makefile_debug luajit/src/Makefile

cd luajit

make CFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT=1
mv src/luajit ../../luajit
rm -r ../../jit
mv src/jit/ ../../jit/
