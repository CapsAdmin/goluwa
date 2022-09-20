local PLUGIN = {
	name = "remote console",
	description = "",
	author = "CapsAdmin",
	version = 0.1,
}
ide.config.keymap[ID.STARTDEBUG] = nil
ide.config.keymap[ID.RUN] = nil
local BRANCH = nil
local DEBUG = false

if jit.os == "Windows" then
	local ok, winapi = pcall(require, "winapi")

	if ok then
		if not winapi.find_all_windows then
			winapi.find_all_windows = function()
				return {}
			end
		end
	end
end

function PLUGIN:Setup()
	local META = {}
	META.__index = META
	local last_msg = ""
	local delimiter = "_aeoaa__DELIMITER_aeoaa_"

	function META:Update()
		if not self.next_update or self.next_update < os.clock() then
			local f = io.open(ide:GetProject() .. "data/ide/goluwa_output_" .. self.id, "r")

			if f then
				local str = f:read("*all")
				f:close()

				for chunk in str:gmatch("(.-)" .. delimiter) do
					local func, err = loadstring(chunk)

					if func then
						local ok, err = pcall(func)

						if not func then ide:Print(err) end
					else
						ide:Print(err)
					end
				end

				io.open(ide:GetProject() .. "data/ide/goluwa_output_" .. self.id, "w"):close()
			end

			self.next_update = os.clock() + 1 / 5
		end
	end

	function META:Send(str)
		local f = io.open(ide:GetProject() .. "data/ide/goluwa_input_" .. self.id, "ab")
		f:write(str)
		f:write(delimiter)
		f:close()
	end

	function META:Remove() end

	function create_connection(id)
		local self = setmetatable({}, META)
		self.id = id
		return self
	end

	local function setup_console(id, name, cmd_line, icon, on_key, env_vars)
		return {
			id = id,
			name = name,
			cmd_line = cmd_line,
			icon = icon,
			working_directory = "../../",
			env_vars = env_vars or
				{
					GOLUWA_IDE = "",
					GOLUWA_ARGS = [==[{[[
					local delimiter = "]==] .. delimiter .. [==["

					pvars.Set("system_texteditor_path", "./../../ide/zbstudio.sh %PATH%:%LINE%")

					event.Timer("remote_console", 1/5, 0, function()
						local input = vfs.Read("os:" .. e.ROOT_FOLDER .. "data/ide/goluwa_input_LUA{console.id}")
						if input and input ~= "" then
							vfs.Write("os:" .. e.ROOT_FOLDER .. "data/ide/goluwa_input_LUA{console.id}", "")

							for _, chunk in ipairs(input:split(delimiter)) do
								if chunk ~= "" then
									commands.RunString(chunk, nil, nil, true)
								end
							end
						end
					end)

					_G.zb = function(str)
						vfs.Write("os:" .. e.ROOT_FOLDER .. "data/ide/goluwa_output_LUA{console.id}", vfs.Read(e.ROOT_FOLDER .. "data/ide/goluwa_output_LUA{console.id}") .. str .. delimiter)
					end

					ZEROBRANE = true

					if "DEFERRED_CMD" ~= "" then
						commands.RunString("DEFERRED_CMD")
					end

					if CLIENT and LUA{plugin:IsRunning("server")} then
						commands.RunString("connect localhost")
					end
				]]}]==],
				},
			start = function(console)
				console.connection = create_connection(id)
			end,
			stop = function(console)
				if not console.connection then return end

				console.connection:Remove()
			end,
			run_string = function(console, str)
				if not console.connection then return end

				console.connection:Send(str)
			end,
			run_script = function(console, path)
				if not console.connection then return end

				console:Print("loading: ", path, "\n")
				console:run_string(
					"_G.RELOAD = true runfile([[" .. path .. "]]) _G.RELOAD = nil print('script ran successfully')"
				)
			end,
			print = function(console, ...)
				console:Print(...)
			end,
			on_update = function(console)
				if not console.connection then return end

				console.connection:Update()
			end,
			on_save = function(console, path)
				local dir = path:lower():match("^.+/([^/]-)/[^/]+$")

				if dir == id or (id == "client" and (id == "graphics" or id == "audio")) then
					console:run_script(path)
				elseif dir ~= "server" and dir ~= "client" then
					console:run_script(path)
				end
			end,
			on_key = on_key,
		}
	end

	local server_icon = wx.wxBitmap({
		"16 16 143 2",
		"  	c None",
		". 	c #CCCCCC",
		"+ 	c #C8C8C8",
		"@ 	c #C4C4C4",
		"# 	c #C0C0C0",
		"$ 	c #BBBBBB",
		"% 	c #B6B6B6",
		"& 	c #B0B0B0",
		"* 	c #A9A9A9",
		"= 	c #CBCBCB",
		"- 	c #DCDCDC",
		"; 	c #E3E3E6",
		"> 	c #DCDEE1",
		", 	c #DCDCDF",
		"' 	c #DBDCDF",
		") 	c #DBDBDE",
		"! 	c #ECECEE",
		"~ 	c #A5A5A5",
		"{ 	c #CACACA",
		"] 	c #DFDFDF",
		"^ 	c #EAEAEA",
		"/ 	c #C9CACF",
		"( 	c #C5C6CB",
		"_ 	c #C3C4CA",
		": 	c #C1C3C8",
		"< 	c #C1C1C7",
		"[ 	c #D8D9DC",
		"} 	c #9E9E9E",
		"| 	c #E9E9E9",
		"1 	c #E1E1E2",
		"2 	c #C4C6CB",
		"3 	c #979798",
		"4 	c #959596",
		"5 	c #939394",
		"6 	c #919192",
		"7 	c #D6D7DB",
		"8 	c #989898",
		"9 	c #C6C6C6",
		"0 	c #EFEFEF",
		"a 	c #E1E1E1",
		"b 	c #DDDDDD",
		"c 	c #C2C3C8",
		"d 	c #C1C2C8",
		"e 	c #BFC1C6",
		"f 	c #BEBFC5",
		"g 	c #BBBDC3",
		"h 	c #D5D6DA",
		"i 	c #919191",
		"j 	c #ECECEC",
		"k 	c #E0E0E0",
		"l 	c #DCDCDD",
		"m 	c #C0C1C7",
		"n 	c #8F8F8F",
		"o 	c #8D8D8D",
		"p 	c #8A8A8A",
		"q 	c #D4D5D9",
		"r 	c #8B8B8B",
		"s 	c #D9D9DA",
		"t 	c #BEBFC6",
		"u 	c #BCBEC4",
		"v 	c #BBBCC3",
		"w 	c #B9BBC1",
		"x 	c #B8B9C0",
		"y 	c #6FA53D",
		"z 	c #659F31",
		"A 	c #B5B5B5",
		"B 	c #DEDEDE",
		"C 	c #D8D8D9",
		"D 	c #BABBC2",
		"E 	c #B9BAC1",
		"F 	c #A4C8A0",
		"G 	c #56A950",
		"H 	c #67A138",
		"I 	c #81B35A",
		"J 	c #579828",
		"K 	c #AFAFAF",
		"L 	c #EBEBEB",
		"M 	c #D5D5D7",
		"N 	c #6EA338",
		"O 	c #67A133",
		"P 	c #619D2F",
		"Q 	c #7CAF55",
		"R 	c #AACB91",
		"S 	c #74AB4F",
		"T 	c #458E16",
		"U 	c #A8A8A8",
		"V 	c #D3D4D5",
		"W 	c #B7B9C0",
		"X 	c #6BA337",
		"Y 	c #B0CE96",
		"Z 	c #ADCD94",
		"` 	c #A8CB90",
		" .	c #90BC74",
		"..	c #A1C78A",
		"+.	c #68A546",
		"@.	c #348606",
		"#.	c #A2A2A2",
		"$.	c #F0F0F0",
		"%.	c #D2D2D4",
		"&.	c #B5B6BE",
		"*.	c #639F31",
		"=.	c #8EBA6F",
		"-.	c #89B86B",
		";.	c #85B666",
		">.	c #80B361",
		",.	c #82B567",
		"'.	c #98C283",
		").	c #5CA03C",
		"!.	c #247E00",
		"~.	c #9B9B9B",
		"{.	c #B3B3B3",
		"].	c #D4D4D4",
		"^.	c #DFDFE1",
		"/.	c #BDBFC5",
		"(.	c #5B9B29",
		"_.	c #A9CA90",
		":.	c #A5C88D",
		"<.	c #A1C68A",
		"[.	c #9EC588",
		"}.	c #85B66A",
		"|.	c #97C282",
		"1.	c #66A548",
		"2.	c #217C00",
		"3.	c #A3A3A3",
		"4.	c #C4C5C6",
		"5.	c #529722",
		"6.	c #4A911C",
		"7.	c #448F16",
		"8.	c #3C8B10",
		"9.	c #5E9F3A",
		"0.	c #96C180",
		"a.	c #62A346",
		"b.	c #1F7D00",
		"c.	c #787878",
		"d.	c #747474",
		"e.	c #707070",
		"f.	c #6B6B6B",
		"g.	c #676767",
		"h.	c #2D8205",
		"i.	c #5FA143",
		"j.	c #1E7A00",
		"k.	c #207D00",
		"l.	c #1E7B03",
		"                                ",
		"        . + @ # $ % & *         ",
		"      = - ; > , ' ) ! ~         ",
		"    { ] ^ / ( _ : < [ }         ",
		"  = | | 1 2 3 4 5 6 7 8         ",
		"  9 0 a b c d e f g h i         ",
		"  # j k l m 6 n o p q r         ",
		"  $ j ] s t u v w x y z         ",
		"  A j B C g D E F G H I J       ",
		"  K L b M w y N O P Q R S T     ",
		"  U ^ b V W X Y Z R `  ...+.@.  ",
		"  #.$.k %.&.*.Z =.-.;.>.,.'.).!.",
		"  ~.{.].^./.(._.:.<.[.}.|.1.2.  ",
		"      p 3.4.5.6.7.8.9.0.a.b.    ",
		"          c.d.e.f.g.h.i.j.      ",
		"                    k.l.        ",
	}
)

