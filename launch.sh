#!/bin/bash
cd bin/linux/x64
export LD_LIBRARY_PATH=.
while true; do
	gdb --args ./luajit -e "PLATFORM='glw' dofile('../../../lua/init.lua')"
	if [ $? -ne 0 ]; then break; fi
	sleep 1
done
