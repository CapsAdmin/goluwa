local steam = ... or _G.steam

commands.Add("mount=string", function(game)
	local game_info = assert(steam.MountSourceGame(game))
	llog("mounted %s", game_info.name)
end)

commands.Add("unmount=string", function(game)
	local game_info = assert(steam.UnmountSourceGame(game))
	llog("unmounted %s", game_info.name)
end)

commands.Add("mount_all=string", function(game)
	steam.MountAllSourceGames()
end)

commands.Add("unmount_all", function()
	steam.UnmountAllSourceGames()
end)

commands.Add("mount_clear", function()
	local ok = false

	for i, v in ipairs(vfs.Find("cache/archive/", true)) do
		vfs.Delete(v)
		ok = true
	end

	if not ok and vfs.Delete("cache/source_games") then ok = true end

	if ok then
		logn("removed cache/archive/* and data/source_games")
	else
		logn("nothing to remove")
	end
end)

pvars.Setup2(
	{
		key = "steam_mount",
		default = {},
		get_list = function()
			local lst = {}

			for _, info in pairs(steam.GetSourceGames()) do
				lst[info.filesystem.steamappid] = {friendly = info.name}
			end

			return lst
		end,
		callback = function(lst)
			for appid, v in pairs(steam.GetMountedSourceGames()) do
				steam.UnmountSourceGame(appid)
			end

			for i, v in ipairs(lst) do
				steam.MountSourceGame(v)
			end
		end,
	}
)

commands.Add("list_games", function()
	if not next(steam.GetSourceGames()) then
		logn("no source games found")
		table.print(steam.GetGameFolders())
		table.print(steam.GetLibraryFolders())
	end

	for _, info in pairs(steam.GetSourceGames()) do
		logn(info.game)
		logn("\tgame_dir = ", info.game_dir)
		logn("\tappid = ", info.filesystem.steamappid)
		logn()
	end
end)