local client_icon = wx.wxBitmap({
	"16 16 140 2",
	"  	c None",
	". 	c #8C4712",
	"+ 	c #904B10",
	"@ 	c #8A480F",
	"# 	c #7D4211",
	"$ 	c #5B3213",
	"% 	c #964D10",
	"& 	c #9B5812",
	"* 	c #995812",
	"= 	c #935311",
	"- 	c #874A0F",
	"; 	c #703D0D",
	"> 	c #492D12",
	", 	c #974B0F",
	"' 	c #9F5812",
	") 	c #8A4A0F",
	"! 	c #874B0F",
	"~ 	c #874B11",
	"{ 	c #854C15",
	"] 	c #754112",
	"^ 	c #5B330F",
	"/ 	c #873E0C",
	"( 	c #B8977C",
	"_ 	c #E4B78A",
	": 	c #C89C71",
	"< 	c #6E4015",
	"[ 	c #724419",
	"} 	c #6B4522",
	"| 	c #663A10",
	"1 	c #9B5E1E",
	"2 	c #F7E8D9",
	"3 	c #F1C597",
	"4 	c #E5BB8E",
	"5 	c #D1A97F",
	"6 	c #DFB589",
	"7 	c #EEDFCD",
	"8 	c #A66823",
	"9 	c #925A2A",
	"0 	c #EECAA6",
	"a 	c #EACCAB",
	"b 	c #F6D0A7",
	"c 	c #F6D0A8",
	"d 	c #EECDA7",
	"e 	c #9A622D",
	"f 	c #243C69",
	"g 	c #A76D34",
	"h 	c #F8CC9C",
	"i 	c #F7D4AF",
	"j 	c #F6CFA5",
	"k 	c #AE7434",
	"l 	c #679D39",
	"m 	c #659F31",
	"n 	c #1C48BC",
	"o 	c #D4E2F4",
	"p 	c #A97B4E",
	"q 	c #A87B4D",
	"r 	c #C3D6F3",
	"s 	c #5D983C",
	"t 	c #81B35A",
	"u 	c #579828",
	"v 	c #1F4CC4",
	"w 	c #D6E4F6",
	"x 	c #A4E4FF",
	"y 	c #72D4FF",
	"z 	c #6FA53D",
	"A 	c #6DA33A",
	"B 	c #67A136",
	"C 	c #619E32",
	"D 	c #7CAF55",
	"E 	c #AACB91",
	"F 	c #74AB4F",
	"G 	c #448E16",
	"H 	c #44548A",
	"I 	c #ABC8FC",
	"J 	c #98D1FF",
	"K 	c #6DC7FE",
	"L 	c #68BFFE",
	"M 	c #6BA337",
	"N 	c #B0CE96",
	"O 	c #ADCD94",
	"P 	c #A8CB90",
	"Q 	c #90BC74",
	"R 	c #A1C78A",
	"S 	c #68A546",
	"T 	c #358606",
	"U 	c #CD7B27",
	"V 	c #EAB378",
	"W 	c #949EB3",
	"X 	c #60B7FF",
	"Y 	c #63B6FF",
	"Z 	c #61B2FE",
	"` 	c #639F31",
	" .	c #8EBA6F",
	"..	c #89B86B",
	"+.	c #85B666",
	"@.	c #80B361",
	"#.	c #82B567",
	"$.	c #98C283",
	"%.	c #5CA03C",
	"&.	c #257F00",
	"*.	c #D17C28",
	"=.	c #EEBA82",
	"-.	c #58669F",
	";.	c #84BBF5",
	">.	c #5BACFF",
	",.	c #5AA8FE",
	"'.	c #5B9B29",
	").	c #A9CA90",
	"!.	c #A5C88D",
	"~.	c #A1C68A",
	"{.	c #9EC588",
	"].	c #85B66A",
	"^.	c #97C282",
	"/.	c #66A548",
	"(.	c #207D00",
	"_.	c #CC7925",
	":.	c #616185",
	"<.	c #3560BF",
	"[.	c #61B9FE",
	"}.	c #62B9FE",
	"|.	c #519723",
	"1.	c #49911D",
	"2.	c #438F17",
	"3.	c #3B8B11",
	"4.	c #5E9F3A",
	"5.	c #96C180",
	"6.	c #62A346",
	"7.	c #30800B",
	"8.	c #204FB2",
	"9.	c #1E3FA0",
	"0.	c #2145AA",
	"a.	c #2245AB",
	"b.	c #2243AA",
	"c.	c #2040A7",
	"d.	c #1F3C9E",
	"e.	c #2B800A",
	"f.	c #5FA143",
	"g.	c #217B01",
	"h.	c #217D00",
	"i.	c #1E7B03",
	"                                ",
	"          . + @ # $             ",
	"        % & * = - ; >           ",
	"      , ' ) ! ~ { ] ^           ",
	"      / ( _ : < [ } |           ",
	"      1 2 3 4 5 6 7 8           ",
	"      9 0 a b c a d e           ",
	"      f g h i i j k l m         ",
	"      n o p q q p r s t u       ",
	"    v w x y z A B C D E F G     ",
	"  H I J K L M N O E P Q R S T   ",
	"U V W X Y Z ` O  ...+.@.#.$.%.&.",
	"*.=.-.;.>.,.'.).!.~.{.].^./.(.  ",
	"  _.:.<.[.}.|.1.2.3.4.5.6.7.    ",
	"      8.9.0.a.b.c.d.e.f.g.      ",
	"                    h.i.        ",
}
)

