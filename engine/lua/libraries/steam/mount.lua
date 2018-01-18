local steam = ... or _G.steam

commands.Add("mount=string", function(game)
	local game_info = assert(steam.MountSourceGame(game))
	llog("mounted %s %s", game_info.game, game_info.title2)
end)

commands.Add("unmount=string", function(game)
	local game_info = assert(steam.UnmountSourceGame(game))
	llog("unmounted %s %s", game_info.game, game_info.title2 or game_info.title)
end)

commands.Add("mount_all=string", function(game)
	local game_info = assert(steam.MountSourceGame(game))
	llog("mounted %s %s", game_info.game, game_info.title2)
end)

commands.Add("unmount_all", function()
	steam.UnmountAllSourceGames()
end)

commands.Add("list_games", function()
	for _, info in pairs(steam.GetSourceGames()) do
		logn(info.game)
		logn("\tgame_dir = ", info.game_dir)
		logn("\tappid = ", info.filesystem.steamappid)
		logn()
	end
end)

commands.Add("list_maps=string", function(search)
	for _, name in ipairs(vfs.Find("maps/%.bsp$")) do
		if not search or name:find(search) then
			logn(name:sub(0, -5))
		end
	end
end)

commands.Add("game_info=string", function(game)
	local info = steam.FindSourceGame(game)
	print(vfs.Read(info.gameinfo_path))
	table.print(info)
end)

function steam.GetInstallPath()
	local path

	if WINDOWS then
		path = system.GetRegistryValue("CurrentUser/Software/Valve/Steam/SteamPath") or (X64 and "C:\\Program Files (x86)\\Steam" or "C:\\Program Files\\Steam")
	elseif LINUX then
		path = os.getenv("HOME") .. "/.steam/steam"
		if not vfs.IsDirectory(path) then
			path = os.getenv("HOME") .. "/.local/share/Steam"
		end
	end

	return path --lfs.symlinkattributes(path, "mode") and path or nil
end

function steam.GetLibraryFolders()
	local base = steam.GetInstallPath()

	local str = vfs.Read(base .. "/config/config.vdf", "r")

	if not str then return {} end

	local tbl = {base .. "/steamapps/"}

	local config = utility.VDFToTable(str, true)

	for key, path in pairs(config.installconfigstore.software.valve.steam) do
		if key:find("baseinstallfolder_") then
			table.insert(tbl, vfs.FixPathSlashes(path) .. "/steamapps/")
		end
	end

	return tbl
end

function steam.GetGamePath(game)
	for _, dir in pairs(steam.GetLibraryFolders()) do
		local path = dir .. "common/" .. game .. "/"
		if vfs.IsDirectory(path) then
			return path
		end
	end

	return ""
end

function steam.GetGameFolders(skip_mods)
	local games = {}

	for _, library in ipairs(steam.GetLibraryFolders()) do
		for _, game in ipairs(vfs.Find(library .. "/common/", true)) do
			table.insert(games, game .. "/")
		end
		if not skip_mods then
			for _, mod in ipairs(vfs.Find(library .. "/sourcemods/", true)) do
				table.insert(games, mod .. "/")
			end
		end
	end

	return games
end

function steam.GetSourceGames()
	local found = serializer.ReadFile("msgpack", "source_games_cache")

	if found then
		return found
	end

	found = {}

	for _, game_dir in ipairs(steam.GetGameFolders()) do
		for _, folder in ipairs(vfs.Find("os:" .. game_dir, true)) do
			local path = folder .. "/gameinfo.txt"
			local str = vfs.Read("os:" .. path)

			if not str then
				str = vfs.Read("os:" .. folder .. "/GameInfo.txt")
			end

			local dir = path:match("(.+/).+/")

			if str then
				local tbl = utility.VDFToTable(str, true)
				if tbl and tbl.gameinfo and tbl.gameinfo.game then
					tbl = tbl.gameinfo
					tbl.gameinfo_path = path

					tbl.game_dir = game_dir


					if tbl.filesystem then
						local fixed = {}

						local done = {}

						for _, v in pairs(tbl.filesystem.searchpaths) do
							for _, path in pairs(type(v) == "string" and {v} or v) do
								if path:find("|", nil, true) then
									path = path:replace("|gameinfo_path|", tbl.gameinfo_path:match("(.+/)"))
									path = path:replace("|all_source_engine_paths|", dir)
								else
									path = dir .. path
								end

								path = vfs.FixPathSlashes(path)

								if path:endswith("*") then
									if not done[path] then
										table.insert(fixed, path)
										done[path] = true
									end
								else

									if path:endswith(".") then
										path = path:sub(0,-2)
									end

									if not path:endswith("/") then
										if vfs.GetExtensionFromPath(path) then
											if not vfs.IsFile("os:" .. path) then
												path = path:gsub("(.+/.+)%.vpk", "%1_dir.vpk")
											end
										elseif vfs.IsDirectory(path) then
											path = path .. "/"
										end
									end

									local pak = path .. "pak01_dir.vpk"

									if vfs.IsFile(pak) then
										if not done[pak] then
											table.insert(fixed, pak)
											done[pak] = true
										end
									end

									if not done[path] and vfs.IsDirectory(path) then
										table.insert(fixed, path)
										done[path] = true
									end
								end
							end
						end

						tbl.filesystem.searchpaths = fixed

						table.insert(found, tbl)
					end
				end
			end
		end
	end

	serializer.WriteFile("msgpack", "source_games_cache", found)

	return found
