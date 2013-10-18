cd %~dp0
cd bin/windows/x86/
start "" "luajit.exe" "-e PLATFORM='glw'ARGS={'%1','%2','%3','%3','%5','%6','%7','%8','%9'}dofile('../../../lua/init.lua')"