local out = {
setup_console("server", "Server", "server", server_icon),
setup_console(
	"client",
	"Client",
	"client",
	client_icon,
	function(console, suppress_only)
		if
			ide:GetMainFrame():IsActive() and
			(
				wx.wxGetKeyState(wx.WXK_F5) or
				wx.wxGetKeyState(wx.WXK_F6)
			)
		then
			if suppress_only then return false end

			if (console.last_start or 0) < os.clock() then
				if self:IsRunning(console.id) then
					console:Stop()
				else
					console:Start()
				end

				console.last_start = os.clock() + 0.1
			end
		end
	end
),
}

if GetGMODDir() then
table.insert(
	out,
	setup_console(
		"gmod",
		"GMOD",
		function(console)
			local cmd_line = ""

			if WINE then
				cmd_line = "wineconsole hl2.exe -steam -game garrysmod -disableluarefresh"
			elseif jit.os ~= "Windows" then
				cmd_line = "./hl2_linux -steam -game garrysmod -disableluarefresh"
			else

			end

			local pid = CommandLineRun(
				cmd_line,
				GetGMODDir() .. "../",
				true, --tooutput,
				true, --nohide,
				function(...)
					console:print(...)
				end,
				"goluwa_" .. console.id,
				function()
					local tb = ide:GetToolBar()
					tb:ToggleTool(console.wx_start_id, false)
					tb:EnableTool(console.wx_run_id, false)
					tb:Realize()
					self:StopProcess(console.id)
				end
			)
			os.execute(
				"xterm -e 'echo password needed to attach to process " .. pid .. " && sudo gdb -p " .. pid .. " --ex continue' &"
			)
			return pid
		end,
		server_icon,
		nil,
		{
			__GL_THREADED_OPTIMIZATIONS = "1",
			LIBGL_DEBUG = "1",
			MESA_DEBUG = "context",
			LD_LIBRARY_PATH = GetGMODDir() .. "../bin",
		}
	)
)
end

