#!/bin/bash

#figure out the binary architecture to use and download
arch=unknown

case $(uname -m) in
	x86_64)  arch=x64 ;;
	i[36]86) arch=x86 ;;
	arm*)    arch=arm ;;
esac

# make sure we're in this bash's directory
cd $( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p ../data/bin
cd ../data/bin

#if we don't have binaries get them from github
if [ ! -f "linux_${arch}/luajit" ]; then
	wget "https://github.com/CapsAdmin/goluwa/releases/download/linux-binaries/${arch}.zip" -O temp.zip
	mkdir linux_${arch}
	unzip temp.zip -d linux_${arch}
	rm temp.zip
fi

cd ./linux_${arch}/

#lookup shared libraries in "goluwa/data/bin/linux_${arch}/" first
export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"

#i don't know if this is stupid or not but it's so i can execute luajt without
#the need for execute permissions on a non ext filesystem (like on a usb stick with fat32)
if [ -e "/lib64/ld-linux-x86-64.so.2" ]; then
	/lib64/ld-linux-x86-64.so.2 ./luajit ../../../src/lua/init.lua
else
	./luajit ../../../src/lua/init.lua
fi
