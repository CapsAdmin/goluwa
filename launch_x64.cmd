cd %~dp0
cd bin/windows/x64/
mode con:cols=140 lines=100

start "" "luajit.exe" "-e PLATFORM='glw'PDCURSES='yes'ARGS={'%1','%2','%3','%3','%5','%6','%7','%8','%9'}dofile('../../../lua/init.lua')"
