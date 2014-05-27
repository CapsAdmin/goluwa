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

tmuxify() {
	local NAME=$1
	shift
	tmux attach-session -t $NAME || tmux new-session -s $NAME "$@"
}

cd .base/bin/linux/$ARCH

ENVIRONMENT="
	DISPLAY=$DISPLAY
	HOME=$HOME
	LD_LIBRARY_PATH=$PWD
	LD_PRELOAD=libSegFault.so
	PATH=$PWD
	TERM=$TERM
	USER=$USER
"

while true; do
	env - $ENVIRONMENT ./luajit ../../../lua/init.lua

	if [ $? -eq 0 ] || [ $? -ge 128 ]; then
		echo "IM OUTTA HERE"
		break
	fi

	sleep 1
done
