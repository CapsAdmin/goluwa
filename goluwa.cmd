@echo OFF & PowerShell Invoke-Expression ('$args=(''%*'').split('' '');'+'$PSScriptRoot=(''%~dp0'');'+((Get-Content -Raw %~dp0%~n0%~x0 ) -Replace '^.*goto :EOF')); & goto :EOF

$ROOT_DIR = $PSScriptRoot
$ROOT_DIR = $([System.IO.Path]::GetFullPath("$ROOT_DIR"))
$ROOT_DIR = $ROOT_DIR.substring(0, $ROOT_DIR.Length - 1)

if (((gwmi -Query "select osarchitecture from win32_operatingsystem").OSArchitecture) -Match "64") {
	$ARCH = "x64"
} else {
	$ARCH = "x86"
}

$ide_url = "https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
$bin_url = "https://github.com/CapsAdmin/goluwa/releases/download/windows-binaries/$ARCH.zip"

function Remove($path) {
	if(Test-Path "$path" -PathType Container) {
		Write-Host -NoNewline "removing directory: '$path' ... "
		Get-ChildItem -Path "$path\\*" -Recurse -Force | Remove-Item -Force -Recurse
		Remove-Item $path -Recurse -Force
		Write-Host "OK"
	} elseif(Test-Path "$path" -PathType Leaf) {
		Write-Host -NoNewline "removing file: '$path' ... "
		Remove-Item -Force "$path"
		Write-Host "OK"
	} else {
		Write-Host "could not find: $path"
	}
}

function Download($url, $location) {
	if(!(Test-Path "$location")) {
		Write-Host -NoNewline "'$url' >> '$location' ... "
		#if (Get-Module -ListAvailable -Name BitsTransfer) {
		#	Import-Module BitsTransfer
		#	Start-BitsTransfer -Source $url -Destination $location
		#} else {
			(New-Object System.Net.WebClient).DownloadFile($url, "$location")
		#}
		Write-Host "OK"
	} else {
		Write-Host "'$location' already exists"
	}
}

function Extract($file, $location, $move_files) {
	Write-Host -NoNewline "$file >> '$location' ... "

	$shell = New-Object -Com Shell.Application

	$zip = $shell.NameSpace($([System.IO.Path]::GetFullPath("$file")))

	if (!$zip) {
		Write-Error "could not extract $file!"
	}

	if (!(Test-Path $location)) {
		New-Item -ItemType directory -Path $location | Out-Null
	}

	foreach($item in $zip.items()) {
		$shell.Namespace("$location").CopyHere($item, 0x14)
	}

	if ($move_files)
	{
		Move-Item -Confirm:$false -Force -Path "$location\*\*" -Destination "$location"
	}

	Write-Host "OK"
}

if (!(Test-Path "$ROOT_DIR\core") -Or $args[0] -Eq "update")
{
	if (Get-Command git -errorAction SilentlyContinue)
	{
		if (Test-Path "$ROOT_DIR\.git")
		{
			git pull;
		}
		else
		{
			git clone https://github.com/CapsAdmin/goluwa --depth 1
			Copy-Item -Confirm:$false -Recurse -Force -Path "$ROOT_DIR\goluwa\*" -Destination "$ROOT_DIR\"
			Remove "$ROOT_DIR\goluwa"
		}
	}
	else
	{
		Download "https://github.com/CapsAdmin/goluwa/archive/master.zip" "$ROOT_DIR\temp.zip"
		Extract "$ROOT_DIR\temp.zip" "$ROOT_DIR\" $true
		Remove temp.zip
	}
	
	if ($args[0] -Eq "update")
	{
		exit 0
	}
}

New-Item -ItemType Directory -Force -Path "$ROOT_DIR\data" | Out-Null

if($args[0] -eq "client") {
	$env:GOLUWA_CLIENT = "1"
	$env:GOLUWA_SERVER = "0"
}

if($args[0] -eq "server") {
	$env:GOLUWA_CLIENT = "1"
	$env:GOLUWA_SERVER = "0"
	$env:GOLUWA_ARGS = "{'host'}"
}

if (($args[0] -eq "ide" -Or ! $args[0]) -And (Test-Path "$ROOT_DIR\engine\lua\zerobrane\config.lua")) {
	
	if (!(Test-Path "$ROOT_DIR\data\ide\zbstudio.exe")) {
		New-Item -ItemType Directory -Force -Path "$ROOT_DIR\data\ide" | Out-Null
		
		if (Get-Command git -errorAction SilentlyContinue)
		{
			if (Test-Path "$ROOT_DIR\data\ide\.git")
			{
				git pull;
			}
			else
			{
				git clone https://github.com/pkulchenko/ZeroBraneStudio --depth 1
				Copy-Item -Confirm:$false -Recurse -Force -Path "$ROOT_DIR\ZeroBraneStudio\*" -Destination "$ROOT_DIR\data\ide\"
				Remove "$ROOT_DIR\ZeroBraneStudio"
			}
		}
		else
		{
			Download $ide_url "$ROOT_DIR\data\temp.zip"
			Extract "$ROOT_DIR\data\temp.zip" "$ROOT_DIR\data\ide" $true
			Remove "$ROOT_DIR\data\temp.zip"
		}
	}

	Set-Location "data\ide"
	
	if ((Get-Command git -errorAction SilentlyContinue) -And (Test-Path "$ROOT_DIR\data\ide\.git"))
	{	
		git pull;
	}
	
	.\zbstudio.exe -cfg ../../engine/lua/zerobrane/config.lua
}

if ($args[0] -eq "client" -Or $args[0] -eq "server") {
	$bin_dir = "data\bin\windows_$ARCH"

	if (!(Test-Path "$bin_dir\downloaded_binaries")) {
		Download $bin_url "$ROOT_DIR\data\temp.zip"
		Extract "$ROOT_DIR\data\temp.zip" "$ROOT_DIR\$bin_dir"
		Remove "$ROOT_DIR\data\temp.zip"
		New-Item "$ROOT_DIR\$bin_dir\downloaded_binaries" -type file
	}

	Set-Location "$ROOT_DIR\$bin_dir\"

	Add-Type -Name ConsoleUtils -Namespace Foo -MemberDefinition @'
    [DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'@

	if ($GOLUWA_CURSES -eq "1")
	{
		$window = [Foo.ConsoleUtils]::GetConsoleWindow()
		[Foo.ConsoleUtils]::ShowWindow($window, 0)
	}
	.\luajit.exe ../../../core/lua/init.lua
	if ($GOLUWA_CURSES -eq "1")
	{
		[Foo.ConsoleUtils]::ShowWindow($window, 1)
	}
}
