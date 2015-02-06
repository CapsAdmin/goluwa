function PSScriptRoot { $MyInvocation.ScriptName | Split-Path }

if ($ENV:PROCESSOR_ARCHITECTURE -Match "64"){ $arch = "x64" } else { $arch = "x86" }
$url = "https://github.com/CapsAdmin/goluwa/releases/download/windows-binaries/" + $arch + ".zip"
$output_folder = $(PSScriptRoot) + "\windows_" + $arch

if(!(Test-Path ($output_folder + "\luajit.exe")))
{
	if (!(Test-Path $output_folder))
	{
		New-Item -ItemType directory -Path $output_folder
	}
	
	Write-Output $output_folder
	
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
		
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($download_location)

	foreach($item in $zip.items())
	{
		$shell.Namespace($output_folder).copyhere($item)
	}
	
	Remove-Item ($download_location) -ErrorAction SilentlyContinue -Confirm:$false -Recurse:$true
}

Set-Location ($(PSScriptRoot) + "\windows_$arch\")
Start-Process "luajit" "../../lua/init.lua "