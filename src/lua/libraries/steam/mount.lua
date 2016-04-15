local steam = ... or _G.steam

console.AddCommand("mount", function(game)
	local game_info = assert(steam.MountSourceGame(game))
	llog("mounted %s %s", game_info.game, game_info.title2)
end)

console.AddCommand("unmount", function(game)
	local game_info = assert(steam.UnmountSourceGame(game))
	llog("unmounted %s %s", game_info.game, game_info.title2 or game_info.title)
end)

console.AddCommand("mount_all", function(game)
	local game_info = assert(steam.MountSourceGame(game))
	llog("mounted %s %s", game_info.game, game_info.title2)
end)

console.AddCommand("unmount_all", function(game)
	steam.UnmountAllSourceGames()
end)


console.AddCommand("list_games", function(game)
	for _, info in pairs(steam.GetSourceGames()) do
		logn(info.game)
		logn("\tgame_dir = ", info.game_dir)
		logn("\tappid = ", info.filesystem.steamappid)
		logn()
	end
end)

console.AddCommand("game_info", function(game)
	local info = steam.FindSourceGame(game)
	print(vfs.Read(info.gameinfo_path))
	table.print(info)
end)

function steam.GetInstallPath()
	local path

	if WINDOWS then
		path = system.GetRegistryValue("CurrentUser/Software/Valve/Steam/SteamPath") or (X64 and "C:\\Program Files (x86)\\Steam" or "C:\\Program Files\\Steam")
	elseif LINUX then
		path = os.getenv("HOME") .. "/.local/share/Steam"
		if not vfs.IsDirectory(path) then
			path = os.getenv("HOME") .. "/.steam/steam"
		end
	end

	return path --lfs.symlinkattributes(path, "mode") and path or nil
end

function steam.GetLibraryFolders()
	local base = steam.GetInstallPath()

	local tbl = {base .. "/steamapps/"}

	local config = steam.VDFToTable(assert(vfs.Read(base .. "/config/config.vdf", "r")))

	for key, path in pairs(config.InstallConfigStore.Software.Valve.Steam) do

		if key:find("BaseInstallFolder_") then
			table.insert(tbl, vfs.FixPath(path) .. "/steamapps/")
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

	for i, library in ipairs(steam.GetLibraryFolders()) do
		for i, game in ipairs(vfs.Find(library .. "/common/", nil, true)) do
			table.insert(games, game .. "/")
		end
		if not skip_mods then
			for i, mod in ipairs(vfs.Find(library .. "/sourcemods/", nil, true)) do
				table.insert(games, mod .. "/")
			end
		end
	end

	return games
end

function steam.GetSourceGames()
	local found = {}

	for i, game_dir in ipairs(steam.GetGameFolders()) do
		for i, folder in ipairs(vfs.Find("os:" .. game_dir, nil, true)) do
			local path = folder .. "/gameinfo.txt"
			local str = vfs.Read("os:" .. path)
			local dir = path:match("(.+/).+/")

			if str then
				local tbl = steam.VDFToTable(str, true)
				if tbl and tbl.gameinfo and tbl.gameinfo.game then
					tbl = tbl.gameinfo
					tbl.gameinfo_path = path

					tbl.game_dir = game_dir


					if tbl.filesystem then
						local fixed = {}

						local done = {}

						for k,v in pairs(tbl.filesystem.searchpaths) do
							for k,v in pairs(type(v) == "string" and {v} or v) do
								if v:find("|gameinfo_path|") then
									v = v:gsub("|gameinfo_path|", path:match("(.+/)"))
								elseif v:find("|all_source_engine_paths|") then
									v = v:gsub("|all_source_engine_paths|", dir)
								else
									v = dir .. v
								end

								if v:endswith(".") then
									v = v:sub(0,-2)
								end

								if not done[v] and not done[v.."/"] then

									if tbl.filesystem.steamappid == 4000 then
										-- is there an internal fix in gmod for this?
										v = v:gsub("GarrysMod/hl2", "GarrysMod/sourceengine")
									end

									v = v:gsub("/+", "/") -- TODO

									table.insert(fixed, v)
									done[v] = true
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

	return found
end

local cache_mounted = {}

