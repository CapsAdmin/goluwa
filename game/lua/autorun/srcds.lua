if not system.OSCommandExists("tmux", "tar") then return end

gserv = gserv or {}

gserv.loaded_config = false

gserv.config = {
	ip = nil,
	port = 27015,

	workshop_authkey = nil,
	workshop_collection = nil,

	webhook_port = 27020,
	webhook_secret = false,

	startup = {
		maxplayers = 32,
		map = "gm_construct",
	},

	launch = {
		"disableluarefresh",
	},

	cfg = {
		sv_hibernate_think = 1, -- so pinger can run even if there are no players on the server
	},

	addons = {},
}

local function get_gmod_dir()
	return gserv.GetInstallDir() .. "/garrysmod/"
end

local function get_gserv_addon_dir()
	return get_gmod_dir() .. "addons/gserv/"
end

local srcds_dir = e.DATA_FOLDER .. "srcds/"

local data_dir = "data/gserv/"

local function load_config()
	if not gserv.loaded_config then
		table.merge(gserv.config, serializer.ReadFile("luadata", data_dir .. "config.lua") or {})
		gserv.loaded_config = true
	end
end

local function save_config()
	serializer.WriteFile("luadata", data_dir .. "config.lua", gserv.config)
end

local function check_setup() if not gserv.IsSetup() then error("server is not setup", 3) end end
local function check_running() if not gserv.IsRunning() then error("server is not running", 3) end end

function gserv.IsSetup()
	if
		gserv.GetInstallDir() and
		vfs.IsFile(gserv.GetInstallDir() .. "/srcds_run") and
		vfs.IsFile(get_gserv_addon_dir() .. "lua/autorun/server/gserv_pinger.lua")
	then
		return true
	end
end

function gserv.Setup()
	if gserv.IsRunning() then error("server is running", 2) end

	if gserv.IsSetup() then
		logn("server is already setup")
	else
		logn("setting up gmod server for first time")
	end

	gserv.InstallGame("gmod", nil, function()
		-- create glua script that writes os.time to a file every second
		if not vfs.IsFile(get_gserv_addon_dir() .. "lua/autorun/server/gserv_pinger.lua") then
			vfs.CreateFolders("os", get_gserv_addon_dir() .. "lua/autorun/server/")
			vfs.Write(get_gserv_addon_dir() .. "lua/autorun/server/gserv_pinger.lua", [[
				timer.Create("gserv_pinger", 1, 0, function()
					file.Write("gserv_pinger.txt", os.time(), "DATA")
				end)
			]])
		end

		vfs.Write(get_gmod_dir() .. "cfg/server.cfg", "exec gserv.cfg\n")

		-- silence some startup errors
		vfs.Write(get_gmod_dir() .. "cfg/trusted_keys_base.txt", "trusted_key_list\n{\n}\n")
		vfs.Write(get_gmod_dir() .. "cfg/pure_server_minimal.txt", "whitelist\n{\n}\n")
		vfs.Write(get_gmod_dir() .. "cfg/network.cfg", "")

		gserv.BuildMountConfig()
	end)
end

function gserv.InstallGame(name, dir, callback)
	if gserv.IsRunning() then error("server is running", 2) end

	local appid, full_name = steam.GetAppIdFromName(name .. " Dedicated Server")
	if not appid and tonumber(name) then
		appid = tonumber(name)
	end

	if not appid then
		error("could not find " .. name, 2)
	end

	local dir_name = dir or full_name:lower():gsub("%p", ""):gsub("%s+", "_")

	logn("setting up " .. name)

	-- create the srcds directory in goluwa/data/srcds
	vfs.CreateFolder("os:" .. srcds_dir)

	-- download steamcmd
	resource.Download("http://media.steampowered.com/client/steamcmd_linux.tar.gz", function(path)

		-- if steamcmd.sh does not exist then we need to extract it
		if not vfs.IsFile(srcds_dir .. "steamcmd.sh") then
			os.execute("tar -xvzf " .. vfs.GetAbsolutePath(path) .. " -C " .. srcds_dir)
		end

		logn("installing ", name, " (", appid, ")", " to ", srcds_dir .. dir_name)

		serializer.SetKeyValueInFile("luadata", data_dir .. "games.lua", appid, srcds_dir .. dir_name)
		os.execute(srcds_dir .. "steamcmd.sh +login anonymous +force_install_dir \"" .. srcds_dir .. dir_name .. "\" +app_update " .. appid .. " validate +quit")

		logn("done")
		if callback then callback() end
	end)
