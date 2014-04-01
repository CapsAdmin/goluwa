mkdir temp
cd temp

git clone --depth=1 https://github.com/glfw/glfw.git

cd glfw
git clean -d -x -f
git rebase

cmake -D DUNICODE=TRUE -D BUILD_SHARED_LIBS=TRUE -G "MinGW Makefiles" .
mingw32-make

xcopy src\glfw3.dll ..\..\..\ /Y /C /R

pause