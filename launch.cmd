cd bin/windows/x86/
mode con:cols=140 lines=50

:LOL:
luajit.exe -e PLATFORM='glw'dofile('../../../lua/init.lua')
pause
goto LOL