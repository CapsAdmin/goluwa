#!/bin/bash
cd bin/linux/x64
./luajit -e "PLATFORM='asdfml' CLIENT=true dofile('../../../lua/init.lua')"
