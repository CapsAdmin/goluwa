local steam = ... or _G.steam

console.AddCommand("mount", function(game)
	local game_info = assert(steam.MountSourceGame(game))
	llog("mounted %s %s", game_info.game, game_info.title2)
end)

console.AddCommand("unmount", function(game)
	local game_info = assert(steam.UnmountSourceGame(game))
	llog("unmounted %s %s", game_info.game, game_info.title2 or game_info.title)
end)

function steam.FindGamePaths(force_cache_update)
	steam.paths = {}

	if vfs.Exists(steam.cache_path) and not force_cache_update then
		steam.LoadGamePaths()
	else
		steam._Traverse(steam.GetInstallPath() .. "/SteamApps", function(path, mode, count)
			if mode == "file" and path:find("gameinfo.txt", -12, true) then
				local data = vfs.Read(path)

				if data then
					local name = data:match("game%s-\"([^\"]+)\"")
					local appid = data:match("SteamAppId%s-(%d+)")

					if name and appid then
						steam.paths[#steam.paths + 1] = {
							name = name,
							appid = appid,
							path = path:match("^(.-)/?[^/]*$")
						}

						llog("found %s with appid %s", name, appid)

						--table.sort(steam.paths)

						steam.SaveGamePaths()
					end
				end
			end
			if wait(1) then
				llog("found %i files..", count)
			end
		end)
	end
end

function steam.GetInstallPath()
	local path

	if WINDOWS then
		path = system.GetRegistryValue("CurrentUser/Software/Valve/Steam/SteamPath") or (X64 and "C:\\Program Files (x86)\\Steam" or "C:\\Program Files\\Steam")
	elseif LINUX then
		path = os.getenv("HOME") .. "/.local/share/Steam"
		if not vfs.IsFolder(path) then
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
		if vfs.IsDir(path) then
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

					tbl.game_dir = game_dir

					if tbl.filesystem then
						local fixed = {}

						for k,v in pairs(tbl.filesystem.searchpaths) do
							for k,v in pairs(type(v) == "string" and {v} or v) do
								if v:find("|gameinfo_path|") then
									v = v:gsub("|gameinfo_path|", path:match("(.+/)"))
								elseif v:find("|all_source_engine_paths|") then
									v = v:gsub("|all_source_engine_paths|", dir)
								else
									v = dir .. v
								end

								table.insert(fixed, v)
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

	local done = {}

	for i, path in pairs(game_info.filesystem.searchpaths) do
		local path = "os:" .. path

		if path:endswith("/.") then
			path = path:sub(0, -2)
		end

		if not done[path] and vfs.Exists(path) then
			if not vfs.GetMounts()[path] then
				vfs.Mount(path, nil, game_info)
			end

			if vfs.IsDir(path .. "addons/") then
				for k, v in pairs(vfs.Find(path .. "addons/")) do
					if vfs.IsDir(path .. "addons/" .. v) or v:endswith(".gma") then
						logn("[vfs] also mounting addon ", v)
						vfs.Mount(path .. "addons/" .. v, nil, game_info)
					end
				end
			end

			if vfs.IsDir(path .. "maps/workshop/") then
				for k, v in pairs(vfs.Find(path .. "maps/workshop/")) do
					vfs.Mount(path .. "maps/workshop/" .. v, "maps/", game_info)
				end
			end

			-- garry's mod exceptions..
			if game_info.filesystem.steamappid == 4000 then
				for k, v in pairs(vfs.Find(game_info.game_dir .. "sourceengine/")) do
					if not done[v] then
						if v:find("%.vpk") and v:find("_dir") and not vfs.GetMounts()[game_info.game_dir .. v .. "/"] then
							vfs.Mount(game_info.game_dir .. "sourceengine/" .. v .. "/", nil, game_info)
						end
						done[v] = true
					end
				end
			end

			if vfs.IsDir(path) then
				if not path:endswith("/") then
					path = path .. "/"
				end

				if vfs.IsDir(path .. "download/") and not vfs.GetMounts()[path .. "download/"] then
					vfs.Mount(path .. "download/", nil, game_info)
				end

				for k, v in pairs(vfs.Find(path)) do
					if not done[path .. v] then
						if v:find("%.vpk") and v:find("_dir") and not vfs.GetMounts()[path .. v .. "/"] then
							vfs.Mount(path:sub(4) .. v .. "/", nil, game_info)
						end
						done[path .. v] = true
					end
				end
			end
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


local translate = {
	["counter-strike: source"] = 240,
	["css"] = 240,
	["half-life: source"] = 280,
	["hls"] = 280,
	["day of defeat: source"] = 300,
	["dods"] = 300,
	["half-life 2: deathmatch"] = 320,
	["hl2dm"] = 320,
	["half-life 2: lost coast"] = 220,
	["hl2lc"] = 220,
	["half-life deathmatch: source"] = 360,
	["hldm"] = 360,
	["half-life 2: episode one"] = 380,
	["hl2e1"] = 380,
	["portal"] = 400,
	["half-life 2: episode two"] = 420,
	["hl2ep2"] = 420,
	["team fortress 2"] = 440,
	["tf2"] = 440,
	["left 4 dead"] = 500,
	["l4d2"] = 550,
	["left 4 dead 2"] = 550,
	["dota 2"] = 570,
	["portal 2"] = 620,
	["alien swarm"] = 630,
	["counter-strike: global offensive"] = 730,
	["csgo"] = 730,
	["dota 2"] = 570,
	["gmod"] = 4000	,
	["garrysmod"] = 4000,
}

local name_translate = {
	["ep1"] = "episodic",
}

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

function steam.MountAllSourceGames()
	for i, game_info in ipairs(steam.GetSourceGames()) do
		steam.MountSourceGame(game_info)
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