if not system.OSCommandExists("tmux", "tar") then return end

gserv = gserv or {}

gserv.workshop_auth_key = pvars.Setup("gserv_authkey")
gserv.workshop_collection = "https://steamcommunity.com/sharedfiles/filedetails/?id=427843415"

gserv.startup_parameters = {
	maxplayers = 32,
	map = "gm_construct",
}

gserv.cfg = {
	sv_hibernate_think = 1, -- so watchdog can run even if there are no players on the server
}

local srcds_dir = e.DATA_FOLDER .. "srcds/"
local gmod_dir = srcds_dir .. "gmod/garrysmod/"
local gserv_addon_dir = gmod_dir .. "addons/gserv/"
local log_dir = e.USERDATA_FOLDER .. "logs/gserv/"

local function load_configs()
	if not gserv.loaded_configs then
		table.merge(gserv.startup_parameters, serializer.ReadFile("luadata", "data/gserv_startup_parameters.lua") or {})
		table.merge(gserv.cfg, serializer.ReadFile("luadata", "data/gserv_config.lua") or {})
		gserv.loaded_configs = true
	end
end

local function check_setup() if not gserv.IsSetup() then error("server is not setup", 3) end end
local function check_running() if not gserv.IsRunning() then error("server is not running", 3) end end

function gserv.IsSetup()
	if vfs.IsFile(gserv_addon_dir .. "lua/autorun/server/server_watchdog.lua") then
		return true
	end
end

function gserv.Setup()
	if gserv.IsRunning() then error("server is running", 2) end

	logn("setting up gmod server")

	-- create the srcds directory in goluwa/data/srcds
	vfs.CreateFolder("os:" .. srcds_dir)

	-- download steamcmd
	resource.Download("http://media.steampowered.com/client/steamcmd_linux.tar.gz", function(path)

		-- if steamcmd.sh does not exist then we need to extract it
		if not vfs.IsFile(srcds_dir .. "steamcmd.sh") then
			os.execute("tar -xvzf " .. vfs.GetAbsolutePath(path) .. " -C " .. srcds_dir)
		end

		-- if srcds_run does not exist install gmod
		if not vfs.IsFile(srcds_dir .. "gmod/srcds_run") then
			os.execute(srcds_dir .. "steamcmd.sh +login anonymous +force_install_dir " .. srcds_dir .. "gmod +app_update 4020 validate +quit")
		end

		-- create glua script that writes os.time to a file every second
		if not vfs.IsFile(gserv_addon_dir .. "lua/autorun/server/server_watchdog.lua") then
			vfs.CreateFolders("os", gserv_addon_dir .. "lua/autorun/server/")
			vfs.Write(gserv_addon_dir .. "lua/autorun/server/server_watchdog.lua", [[
				timer.Create("server_watchdog", 1, 0, function()
					file.Write("server_watchdog.txt", os.time(), "DATA")
				end)
			]])
		end

		vfs.Write(gmod_dir .. "cfg/server.cfg", "exec gserv.cfg\n")

		-- silence some startup errors
		vfs.Write(gmod_dir .. "cfg/trusted_keys_base.txt", "trusted_key_list\n{\n}\n")
		vfs.Write(gmod_dir .. "cfg/pure_server_minimal.txt", "whitelist\n{\n}\n")
		vfs.Write(gmod_dir .. "cfg/network.cfg", "")
	end)
end

do
	function gserv.SetConfigParameter(key, val)
		check_setup()
		load_configs()
		gserv.cfg[key] = val
		serializer.WriteFile("luadata", "data/gserv_config.lua", gserv.cfg)
		gserv.BuildConfig()
		if gserv.IsRunning() then
			gserv.Execute(key .. " " .. val)
		end
	end

	function gserv.GetConfigParameter(key)
		check_setup()
		load_configs()
		return gserv.cfg[key]
	end

	function gserv.BuildConfig()
		check_setup()

		-- write the cfg file
		local str = ""
		for k,v in pairs(gserv.cfg) do
			str = str .. k .. " " .. v .. "\n"
		end
		vfs.Write(gmod_dir .. "cfg/gserv.cfg", str)
	end
end

do
	function gserv.SetStartupParameter(key, val)
		load_configs()

		gserv.startup_parameters[key] = val
		serializer.WriteFile("luadata", "data/gserv_startup_parameters.lua", gserv.startup_parameters)
	end

	function gserv.GetStartupParameter(key)
		load_configs()

		return gserv.startup_parameters[key]
	end
end

