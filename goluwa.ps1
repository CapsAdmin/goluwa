$ROOT_DIR = $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ROOT_DIR = $([System.IO.Path]::GetFullPath("$ROOT_DIR"))

if (((gwmi -Query "select osarchitecture from win32_operatingsystem").OSArchitecture) -Match "64") {
	$ARCH = "x64"
} else {
	$ARCH = "x86"
}

$ide_url = "https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
$bin_url = "https://github.com/CapsAdmin/goluwa/releases/download/windows-binaries/$ARCH.zip"

function Remove($path) {
	if(Test-Path "$path" -PathType Container) {
		Write-Host -NoNewline "removing directory: '$ROOT_DIR\$path' ... "
		Get-ChildItem -Path "$path\\*" -Recurse -Force | Remove-Item -Force -Recurse
		Remove-Item $path -Recurse -Force
		Write-Host "OK"
	} elseif(Test-Path "$path" -PathType Leaf) {
		Write-Host -NoNewline "removing file: '$ROOT_DIR\$path' ... "
		Remove-Item -Force "$path"
		Write-Host "OK"
	} else {
		Write-Host "could not find: $path"
	}
}

function Download($url, $location) {
	if(!(Test-Path "$location")) {
		Write-Host -NoNewline "'$url' >> '$ROOT_DIR\$location' ... "
		#if (Get-Module -ListAvailable -Name BitsTransfer) {
		#	Import-Module BitsTransfer
		#	Start-BitsTransfer -Source $url -Destination $location
		#} else {
			(New-Object System.Net.WebClient).DownloadFile($url, "$pwd\$location")
		#}
		Write-Host "OK"
	} else {
		Write-Host "'$ROOT_DIR\$location' already exists"
	}
}

function Extract($file, $location, $move_files) {
	Write-Host -NoNewline "$file >> '$location' ... "

	$shell = New-Object -Com Shell.Application

	$zip = $shell.NameSpace($([System.IO.Path]::GetFullPath("$pwd\$file")))

	if (!$zip) {
		Write-Error "could not extract $ROOT_DIR\$file!"
	}

	if (!(Test-Path $location)) {
		New-Item -ItemType directory -Path $location | Out-Null
	}

	foreach($item in $zip.items()) {
		$shell.Namespace("$pwd\$location").CopyHere($item, 0x14)
	}

	if ($move_files)
	{
		Move-Item -Confirm:$false -Force -Path "$location\*\*" -Destination "$location"
	}

	Write-Host "OK"
}

New-Item -ItemType Directory -Force -Path $ROOT_DIR\data | Out-Null

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
	
	if (!(Test-Path "data\ide\zbstudio.exe")) {
		Download $ide_url data\temp.zip
		Extract data\temp.zip data\ide $true
		Remove data\temp.zip
	}

	Set-Location "data\ide"
	.\zbstudio.exe -cfg ../../engine/lua/zerobrane/config.lua
}

if ($args[0] -eq "client" -Or $args[0] -eq "server") {
	$bin_dir = "data\bin\windows_$ARCH"

	if (!(Test-Path "$bin_dir\downloaded_binaries")) {
		Download $bin_url temp.zip
		Extract temp.zip $bin_dir
		Remove temp.zip
		New-Item "$bin_dir\downloaded_binaries" -type file
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
