local steam = ... or _G.steam

console.AddCommand("mount", function(game)
	steam.MountSourceGame(game)
end)

console.AddCommand("unmount", function(game)
	steam.UnmountSourceGame(game)
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
						
						logf("found %s with appid %s\n", name, appid)
												
						--table.sort(steam.paths)

						steam.SaveGamePaths()
					end
				end
			end
			if wait(1) then
				logf("found %i files..\n", count)
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
	end

	return lfs.symlinkattributes(path, "mode") and path or nil
end

function steam.GetLibraryFolders()
	local base = steam.GetInstallPath()
	
	local tbl = {base .. "/SteamApps/"}
		
	local config = steam.VDFToTable(assert(vfs.Read(base .. "/config/config.vdf", "r")))

	for key, path in pairs(config.InstallConfigStore.Software.Valve.Steam) do
		
		if key:find("BaseInstallFolder_") then
			table.insert(tbl, vfs.FixPath(path) .. "/SteamApps/")
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
		for i, folder in ipairs(vfs.Find(game_dir, nil, true)) do
			if vfs.IsDir(folder) then
				for i, path in ipairs(vfs.Find(folder .. "/", nil, true)) do
					if path:lower():find("gameinfo") then
						local str = vfs.Read(path)
						
						local tbl = steam.VDFToTable(str, true, {gameinfo_path = path:match("(.+/)"), all_source_engine_paths = path:match("(.+/).+/")})
						if tbl and tbl.gameinfo and tbl.gameinfo.game then
							tbl = tbl.gameinfo
							
							tbl.game_dir = game_dir
							
							table.insert(found, tbl)
						end
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
		return
	end
	
	local str_game_info

	if type(game_info) == "string" then 
		str_game_info = game_info
		game_info = steam.FindSourceGame(game_info) 
	end
	
	steam.UnmountSourceGame(game_info)
	
	local done = {}
	
	for i, paths in pairs(game_info.filesystem.searchpaths) do
		if type(paths) == "string" then 
			paths = {paths} 
		end
		
		for i, path in pairs(paths) do				
			
			if not vfs.IsDir(path) then
				path = game_info.game_dir .. path .. "/"
			end
			
			path = path:gsub("/%.", "/")
			
			if not done[path] and vfs.Exists(path) then
				if not vfs.GetMounts()[path] then
					vfs.Mount(path, nil, game_info)
				end
									
				
				if vfs.IsDir(path .. "addons/") then
					for k, v in pairs(vfs.Find(path .. "addons/")) do
						if vfs.IsDir(path .. "addons/" .. v) then
							vfs.Mount(path .. "addons/" .. v, nil, game_info)
							logn("[vfs] also mounting addon ", v)
						end
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
								vfs.Mount(path .. v .. "/", nil, game_info)
							end
							done[path .. v] = true
						end
					end
				end
				
				done[path] = true
			end
		end
	end
	
	if str_game_info then
		cache_mounted[str_game_info] = true
	end
end

function steam.UnmountSourceGame(game_info, title)

	if type(game_info) == "string" then 
		cache_mounted[game_info] = nil
		game_info = steam.FindSourceGame(game_info, title) 
	end
	
	for k, v in pairs(vfs.GetMounts()) do
		if v.userdata and v.userdata.filesystem.steamappid == game_info.filesystem.steamappid then
			vfs.Unmount(v.full_where, v.full_to)
		end
	end
end


local translate = {
	["half-life 2"] = 220,
	["counter-strike: source"] = 240,
	["half-life: source"] = 280,
	["day of defeat: source"] = 300,
	["half-life 2: deathmatch"] = 320,
	["half-life 2: lost coast"] = 220,
	["half-life deathmatch: source"] = 360,
	["half-life 2: episode one"] = 380,
	["portal"] = 400,
	["half-life 2: episode two"] = 420,
	["team fortress 2"] = 440,
	["left 4 dead"] = 500,
	["left 4 dead 2"] = 550,
	["dota 2"] = 570,
	["portal 2"] = 620,
	["alien swarm"] = 630,
	["counter-strike: global offensive"] = 730,
	["dota 2"] = 570,
	["gmod"] = 4000	,
	["garrysmod"] = 4000,
}

function steam.FindSourceGame(name, title)
	if name then 
		name = translate[name:lower()] or name
	end
	title = title or ""
	
	for i, game_info in ipairs(steam.GetSourceGames()) do
		if 
			(type(name) == "number" and game_info.filesystem.steamappid == name) or 
			(type(name) == "string" and ((game_info.filesystem.searchpaths.mod and game_info.filesystem.searchpaths.mod:compare(name)) or game_info.game:compare(name)) and (game_info.title2 or game_info.title):compare(title))
		then 
			return game_info
		end
	end
end
function steam.MountAllSourceGames()
	for i, game_info in ipairs(steam.GetSourceGames()) do
		steam.MountSourceGame(game_info)
	end
end