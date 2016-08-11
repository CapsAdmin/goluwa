function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

function download([string]$url, [string]$loc)
{
	Write-Output "downloading binaries from $url to $loc"

	#remove any previous attempted downloads
	Remove-Item "$loc.zip" -ErrorAction SilentlyContinue -Confirm:$false -Recurse:$true

	
	if (Get-Command Invoke-WebRequest -CommandType cmdlet -errorAction SilentlyContinue)
	{
		Invoke-WebRequest $url -OutFile $loc
	}
	else
	{
		$client = new-object System.Net.WebClient
		$client.DownloadFile( $url, $loc )
	}
}

function extract([string] $source, [string] $dir, [string] $zip_dir)
{
	Write-Output "unzipping files from $source/$zip_dir to $dir"
	$shell = New-Object -ComObject Shell.Application

	$zip = $shell.NameSpace("$source\$zip_dir")

	if (!(Test-Path $dir)) 
	{
		$null = mkdir $dir
	}
	
	foreach($item in $zip.items())
	{
		$shell.Namespace($dir).copyhere($item)
	}
	
	Remove-Item $source -ErrorAction SilentlyContinue -Confirm:$false -Recurse:$true
}

$src = @'
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("User32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'@

Add-Type -Name ConsoleUtils -Namespace Foo -MemberDefinition $src
$hWnd = [Foo.ConsoleUtils]::GetConsoleWindow()

if ($ENV:PROCESSOR_ARCHITECTURE -Match "64"){ $arch = "x64" } else { $arch = "x86" }

if ($env:EDITOR)
{
	$editor_url = "https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip"
	$editor_dir = [IO.Path]::GetFullPath($(PSScriptRoot) + "\..\..\data\editor")

	if(!(Test-Path ($editor_dir + "\zbstudio.exe")))
	{
		download $editor_url "$editor_dir.zip"
		extract "$editor_dir.zip" $editor_dir "ZeroBraneStudio-master"	
	}
	
	cd $editor_dir
	Start-Process -FilePath "zbstudio.exe" -ArgumentList "-cfg ../../src/lua/zerobrane/config.lua"
}
else
{
	$binaries_url = "https://github.com/CapsAdmin/goluwa/releases/download/windows-binaries/" + $arch + ".zip"
	$binaries_dir = [IO.Path]::GetFullPath($(PSScriptRoot) + "\..\..\data\bin\windows_" + $arch)

	if(!(Test-Path ($binaries_dir + "\luajit.exe")))
	{
		[Foo.ConsoleUtils]::ShowWindow($hWnd, 1)

		download $binaries_url "$binaries_dir.zip"
		extract "$binaries_dir.zip" $binaries_dir
	}
	
	Write-Output "launching"

	[Foo.ConsoleUtils]::ShowWindow($hWnd, 0)

	$pinfo = New-Object System.Diagnostics.ProcessStartInfo
	$pinfo.FileName = $binaries_dir + "\luajit.exe"
	$pinfo.WorkingDirectory = $binaries_dir + "\"
	$pinfo.RedirectStandardError = $true
	$pinfo.RedirectStandardOutput = $true
	$pinfo.UseShellExecute = $false
	$pinfo.Arguments = "../../../src/lua/init.lua"
	$p = New-Object System.Diagnostics.Process
	$p.StartInfo = $pinfo
	$p.Start() | Out-Null
	#$p.WaitForExit()
	$stdout = $p.StandardOutput.ReadToEnd()
	$stderr = $p.StandardError.ReadToEnd()

	Write-Host "======== stdout ========`n$stdout========================`n`n"
	Write-Host "======== stderr ========`n$stderr========================`n`n"
	Write-Host "exit code: " $p.ExitCode "`n`n"

	if ($stderr -or ($p.ExitCode -ne 0))
	{
		[Foo.ConsoleUtils]::ShowWindow($hWnd, 1)
	}
}