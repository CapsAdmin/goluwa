mkdir temp
cd temp

git clone --depth=1 git://repo.or.cz/openal-soft.git

cd openal-soft
git clean -d -x -f
git rebase

cmake -D DUNICODE=TRUE -D BUILD_SHARED_LIBS=TRUE -G "MinGW Makefiles" .
mingw32-make

xcopy OpenAL32.dll ..\..\..\ /Y /C /R

pause