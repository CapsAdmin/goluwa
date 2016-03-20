#!/bin/bash

ARCH=$(case $(uname -m) in x86_64) echo x64 ;;i[36]86) echo x86 ;; arm*) echo arm ;; esac)
ROOT_DIR=./../..
BUILD_DIR=$ROOT_DIR/data/bin/src
OUT_DIR=$ROOT_DIR/data/bin/linux_$ARCH

mkdir -p $BUILD_DIR
mkdir -p $OUT_DIR
mkdir -p $OUT_DIR/socket
mkdir -p $OUT_DIR/mime

git clone https://github.com/CapsAdmin/ffibuild $BUILD_DIR/ffibuild
git clone https://github.com/brunoos/luasec $BUILD_DIR/luasec
git clone https://github.com/diegonehab/luasocket $BUILD_DIR/luasocket

make -C $BUILD_DIR/ffibuild
make -C $BUILD_DIR/luasocket linux MYCFLAGS="-I$(realpath $BUILD_DIR/ffibuild/LuaJIT/src)" MYLDFLAGS="-l:libluajit.a -L$(realpath $BUILD_DIR/ffibuild/LuaJIT/src)"
make linux -C $BUILD_DIR/luasec INC_PATH="-I$(realpath $BUILD_DIR/ffibuild/LuaJIT/src)" LIB_PATH="-l:libluajit.a -L$(realpath $BUILD_DIR/ffibuild/LuaJIT/src)"

cp $BUILD_DIR/luasec/src/ssl.so $OUT_DIR/ssl.so
cp $BUILD_DIR/luasocket/src/socket*.so $OUT_DIR/socket/core.so
cp $BUILD_DIR/luasocket/src/mime*.so $OUT_DIR/mime/core.so

cp $BUILD_DIR/ffibuild/LuaJIT/src/luajit $OUT_DIR/.
for file in $BUILD_DIR/ffibuild/examples/*/*lib*.*; do cp ${file} $OUT_DIR/.; done