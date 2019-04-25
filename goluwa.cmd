@echo off & set GOLUWA_START_TIME="%time%" & PowerShell -nologo -noprofile -noninteractive Invoke-Expression ('$args=(''%*'').split('' '');'+'$PSScriptRoot=(''%~dp0'');$env:GOLUWA_WORKING_DIRECTORY=(''%cd%'');'+((Get-Content -Raw %~dp0%~n0%~x0 ) -Replace '^.*goto :EOF')); & goto :EOF

if (((gwmi -Query "select osarchitecture from win32_operatingsystem").OSArchitecture) -Match "64") {
	$ARCH = "x64"
} else {
	$ARCH = "x86"
}

$BINARIES_LOCATION = "https://gitlab.com/CapsAdmin/goluwa-binaries-windows_$ARCH/raw/master"

function Download($url, $location) {
	$path = "$(Get-Location)\$location"
	if(!(Test-Path "$path")) {
		Write-Host -NoNewline "'$url' >> '$path' ... "
		(New-Object System.Net.WebClient).DownloadFile($url, "$path")
		Write-Host "OK"
	}
}

$ROOT_DIR = $([System.IO.Path]::GetFullPath("$PSScriptRoot"))
$ROOT_DIR = $ROOT_DIR.substring(0, $ROOT_DIR.Length - 1)
Set-Location "$ROOT_DIR"

New-Item -ItemType Directory -Force -Path "data\windows_$ARCH" | Out-Null
Set-Location "data\windows_$ARCH\"
Download "$BINARIES_LOCATION/luajit.exe" "luajit.exe"
Download "$BINARIES_LOCATION/lua51.dll" "lua51.dll"
Download "$BINARIES_LOCATION/vcruntime140.dll" "vcruntime140.dll"

New-Item -ItemType Directory -Force -Path "..\..\core\lua" | Out-Null
Download "https://gitlab.com/CapsAdmin/goluwa/raw/master/core/lua/boot.lua" "..\..\core\lua\boot.lua"

.\luajit.exe "../../core/lua/boot.lua" $args