return out
end

function PLUGIN:IsRunning(id)
local console = self.consoles[id]
return console.pid and wx.wxProcess.Exists(console.pid)
end

function PLUGIN:StartProcess(id, cmd)
local console = self.consoles[id]

if self:IsRunning(console.id) then
console:print("already started\n")
self:StopProcess(id)
console.restart = true
return
end

if console.start then console:start() end

console:print("launching...\n")

for k, v in pairs(console.env_vars) do
v = v:gsub("LUA(%b{})", function(code)
	return tostring(
		assert(loadstring("local console, plugin = ... return " .. code:sub(2, -2)))(console, self)
	)
end)
v = v:gsub("DEFERRED_CMD", cmd or "")
wx.wxSetEnv(k, v)

if os.getenv(k) ~= v then
	ide:Print("failed to set environment variable " .. k)

	for i = 1, #v do
		local str = v:sub(0, i)
		wx.wxSetEnv(k, str)

		if os.getenv(k) ~= str and i > 1 then
			local bad_char = v:sub(i - 1, i - 1)
			ide:Print(
				"the character " .. bad_char .. "(" .. (
						bad_char:byte() or
						-1
					) .. ")" .. " seems to be problematic"
			)
			ide:Print(str)

			break
		end
	end
end
end

local tb = ide:GetToolBar()
local cmd_line = console.cmd_line

if type(cmd_line) == "function" then
console.pid = cmd_line(console)
else
if WINE then
	cmd_line = "wineconsole " .. ide:GetProject() .. "data/windows_x64/luajit.exe " .. " " .. ide:GetProject() .. "core/lua/boot.lua " .. cmd_line
elseif jit.os == "Windows" then
	cmd_line = ide:GetProject() .. "goluwa.cmd " .. cmd_line
else
	cmd_line = "./goluwa " .. cmd_line
end

if BRANCH then
	cmd_line = cmd_line .. " branch " .. BRANCH

	if DEBUG then cmd_line = cmd_line .. " debug" end
end

console.pid = CommandLineRun(
	cmd_line,
	console.working_directory,
	true, --tooutput,
	true, --nohide,
	function(...)
		console:print(...)
	end,
	"luacraft_" .. id,
	function()
		tb:ToggleTool(console.wx_start_id, false)
		tb:EnableTool(console.wx_run_id, false)
		tb:Realize()
		self:StopProcess(console.id)
	end
)
end

tb:ToggleTool(console.wx_start_id, true)
tb:EnableTool(console.wx_run_id, true)
tb:Realize()
console.shellbox:SetFocus()

for k, v in pairs(console.env_vars) do
wx.wxUnsetEnv(k)
end
end

function PLUGIN:StopProcess(id)
local console = self.consoles[id]

if self:IsRunning(console.id) then
local pid = self.consoles[id].pid
console:print("stopping " .. console.name .. (" (pid: %d) ... \n"):format(pid))

if jit.os == "Windows" then os.execute("taskkill /F /T /PID " .. pid) end

local ret = wx.wxProcess.Kill(pid, wx.wxSIGKILL, wx.wxKILL_CHILDREN)

if ret == wx.wxKILL_OK then
	console:print(("stopped process (pid: %d).\n"):format(pid))
elseif ret ~= wx.wxKILL_NO_PROCESS then
	wx.wxMilliSleep(250)

	if wx.wxProcess.Exists(pid) then
		console:print(("unable to stop process (pid: %d), code %d.\n"):format(pid, ret))
	end
end

if console.stop then console:stop() end
end
end

function PLUGIN:onRegister()
self.consoles = {}
local tb = ide:GetToolBar()
tb:ClearTools()

for _, info in ipairs(self:Setup()) do
local console = {}

for k, v in pairs(info) do
	console[k] = v
end

console.wx_start_id = NewID()
console.Start = function()
	self:StartProcess(console.id)
end
console.Stop = function()
	self:StopProcess(console.id)
end
console.IsRunning = function()
	return self:IsRunning(console.id)
end
console.Print = function(_, ...)
	console.shellbox:Print(...)
end
tb:AddTool(console.wx_start_id, console.icon, console.icon, true)

ide:GetMainFrame():Connect(console.wx_start_id, wx.wxEVT_COMMAND_MENU_SELECTED, function(event)
	if event:IsChecked() then
		self:StartProcess(console.id)
	else
		self:StopProcess(console.id)
	end
end)

tb:AddLabel(console.wx_start_id, "Start " .. console.name)
console.shellbox = self:CreateRemoteConsole(
	console.name .. " Console",
	function(str)
		if self:IsRunning(console.id) then
			console:run_string(str)
		else
			self:StartProcess(console.id, str)
			console:run_string(str)
		end
	end,
	console.icon
)
self.consoles[console.id] = console
end