commands.Add("list_maps", function(search)
	for _, name in ipairs(vfs.Find("maps/%.bsp$")) do
		if not search or name:find(search) then logn(name:sub(0, -5)) end
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
		path = system.GetRegistryValue("CurrentUser/Software/Valve/Steam/SteamPath") or
			(
				X64 and
				"C:\\Program Files (x86)\\Steam" or
				"C:\\Program Files\\Steam"
			)
	elseif OSX then
		path = os.getenv("HOME") .. "/Library/Application Support/Steam"
	else
		path = os.getenv("HOME") .. "/.steam/steam"

		if not vfs.IsDirectory(path) then
			path = os.getenv("HOME") .. "/.local/share/Steam"
		end

		if not vfs.IsDirectory(path) then
			path = os.getenv("HOME") .. "/.wine/drive_c/Program Files (x86)/Steam"
		end

		if not vfs.IsDirectory(path) then
			path = os.getenv("HOME") .. "/.var/app/com.valvesoftware.Steam/.local/share/Steam"
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
			list.insert(tbl, vfs.FixPathSlashes(path) .. "/steamapps/")
		end
	end

	return tbl
end

function steam.GetGamePath(game)
	for _, dir in pairs(steam.GetLibraryFolders()) do
		local path = dir .. "common/" .. game .. "/"

		if vfs.IsDirectory(path) then return path end
	end

	return ""
end

function steam.GetGameFolders(skip_mods)
	local games = {}

	for _, library in ipairs(steam.GetLibraryFolders()) do
		for _, game in ipairs(vfs.Find(library .. "common/", true)) do
			list.insert(games, game .. "/")
		end

		if not skip_mods then
			for _, mod in ipairs(vfs.Find(library .. "sourcemods/", true)) do
				list.insert(games, mod .. "/")
			end
		end
	end

	return games
end

function steam.GetSourceGames()
	local found = serializer.ReadFile("msgpack", "cache/source_games")

	if found and found[1] then
		for i, v in ipairs(found) do
			if not vfs.IsFile(v.gameinfo_path) then
				logn("unable to find ", v.gameinfo_path, ", rebuilding steam.GetSourceGames cache")
				found = nil

				break
			end
		end

		if found then return found end
	end

	found = {}
	local done = {}

	local function collect_gameinfos()
		local gameinfos = {}

		for _, game_dir in ipairs(steam.GetGameFolders()) do
			if vfs.IsDirectory("os:" .. game_dir .. "/game") then
				for _, dir in ipairs(vfs.Find("os:" .. game_dir .. "game/", true)) do
					if not dir:ends_with("/core") then
						dir = dir .. "/"
						local path = "os:" .. dir .. "gameinfo.gi"
						local str = vfs.Read(path)
						local game_info_dir = dir
						dir = vfs.GetParentFolderFromPath(dir)

						if str then
							local tbl = utility.VDFToTable(str, true)

							if tbl and tbl.gameinfo and tbl.gameinfo.game and tbl.gameinfo.filesystem then
								local core = utility.VDFToTable(vfs.Read("os:" .. game_dir .. "game/core/gameinfo.gi"), true)
								tbl = tbl.gameinfo
								tbl = table.merge(core.gameinfo, tbl)
								tbl.gameinfo_path = path
								tbl.game_dir = game_dir
								tbl.vdf_directory = dir
								list.insert(gameinfos, tbl)
							end
						end
					end
				end
			end

			for _, dir in ipairs(vfs.Find("os:" .. game_dir, true)) do
				dir = dir .. "/"
				local path = "os:" .. dir .. "gameinfo.txt"
				local str = vfs.Read(path)

				if not str then
					path = "os:" .. dir .. "GameInfo.txt"
					str = vfs.Read(path)
				end

				local game_info_dir = dir
				dir = vfs.GetParentFolderFromPath(dir)

				if str then
					local tbl = utility.VDFToTable(str, true)

					if tbl and tbl.gameinfo and tbl.gameinfo.game and tbl.gameinfo.filesystem then
						tbl = tbl.gameinfo
						tbl.gameinfo_path = path
						tbl.game_dir = game_dir
						tbl.vdf_directory = dir
						list.insert(gameinfos, tbl)
					end
				end
			end
		end

		return gameinfos
	end

	for _, tbl in ipairs(collect_gameinfos()) do
		if not tbl.filesystem.steamappid or not done[tbl.filesystem.steamappid] then
			if tbl.filesystem.steamappid then
				done[tbl.filesystem.steamappid] = true
			end

			local name = tbl.game

			if tbl.title and tbl.title ~= name then
				name = name .. " - " .. tbl.title
			end

			if tbl.title and tbl.title2 and tbl.title2 ~= tbl.title then
				name = name .. " - " .. tbl.title2
			end

			tbl.name = name
			local gameinfo = tbl

			if tbl.filesystem then
				local fixed = {}
				local done = {}

				for _, v in pairs(tbl.filesystem.searchpaths) do
					local vdf_directory = tbl.vdf_directory
					local tbl = type(v) == "string" and {v} or v

					for _, path in pairs(tbl) do
						if path:find("|", nil, true) then
							path = path:replace("|gameinfo_path|", game_info_dir)
							path = path:replace("|all_source_engine_paths|", dir)
						else
							path = vdf_directory .. path
						end

						path = vfs.FixPathSlashes(path)

						if path:ends_with("*") then
							if not done[path] then
								list.insert(fixed, path)
								done[path] = true
							end
						else
							if path:ends_with(".") then path = path:sub(0, -2) end

							if path:ends_with("/") then
								local test = path .. "/"

								if vfs.IsDirectory(test) then
									if not done[test] then
										list.insert(fixed, test)
										done[test] = true
									end
								end
							else
								local test = path .. "/"

								if vfs.IsDirectory(test) then
									if not done[test] then
										list.insert(fixed, test)
										done[test] = true
									end
								end

								local test = path .. "/pak01_dir.vpk/"

								if vfs.IsDirectory(test) then
									if not done[test] then
										list.insert(fixed, test)
										done[test] = true
									end
								end

								local test = gameinfo.game_dir .. path

								if not vfs.IsDirectory(path) and vfs.IsDirectory(test) then
									if not done[test] then
										list.insert(fixed, test)
										done[test] = true
									end
								end

								if test:ends_with(".vpk") and not vfs.IsFile("os:" .. test) then
									local path = test:gsub("(.+/.+)%.vpk", "%1_dir.vpk") .. "/"

									if not done[path] then
										list.insert(fixed, path)
										done[path] = true
									end
								end
							end

							if path:ends_with(".vpk") and not vfs.IsFile("os:" .. path) then
								local path = path:gsub("(.+/.+)%.vpk", "%1_dir.vpk") .. "/"

								if not done[path] then
									list.insert(fixed, path)
									done[path] = true
								end
							end
						end
					end
				end

				-- utility.VDFToTable does not support ordered keys.
				-- lets just prioritize vpk in the meantime
				local sorted = {}

				for _, v in ipairs(fixed) do
					if v:ends_with(".vpk/") then list.insert(sorted, v) end
				end

				for _, v in ipairs(fixed) do
					if not v:ends_with(".vpk/") then list.insert(sorted, v) end
				end

				tbl.filesystem.searchpaths = sorted
				list.insert(found, tbl)
			end
		end
	end

	serializer.WriteFile("msgpack", "cache/source_games", found)
	return found
end

do
	local cache_mounted = {}

	function steam.IsSourceGameMounted(var)
		local game_info, err = steam.FindSourceGame(var)

		if not game_info then return nil, err end

		if cache_mounted[game_info.filesystem.steamappid] then return true end

		return false
	end

	function steam.MountSourceGame(var, skip_addons)
		local game_info, err = steam.FindSourceGame(var)

		if not game_info then return nil, err end

		if cache_mounted[game_info.filesystem.steamappid] then
			llog("already mounted")
			return cache_mounted[game_info.filesystem.steamappid]
		end

		steam.UnmountSourceGame(game_info)

		for _, path in ipairs(game_info.filesystem.searchpaths) do
			if path:ends_with("*") then
				for _, path in ipairs(vfs.Find(path:sub(0, -2), true)) do
					if vfs.IsDirectory(path) then
						if
							game_info.game == "Garry's Mod" and
							not pvars.Get("gine_local_addons_only")
							and
							not skip_addons
						then
							llog("mounting %s", path)
							vfs.Mount(path, nil, game_info)
						else

						--llog("NOT mounting %s", path)
						end
					end
				end
			else
				if not path:ends_with(".vpk/") then
					for _, v in ipairs(vfs.Find(path .. "/maps/workshop/")) do
						llog("mounting workshop map %s", v)
						vfs.Mount(path .. "/maps/workshop/" .. v, "maps/", game_info)
					end
				end

				llog("mounting %s", path)
				vfs.Mount(path, nil, game_info)
			end
		end

		for _, lib_folder in ipairs(steam.GetLibraryFolders()) do
			for _, path in ipairs(
				vfs.Find(lib_folder .. "workshop/content/" .. game_info.filesystem.steamappid .. "/", true)
			) do
				if vfs.IsFile(path .. "/temp.gma") then
					llog("mounting workshop addon %s", path)
					vfs.Mount(path .. "/temp.gma", nil, game_info)
				end
			end
		end

		cache_mounted[game_info.filesystem.steamappid] = game_info
		return game_info
	end

	function steam.UnmountSourceGame(var)
		local game_info, err = steam.FindSourceGame(var)

		if not game_info then return nil, err end

		cache_mounted[game_info.filesystem.steamappid] = nil

		for _, v in pairs(vfs.GetMounts()) do
			if
				v.userdata and
				v.userdata.filesystem.steamappid == game_info.filesystem.steamappid
			then
				vfs.Unmount(v.full_where, v.full_to)
			end
		end

		return game_info
	end

	function steam.GetMountedSourceGames()
		return cache_mounted
	end

	function steam.GetMountedSourceGames2()
		local out = {}
		local done = {}

		for k, v in pairs(vfs.GetMounts()) do
			if v.userdata and v.userdata.filesystem and v.userdata.filesystem.steamappid then
				if not done[v.userdata] then
					list.insert(out, v.userdata)
					done[v.userdata] = true
				end
			end
		end

		return out
	end
end

function steam.FindSourceGame(var)
	local appid

	if type(var) == "number" then
		appid = var
	elseif type(var) == "table" then
		if var.filesystem and var.filesystem.steamappid then
			appid = var.filesystem.steamappid
		end
	else
		appid = steam.GetAppIdFromName(var)
	end

	if appid and tonumber(appid) then
		for _, game_info in ipairs(steam.GetSourceGames()) do
			if game_info.filesystem.steamappid == tonumber(appid) then
				return game_info
			end
		end
	end

	return nil, "could not find " .. tostring(var)
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
			for k, v in pairs(mount_info) do
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