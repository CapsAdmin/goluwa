local steam = _G.steam or {}

steam.cache_path = "gamepaths.txt"

local function traverse(path, callback)
	local mode = lfs.symlinkattributes(path, "mode")

	if not mode then
		return
	end
	
	callback(path, mode)

	if mode == "directory" then
		for child in lfs.dir(path) do
			if child ~= "." and child ~= ".." then
				traverse(path .. "/" .. child, callback)
			end
		end
	end
end

function steam._Traverse(path, callback)
	local found = 0
	
	local co = coroutine.create(function()
		traverse(path, function(path, mode) 
			found = found + 1
			callback(path, mode, found)
			coroutine.yield()
		end)
	end)
	
	timer.Thinker(function() 
		local ok, err = coroutine.resume(co)
		
		if not ok then
			logn(err)
			return false
		end
	end, 100)
end

function steam.LoadGamePaths()
	logf("Loading game paths")

	steam.paths = luadata.ReadFile(steam.cache_path)
end

function steam.SaveGamePaths()
	--logf("Saving game paths")

	luadata.WriteFile(steam.cache_path, steam.paths)
end

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
						
						logf("found %s with appid %s", name, appid)
												
						--table.sort(steam.paths)

						steam.SaveGamePaths()
					end
				end
			end
			if wait(1) then
				logf("found %i files..", count)
			end
		end)
	end
end

function steam.GetInstallPath()
	local path

	if WINDOWS then
		path = system.GetRegistryKey("Software\\Valve\\Steam", "SteamPath") or (X64 and "C:\\Program Files (x86)\\Steam" or "C:\\Program Files\\Steam")
	elseif LINUX then
		path = os.getenv("HOME") .. "/.local/share/Steam"
	end

	return lfs.symlinkattributes(path, "mode") and path or nil
end

function steam.GetLibraryFolders()
	local base = steam.GetInstallPath()
	
	local tbl = {base .. "/SteamApps/"}
	
	local cfg = assert(vfs.Read(base .. "/config/config.vdf", "r"))
	
	for path in cfg:gmatch([["BaseInstallFolder.."%s-"(.-)"]]) do
		table.insert(tbl, vfs.FixPath(path) .. "/SteamApps/")
	end
	
	return tbl
end

function steam.GetGamePath(game)
	for _, dir in pairs(steam.GetLibraryFolders()) do
		local path = dir .. "Common/" .. game .. "/"
		if vfs.Exists(path .. "nul") then
			return path
		end
	end
end

return steam
