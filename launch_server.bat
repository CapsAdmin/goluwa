cd %~dp0
ECHO %PROCESSOR_ARCHITECTURE%|FINDSTR AMD64>NUL && SET ARCH=x64|| SET ARCH=x86

SET CLIENT=0
SET SERVER=1
SET ARGS={'host','open steam/friends'}

cd .base/bin/windows_%ARCH%/
start luajit ../../lua/init.lua %*