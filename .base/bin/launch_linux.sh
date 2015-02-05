#!/bin/bash

timestamp() {
	date +"%T"
}

log() {
	local level=$1
	local format=$2
	shift 2

	local prefix="\033[1;36m[INFO]"

	case ${level} in
		w) prefix="\033[1;33m[WARN]" ;;
		e) prefix="\033[1;31m[EROR]" ;;
		c) prefix="\033[1;4;5;31m[CRIT]" ;;
	esac

	printf "[$(timestamp)] ${prefix}\033[0m ${format}\n" "${@}"
}

die() {
	log c "${@}"
	exit 1
}

get_arch() {
	local arch=unknown

	case $(uname -m) in
		x86_64)  arch=x64 ;;
		i[36]86) arch=x86 ;;
		arm*)    arch=arm ;;
	esac

	echo "${arch}"
}

log i "You should %s that kind of talk in the %s." bud nip
log w "Watch it will ya?"
log e "We're done for!"

ARCH=$(get_arch)
cd $ARCH 2>/dev/null || die "CPU architecture '%s' not supported" ${ARCH}

export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"
export LD_PRELOAD="libSegFault.so:$LD_PRELOAD"
export TERM="xterm-color"

while true; do
	./luajit ../../lua/init.lua

	if [ $? -eq 0 ] || [ $? -ge 128 ]; then
		log i "I'm outta here!"
		break
	fi

	log error "Program returned %d" $?

	sleep 1
done
