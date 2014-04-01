mkdir temp
cd temp

git clean -d -x -f
git clone --depth=1 https://github.com/assimp/assimp.git

cd assimp
git rebase

cmake -D DUNICODE=TRUE -D BUILD_SHARED_LIBS=TRUE -D ASSIMP_BUILD_ASSIMP_TOOLS=FALSE -G "MinGW Makefiles" .
mingw32-make

xcopy assimp.dll ..\..\..\ /Y /C /R

pause