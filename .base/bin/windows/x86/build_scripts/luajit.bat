mkdir temp
cd temp

git clean -d -x -f
git clone --depth=1 -b master http://luajit.org/git/luajit-2.0.git 

cd luajit-2.0
git rebase

cd src
mingw32-make

xcopy lua51.dll ..\..\..\..\ /Y /C /R
xcopy luajit.exe ..\..\..\..\ /Y /C /R

pause