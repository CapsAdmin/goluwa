#!/bin/bash

cd bin/linux/x64
export LD_LIBRARY_PATH=.

while true; do
	./luajit -e "PLATFORM='glw'dofile('../../../lua/init.lua')"
	[ $? -ne 0 ] && break
	sleep 1
done