tb:AddSeparator()

for _, console in pairs(self.consoles) do
console.wx_run_id = NewID()
tb:AddTool(console.wx_run_id, "", console.icon)

ide:GetMainFrame():Connect(console.wx_run_id, wx.wxEVT_COMMAND_MENU_SELECTED, function(event)
	if self:IsRunning(console.id) then
		local path = ide:GetDocument(ide:GetEditor()).filePath:gsub("\\", "/")
		path = path:match("shared/lua/(.+)") or path
		console:run_script(path)
	end
end)

tb:AddLabel(console.wx_run_id, "Run On " .. console.name)
tb:EnableTool(console.wx_run_id, false)
end

if jit.os ~= "Windows" then
local project_menu = ide:FindTopMenu("&Project")
local MAKE_ID = NewID()
project_menu:Append(MAKE_ID, "Make")

ide:GetMainFrame():Connect(MAKE_ID, wx.wxEVT_COMMAND_MENU_SELECTED, function()
	ide:GetOutput():SetFocus()

	ide:ExecuteCommand("make", ide:GetDocument(ide:GetEditor()).filePath:match("(.+/)"), function(s)
		ide:GetOutput():Print(s)
	end)
end)

local branches = {}
table.insert(branches, {
	wx_id = NewID(),
	branch_id = nil,
	name = "LuaJIT",
})

