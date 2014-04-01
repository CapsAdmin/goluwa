mkdir temp
cd temp

git clone --depth=1 https://github.com/erikd/libsndfile.git

cd libsndfile
git clean -d -x -f
git rebase

mingw32-make

xcopy libsndfile.dll ..\..\..\..\ /Y /C /R

pause