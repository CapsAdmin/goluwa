del *.o
del *.lik
del *.a
del *.def
del none

mingw32-make -f mingwin32.mak DEBUG=N DLL=Y WIDE=Y UTF8=Y all
pause