#!/bin/bash

if %OS% == Windows_NT goto WINDOWS
then
:
## Hack to make a cross-OS compatible script
fi 2> /dev/null

# ------------------------------------------------------------------------------
# Unix execution
# ------------------------------------------------------------------------------

ARCH=$(getconf LONG_BIT)

if [ $ARCH -eq "64" ]; then
	cd .base/bin/linux/x64
else
	cd .base/bin/linux/x86
fi

while true; do
	$(hash screen 2> /dev/null && echo "screen") env LD_LIBRARY_PATH=. ./luajit ../../../lua/init.lua
	# BROKE (when using screen) ==> if [ $? -eq 0 ] || [ $? -ge 128 ]; then echo "im outta here"; break; fi
	sleep 1
done

# ------------------------------------------------------------------------------
# Windows execution
# ------------------------------------------------------------------------------

:WINDOWS

cd %~dp0
ECHO %PROCESSOR_ARCHITECTURE%|FINDSTR AMD64>NUL && SET ARCH=x64|| SET ARCH=x86

findstr /m "NVIDIA" .userdata\%USERNAME%\info\gpu_vendor
if %errorlevel%==0 (
	SET ARCH=x86
)

cd .base/bin/windows/%arch%/
start luajit.exe ../../../lua/init.lua