do -- addons
	function gserv.UpdateAddons()
		check_setup()

		for url, info in pairs(gserv.GetAddons()) do
			gserv.UpdateAddon(url)
		end
	end

	function gserv.UpdateAddon(url)
		check_setup()

		local info = assert(gserv.GetAddon(url))

		if info.type == "git" then
			logn("updating git repository addon ", info.url)
			local dir = gmod_dir .. "addons/" .. info.name

			if not vfs.IsDirectory(dir) then
				os.execute("git clone " .. info.url .. " " .. dir)
			else
				os.execute("git -C " .. dir .. " reset --hard HEAD")
				os.execute("git -C " .. dir .. " clean -f -d")
				os.execute("git -C " .. dir .. " pull")
			end
			logn("done updating ", info.url)
		elseif info.type == "workshop" then
			logn("updating workshop addon ", info.url)
			steam.DownloadWorkshop(info.id, function(header, compressed_path)
				vfs.Write(gmod_dir .. "addons/".. info.name, serializer.ReadFile("lzma", compressed_path))
				logn("done updating ", info.url)
			end)
		end
	end

	function gserv.AddAddon(url, name_override)
		check_setup()

		local key = url
		local info

		if url:find("github.com", nil, true) and not url:endswith(".git") then
			url = url .. ".git"
		end

		if url:endswith(".git") then
			info = {
				url = url,
				type = "git",
				name = name_override or url:match(".+/(.+)%.git"):lower(),
			}
		elseif url:find("steamcommunity") and url:find("id=%d+") then
			info = {
				url = url,
				id = url:match("id=(%d+)"),
				type = "workshop",
				name = name_override or url:match("id=(%d+)") .. ".gma",
			}
		else
			info = {
				url = url,
				type = "unknown",
				name = name_override or vfs.FixIllegalCharactersInPath(url):lower():gsub("%s+", "_"),
			}
		end

		serializer.SetKeyValueInFile("luadata", "data/gserv_addons.lua", key, info)
	end

	function gserv.RemoveAddon(url)
		check_setup()

		local info = assert(gserv.GetAddon(url))

		local path = gmod_dir .. "addons/".. info.name

		if vfs.IsFile(path) then
			vfs.Delete(path)
		elseif vfs.IsDirectory(path) then
			os.execute("rm -rf " .. path)
		end

		serializer.SetKeyValueInFile("luadata", "data/gserv_addons.lua", url, nil)
	end

	function gserv.GetAddon(url)
		check_setup()

		return serializer.GetKeyFromFile("luadata", "data/gserv_addons.lua", url)
	end

	function gserv.GetAddons()
		check_setup()

		return serializer.ReadFile("luadata", "data/gserv_addons.lua")
	end
end

do
	function gserv.IsRunning()
		return io.popen("tmux has-session -t goluwa_srcds 2>&1"):read("*all") == ""
	end

	function gserv.Start()
		check_setup()

		if gserv.IsRunning() then error("server is running", 2) end

		load_configs()

		logn("starting gmod server")

		vfs.Write(gmod_dir .. "data/server_watchdog.txt", "booting")

		os.execute("tmux kill-session -t goluwa_srcds 2>/dev/null")
		os.execute("tmux new-session -d -s goluwa_srcds")

		gserv.log_path = log_dir .. os.date("%Y/%m/%d/%H-%M-%S.txt")
		vfs.CreateFolders("os", gserv.log_path)
		os.execute("tmux pipe-pane -o -t goluwa_srcds 'cat >> " .. gserv.log_path .. "'")

		gserv.BuildConfig()

		local str = ""
		for k, v in pairs(gserv.startup_parameters) do
			str = str .. "+" .. k .. " " .. v .. " "
		end

		if gserv.workshop_collection then
			local id = tonumber(gserv.workshop_collection) or gserv.workshop_collection:match("id=(%d+)") or gserv.workshop_collection
			str = str .. "+workshop_collection " .. id
		end

		local key = gserv.workshop_auth_key:Get()

		if key then
			str = str .. "-authkey " .. key
		end

		os.execute("tmux send-keys -t goluwa_srcds \"" .. srcds_dir .. "gmod/srcds_run -game garrysmod " .. str .. "\" C-m")

		event.Timer("gserv_watchdog", 1, 0, function()
			local time = vfs.Read(gmod_dir .. "data/server_watchdog.txt")

			if time then
				if time == "booting" then return end

				time = tonumber(time)
				local diff = os.difftime(os.time(), time)
				if diff > 1 then
					logn("server hasn't responded for more than ", diff ," seconds")
					if diff > 20 then
						gserv.Reboot()
					end
				end
			end
		end)
	end

	function gserv.Kill()
		event.RemoveTimer("gserv_watchdog")

		check_running()

		logn("killing gmod server")
		os.execute("tmux kill-session -t goluwa_srcds 2>/dev/null")
	end

	function gserv.Reboot()
		if gserv.IsRunning() then
			gserv.Kill()
		end
		gserv.Start()
	end

