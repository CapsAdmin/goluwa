cd %~dp0
ECHO %PROCESSOR_ARCHITECTURE%|FINDSTR AMD64>NUL && SET ARCH=x64|| SET ARCH=x86
cd bin/windows/%arch%/
start "" "luajit.exe" "-e PLATFORM='glw'ARGS={'%1','%2','%3','%3','%5','%6','%7','%8','%9'}dofile('../../../lua/init.lua')"
