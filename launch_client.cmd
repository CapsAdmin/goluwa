cd %~dp0
ECHO %PROCESSOR_ARCHITECTURE%|FINDSTR AMD64>NUL && SET ARCH=x64|| SET ARCH=x86
cd bin/windows/%arch%/
start "" "luajit.exe" "-e PLATFORM='glw'CLIENT=true;dofile('../../../lua/init.lua')"