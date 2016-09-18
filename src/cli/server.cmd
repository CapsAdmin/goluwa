@ECHO OFF
SET GRAPHICS=0
SET CLIENT=0
SET SERVER=1
SET ARGS={'host'}
PowerShell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command "& '%~dp0launch_windows.ps1'"
pause
