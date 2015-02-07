@ECHO OFF
SET CLIENT=1
SET SERVER=0
PowerShell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command "& '%~dp0.base\bin\launch_windows.ps1'"