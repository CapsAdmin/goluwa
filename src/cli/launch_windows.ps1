function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

$src = @'
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("User32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'@

Add-Type -Name ConsoleUtils -Namespace Foo -MemberDefinition $src
$hWnd = [Foo.ConsoleUtils]::GetConsoleWindow()

if ($ENV:PROCESSOR_ARCHITECTURE -Match "64"){ $arch = "x64" } else { $arch = "x86" }
$url = "https://github.com/CapsAdmin/goluwa/releases/download/windows-binaries/" + $arch + ".zip"
$output_folder = [IO.Path]::GetFullPath($(PSScriptRoot) + "\..\..\data\bin\windows_" + $arch)

if(!(Test-Path ($output_folder + "\luajit.exe")))
{
	[Foo.ConsoleUtils]::ShowWindow($hWnd, 1)

	if (!(Test-Path $output_folder))
	{
		New-Item -ItemType directory -Path $output_folder
	}

	Clear-Host

	Write-Output "downloading binaries from $url to $output_folder"

	$download_location = (get-item $output_folder).parent.FullName + "\temp.zip"

	Remove-Item $download_location -ErrorAction SilentlyContinue -Confirm:$false -Recurse:$true

	if (Get-Command Invoke-WebRequest -CommandType cmdlet -errorAction SilentlyContinue)
	{
		#nicer download
		Invoke-WebRequest $url -OutFile $download_location
	}
	else
	{
		$client = new-object System.Net.WebClient
		$client.DownloadFile( $url, $download_location )
	}

	Write-Output "unzipping files"

	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($download_location)

	foreach($item in $zip.items())
	{
		$shell.Namespace($output_folder).copyhere($item)
	}

	Write-Output "removing leftover files"

	Remove-Item ($download_location) -ErrorAction SilentlyContinue -Confirm:$false -Recurse:$true

	Write-Output "launching"

	[Foo.ConsoleUtils]::ShowWindow($hWnd, 0)
}

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $output_folder + "\luajit.exe"
$pinfo.WorkingDirectory = $output_folder + "\"
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

Write-Host "press any key to exit"
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

}