end

function gserv.GetInstallDir()
	return gserv.GetInstalledGames()[4020]
end

function gserv.GetInstalledGames()
	return serializer.ReadFile("luadata", data_dir .. "games.lua") or {}
end

function gserv.BuildMountConfig()
	local str = '"mountcfg"\n'
	str = str .. "{\n"

	for appid, dir in pairs(gserv.GetInstalledGames()) do
		if appid ~= 4020 then
			for _, dir in ipairs(vfs.Find(dir .. "/", true)) do
				local gameinfo = vfs.IsFile(dir .. "/gameinfo.txt")
				if gameinfo then
					local name = dir:match(".+/(.+)")

					str = str .. "\t\"" .. name .. "\"\t\t" .. "\""..dir.."\"\n"
				end
			end
		end
	end

	str = str .. "}"

	vfs.Write(get_gmod_dir() .. "cfg/mount.cfg", str)
end

do
	function gserv.SetConfigParameter(key, val)
		check_setup()
		load_config()
		gserv.config.cfg[key] = val
		save_config()
		gserv.BuildConfig()
		if gserv.IsRunning() then
			gserv.Execute(key .. " " .. val)
		end
	end

	function gserv.GetConfigParameter(key)
		check_setup()
		load_config()
		return gserv.config.cfg[key]
	end

	function gserv.BuildConfig()
		check_setup()

		-- write the cfg file
		local str = ""
		for k,v in pairs(gserv.config.cfg) do
			str = str .. k .. " " .. v .. "\n"
		end
		vfs.Write(get_gmod_dir() .. "cfg/gserv.cfg", str)
	end
end

do
	function gserv.SetStartupParameter(key, val)
		load_config()

		gserv.config.startup[key] = val

		save_config()
	end

	function gserv.GetStartupParameter(key)
		load_config()

		return gserv.config.startup[key]
	end

	function gserv.SetLaunchParameter(key, val)
		load_config()

		gserv.config.launch[key] = val or ""

		save_config()
	end

	function gserv.RemoveLaunchParameter(key)
		load_config()

		gserv.config.launch[key] = nil

		save_config()
	end

	function gserv.GetLaunchParameter(key)
		load_config()

		return gserv.config.launch[key]
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

		local info = gserv.GetAddon(url)

		if not info then
			error("no such addon: " .. url)
		end

		if info.type == "git" then
			logn("updating git repository addon ", info.url)
			local dir = get_gmod_dir() .. "addons/" .. info.name

			if not vfs.IsDirectory(dir) then
				os.execute("git clone " .. info.url .. " '" .. dir .. "' --depth 1")
			else
				os.execute("git -C '" .. dir .. "' reset --hard HEAD")
				os.execute("git -C '" .. dir .. "' clean -f -d")
				os.execute("git -C '" .. dir .. "' pull")
			end
			logn("done updating ", info.url)
		elseif info.type == "workshop" then
			logn("updating workshop addon ", info.url)
			steam.DownloadWorkshop(info.id, function(header, compressed_path)
				-- if the name is just the id make it more readable
				if info.id == info.name then
					info.name = header.response.publishedfiledetails[1].title:lower():gsub("%p", ""):gsub("%s+", "_") .. "_" .. info.name
					save_config()
				end

				local name = info.name

				vfs.Write(get_gmod_dir() .. "addons/" .. name .. ".gma", serializer.ReadFile("lzma", compressed_path))

				os.execute(gserv.GetInstallDir() .. "/bin/gmad_linux extract -file " .. get_gmod_dir() .. "addons/" .. name ..".gma -out " .. get_gmod_dir() .. "addons/" .. name)

				vfs.Delete(get_gmod_dir() .. "addons/" .. name .. ".gma")

				logn("done updating ", info.url)
			end)
		end
	end

	function gserv.AddAddon(url, name_override)
		load_config()

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
				name = name_override or url:match("id=(%d+)"),
			}
		else
			info = {
				url = url,
				type = "unknown",
				name = name_override or vfs.FixIllegalCharactersInPath(url):lower():gsub("%s+", "_"),
			}
		end

		gserv.config.addons[key] = info

		save_config()

		llog("added addon")
		table.print(info)
	end

	function gserv.RemoveAddon(url)
		check_setup()
		load_config()

		local info = gserv.GetAddon(url)

		if not info then
			error("no such addon: " .. url)
		end

		local path = get_gmod_dir() .. "addons/".. info.name

		local dir

		if vfs.IsDirectory(path) then
			dir = path
		elseif info.id then
			local found = vfs.Find(get_gmod_dir() .. "addons/".. info.id, true)
			if #found == 1 and vfs.IsDirectory(found[1]) then
				dir = found[1]
			end
		end

		if not dir then
			logn("could not find the addon directory")
		end

		if dir then
			os.execute("rm -rf '" .. dir .. "'")
		end

		gserv.config.addons[url] = nil

		save_config()

		llog("removed addon")
		table.print(info)
	end

	function gserv.GetAddon(url)
		load_config()

		local info = gserv.config.addons[url]

		if not info then
			for _, info in pairs(gserv.GetAddons()) do
				if info.name:lower() == url:lower() then
					return info
				end
			end
		end

		return info
	end

	function gserv.GetAddons()
		load_config()

		return gserv.config.addons
	end
