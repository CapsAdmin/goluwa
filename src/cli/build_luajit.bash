#!/bin/bash
 
read -e -p "git url: " -i "https://github.com/corsix/LuaJIT" LUA_URL
read -e -p "branch: " -i "x64" LUA_BRANCH
read -e -p "flags: " -i "XCFLAGS+=-DLUAJIT_ENABLE_GC64 XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT XCFLAGS+=-DLUAJIT_USE_GDBJIT CCDEBUG=-g" LUA_FLAGS

arch=unknown

case $(uname -m) in
	x86_64)  arch=x64 ;;
	i[36]86) arch=x86 ;;
	arm*)    arch=arm ;;
esac

cd ../../data/bin/linux_${arch}/

echo "$LUA_URL : $LUA_BRANCH"


git clone $LUA_URL luajit_src
cd luajit_src 
git checkout $LUA_BRANCH
export CFLAGS=-fPIC 
make clean
make $LUA_FLAGS
yes | cp src/luajit ../luajit