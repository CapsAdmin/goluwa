#!/bin/bash
ARCH=$(getconf LONG_BIT)

if [ $ARCH -eq "64" ]; then
	cd bin/linux/x64
else
	cd bin/linux/x86
fi

while true; do
	$(hash screen 2> /dev/null && echo "screen") env LD_LIBRARY_PATH=. ./luajit -e 'PLATFORM = "glw" dofile("../../../lua/init.lua")'
	if [ $? -eq 0 ]; then break; fi
	sleep 1
done
