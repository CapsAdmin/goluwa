cd %~dp0
ECHO %PROCESSOR_ARCHITECTURE%|FINDSTR AMD64>NUL && SET ARCH=x64|| SET ARCH=x86


SET SERVER=1
SET ARGS={'host','open steam/steam_friends'}

cd .base/bin/windows/%ARCH%/
start luajit ../../../lua/init.lua