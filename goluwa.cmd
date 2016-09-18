@ECHO OFF
SET IDE=1
PowerShell.exe -ExecutionPolicy Bypass -Command "& '%~dp0src\cli\windows.ps1'"