for _, path in pairs(
	FileSysGetRecursive("../" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/", false, "luajit_*")
) do
	local id = path:match(".+/luajit_(.+)")
	table.insert(
		branches,
		{
			wx_id = ID(id),
			branch_id = id,
			name = id:gsub("_", " "),
		}
	)
end

local branch_menu = ide:MakeMenu()

for i, info in pairs(branches) do
	branch_menu:AppendRadioItem(info.wx_id, info.name)

	ide:GetMainFrame():Connect(info.wx_id, wx.wxEVT_COMMAND_MENU_SELECTED, function()
		BRANCH = info.branch_id
		DEBUG = info.name:find("debug") ~= nil
		ide:Print("selected branch ", info.name)
	end)
end

project_menu:AppendSubMenu(branch_menu, "LuaJIT Branch")
end

tb:Realize()
end

function PLUGIN:onUnregister()
for _, console in pairs(self.consoles) do
console:Stop()
end
end

function PLUGIN:onEditorKeyDown(event)
if not event.GetKeyCode then return end -- huh
local keycode = event:GetKeyCode()
local mod = event:GetModifiers()

for _, console in pairs(self.consoles) do
if console.on_key then
	local res = console:on_key(true)

	if res ~= nil then return res end
end
end
end

function PLUGIN:onIdle()
if not self.focused_once then
self.consoles.client.shellbox:SetFocus()
self.focused_once = true
end

for _, console in pairs(self.consoles) do
if console.on_update then console:on_update() end

if console.restart and not self:IsRunning(console.id) then
	self:StartProcess(console.id)
	console.restart = nil
end

if console.on_key then console:on_key(false) end
end
end

function PLUGIN:onEditorSave(editor)
local path = ide:GetDocument(editor).filePath:gsub("\\", "/")

for _, console in pairs(self.consoles) do
if console.on_save and self:IsRunning(console.id) then
	console:on_save(path)
end
end
end

function PLUGIN:CreateRemoteConsole(name, on_execute, bitmap)
--ide.frame.bottomnotebook:RemovePage(0)
local shellbox = ide:CreateStyledTextCtrl(
ide.frame.bottomnotebook,
wx.wxID_ANY,
wx.wxDefaultPosition,
wx.wxDefaultSize,
wx.wxBORDER_NONE
)
local page = ide.frame.bottomnotebook:AddPage(shellbox, name, false, bitmap)
-- Copyright 2011-16 Paul Kulchenko, ZeroBrane LLC
-- authors: Luxinia Dev (Eike Decker & Christoph Kubisch)
---------------------------------------------------------
local ide = ide
local unpack = table.unpack or unpack
local bottomnotebook = ide.frame.bottomnotebook
local console = shellbox
local remotesend
local PROMPT_MARKER = StylesGetMarker("prompt")
local PROMPT_MARKER_VALUE = 2 ^ PROMPT_MARKER
local ERROR_MARKER = StylesGetMarker("error")
local OUTPUT_MARKER = StylesGetMarker("output")
local MESSAGE_MARKER = StylesGetMarker("message")
local config = ide.config.console
console:SetFont(
wx.wxFont(
	config.fontsize or 10,
	wx.wxFONTFAMILY_MODERN,
	wx.wxFONTSTYLE_NORMAL,
	wx.wxFONTWEIGHT_NORMAL,
	false,
	config.fontname or "",
	config.fontencoding or wx.wxFONTENCODING_DEFAULT
)
)
console:StyleSetFont(wxstc.wxSTC_STYLE_DEFAULT, console:GetFont())
console:SetBufferedDraw(not ide.config.hidpi and true or false)
console:StyleClearAll()
console:SetTabWidth(ide.config.editor.tabwidth or 2)
console:SetIndent(ide.config.editor.tabwidth or 2)
console:SetUseTabs(ide.config.editor.usetabs and true or false)
console:SetViewWhiteSpace(ide.config.editor.whitespace and true or false)
console:SetIndentationGuides(true)
console:SetWrapMode(wxstc.wxSTC_WRAP_WORD)
console:SetWrapStartIndent(0)
console:SetWrapVisualFlagsLocation(wxstc.wxSTC_WRAPVISUALFLAGLOC_END_BY_TEXT)
console:SetWrapVisualFlags(wxstc.wxSTC_WRAPVISUALFLAG_END)
console:MarkerDefine(StylesGetMarker("prompt"))
console:MarkerDefine(StylesGetMarker("error"))
console:MarkerDefine(StylesGetMarker("output"))
console:MarkerDefine(StylesGetMarker("message"))
console:SetReadOnly(false)
SetupKeywords(console, "lua", nil, ide.config.stylesoutshell)

local function getPromptLine()
local totalLines = console:GetLineCount()
return console:MarkerPrevious(totalLines + 1, PROMPT_MARKER_VALUE)
end

local function getPromptText()
local prompt = getPromptLine()
return console:GetTextRangeDyn(console:PositionFromLine(prompt), console:GetLength())
end

local function setPromptText(text)
local length = console:GetLength()
console:SetSelectionStart(length - string.len(getPromptText()))
console:SetSelectionEnd(length)
console:ClearAny()
console:AddTextDyn(text)
-- refresh the output window to force recalculation of wrapped lines;
-- otherwise a wrapped part of the last line may not be visible.
console:Update()

console:Refresh()
console:GotoPos(console:GetLength())
end

local function positionInLine(line)
return console:GetCurrentPos() - console:PositionFromLine(line)
end

local function caretOnPromptLine(disallowLeftmost, line)
local promptLine = getPromptLine()
local currentLine = line or console:GetCurrentLine()
local boundary = disallowLeftmost and 0 or -1
return (
		currentLine > promptLine or
		currentLine == promptLine and
		positionInLine(promptLine) > boundary
	)
end

local function chomp(line)
return (line:gsub("%s+$", ""))
end

local function getInput(line)
local count = console:GetLineCount()
local nextMarker = line or count

repeat -- check until we find at least some marker
	nextMarker = nextMarker + 1
until console:MarkerGet(nextMarker) > 0 or nextMarker > count - 1

return chomp(
	console:GetTextRangeDyn(console:PositionFromLine(line), console:PositionFromLine(nextMarker))
)
end

local command_history = {}
local history_i = 0

local function getNextHistoryLine(backward)
if backward then
	history_i = history_i + 1
else
	history_i = history_i - 1
end

return command_history[history_i % #command_history + 1] or ""
end

local function getNextHistoryMatch(promptText)
for i, v in ipairs(command_history) do
	if promptText:find(v, nil, true) then return v end
end
end

local function concat(sep, ...)
local text = ""

for i = 1, select("#", ...) do
	text = text .. (i > 1 and sep or "") .. tostring(select(i, ...))
end

return text
end

local partial = false

local function shellPrint(marker, text, newline)
if not text or text == "" then return end -- return if nothing to print
--if newline then text = text:gsub("\n+$", "").."\n" end
local isPrompt = marker and (getPromptLine() ~= wx.wxNOT_FOUND)
local lines = console:GetLineCount()
local promptLine = isPrompt and getPromptLine() or nil
local insertLineAt = isPrompt and not partial and getPromptLine() or console:GetLineCount() - 1
local insertAt = isPrompt and
	not partial and
	console:PositionFromLine(getPromptLine()) or
	console:GetLength()
console:InsertTextDyn(
	insertAt,
	console.useraw and
		text or
		FixUTF8(text, function(s)
			return "\\" .. string.byte(s)
		end)
)
local linesAdded = console:GetLineCount() - lines
partial = text:find("\n$") == nil

if marker then
	if promptLine then console:MarkerDelete(promptLine, PROMPT_MARKER) end

	for line = insertLineAt, insertLineAt + linesAdded - 1 do
		console:MarkerAdd(line, marker)
	end

	if promptLine then console:MarkerAdd(promptLine + linesAdded, PROMPT_MARKER) end
end

console:EmptyUndoBuffer() -- don't allow the user to undo shell text
console:GotoPos(console:GetLength())
console:EnsureVisibleEnforcePolicy(console:GetLineCount() - 1)
end

local displayShellDirect = function(...)
shellPrint(nil, concat("\t", ...), true)
end
local DisplayShell = function(...)
shellPrint(OUTPUT_MARKER, concat("\t", ...), true)
end
local DisplayShellErr = function(...)
shellPrint(ERROR_MARKER, concat("\t", ...), true)
end
-- don't print anything; just mark the line with a prompt mark
local DisplayShellPrompt = function(...)
console:MarkerAdd(console:GetLineCount() - 1, PROMPT_MARKER)
end

function console:Print(...)
return DisplayShell(...)
end

function console:Write(...)
return shellPrint(OUTPUT_MARKER, concat("", ...), false)
end

function console:Error(...)
return DisplayShellErr(...)
end

local function executeShellCode(tx)
if tx == nil or tx == "" then return end

DisplayShellPrompt("")
on_execute(tx)
end

function console:GetRemote()
return remotesend
end

function console:SetRemote(client)
remotesend = client
local index = bottomnotebook:GetPageIndex(console)

if index then
	bottomnotebook:SetPageText(index, client and TR("Remote console") or TR("Local console"))
end
end

console:Connect(wx.wxEVT_KEY_DOWN, function(event)
-- this loop is only needed to allow to get to the end of function easily
-- "return" aborts the processing and ignores the key
-- "break" aborts the processing and processes the key normally
while true do
	local key = event:GetKeyCode()
	local modifiers = event:GetModifiers()

	if key == wx.WXK_UP or key == wx.WXK_NUMPAD_UP then
		-- if we are below the prompt line, then allow to go up
		-- through multiline entry
		if console:GetCurrentLine() > getPromptLine() then break end

		-- if we are not on the caret line, or are on wrapped caret line, move normally
		if
			not caretOnPromptLine() or
			console:GetLineWrapped(console:GetCurrentPos(), -1)
		then
			break
		end

		-- only change prompt if no modifiers are used (to allow for selection movement)
		if modifiers == wx.wxMOD_NONE then
			local promptText = getPromptText()
			setPromptText(getNextHistoryLine(false, promptText))
		-- move to the beginning of the updated prompt
		--console:GotoPos(console:PositionFromLine(getPromptLine()))
		end

		return
	elseif key == wx.WXK_DOWN or key == wx.WXK_NUMPAD_DOWN then
		-- if we are above the last line, then allow to go down
		-- through multiline entry
		local totalLines = console:GetLineCount() - 1

		if console:GetCurrentLine() < totalLines then break end

		-- if we are not on the caret line, or are on wrapped caret line, move normally
		if
			not caretOnPromptLine() or
			console:GetLineWrapped(console:GetCurrentPos(), 1)
		then
			break
		end

		-- only change prompt if no modifiers are used (to allow for selection movement)
		if modifiers == wx.wxMOD_NONE then
			local promptText = getPromptText()
			setPromptText(getNextHistoryLine(true, promptText))
		-- staying at the end of the updated prompt
		end

		return
	elseif key == wx.WXK_TAB then
		-- if we are above the prompt line, then don't move
		local promptline = getPromptLine()

		if console:GetCurrentLine() < promptline then return end

		local promptText = getPromptText()
		-- save the position in the prompt text to restore
		local pos = console:GetCurrentPos()
		local text = promptText:sub(1, positionInLine(promptline))

		if #text == 0 then return end

		-- find the next match and set the prompt text
		local match = getNextHistoryMatch(text)

		if match then
			setPromptText(match)
			-- restore the position to make it easier to find the next match
			console:GotoPos(pos)
		end

		return
	elseif key == wx.WXK_ESCAPE then
		setPromptText("")
		return
	elseif key == wx.WXK_BACK or key == wx.WXK_LEFT or key == wx.WXK_NUMPAD_LEFT then
		if
			(
				key == wx.WXK_BACK or
				console:LineFromPosition(console:GetCurrentPos()) >= getPromptLine()
			)
			and
			not caretOnPromptLine(true)
		then
			if key == wx.WXK_BACK then setPromptText("") end

			return
		end
	elseif key == wx.WXK_DELETE or key == wx.WXK_NUMPAD_DELETE then
		if
			not caretOnPromptLine() or
			console:LineFromPosition(console:GetSelectionStart()) < getPromptLine()
		then
			return
		end
	elseif
		key == wx.WXK_PAGEUP or
		key == wx.WXK_NUMPAD_PAGEUP or
		key == wx.WXK_PAGEDOWN or
		key == wx.WXK_NUMPAD_PAGEDOWN or
		key == wx.WXK_END or
		key == wx.WXK_NUMPAD_END or
		key == wx.WXK_HOME or
		key == wx.WXK_NUMPAD_HOME -- `key == wx.WXK_LEFT or key == wx.WXK_NUMPAD_LEFT` are handled separately
		or
		key == wx.WXK_RIGHT or
		key == wx.WXK_NUMPAD_RIGHT or
		key == wx.WXK_SHIFT or
		key == wx.WXK_CONTROL or
		key == wx.WXK_ALT
	then
		break
	elseif key == wx.WXK_RETURN or key == wx.WXK_NUMPAD_ENTER then
		if
			not caretOnPromptLine() or
			console:LineFromPosition(console:GetSelectionStart()) < getPromptLine()
		then
			return
		end

		-- allow multiline entry for shift+enter
		if caretOnPromptLine(true) and event:ShiftDown() then break end

		local promptText = getPromptText()

		if #promptText == 0 then return end -- nothing to execute, exit
		if promptText == "clear" then
			console:Erase()
		elseif promptText == "reset" then
			console:Reset()
			setPromptText("")
		else
			displayShellDirect("\n")
			executeShellCode(promptText)
		end

		if command_history[#command_history] ~= promptText then
			table.insert(command_history, promptText)
		end

		history_i = #command_history
		return -- don't need to do anything else with return
	elseif modifiers == wx.wxMOD_NONE or console:GetSelectedText() == "" then
		-- move cursor to end if not already there
		if not caretOnPromptLine() then
			console:GotoPos(console:GetLength())
			console:SetReadOnly(false) -- allow the current character to appear at the new location
		-- check if the selection starts before the prompt line and reset it
		elseif console:LineFromPosition(console:GetSelectionStart()) < getPromptLine() then
			console:GotoPos(console:GetLength())
			console:SetSelection(console:GetSelectionEnd() + 1, console:GetSelectionEnd())
		end
	end

	break
end

event:Skip()
end)

local function inputEditable(line)
return caretOnPromptLine(false, line) and
	not (
		console:LineFromPosition(console:GetSelectionStart()) < getPromptLine()
	)
end

-- Scintilla 3.2.1+ changed the way markers move when the text is updated
-- ticket: http://sourceforge.net/p/scintilla/bugs/939/
-- discussion: https://groups.google.com/forum/?hl=en&fromgroups#!topic/scintilla-interest/4giFiKG4VXo
if ide.wxver >= "2.9.5" then
-- this is a workaround that stores a position of the last prompt marker
-- before insert and restores the same position after as the marker
-- could have moved if the text is added at the beginning of the line.
local promptAt

console:Connect(wxstc.wxEVT_STC_MODIFIED, function(event)
	local evtype = event:GetModificationType()

	if bit.band(evtype, wxstc.wxSTC_MOD_BEFOREINSERT) ~= 0 then
		local promptLine = getPromptLine()

		if promptLine and event:GetPosition() == console:PositionFromLine(promptLine) then
			promptAt = promptLine
		end
	end

	if bit.band(evtype, wxstc.wxSTC_MOD_INSERTTEXT) ~= 0 then
		local promptLine = getPromptLine()

		if promptLine and promptAt then
			console:MarkerDelete(promptLine, PROMPT_MARKER)
			console:MarkerAdd(promptAt, PROMPT_MARKER)
			promptAt = nil
		end
	end
end)
end

console:Connect(wxstc.wxEVT_STC_UPDATEUI, function(event)
console:SetReadOnly(not inputEditable())
end)

-- only allow copy/move text by dropping to the input line
console:Connect(wxstc.wxEVT_STC_DO_DROP, function(event)
if not inputEditable(console:LineFromPosition(event:GetPosition())) then
	event:SetDragResult(wx.wxDragNone)
end
end)

if config.nomousezoom then
-- disable zoom using mouse wheel as it triggers zooming when scrolling
-- on OSX with kinetic scroll and then pressing CMD.
console:Connect(wx.wxEVT_MOUSEWHEEL, function(event)
	if wx.wxGetKeyState(wx.WXK_CONTROL) then return end

	event:Skip()
end)
end

function console:Erase()
-- save the last command to keep when the history is cleared
--currentHistory = getPromptLine()
--lastCommand = getNextHistoryLine(false, "")
-- allow writing as the editor may be read-only depending on current cursor position
self:SetReadOnly(false)
self:ClearAll()
end

function console:Reset() end

local jumptopatterns = {
-- <filename>(line,linepos):
"^%s*(.-%.lua)%((%d+),(%d+)%)%s*:",
-- <filename>(line):
"^%s*(.-%.lua)%((%d+).*%)%s*:",
--[string "<filename>"]:line:
"^.-%[string \"([^\"]+)\"%]:(%d+)%s*:",
-- <filename>:line:linepos
"^%s*(.-%.lua):(%d+):(%d+):",
"%s+(%S+%.lua):(%d+):(%d+)",
-- <filename>:line:
"^%s*(.-%.lua):(%d+)%s*:",
-- <filename>:line
"(%S-%.lua):(%d+)",
"Line (%d+).-@(%S+%.lua)",
"(%d+)%s-@(%S+%.lua)",
"(%d+)%s-(%S+%.lua)",
"@(%S+%.lua):(%d+)",
"@(%S+%.lua)",
"(%S+%.lua):(%d+)",
"(%S+%.lua)",
}

console:Connect(wxstc.wxEVT_STC_DOUBLECLICK, function(event)
local line = console:GetCurrentLine()
local linetx = console:GetLineDyn(line)
-- try to detect a filename and line in linetx
local fname, jumpline, jumplinepos

for _, pattern in ipairs(jumptopatterns) do
	fname, jumpline, jumplinepos = linetx:match(pattern)

	if fname then ide:Print(pattern, " = ", fname, jumpline, jumplinepos) end

	if tonumber(fname) then
		local line = tonumber(fname)
		fname = jumpline
		jumpline = line
	end

	if fname then break end
end

jumpline = jumpline or 0

if not fname then return end

-- fname may include name of executable, as in "path/to/lua: file.lua";
-- strip it and try to find match again if needed.
-- try the stripped name first as if it doesn't match, the longer
-- name may have parts that may be interpreter as network path and
-- may take few seconds to check.
local name
local fixedname = fname:match(":%s+(.+)")

if fixedname then
	name = GetFullPathIfExists(ide:GetProject(), fixedname) or
		FileTreeFindByPartialName(fixedname)
end

name = name or
	GetFullPathIfExists(ide:GetProject(), fname) or
	FileTreeFindByPartialName(fname)
ide:Print(name, fname, jumpline, jumplinepos)
local editor = LoadFile(name or fname, nil, true)

if not editor then
	local ed = ide:GetEditor()

	if ed and ide:GetDocument(ed):GetFileName() == (name or fname) then
		editor = ed
	end
end

if editor then
	jumpline = tonumber(jumpline)
	jumplinepos = tonumber(jumplinepos)
	editor:GotoPos(
		editor:PositionFromLine(math.max(0, jumpline - 1)) + (
				jumplinepos and
				(
					math.max(0, jumplinepos - 1)
				) or
				0
			)
	)
	editor:EnsureVisibleEnforcePolicy(jumpline)
	editor:SetFocus()
end

-- doubleclick can set selection, so reset it
local pos = event:GetPosition()

if pos == wx.wxNOT_FOUND then
	pos = console:GetLineEndPosition(event:GetLine())
end

console:SetSelection(pos, pos)
end)

shellbox:Connect(wx.wxEVT_CONTEXT_MENU, function(event)
local menu = ide:MakeMenu({
	{ID_UNDO, TR("&Undo")},
	{ID_REDO, TR("&Redo")},
	{},
	{ID_CUT, TR("Cu&t")},
	{ID_COPY, TR("&Copy")},
	{ID_PASTE, TR("&Paste")},
	{ID_SELECTALL, TR("Select &All")},
	{},
	{ID_CLEARCONSOLE, TR("C&lear Console Window")},
}
)

if ide.osname == "Unix" then UpdateMenuUI(menu, shellbox) end

shellbox:PopupMenu(menu)
end)

shellbox:Connect(ID_CLEARCONSOLE, wx.wxEVT_COMMAND_MENU_SELECTED, function(event)
shellbox:Erase()
end)

return shellbox, page
end

return PLUGIN