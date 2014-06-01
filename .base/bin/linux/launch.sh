#!/bin/bash

has_command() {
	command -v $1 2>&1 >/dev/null
	return $?
}

get_arch() {
	case $(uname -m) in
		x86_64)  echo x64 ;;
		i[36]86) echo x86 ;;
		arm*)    echo arm ;;
		*)       echo unknown ;;
	esac
}

ARCH=$(get_arch)
cd $ARCH

export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
export LD_PRELOAD=libSegFault.so:$LD_PRELOAD
export TERM=xterm-color

while true; do
	./luajit ../../../lua/init.lua

	if [ $? -eq 0 ] || [ $? -ge 128 ]; then
		echo "IM OUTTA HERE"
		break
	fi

	sleep 1
done
