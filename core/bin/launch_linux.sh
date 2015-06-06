#!/bin/bash

#figure out the binary architecture to use and download
arch=unknown

case $(uname -m) in
	x86_64)  arch=x64 ;;
	i[36]86) arch=x86 ;;
	arm*)    arch=arm ;;
esac

#if we don't have binaries get them from github
if [ ! -f "linux_${arch}/luajit" ]; then
	wget "https://github.com/CapsAdmin/goluwa/releases/download/linux-binaries/${arch}.zip" -O temp.zip
	mkdir linux_${arch}
	unzip temp.zip -d linux_${arch}
	rm temp.zip
fi

cd ./linux_${arch}/

#lookup shared libraries in "goluwa/core/bin/linux_${arch}/" first
export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"

./luajit ../../lua/init.lua