end

function gserv.GetOutput()
	check_running()

	local str = vfs.Read(gserv.log_path)
	str = str:gsub("\r", "")

	return str
end

function gserv.Show()
	check_running()

	logn(gserv.GetOutput())
end

function gserv.Execute(line)
	check_running()

	os.execute("tmux send-keys -t goluwa_srcds \"" .. line .. "\" C-m")
end

function gserv.Stop()
	check_running()

	gserv.Execute("exit")
	event.Delay(1, function() gserv.Kill() end)
end

function gserv.RunLua(line)
	check_running()

	gserv.Execute("lua_run " .. line)
end

-- this is really stupid but idk what else to do at the moment
function gserv.GetLuaOutput(line)
	check_running()

	local id = tostring({})
	gserv.RunLua("file.Write('gserv_capture_output.txt', '" .. id .."' .. tostring((function()"..line.."end)()), 'DATA')")
	while true do
		local str = vfs.Read(gmod_dir .. "data/gserv_capture_output.txt")
		if str and str:startswith(id) then
			return str:sub(#id + 1)
		end
	end
end

function gserv.GetMap()
	check_running()

	return gserv.GetLuaOutput("return game.GetMap()")
end

function gserv.Restart(time)
	check_running()

	time = time or 0
	logn("restarting server in ", time, " seconds")
	gserv.RunLua("if aowl then RunConsoleCommand('aowl', 'restart', '"..time.."') else timer.Simple("..time..", function() RunConsoleCommand('changelevel', game.GetMap()) end) end")
end

do -- commands
	commands.Add("gserv setup", function() gserv.Setup() end)

	commands.Add("gserv start", function() gserv.Start() end)
	commands.Add("gserv stop", function() gserv.Stop() end)
	commands.Add("gserv kill", function() gserv.Kill() end)
	commands.Add("gserv show", function() gserv.Show() end)
	commands.Add("gserv restart=number[30]", function(time) print("!?") gserv.Restart(time) end)
	commands.Add("gserv reboot", function() gserv.Reboot() end)

	commands.Add("gserv add_addon=string", function(url) gserv.AddAddon(url) end)
	commands.Add("gserv remove_addon=string", function(url) gserv.RemoveAddon(url) end)
	commands.Add("gserv update_addon=string", function(url) gserv.UpdateAddon(url) end)

	commands.Add("gserv add_addon=string", function(url) gserv.AddAddon(url) end)
	commands.Add("gserv remove_addon=string", function(url) gserv.RemoveAddon(url) end)
	commands.Add("gserv update_addon=string", function(url) gserv.UpdateAddon(url) end)
	commands.Add("gserv update_addons", function() gserv.UpdateAddons() end)

	commands.Add("gserv list_addons", function() table.print(gserv.GetAddons()) end)
	commands.Add("gserv list_config", function() table.print(gserv.cfg) end)
	commands.Add("gserv list_startup", function() table.print(gserv.startup_parameters) end)

	commands.Add("gserv setup_info", function()
		logn("startup parameters:")
		table.print(gserv.startup_parameters)

		logn("server config:")
		table.print(gserv.cfg)

		logn("addons:")
		table.print(gserv.GetAddons())
	end)

	commands.Add("gserv set_startup_param=string,string", function(key, val) gserv.SetStartupParameter(key, val) end)
	commands.Add("gserv get_startup_param=string", function(key) logn(gserv.GetStartupParameter(key)) end)

	commands.Add("gserv set_config_param=string,string", function(key, val) gserv.SetConfigParameter(key, val) end)
	commands.Add("gserv get_config_param=string", function(key) logn(gserv.GetConfigParameter(key)) end)

	commands.Add("gserv run=arg_line", function(str)
		logn("running |", str, "| on srcds")
		gserv.Execute(str)
		event.Delay(0.1, function() gserv.Show() end)
	end)

	commands.Add("gserv lua=arg_line", function(code)
		logn("running |lua_run ", code, "| on srcds")
		gserv.RunLua(code)
		event.Delay(0.1, function() gserv.Show() end)
	end)
end