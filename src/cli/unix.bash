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

if [ "$1" == "build" ]; then
	ROOT_DIR=./../..
	BUILD_DIR=$ROOT_DIR/data/bin/src
	OUT_DIR=$ROOT_DIR/data/bin/$OS_$ARCH

	mkdir -p "$BUILD_DIR"

	mkdir -p "$OUT_DIR"
	git clone https://github.com/CapsAdmin/ffibuild $BUILD_DIR/ffibuild --depth 1
	make -C $BUILD_DIR/ffibuild

	cp "$BUILD_DIR/ffibuild/LuaJIT/src/luajit" "$OUT_DIR/."
	yes | cp src/luajit ../luajit
	yes | cp "$BUILD_DIR/ffibuild/LuaJIT/src/jit/*" "$OUT_DIR/jit/"
	for file in $BUILD_DIR/ffibuild/examples/*/*lib*.*; do
		cp "${file}" "$OUT_DIR/.";
	done

	mkdir -p "$OUT_DIR/socket"
	mkdir -p "$OUT_DIR/mime"

	git clone https://github.com/diegonehab/luasocket $BUILD_DIR/luasocket --depth 1
	git clone https://github.com/brunoos/luasec $BUILD_DIR/luasec --depth 1

	if ["$OS" == "osx"]; then
		target=macosx
	else
		target=$OS
	fi

	make $target -C $BUILD_DIR/luasocket MYCFLAGS="-I$(realpath $BUILD_DIR/ffibuild/LuaJIT/src)" MYLDFLAGS="-l:libluajit.a -L$(realpath $BUILD_DIR/ffibuild/LuaJIT/src)"
	make $target -C $BUILD_DIR/luasec INC_PATH="-I$(realpath $BUILD_DIR/ffibuild/LuaJIT/src)" LIB_PATH="-l:libluajit.a -L$(realpath $BUILD_DIR/ffibuild/LuaJIT/src)"

	cp "$BUILD_DIR/luasec/src/ssl.so" "$OUT_DIR/ssl.so"
	cp "$BUILD_DIR/luasocket/src/socket*.so" "$OUT_DIR/socket/core.so"
	cp "$BUILD_DIR/luasocket/src/mime*.so" "$OUT_DIR/mime/core.so"
fi

if [ "$1" == "launch"  ] || [ "$1" == "" ]; then

	#if we don't have binaries get them from github
	if [ ! -f "bin/${OS}_${ARCH}/luajit" ]; then
		curl "https://github.com/CapsAdmin/goluwa/releases/download/${OS}-binaries/${ARCH}.zip" -O "temp.zip"
		mkdir "bin/${OS}_${ARCH}"
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
