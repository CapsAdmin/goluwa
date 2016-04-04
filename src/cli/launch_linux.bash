#!/bin/bash

#figure out the binary architecture to use and download
arch=unknown

case $(uname -m) in
	x86_64)  arch=x64 ;;
	i[36]86) arch=x86 ;;
	arm*)    arch=arm ;;
esac

# make sure we're in this bash's directory
cd "$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p ../../data/bin

if [ -z "$EDITOR" ]; then
	cd ../../data/bin
else
	cd ../../data/

	if [ -d ./editor ]; then
		git -C ./editor pull;
	else
		git clone https://github.com/pkulchenko/ZeroBraneStudio.git editor --depth 1;
	fi

	cd bin
fi

#if we don't have binaries get them from github
if [ ! -f "linux_${arch}/luajit" ]; then
	wget "https://github.com/CapsAdmin/goluwa/releases/download/linux-binaries/${arch}.zip" -O temp.zip
	mkdir linux_${arch}
	unzip temp.zip -d linux_${arch}
	rm temp.zip
fi

if [ -z "$EDITOR" ]; then
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
else
	cd ../editor/
	./zbstudio.sh -cfg ../../src/lua/editor/config.lua
fi