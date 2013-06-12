#!/bin/bash
cd bin/linux/x64
while true; do
	./luajit -e "PLATFORM='asdfml' dofile('../../../lua/init.lua')"
	if [ $? -ne 0 ]; then break; fi
	sleep 1
done
