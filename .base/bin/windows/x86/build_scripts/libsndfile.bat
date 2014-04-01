mkdir temp
cd temp

git clean -d -x -f
git clone --depth=1 https://github.com/erikd/libsndfile.git

cd luajit-2.0
git rebase

mingw32-make

xcopy libsndfile.dll ..\..\..\..\ /Y /C /R

pause