function steam.MountSourceGame(game_info)

	if cache_mounted[game_info] then
		return cache_mounted[game_info]
	end

	local str_game_info

	if type(game_info) == "string" then
		str_game_info = game_info

		game_info = steam.FindSourceGame(str_game_info)
	end

	if not game_info then return nil, "could not find " .. str_game_info end

	steam.UnmountSourceGame(game_info)
	for i, path in pairs(game_info.filesystem.searchpaths) do
		if path:endswith(".vpk") then
			path = "os:" .. path:gsub("(.+)%.vpk", "%1_dir.vpk")
		else
			path = "os:" .. path

			if path:endswith("*") then
				path = path:sub(0, -2)
				for k, v in pairs(vfs.Find(path)) do
					if vfs.IsDirectory(path .. "/" .. v) or v:endswith(".vpk") then
						llog("mounting custom folder/vpk %s", v)
						vfs.Mount(path .. "/" .. v, nil, game_info)
					end
				end
			else
				for k, v in pairs(vfs.Find(path .. "addons/")) do
					if vfs.IsDirectory(path .. "addons/" .. v) or v:endswith(".gma") then
						llog("mounting addon %s", v)
						vfs.Mount(path .. "addons/" .. v, nil, game_info)
					end
				end

				for k, v in pairs(vfs.Find(path .. "maps/workshop/")) do
					llog("mounting workshop map %s", v)
					vfs.Mount(path .. "maps/workshop/" .. v, "maps/", game_info)
				end
			end


			local pak = path .. "pak01_dir.vpk"
			if vfs.IsFile(pak) then
				llog("mounting %s", pak)
				vfs.Mount(pak, nil, game_info)
			end
		end

		if vfs.Exists(path) then
			llog("mounting %s", path)
			vfs.Mount(path, nil, game_info)
		else
			llog("%s not found", path)
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
		for k, v in pairs(vfs.GetMounts()) do
			if v.userdata and v.userdata.filesystem.steamappid == game_info.filesystem.steamappid then
				vfs.Unmount(v.full_where, v.full_to)
			end
		end
	end

	return game_info
end


do
	local translate = {
		[630] = {"alien swarm", "as"},
		[420] = {"hl2ep2", "half-life 2: episode two", "ep2"},
		[320] = {"hl2dm", "half-life 2: deathmatch"},
		[240] = {"css", "counter-strike: source"},
		[730] = {"counter-strike: global offensive", "csgo"},
		[360] = {"hldm", "hl1dm", "half-life deathmatch: source"},
		[4000] = {"gmod", "gm", "garrysmod", "garrys mod"},
		[550] = {"left 4 dead 2", "l4d2"},
		[280] = {"half-life: source", "hls"},
		[500] = {"left 4 dead"},
		[220] = {"half-life 2: lost coast", "hl2lc"},
		[400] = {"portal"},
		[300] = {"day of defeat: source", "dods", "dod"},
		[380] = {"half-life 2: episode one", "hl2e1", "ep1"},
		[570] = {"dota 2", "dota"},
		[440] = {"tf2", "team fortress 2"},
		[620] = {"portal 2"},
	}

	local temp = {}

	for k, v in pairs(translate) do
		for _, name in ipairs(v) do
			temp[name] = k
		end
	end

	translate = temp

	function steam.FindSourceGame(name)
		local games = steam.GetSourceGames()

		if type(name) == "number" then
			for i, game_info in ipairs(games) do
				if game_info.filesystem.steamappid == name then
					return game_info
				end
			end
		else
			local id = translate[name:lower()]

			if id then
				for i, game_info in ipairs(games) do
					if game_info.filesystem.steamappid == id then
						return game_info
					end
				end
			end

			for i, game_info in ipairs(games) do
				if game_info.game:lower() == name then
					return game_info
				end
			end

			for i, game_info in ipairs(games) do
				if game_info.game:compare(name) then
					return game_info
				end
			end

			for i, game_info in ipairs(games) do
				if game_info.filesystem.searchpaths.mod and game_info.filesystem.searchpaths.mod:compare(name) then
					return game_info
				end
			end
		end
	end

end

function steam.MountSourceGames()
	for i, game_info in ipairs(steam.GetSourceGames()) do
		steam.MountSourceGame(game_info)
	end
end

function steam.UnmountAllSourceGames()
	for i, game_info in ipairs(steam.GetSourceGames()) do
		steam.UnmountSourceGame(game_info)
	end
end

local mount_info = {
	["gm_.+"] = {"garry's mod", "tf2", "css"},
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
	["sp_a4_finale1"] = {"portal 2"},
	["c3m1_plankcountry"] = {"left 4 dead 2"},
	["achievement_apg_r11b"] = {"half-life 2", "team fortress 2"},
}

function steam.MountGamesFromPath(path)
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

