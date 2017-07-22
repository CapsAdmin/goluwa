@ECHO OFF
SET GOLUWA_CLIENT=0
SET GOLUWA_SERVER=1
SET ARGS={'host'}
PowerShell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0windows.ps1" launch
