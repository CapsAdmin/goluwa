#!/bin/bash
pushd bin/linux/x64
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
while true; do
	./luajit -e "PLATFORM='glw'dofile('../../../lua/init.lua')"
	if [ $? -eq 0 ]; then break; fi
	sleep 1
done
popd
