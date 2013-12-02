mingw32-make -f mingwin32.mak DEBUG=N DLL=Y WIDE=Y UTF8=Y all
copy pdcurses.dll ..\..\windows\x64
del *.o
del *.lik
del *.a
del *.def
del none
del *.exe
pause