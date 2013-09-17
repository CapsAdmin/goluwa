local function traverse(path, callback)
	local mode = lfs.symlinkattributes(path, "mode")
	if mode then
		callback(path, mode)
		if mode == "directory" then
			for child in lfs.dir(path) do
				if child ~= "." and child ~= ".." then
					traverse(path .. "/" .. child, callback)
				end
			end
		end
	end
end

VPKS = {}

local function callback(path, mode)
	if mode == "file" then
		local vpk_path = path:match("^(.*)_dir%.vpk$")

		if vpk_path then
			local vpk_ = vpk.Open(vpk_path)

			if vpk_ then
				print("Loaded VPK " .. vpk_path)
				VPKS[#VPKS + 1] = vpk_
			else
				print("Loading VPK " .. vpk_path .. " failed")
			end
		end
	end
end

function FindFileInVPKs(path)
	for k, v in ipairs(VPKS) do
		local data = v:Read(path)
		if data then print("FOUND IN " .. v.path) return data end
	end

	print("WHAT A HSAME")
end

if jit.os == "Linux" then
	traverse(os.getenv("HOME") .. "/.local/share/Steam/SteamApps/common", callback)
end

if CAPSADMIN then
	traverse("G:/steam/steamapps/common")
end

-- yabba
FindFileInVPKs("models/zombie/classic.mdl")
