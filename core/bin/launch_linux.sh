#!/bin/bash

get_arch() {
	local arch=unknown

	case $(uname -m) in
		x86_64)  arch=x64 ;;
		i[36]86) arch=x86 ;;
		arm*)    arch=arm ;;
	esac

	echo "${arch}"
}

ARCH=$(get_arch)

download() {
	if [ ! -f "linux_${ARCH}/luajit" ]; then
		wget "https://github.com/CapsAdmin/goluwa/releases/download/linux-binaries/${ARCH}.zip" -O temp.zip
		mkdir linux_${ARCH}
		unzip temp.zip -d linux_${ARCH}
		rm temp.zip
	fi
}

download

cd ./linux_${ARCH}/

export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"

/lib64/ld-linux-x86-64.so.2 ./luajit "../../lua/init.lua"
