cd bin/windows/x86/
mode con:cols=140 lines=50
luajit.exe -e PLATFORM='asdfml'CLIENT=true;dofile('../../../lua/init.lua')
pause