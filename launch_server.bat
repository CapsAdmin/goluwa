@ECHO OFF
SET CLIENT=0
SET SERVER=1
SET ARGS={'host','open steam/friends'}
PowerShell.exe -ExecutionPolicy Bypass -Command "& '%~dp0.base\bin\launch_windows.ps1'"