end

do
	function gserv.IsRunning()
		local f = assert(io.popen("tmux has-session -t srcds_goluwa 2>&1"))
		local ok = f:read("*all") == ""
		f:close()
		return ok
	end

	local function start_pinging()
		event.Timer("gserv_pinger", 1, 0, function()
			local time = vfs.Read(get_gmod_dir() .. "data/gserv_pinger.txt")

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

	function gserv.Resume()
		if gserv.IsRunning() then
			llog("resuming server")

			start_pinging()
			gserv.log_path = vfs.Read(data_dir .. "last_log_path")
		end
	end

	function gserv.Start()
		check_setup()

		if gserv.IsRunning() then error("server is running", 2) end

		load_config()

		llog("starting gmod server")

		vfs.Write(get_gmod_dir() .. "data/gserv_pinger.txt", "booting")

		os.execute("tmux kill-session -t srcds_goluwa 2>/dev/null")
		os.execute("tmux new-session -d -s srcds_goluwa")

		gserv.log_path = "gserv/logs/" .. os.date("%Y/%m/%d/%H-%M-%S.txt")
		vfs.Write("data/" .. gserv.log_path, "")
		vfs.Write(data_dir .. "last_log_path", gserv.log_path)
		os.execute("tmux pipe-pane -o -t srcds_goluwa 'cat >> " .. R("data/" .. gserv.log_path) .. "'")

		gserv.BuildConfig()

		local str = ""
		for k, v in pairs(gserv.config.startup) do
			str = str .. "+" .. k .. " " .. v .. " "
		end

		if gserv.config.workshop_collection then
			local id = tonumber(gserv.config.workshop_collection) or gserv.config.workshop_collection:match("id=(%d+)") or gserv.config.workshop_collection
			str = str .. "+host_workshop_collection " .. id  .. " "
		end

		local key = gserv.config.workshop_authkey

		if key then
			str = str .. "-authkey " .. key .. " "
		else
			llog("workshop auth key not setup")
		end


		str = str .. "-port " .. gserv.config.port .. " "

		for k, v in pairs(gserv.config.launch) do
			str = str .. "-" .. k .. " " .. v .. " "
		end

		os.execute("tmux send-keys -t srcds_goluwa \"sh '" .. gserv.GetInstallDir() .. "/srcds_run' -game garrysmod " .. str .. "\" C-m")

		start_pinging()

		sockets.StartWebhookServer(gserv.config.webhook_port, gserv.config.webhook_secret)
	end

	function gserv.Kill()
		event.RemoveTimer("gserv_pinger")
		vfs.Delete(data_dir .. "last_log_path")

		check_running()

		llog("killing gmod server")
		os.execute("tmux kill-session -t srcds_goluwa 2>/dev/null")

		sockets.StopWebhookServer(gserv.webhook_port:Get())
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

	local str = assert(vfs.Read(gserv.log_path))
	str = str:gsub("\r", "")

	return str
end

function gserv.Show()
	check_running()

	logn(gserv.GetOutput())
end

function gserv.Execute(line)
	check_running()

	os.execute("tmux send-keys -t srcds_goluwa \"" .. line .. "\" C-m")
end

function gserv.ExecuteSync(str)
	local delimiter = "goluwa_gserv_ExecuteSync_" .. os.clock()
	local prev = gserv.GetOutput()

	gserv.Execute(str)
	gserv.Execute("echo " .. delimiter)

	local end_line = "echo "..delimiter.."\n"..delimiter.." \n"
	local current

	local timeout = os.clock() + 1

	repeat
		if timeout < os.clock() then
			error("Waiting for output took more than 1 second.\nUse gserv show to dump all output.")
		end

		current = gserv.GetOutput()
	until current:endswith(end_line)

	return current:sub(#prev + #str + 1):sub(2, -#end_line - 2)
end

function gserv.Stop()
	check_running()

	gserv.Execute("exit")

	event.Delay(1, function()
		gserv.Kill()
	end)
end

function gserv.RunLua(line)
	check_running()

	return gserv.ExecuteSync("lua_run " .. line)
end

-- this is really stupid but idk what else to do at the moment
function gserv.GetLuaOutput(line)
	check_running()

	local id = tostring({})
	gserv.RunLua("file.Write('gserv_capture_output.txt', '" .. id .."' .. tostring((function()"..line.."end)()), 'DATA')")
	while true do
		local str = vfs.Read(get_gmod_dir() .. data_dir .. "capture_output.txt")
		if str and str:startswith(id) then
			return str:sub(#id + 1)
		end
	end
end

function gserv.GetMap()
	check_running()

	return gserv.GetLuaOutput("return game.GetMap()")
end

function gserv.Attach(id)
	check_running()
	gserv.Execute("echo to detach hold CTRL and press the following keys: *hold CTRL* b b *release CTRL* d")
	os.execute("unset TMUX; tmux attach -t srcds_goluwa")
end

function gserv.Restart(time)
	check_running()

	time = time or 0
	llog("restarting server in ", time, " seconds")
	gserv.RunLua("if aowl then RunConsoleCommand('aowl', 'restart', '"..time.."') else timer.Simple("..time..", function() RunConsoleCommand('changelevel', game.GetMap()) end) end")
end

do -- commands
	commands.Add("gserv setup", function() gserv.Setup() end)
	commands.Add("gserv update", function() gserv.InstallGame("gmod") end)
	commands.Add("gserv install_game=string|number,string|nil", function(name, dir) gserv.InstallGame(name, dir) end)

	commands.Add("gserv start", function() gserv.Start() end)
	commands.Add("gserv stop", function() gserv.Stop() end)
	commands.Add("gserv kill", function() gserv.Kill() end)
	commands.Add("gserv show", function() gserv.Show() end)
	commands.Add("gserv restart=number[30]", function(time) gserv.Restart(time) end)
	commands.Add("gserv reboot", function() gserv.Reboot() end)

	commands.Add("gserv add_addon=string", function(url) gserv.AddAddon(url) gserv.UpdateAddon(url) end)
	commands.Add("gserv remove_addon=string", function(url) gserv.RemoveAddon(url) end)
	commands.Add("gserv update_addon=string", function(url) gserv.UpdateAddon(url) end)
	commands.Add("gserv update_addons", function() gserv.UpdateAddons() end)

	commands.Add("gserv setup_info", function() load_config() table.print(gserv.config) end)

	commands.Add("gserv set_startup_param=string,string", function(key, val) gserv.SetStartupParameter(key, val) end)
	commands.Add("gserv set_launch_param=string,string|nil", function(key, val) gserv.SetLaunchParameter(key, val) end)
	commands.Add("gserv remove_launch_param=string,string|nil", function(key, val) gserv.RemoveLaunchParameter(key) end)
	commands.Add("gserv set_config_param=string,string", function(key, val) gserv.SetConfigParameter(key, val) end)

	commands.Add("gserv run=arg_line", function(str)
		logn(gserv.ExecuteSync(str))
	end)

	commands.Add("gserv lua=arg_line", function(code)
		logn(gserv.RunLua(code))
	end)

	commands.Add("gserv attach=string[]", function(id)
		gserv.Attach(id)
	end)
end

if vfs.IsFile(data_dir .. "last_log_path") then
	gserv.Resume()
end
