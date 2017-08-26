if not system.OSCommandExists("tmux", "tar") then return end

gserv = gserv or {}

gserv.logs = {}
gserv.configs = {}

gserv.default_config = {
	ip = nil,
	port = 27015,

	workshop_authkey = nil,
	workshop_collection = nil,

	webhook_port = nil, --27020
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

local function underscore(str)
	return str:lower():gsub("%p", ""):gsub("%s+", "_")
end

local function get_gmod_dir(id)
	return gserv.GetInstallDir(id) .. "/garrysmod/"
end

local function get_gserv_addon_dir(id)
	return get_gmod_dir(id) .. "addons/gserv/"
end

local srcds_dir = e.DATA_FOLDER .. "srcds/"

local data_dir = "data/gserv/"
local data_dir = "data/gserv/"

local function load_config(id)
	if not gserv.configs[id] then
		local config = serializer.ReadFile("luadata", data_dir .. "configs/" .. underscore(id) .. ".lua") or {}
		config.id = id
		gserv.configs[id] = table.merge(table.copy(gserv.default_config), config)
		save_config(id)
	end
end

local function save_config(id)
	serializer.WriteFile("luadata", data_dir .. "configs/" .. underscore(id) .. ".lua", gserv.configs[id])
end

local function check_setup(id) if not gserv.IsSetup(id) then error("server is not setup", 3) end end
local function check_running(id) if not gserv.IsRunning(id) then error("server is not running", 3) end end

function gserv.Log(id, ...)
	logn("[", id, "] ", ...)
end

function gserv.IsSetup(id)
	if
		gserv.GetInstallDir(id) and
		vfs.IsFile(gserv.GetInstallDir(id) .. "/srcds_run") and
		vfs.IsFile(get_gserv_addon_dir(id) .. "lua/autorun/server/gserv_pinger.lua")
	then
		return true
	end
end

function gserv.Setup(id)
	if gserv.IsRunning(id) then error("server is running", 2) end

	if gserv.IsSetup(id) then
		gserv.Log(id, "server is already setup")
	else
		gserv.Log(id, "setting up gmod server for first time")
	end

	gserv.InstallGame("gmod", nil, function()

		local dir = underscore(id)

		if not vfs.IsDirectory(srcds_dir .. dir) then
			os.execute("cp -a " .. gserv.GetInstalledGames()[4020] .. "/. " .. srcds_dir .. dir)
			serializer.SetKeyValueInFile("luadata", data_dir .. "games.lua", id, srcds_dir .. dir)
		end

		-- create glua script that writes os.time to a file every second
		if not vfs.IsFile(get_gserv_addon_dir(id) .. "lua/autorun/server/gserv_pinger.lua") then
			vfs.CreateFolders("os", get_gserv_addon_dir(id) .. "lua/autorun/server/")
			vfs.Write(get_gserv_addon_dir(id) .. "lua/autorun/server/gserv_pinger.lua", [[
				timer.Create("gserv_pinger", 1, 0, function()
					file.Write("gserv_pinger.txt", os.time(), "DATA")
				end)
			]])
		end

		vfs.Write(get_gmod_dir(id) .. "cfg/server.cfg", "exec gserv.cfg\n")

		-- silence some startup errors
		vfs.Write(get_gmod_dir(id) .. "cfg/trusted_keys_base.txt", "trusted_key_list\n{\n}\n")
		vfs.Write(get_gmod_dir(id) .. "cfg/pure_server_minimal.txt", "whitelist\n{\n}\n")
		vfs.Write(get_gmod_dir(id) .. "cfg/network.cfg", "")

		gserv.BuildMountConfig(id)

		gserv.SetupCommands(id)
	end)
end

commands.Add("gserv setup=string[gserv]", function(id) gserv.Setup(id) end)
commands.Add("gserv update_game=string|number,string|nil", function(name) gserv.Update(name, dir) end)
commands.Add("gserv install_game=string|number,string|nil", function(name, dir) gserv.InstallGame(name, dir) end)

function gserv.SetupCommands(id)
	commands.Add(id .. " start", function() gserv.Start(id) end)
	commands.Add(id .. " stop", function() gserv.Stop(id) end)
	commands.Add(id .. " kill", function() gserv.Kill(id) end)
	commands.Add(id .. " show", function() gserv.Show(id) end)
	commands.Add(id .. " restart=number[30]", function(id, time) gserv.Restart(id, time) end)
	commands.Add(id .. " reboot", function() gserv.Reboot(id) end)

	commands.Add(id .. " add_addon=string", function(url) gserv.AddAddon(id, url) gserv.UpdateAddon(id, url) end)
	commands.Add(id .. " remove_addon=string", function(url) gserv.RemoveAddon(id, url) end)
	commands.Add(id .. " update_addon=string", function(url) gserv.UpdateAddon(id, url) end)
	commands.Add(id .. " update_addons", function() gserv.UpdateAddons(id) end)

	commands.Add(id .. " setup_info", function() check_setup(id) table.print(gserv.configs[id]) end)
	commands.Add(id .. " setup_info", function() check_setup(id) table.print(gserv.configs[id]) end)

	commands.Add(id .. " set_startup_param=string,string", function(key, val) gserv.SetStartupParameter(id, key, val) end)
	commands.Add(id .. " set_launch_param=string,string|nil", function(key, val) gserv.SetLaunchParameter(id, key, val) end)
	commands.Add(id .. " remove_launch_param=string,string|nil", function(key, val) gserv.RemoveLaunchParameter(id, key) end)
	commands.Add(id .. " set_config_param=string,string", function(key, val) gserv.SetConfigParameter(id, key, val) end)

	commands.Add(id .. " run=string_rest", function(str)
		logn(gserv.ExecuteSync(id, str))
	end)

	commands.Add(id .. " lua=string_rest", function(code)
		logn(gserv.RunLua(id, code))
	end)

	commands.Add(id .. " attach", function()
		gserv.Attach(id)
	end)
end

function gserv.UpdateGame(id)
	gserv.InstallGame("gmod", nil, function(appid)
		if appid == 4020 then
			os.execute("cp -a -rf " .. gserv.GetInstalledGames()[4020] .. "/. " .. srcds_dir .. underscore(id))
		end
	end)
end

function gserv.InstallGame(name, dir, callback)
	local appid, full_name = steam.GetAppIdFromName(name .. " Dedicated Server")
	if not appid and tonumber(name) then
		appid = tonumber(name)
	end

	if not appid then
		error("could not find " .. name, 2)
	end

	gserv.Log(id, "setting up")

	-- create the srcds directory in goluwa/data/srcds
	vfs.CreateFolder("os:" .. srcds_dir)

	-- download steamcmd
	resource.Download("http://media.steampowered.com/client/steamcmd_linux.tar.gz", function(path)

		-- if steamcmd.sh does not exist then we need to extract it
		if not vfs.IsFile(srcds_dir .. "steamcmd.sh") then
			os.execute("tar -xvzf " .. vfs.GetAbsolutePath(path) .. " -C " .. srcds_dir)
		end

		local dir_name = dir or underscore(full_name)

		llog("installing ", name, " (", appid, ")", " to ", srcds_dir .. dir_name)

		serializer.SetKeyValueInFile("luadata", data_dir .. "games.lua", appid, srcds_dir .. dir_name)
		os.execute(srcds_dir .. "steamcmd.sh +login anonymous +force_install_dir \"" .. srcds_dir .. dir_name .. "\" +app_update " .. appid .. " validate +quit")

		llog("done")
		if callback then callback(appid) end
	end)
end

function gserv.GetInstallDir(id)
	return gserv.GetInstalledGames()[id]
end

function gserv.GetInstalledGames()
	return serializer.ReadFile("luadata", data_dir .. "games.lua") or {}
end

function gserv.BuildMountConfig(id)
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

	vfs.Write(get_gmod_dir(id) .. "cfg/mount.cfg", str)
end

do
	function gserv.SetConfigParameter(id, key, val)
		load_config(id)
		gserv.configs[id].cfg[key] = val
		save_config(id)

		gserv.BuildConfig(id)

		if gserv.IsRunning(id) then
			gserv.Execute(id, key .. " " .. val)
		end
	end

	function gserv.GetConfigParameter(id, key)
		load_config(id)
		return gserv.configs[id].cfg[key]
	end

	function gserv.BuildConfig(id)
		check_setup(id)

		-- write the cfg file
		local str = ""
		for k,v in pairs(gserv.configs[id].cfg) do
			str = str .. k .. " " .. v .. "\n"
		end
		vfs.Write(get_gmod_dir(id) .. "cfg/gserv.cfg", str)
	end
end

do
	function gserv.SetStartupParameter(id, key, val)
		load_config(id)

		gserv.configs[id].startup[key] = val

		save_config(id)
	end

	function gserv.GetStartupParameter(id, key)
		load_config(id)

		return gserv.configs[id].startup[key]
	end

	function gserv.SetLaunchParameter(id, key, val)
		load_config(id)

		gserv.configs[id].launch[key] = val or ""

		save_config(id)
	end

	function gserv.RemoveLaunchParameter(id, key)
		load_config(id)

		gserv.configs[id].launch[key] = nil

		save_config(id)
	end

	function gserv.GetLaunchParameter(id, key)
		load_config(id)

		return gserv.configs[id].launch[key]
	end
end

do -- addons
	function gserv.UpdateAddons(id)
		check_setup(id)

		for url, info in pairs(gserv.GetAddons(id)) do
			gserv.UpdateAddon(id, url)
		end
	end

	function gserv.UpdateAddon(id, url)
		check_setup(id)

		local info = gserv.GetAddon(id, url)

		if not info then
			error("no such addon: " .. url)
		end

		if info.type == "git" then
			gserv.Log(id, "updating git repository addon ", info.url)
			local dir = get_gmod_dir(id) .. "addons/" .. info.name

			if not vfs.IsDirectory(dir) then
				os.execute("git clone " .. info.url .. " '" .. dir .. "' --depth 1")
			else
				os.execute("git -C '" .. dir .. "' reset --hard HEAD")
				os.execute("git -C '" .. dir .. "' clean -f -d")
				os.execute("git -C '" .. dir .. "' pull")
			end
			gserv.Log(id, "done updating ", info.url)
		elseif info.type == "workshop" then
			gserv.Log(id, "updating workshop addon ", info.url)
			steam.DownloadWorkshop(info.id, function(header, compressed_path)
				-- if the name is just the id make it more readable
				if info.id == info.name then
					info.name = header.response.publishedfiledetails[1].title:lower():gsub("%p", ""):gsub("%s+", "_") .. "_" .. info.name
					save_config(id)
				end

				local name = info.name

				vfs.Write(get_gmod_dir(id) .. "addons/" .. name .. ".gma", serializer.ReadFile("lzma", compressed_path))

				os.execute(gserv.GetInstallDir(id) .. "/bin/gmad_linux extract -file " .. get_gmod_dir(id) .. "addons/" .. name ..".gma -out " .. get_gmod_dir(id) .. "addons/" .. name)

				vfs.Delete(get_gmod_dir(id) .. "addons/" .. name .. ".gma")

				gserv.Log(id, "done updating ", info.url)
			end)
		end
	end

	function gserv.AddAddon(id, url, name_override)
		load_config(id)

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

		gserv.configs[id].addons[key] = info

		save_config(id)

		gserv.Log(id, "added addon")
		table.print(info)
	end

	function gserv.RemoveAddon(id, url)
		check_setup(id)
		load_config(id)

		local info = gserv.GetAddon(id, url)

		if not info then
			error("no such addon: " .. url)
		end

		local path = get_gmod_dir(id) .. "addons/".. info.name

		local dir

		if vfs.IsDirectory(path) then
			dir = path
		elseif info.id then
			local found = vfs.Find(get_gmod_dir(id) .. "addons/".. info.id, true)
			if #found == 1 and vfs.IsDirectory(found[1]) then
				dir = found[1]
			end
		end

		if not dir then
			gserv.Log(id, "could not find the addon directory")
		end

		if dir then
			os.execute("rm -rf '" .. dir .. "'")
		end

		gserv.configs[id].addons[url] = nil

		save_config(id)

		gserv.Log(id, "removed addon")
		table.print(info)
	end

	function gserv.GetAddon(id, url)
		load_config(id)

		local info = gserv.configs[id].addons[url]

		if not info then
			for _, info in pairs(gserv.GetAddons(id)) do
				if info.name:lower() == url:lower() then
					return info
				end
			end
		end

		return info
	end

	function gserv.GetAddons(id)
		load_config(id)

		return gserv.configs[id].addons
	end
end

do
	function gserv.IsRunning(id)
		local f = assert(io.popen("tmux has-session -t srcds_"..underscore(id).."_goluwa 2>&1"))
		local ok = f:read("*all") == ""
		f:close()
		return ok
	end

	local function start_pinging(id)
		event.Timer("gserv_pinger_" .. underscore(id), 1, 0, function()
			local time = vfs.Read(get_gmod_dir(id) .. "data/gserv_pinger.txt")

			if time then
				if time == "booting" then return end

				time = tonumber(time)
				local diff = os.difftime(os.time(), time)
				if diff > 1 then
					gserv.Log(id, "server hasn't responded for more than ", diff ," seconds")
					if diff > 20 then
						gserv.Reboot(id)
					end
				end
			end
		end)
	end

	local function stop_pinging(id)
		event.RemoveTimer("gserv_pinger_" .. underscore(id))
	end

	function gserv.Resume(id)
		if gserv.IsRunning(id) then
			gserv.Log(id, "resuming server")

			start_pinging(id)
		end
	end

	function gserv.Start(id)
		check_setup(id)

		if gserv.IsRunning(id) then error("server is running", 2) end

		load_config(id)

		gserv.Log(id, "starting gmod server")

		vfs.Write(get_gmod_dir(id) .. "data/gserv_pinger.txt", "booting")

		os.execute("tmux kill-session -t srcds_"..underscore(id).."_goluwa 2>/dev/null")
		os.execute("tmux new-session -d -s srcds_"..underscore(id).."_goluwa")

		gserv.logs[id] = "gserv/logs/" .. os.date("%Y/%m/%d/%H-%M-%S.txt")
		vfs.Write("data/" .. gserv.logs[id], "")
		serializer.WriteFile("luadata", data_dir .. underscore(id) .. "_server_state", {id = id, log_path = gserv.logs[id]})
		os.execute("tmux pipe-pane -o -t srcds_"..underscore(id).."_goluwa 'cat >> " .. R("data/" .. gserv.logs[id]) .. "'")

		gserv.BuildConfig(id)

		local str = ""
		for k, v in pairs(gserv.configs[id].startup) do
			str = str .. "+" .. k .. " " .. v .. " "
		end

		if gserv.configs[id].workshop_collection then
			local collection_id = tonumber(gserv.configs[id].workshop_collection) or gserv.configs[id].workshop_collection:match("id=(%d+)") or gserv.configs[id].workshop_collection
			str = str .. "+host_workshop_collection " .. collection_id  .. " "
		end

		local key = gserv.configs[id].workshop_authkey

		if key then
			str = str .. "-authkey " .. key .. " "
		else
			gserv.Log(id, "workshop auth key not setup")
		end


		str = str .. "-port " .. gserv.configs[id].port .. " "

		for k, v in pairs(gserv.configs[id].launch) do
			str = str .. "-" .. k .. " " .. v .. " "
		end

		os.execute("tmux send-keys -t srcds_"..underscore(id).."_goluwa \"sh '" .. gserv.GetInstallDir(id) .. "/srcds_run' -game garrysmod " .. str .. "\" C-m")

		start_pinging(id)

		if gserv.configs[id].webhook_port then
			sockets.StartWebhookServer(gserv.configs[id].webhook_port, gserv.configs[id].webhook_secret)
		end
	end

	function gserv.Kill(id)
		vfs.Delete(data_dir .. underscore(id) .. "_server_state")
		stop_pinging(id)
		check_running(id)

		gserv.Log(id, "killing gmod server")
		os.execute("tmux kill-session -t srcds_"..underscore(id).."_goluwa 2>/dev/null")

		if gserv.configs[id].webhook_port then
			sockets.StopWebhookServer(gserv.configs[id].webhook_port)
		end
	end

	function gserv.Reboot(id)
		if gserv.IsRunning(id) then
			gserv.Kill(id)
		end
		gserv.Start(id)
	end

end

function gserv.GetOutput(id)
	check_running(id)

	local str = assert(vfs.Read(gserv.logs[id]))
	str = str:gsub("\r", "")

	return str
end

function gserv.Show(id)
	check_running(id)

	logn(gserv.GetOutput(id))
end

function gserv.Execute(id, line)
	check_running(id)

	os.execute("tmux send-keys -t srcds_"..underscore(id).."_goluwa \"" .. line .. "\" C-m")
end

function gserv.ExecuteSync(id, str)
	local delimiter = "goluwa_gserv_ExecuteSync_" .. os.clock()
	local prev = gserv.GetOutput(id)

	gserv.Execute(id, str)
	gserv.Execute(id, "echo " .. delimiter)

	local end_line = "echo "..delimiter.."\n"..delimiter.." \n"
	local current

	local timeout = os.clock() + 1

	repeat
		if timeout < os.clock() then
			error("Waiting for output took more than 1 second.\nUse gserv show to dump all output.")
		end

		current = gserv.GetOutput(id)
	until current:endswith(end_line)

	return current:sub(#prev + #str + 1):sub(2, -#end_line - 2)
end

function gserv.Stop(id)
	check_running(id)

	gserv.Execute(id, "exit")

	event.Delay(1, function()
		gserv.Kill(id)
	end)
end

function gserv.RunLua(id, line)
	check_running(id)

	return gserv.ExecuteSync(id, "lua_run " .. line)
end

-- this is really stupid but idk what else to do at the moment
function gserv.GetLuaOutput(id, line)
	check_running(id)

	local id = tostring({})
	gserv.RunLua(id, "file.Write('gserv_capture_output.txt', '" .. id .."' .. tostring((function()"..line.."end)()), 'DATA')")
	while true do
		local str = vfs.Read(get_gmod_dir() .. data_dir .. "capture_output.txt")
		if str and str:startswith(id) then
			return str:sub(#id + 1)
		end
	end
end

function gserv.GetMap(id)
	check_running(id)

	gserv.ExecuteSync(id, "lua_run print(game.GetMap())")
end

function gserv.Attach(id)
	check_running(id)
	gserv.Execute(id, "echo to detach hold CTRL and press the following keys: *hold CTRL* b b *release CTRL* d")
	os.execute("unset TMUX; tmux attach -t srcds_"..underscore(id).."_goluwa")
end

function gserv.Restart(id, time)
	check_running(id)

	time = time or 0
	gserv.Log(id, "restarting server in ", time, " seconds")
	gserv.RunLua(id, "if aowl then RunConsoleCommand('aowl', 'restart', '"..time.."') else timer.Simple("..time..", function() RunConsoleCommand('changelevel', game.GetMap()) end) end")
end

for _, path in ipairs(vfs.Find(data_dir .. "configs/", true)) do
	local config = serializer.ReadFile("luadata", path)
	gserv.configs[config.id] = config
	gserv.SetupCommands(config.id)
end

for _, path in ipairs(vfs.Find(data_dir, true)) do
	if path:endswith("_server_state") then
		local data = serializer.ReadFile("luadata", path)
		gserv.Resume(data.id)
		gserv.logs[data.id] = data.log_path
	end
end