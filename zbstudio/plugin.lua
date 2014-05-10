local styles = loadfile('cfg/tomorrow.lua')('TomorrowNightEighties')
stylesoutshell = styles -- apply the same scheme to Output/Console windows
styles.auxwindow = styles.text -- apply text colors to auxiliary windows
styles.calltip = styles.text -- apply text colors to tooltips

ide.config.editor.usetabs = true
ide.config.editor.tabwidth = 4

local lfs = require("lfs")

local root = lfs.currentdir():match("(.+\\)%.zbstudio"):gsub("\\", "/")
local bin = ".base/bin/" .. jit.os:lower() ..  "/" .. jit.arch:lower() .. "/"

local luasocket = require("socket")

local port = 16273
local socket = luasocket.tcp()
socket:settimeout(0)

local lua = "ZEROBRANE_LINEINPUT=luasocket.Server([[tcp]],[[localhost]],"..port..")ZEROBRANE_LINEINPUT.debug=true;ZEROBRANE_LINEINPUT.OnClientConnected=function(s,client)return true end;ZEROBRANE_LINEINPUT.OnReceive=function(s,str)console.RunString(str)end"

local PLUGIN = {
	name = "Goluwa",
	description = "",
	author = "CapsAdmin",
	version = 0.1,
}

function PLUGIN:onRegister()
	ide:AddInterpreter("Goluwa", self.interpreter)
end

function PLUGIN:onUnRegister()
	ide:RemoveInterpreter("Goluwa")
end

function PLUGIN:onLineInput(str)
	socket:connect("localhost", port)
	socket:send(str)
end

do 
	local INTEPRETER = {
		name = "Goluwa",
		description = "A game framework written in luajit",
		hasdebugger = true,
		api = {"baselib"},
		unhideanywindow = true,
	}

	function INTEPRETER:frun(wfile, run_debug)
	
		local file_path = wfile:GetFullPath()
		local temp_file 
		
		-- if running on Windows and can't open the file, this may mean that
		-- the file path includes unicode characters that need special handling
		local fh = io.open(file_path, "r")
		if fh then fh:close() end
		if ide.osname == 'Windows' and pcall(require, "winapi") and wfile:FileExists() and not fh then
			winapi.set_encoding(winapi.CP_UTF8)
			file_path = winapi.short_path(file_path)
		end
	
		file_path = file_path:gsub("\\", "/")
			
		if run_debug then
			DebuggerAttachDefault({startwith = file_path, allowediting = true})

			local temp = wx.wxFileName()
			temp:AssignTempFileName(".")
			temp_file = temp:GetFullPath()
			local f = io.open(temp_file, "w")
			if not f then
				DisplayOutput("Can't open temporary file '"..temp_file.."' for writing\n")
				return
			end
			f:write(run_debug)
			f:close()
		end
		
		-- modify CPATH to work with other Lua versions
		local _, cpath = wx.wxGetEnv("LUA_CPATH")
		
		if cpath then
			wx.wxSetEnv("LUA_CPATH", cpath:gsub("/clibs/", "/clibs51/"))
		end
		
		local fmt = "%q -e \"io.stdout:setvbuf('no')ARGS={'include[[%s]]%s'}ZEROBRANE=true;dofile'%s'\""
			
		local pid = CommandLineRun(
			fmt:format(root .. bin .. "luajit", file_path, lua, root .. ".base/lua/init.lua"),
			root .. bin,
			true,
			false,
			nil,
			nil,
			function() 
				if run_debug then 
					wx.wxRemoveFile(temp_file) 
				end 
			end
		)

		if cpath then
			wx.wxSetEnv("LUA_CPATH", cpath)
		end
	
		return pid
	end

	function INTEPRETER:fprojdir(wfilename)
		return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
	end

	function INTEPRETER:fworkdir()
		return ide.config.path.projectdir .. "/" .. bin
	end

	function INTEPRETER:fattachdebug(self) 
		DebuggerAttachDefault() 
	end
	
	PLUGIN.interpreter = INTEPRETER
end

goluwa = PLUGIN

return PLUGIN