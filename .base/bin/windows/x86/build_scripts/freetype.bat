mkdir temp
cd temp

git clone http://git.savannah.gnu.org/cgit/freetype/freetype2.git 

cd freetype2
git clean -d -x -f
git rebase

mingw32-make
mingw32-make

xcopy freetype.dll ..\..\..\..\ /Y /C /R

pause