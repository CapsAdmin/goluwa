#!/bin/bash

# make sure we're in this bash's directory
cd "$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit
mkdir -p ../../data/bin
cd ../../data/

case $(uname -m) in
	x86_64)
		ARCH=x64
	;;
	i[36]86)
		ARCH=x86
	;;
	arm*)
		ARCH=arm
	;;
esac

case $(uname) in
	Darwin)
		OS=osx
	;;
	*)
		OS=linux
	;;
esac

if [ "$1" == "ide" ]; then
	if [ -d ./ide ]; then
		git -C ./ide pull;
	else
		git clone https://github.com/pkulchenko/ZeroBraneStudio.git ide --depth 1;
	fi

	cd ide
	./zbstudio.sh -cfg ../../src/lua/zerobrane/config.lua
fi

if [ "$1" == "launch"  ] || [ "$1" == "" ]; then

	#if we don't have binaries get them from github
	if [ ! -f "bin/${OS}_${ARCH}/luajit" ]; then
		mkdir -p "bin/${OS}_${ARCH}"
		echo "https://github.com/CapsAdmin/goluwa/releases/download/${OS}-binaries/${ARCH}.zip"
		curl -L --url "https://github.com/CapsAdmin/goluwa/releases/download/${OS}-binaries/${ARCH}.zip" --output "temp.zip"
		unzip temp.zip -d "bin/${OS}_${ARCH}"
		rm temp.zip
	fi

	cd "bin/${OS}_${ARCH}/" || exit

	#lookup shared libraries in "goluwa/data/bin/linux_${ARCH}/" first
	export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"

	if [ ! -z "$DEBUG" ]; then
		launch="gdb -ex=r --args luajit"
	elif [ -x "luajit" ]; then
		launch="./luajit"
	elif [ -f "/lib64/ld-linux-x86-64.so.2" ]; then
		# i don't know if this is stupid or not
		# but it's so i can execute luajt without the need for execute permissions
		# on a non ext filesystem (like on a usb stick with fat32)
		launch="/lib64/ld-linux-x86-64.so.2 ./luajit"
	else
		echo "don't know how to launch, trying ./luajit"
		launch="./luajit"
	fi

	eval "$launch $2 ../../../src/lua/init.lua"
fi
