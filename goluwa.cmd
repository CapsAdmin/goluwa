@echo off
SetLocal EnableDelayedExpansion

(set | find "ProgramFiles(x86)" > NUL) && (echo "!ProgramFiles(x86)!" | find "x86") > NUL && set ARCH=x64|| set ARCH=x86
set OS=windows
set APP_NAME=appexample
set ARG_LINE=%*
set STORAGE_PATH=storage
set BINARY_DIR=!STORAGE_PATH!\bin\!OS!_!ARCH!
set BINARY_NAME=luajit.exe
set BASE_BINARY_URL=https://gitlab.com/CapsAdmin/goluwa-binaries-!OS!_!ARCH!/raw/master/
set BASE_SCRIPT_URL=https://gitlab.com/CapsAdmin/goluwa/raw/master/
set SCRIPT_PATH=core/lua/boot.lua

IF %0 == "%~0" set RAN_FROM_FILEBROWSER=1
if defined VSCODE_CWD (
	set RAN_FROM_FILEBROWSER=0
)

:Start
call:Main
goto:eof

:Main
SetLocal
	if not exist "!BINARY_DIR!" ( mkdir "!BINARY_DIR!" )
	if not exist "core" ( mkdir "core" )
	if not exist "core\lua" ( mkdir "core\lua" )

	if not exist "!BINARY_DIR!\lua_downloaded_and_validated" (
		call:DownloadFile "!BASE_BINARY_URL!lua51.dll" "!BINARY_DIR!\lua51.dll"
		call:DownloadFile "!BASE_BINARY_URL!vcruntime140.dll" "!BINARY_DIR!\vcruntime140.dll"
	)

	if not exist "!BINARY_DIR!\!BINARY_NAME!" (
        call:GetLua "!BASE_BINARY_URL!!BINARY_NAME!" "!BINARY_DIR!" "!BINARY_NAME!"
    )

	if not exist "!SCRIPT_PATH!" (
        call:DownloadFile "!BASE_SCRIPT_URL!!SCRIPT_PATH!" "!SCRIPT_PATH!"
    )

	set GOLUWA_STORAGE_PATH=!STORAGE_PATH!
	set GOLUWA_ARG_LINE="!ARG_LINE!"
	set GOLUWA_SCRIPT_PATH=!SCRIPT_PATH!
	set GOLUWA_RAN_FROM_FILEBROWSER=!RAN_FROM_FILEBROWSER!
	set GOLUWA_BINARY_DIR=!BINARY_DIR!

	set "cmd_line=!BINARY_DIR!\!BINARY_NAME! !SCRIPT_PATH!"

	IF !RAN_FROM_FILEBROWSER! equ 1 (
		set "GOLUWA_ARG_LINE=--verbose"
		!cmd_line!
		set err=%errorlevel%
	) else (
		!cmd_line!
		set err=%errorlevel%
	)

	if !err! neq 0 (
		pause
	)

EndLocal
goto:eof

:GetLua
SetLocal
	set url=%~1
	set directory=%~2
	set filename=%~3
	set abs_path=%~2\%~3

	if not exist "!directory!\lua_downloaded_and_validated" (
		call:DownloadFile "!url!" "!abs_path!"

		!abs_path! -e "os.exit(1)"

		if !errorlevel! neq 1 (
			call:AlertBox "exit code from lua does not match 'os.exit(1)'" "error"
			del !abs_path!

			pause

			EndLocal
			goto Start
		)

		echo. 2>!directory!\lua_downloaded_and_validated
	)
EndLocal
goto:eof

:DownloadFile
SetLocal
	set url=%~1
	set output_path=%~2

	if not exist !SystemRoot!\System32\where.exe (
		set tmp_name=!TEMP!\lua_one_click_jscript_download.js
		del /F !tmp_name! 2>NUL
		echo //test > !tmp_name!

		if not exist !tmp_name! (
			call:AlertBox "unable to create temp file !tmp_name! !" "error"
			exit /b
		)

		set forward_slash_path=!output_path:\=/!

		echo try { >> !tmp_name!
		echo var req = new ActiveXObject^("Microsoft.XMLHTTP"^) >> !tmp_name!
		echo req.Open^("GET","!url!",false^) >> !tmp_name!
		echo req.Send^(^) >> !tmp_name!

		echo var stream = new ActiveXObject^("ADODB.Stream"^) >> !tmp_name!
		echo stream.Type = 1 >> !tmp_name!
		echo stream.Open^(^) >> !tmp_name!
		echo stream.Write^(req.responseBody^) >> !tmp_name!
		echo stream.SaveToFile^("!forward_slash_path!", 2^) >> !tmp_name!
		echo stream.Close^(^) >> !tmp_name!
		echo } catch^(err^) { >> !tmp_name!
		echo 	WScript.Echo^("jscript error: "+err.message^) >> !tmp_name!
		echo 	WScript.Quit^(1^) >> !tmp_name!
		echo } >> !tmp_name!

		cscript /Nologo /E:JScript !tmp_name!

		if !errorlevel! neq 0 (
			call:AlertBox "failed to execute JScript to download file" "error"
			goto:eof
		)

		del /F !tmp_name! 2>NUL

	) else (
		where curl
		if !errorlevel! equ 0 (
			curl -L --url "!url!" --output "!output_path!"

			if !errorlevel! neq 0 (
				call:AlertBox "curl failed to execute with error code !errorlevel!" "error"
			)

			goto:eof
		) else (
			where powershell
			if !errorlevel! equ 0 (
				PowerShell -NoLogo -NoProfile -NonInteractive "(New-Object System.Net.WebClient).DownloadFile('!url!','!output_path!')"

				if !errorlevel! neq 0 (
					call:AlertBox "powershell failed to execute with error code !errorlevel!" "error"
				)

				goto:eof
			)
		)

		call:AlertBox "unable to find curl or powershell"
		exit /b
	)
EndLocal
goto:eof

:AlertBox
SetLocal
	set msg=%~1
	set title=%~2

	IF !RAN_FROM_FILEBROWSER! equ 1 (
		set tmp_name=!TEMP!\lua_one_click_jscript_msgbox.vbs
		del /F !tmp_name! 2>NUL
		echo ' test > !tmp_name!

		if not exist !tmp_name! (
			echo "unable to create temp file !tmp_name! for message box !"
			echo !title!: !msg!
			goto:eof
		)

		set forward_slash_path=!output_path:\=/!

		echo MsgBox "!msg!", vbOKOnly, "!title!" >> !tmp_name!

		cscript /Nologo !tmp_name!

		if !errorlevel! neq 0 (
			echo "Failed to execute vbscript for message box"
			echo !title!: !msg!
		)

		del /F !tmp_name! 2>NUL
	) else (
		echo !title!: !msg!
	)

EndLocal
goto:eof
