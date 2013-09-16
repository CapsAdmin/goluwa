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
			print(string.format("Loading VPK %q", vpk_path))

			VPK = vpk.Open(vpk_path)

			if VPK then
				VPKS[#VPKS + 1] = VPK
			end
		end
	end
end

if jit.os == "Linux" then
	print("LOADING VPKS")
	traverse(os.getenv("HOME") .. "/.local/share/Steam/SteamApps/common", callback)
	print("DONE LOADING VPKS ^_^")
end

function JustFindTheDamnThing(path)
	for k, v in ipairs(VPKS) do
		local data = v:Read(path)
		if data then print("FOUND IN " .. v.path) return data end
	end

	print("WHAT A HSAME")
end
