@setlocal enableextensions
@cd /d "%~dp0"

cd %~dp0premake

premake4 vs2010
premake4 vs2012

pause
	
exit /b 0
