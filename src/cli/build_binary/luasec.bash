#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/brunoos/luasec
cd luasec
export LUAPATH=/usr/include/luajit-2.0/
make linux