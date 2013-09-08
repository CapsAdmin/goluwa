cd %~dp0
cd bin/windows/x86/
mode con:cols=140 lines=100

:LOL:
luajit.exe -e PLATFORM='glw'ARGS={'%1','%2','%3','%3','%5','%6','%7','%8','%9'}dofile('../../../lua/init.lua')
pause
goto LOL