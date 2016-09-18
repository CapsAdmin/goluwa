$arg=$args[0]
$ROOT_DIR = $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$ROOT_DIR = $([System.IO.Path]::GetFullPath("$ROOT_DIR\..\..\data"))

New-Item -ItemType Directory -Force -Path $ROOT_DIR | Out-Null
Set-Location $ROOT_DIR

if ($ENV:PROCESSOR_ARCHITEW6432 -Match "64") { 
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

if($arg -eq "ide") {	
	if (!(Test-Path ("ide\zbstudio.exe"))) {
		Download $ide_url temp.zip
		Extract temp.zip ide $true
		Remove temp.zip
	}
	
	Set-Location "ide"
	.\zbstudio.exe -cfg ../../src/lua/zerobrane/config.lua
}

if ($arg -eq "launch" -Or $arg -eq "") {
	Write-Output "launching"
	
	$bin_dir = "bin\windows_$ARCH"

	if (!(Test-Path "$bin_dir\luajit.exe")) {	
		Download $bin_url temp.zip
		Extract temp.zip $bin_dir
		Remove temp.zip
	}

	Set-Location $pwd\$bin_dir\
	
	.\luajit.exe ../../../src/lua/init.lua
}
