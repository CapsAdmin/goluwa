// & @echo off & set GOLUWA_START_TIME="%time%" & cls & cscript.exe //NoLogo //E:JScript %~dp0%~n0%~x0 %* & goto :EOF
var fs = new ActiveXObject("Scripting.FileSystemObject")
var shell = WScript.CreateObject("WScript.Shell")

var ashell = new ActiveXObject("shell.application")
var arch = ashell.GetSystemInformation("ProcessorArchitecture") == 9 ? "x64" : "x86"
var working_dir = fs.GetAbsolutePathName(".")
var script_dir = fs.GetParentFolderName(WScript.ScriptFullName)
var arg_line = ""
for (var i = 0; i < WScript.Arguments.Length; i++)
{
    arg_line += WScript.Arguments(i);
    if (i < WScript.Arguments.Length - 1)
        arg_line += " ";
}

var binary_url = "https://gitlab.com/CapsAdmin/goluwa-binaries-windows_"+arch+"/raw/master/"
var source_url = "https://gitlab.com/CapsAdmin/goluwa/raw/master/"
var binary_dir = "data/windows_"+arch+"/"
var boot_lua = "core/lua/boot.lua"

function Download(url, to)
{
	if (fs.FileExists(to))
		return;

	var request = WScript.CreateObject('MSXML2.ServerXMLHTTP');
	request.open('GET', url, false)
	request.send(false)

	if (request.status === 200) {
		var stream = WScript.CreateObject('ADODB.Stream');
		stream.Open();
		stream.Type = 1;
		stream.Write(request.responseBody);
		stream.Position = 0;
		stream.SaveToFile(to, 1);
		stream.Close();
	}
	else
	{
		WScript.Echo("failed to download " + url + ": ", request.status)
	}
}

function CreateDirectory(path) {
    var arr = path.split("/")
    var cur = ""
    for (var i = 0; i < arr.length; i++)
    {
		if (arr[i] === "")
			break;

		cur += arr[i] + "/"

        if (!fs.FolderExists(cur))
			fs.CreateFolder(cur)
    }
}

shell.Environment("PROCESS")("GOLUWA_CURRENT_DIRECTORY") = working_dir

shell.CurrentDirectory = script_dir

CreateDirectory(binary_dir)
CreateDirectory(fs.GetParentFolderName(boot_lua))

Download(binary_url + "luajit.exe", binary_dir + "luajit.exe")
Download(binary_url + "lua51.dll", binary_dir + "lua51.dll")
Download(binary_url + "vcruntime140.dll", binary_dir + "vcruntime140.dll")

Download(source_url + boot_lua, boot_lua)

shell.CurrentDirectory = "data/windows_"+arch

//shell.Run("luajit ../../core/lua/boot.lua " + arg_line, 1, true)

var obj = shell.Exec("luajit ../../core/lua/boot.lua " + arg_line)
	
while (!obj.StdOut.AtEndOfStream) {	
	WScript.StdOut.WriteLine(obj.StdOut.ReadLine())
}

var str = obj.StdOut.ReadAll()
if (str != "")
	WScript.StdErr.Write(str)

var str = obj.StdErr.ReadAll()
if (str != "")
	WScript.StdErr.Write(str)