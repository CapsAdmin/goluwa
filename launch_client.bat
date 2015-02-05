cd %~dp0
ECHO %PROCESSOR_ARCHITECTURE%|FINDSTR AMD64>NUL && SET ARCH=x64|| SET ARCH=x86

SET CLIENT=1
SET SERVER=0

cd .base/bin/windows_%arch%/
start luajit ../../lua/init.lua %*