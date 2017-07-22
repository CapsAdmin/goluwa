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

if [ "$1" == "ide" ] || [ "$1" == "" ]; then
	if [ -d ./ide ]; then
		git -C ./ide pull;
	else
		git clone https://github.com/pkulchenko/ZeroBraneStudio.git ide --depth 1;
	fi

	cd ide
	./zbstudio.sh -cfg ../../src/lua/zerobrane/config.lua
fi

if [ "$1" == "launch"  ] || [ "$1" == "cli"  ]; then

	if [ "$1" == "cli"  ]; then
		export CLI=1
	fi

	export ARGS=${ARGS:=$*}

	LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libpulse.so.0
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

	executable="luajit$GOLUWA_BRANCH"


	if [ "$GOLUWA_BRANCH" == "_lua"  ]; then
		executable="lua"
	fi

	if [ ! -z "$GOLUWA_DEBUG" ]; then
		launch="x-terminal-emulator -e \"gdb -ex=r --args $executable"
		append="\""
	elif [ -x "$executable" ]; then
		launch="./$executable"
	elif [ -f "/lib64/ld-linux-x86-64.so.2" ]; then
		# i don't know if this is stupid or not
		# but it's so i can execute luajt without the need for execute permissions
		# on a non ext filesystem (like on a usb stick with fat32)
		launch="/lib64/ld-linux-x86-64.so.2 ./$executable"
	else
		echo "don't know how to launch, trying ./$executable"
		launch="./$executable"
	fi

	if [ ! -z "$GOLUWA_APITRACE" ]; then
		eval "apitrace trace --api gl $launch ../../../src/lua/init.lua$append"
	else
		eval "$launch ../../../src/lua/init.lua$append"
	fi
fi
