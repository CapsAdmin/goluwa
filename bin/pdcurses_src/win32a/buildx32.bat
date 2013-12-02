mingw32-make -f mingwin32.mak DEBUG=N DLL=Y WIDE=Y UTF8=Y all
copy pdcurses.dll ../../windows/x86/pdcurses.dll
del *.o
del *.lik
del *.a
del *.def
del none
pause