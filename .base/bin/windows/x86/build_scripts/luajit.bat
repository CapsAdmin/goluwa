mkdir temp
cd temp

git clone -b v2.1 http://luajit.org/git/luajit-2.0.git 

cd luajit-2.0
git clean -d -x -f
git rebase

cd src
mingw32-make

xcopy lua51.dll ..\..\..\..\ /Y /C /R
xcopy luajit.exe ..\..\..\..\ /Y /C /R

mkdir ..\..\..\..\jit
xcopy jit ..\..\..\..\jit /Y /C /R

pause