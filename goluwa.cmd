@echo off & set GOLUWA_START_TIME="%time%" & PowerShell -nologo -noprofile -noninteractive Invoke-Expression ('$args=(''%*'').split('' '');'+'$PSScriptRoot=(''%~dp0'');$env:GOLUWA_CURRENT_DIRECTORY=(''%cd%'');'+((Get-Content -Raw %~dp0%~n0%~x0 ) -Replace '^.*goto :EOF')); & goto :EOF

$ROOT_DIR = $PSScriptRoot
$ROOT_DIR = $([System.IO.Path]::GetFullPath("$ROOT_DIR"))
$ROOT_DIR = $ROOT_DIR.substring(0, $ROOT_DIR.Length - 1)

if (((gwmi -Query "select osarchitecture from win32_operatingsystem").OSArchitecture) -Match "64") {
	$ARCH = "x64"
} else {
	$ARCH = "x86"
}

function Download($url, $location) {
	if(!(Test-Path "$location")) {
		Write-Host -NoNewline "'$url' >> '$location' ... "
		(New-Object System.Net.WebClient).DownloadFile($url, "$location")
		Write-Host "OK"
	}
}

New-Item -ItemType Directory -Force -Path "$ROOT_DIR\data\windows_$ARCH" | Out-Null
Set-Location "$ROOT_DIR\data\windows_$ARCH\"

Download "https://gitlab.com/CapsAdmin/goluwa-binaries-windows_$ARCH/raw/master/luajit.exe" "$ROOT_DIR\data\windows_$ARCH\luajit.exe"
Download "https://gitlab.com/CapsAdmin/goluwa-binaries-windows_$ARCH/raw/master/lua51.dll" "$ROOT_DIR\data\windows_$ARCH\lua51.dll"
Download "https://gitlab.com/CapsAdmin/goluwa-binaries-windows_$ARCH/raw/master/vcruntime140.dll" "$ROOT_DIR\data\windows_$ARCH\vcruntime140.dll"

if(!(Test-Path "$ROOT_DIR\core\lua\boot.lua" -PathType Leaf)) {
	New-Item -ItemType Directory -Force -Path "$ROOT_DIR\core\lua" | Out-Null
	Download "https://gitlab.com/CapsAdmin/goluwa/raw/master/core/lua/boot.lua" "$ROOT_DIR\core\lua\boot.lua"
}

.\luajit.exe "../../core/lua/boot.lua" $args