end

local cache_mounted = {}

function steam.MountSourceGame(game_info)

	if type(game_info) == "number" then
		game_info = tostring(game_info)
	end

	if cache_mounted[game_info] then
		return cache_mounted[game_info]
	end

	local str_game_info

	if type(game_info) == "string" then
		str_game_info = game_info:trim()

		game_info = steam.FindSourceGame(str_game_info)
	end

	if not game_info then return nil, "could not find " .. str_game_info end

	steam.UnmountSourceGame(game_info)

	llog("mounting %s", game_info.game)

	for _, path in ipairs(game_info.filesystem.searchpaths) do
		if path:endswith("*") then
			for _, path in ipairs(vfs.Find(path:sub(0, -2), true)) do
				if vfs.IsDirectory(path) then
					if not path:endswith("/") and not vfs.GetExtensionFromPath(path) then
						path = path .. "/"
					end
					if game_info.game == "Garry's Mod" and not pvars.Get("gine_local_addons_only") then
						vfs.Mount(path, nil, game_info)
					end
				end
			end
		else
			if not path:endswith(".vpk") then
				path = "os:" .. path

				for _, v in ipairs(vfs.Find(path .. "/maps/workshop/")) do
					llog("mounting workshop map %s", v)
					vfs.Mount(path .. "/maps/workshop/" .. v, "maps/", game_info)
				end
			end

			vfs.Mount(path, nil, game_info)
		end
	end

	if str_game_info then
		cache_mounted[str_game_info] = game_info
	end

	return game_info
end

function steam.UnmountSourceGame(game_info)
	local str_game_info = game_info

	if type(game_info) == "string" then
		cache_mounted[game_info] = nil
		str_game_info = game_info
		game_info = steam.FindSourceGame(game_info)
	end

	if not game_info then return nil, "could not find " .. str_game_info end

	if game_info then
		for _, v in pairs(vfs.GetMounts()) do
			if v.userdata and v.userdata.filesystem.steamappid == game_info.filesystem.steamappid then
				vfs.Unmount(v.full_where, v.full_to)
			end
		end
	end

	return game_info
end

function steam.GetMountedSourceGames()
	local out = {}
	local done = {}
	for k,v in pairs(vfs.GetMounts()) do
		if v.userdata and v.userdata.filesystem and v.userdata.filesystem.steamappid then
			if not done[v.userdata] then
				table.insert(out, v.userdata)
				done[v.userdata] = true
			end
		end
	end
	return out
end

do
	function steam.FindSourceGame(name)
		local appid = steam.GetAppIdFromName(name)

		if appid and tonumber(appid) then
			for _, game_info in ipairs(steam.GetSourceGames()) do
				if game_info.filesystem.steamappid == tonumber(appid) then
					return game_info
				end
			end
		end
	end
end

function steam.MountSourceGames()
	for _, game_info in ipairs(steam.GetSourceGames()) do
		steam.MountSourceGame(game_info)
	end
end

function steam.UnmountAllSourceGames()
	for _, game_info in ipairs(steam.GetSourceGames()) do
		steam.UnmountSourceGame(game_info)
	end
end

local mount_info = {
	["gm_.+"] = {"garry's mod", "tf2", "css"},
	["rp_.+"] = {"garry's mod", "tf2", "css"},
	["ep1_.+"] = {"half-life 2: episode one"},
	["ep2_.+"] = {"half-life 2: episode two"},
	["trade_.+"] = {"half-life 2", "team fortress 2"},
	["d%d_.+"] = {"half-life 2"},
	["dm_.*"] = {"half-life 2: deathmatch"},
	["c%dm%d_.+"] = {"left 4 dead 2"},

	["esther"] = {"dear esther"},
	["jakobson"] = {"dear esther"},
	["donnelley"] = {"dear esther"},
	["paul"] = {"dear esther"},

	["aramaki_4d"] = {"team fortress 2", "garry's mod"},
	["de_overpass"] = {"counter-strike: global offensive"},
	["de_bank"] = {"counter-strike: global offensive"},
	["sp_a4_finale1"] = {"portal 2"},
	["c3m1_plankcountry"] = {"left 4 dead 2"},
	["achievement_apg_r11b"] = {"half-life 2", "team fortress 2"},
}

function steam.MountGamesFromMapPath(path)
	local name = path:match("maps/(.+)%.bsp")

	if name == "gm_old_flatgrass" then return end

	if name then
		local mounts = mount_info[name]

		if not mounts then
			for k,v in pairs(mount_info) do
				if name:find(k) then
					mounts = v
					break
				end
			end
		end

		if mounts then
			for _, mount in ipairs(mounts) do
				steam.MountSourceGame(mount)
			end
		end
	end
end

