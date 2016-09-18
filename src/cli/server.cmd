@ECHO OFF
SET GRAPHICS=0
SET CLIENT=0
SET SERVER=1
SET ARGS={'host'}
PowerShell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0windows.ps1" launch