local prefix = steam.GetInstallPath() .. "/SteamApps/common"
local packs = {}

logf("Looking for VPKs in %q", prefix)

vfs.Traverse(prefix, function(path, mode, level)
	if mode == "file" and path:find("_dir%.vpk$") then
		packs[#packs + 1] = path
	end
end)

logf("Found %i VPKs", #packs)

local files = {}

for k, v in ipairs(packs) do
	local data, error_message = vpk.Read(v)

	if not data then
		print(error_message)
	end

	for k, v in ipairs(data.tree) do
		files[v.Path] = files[v.Path] or {}
		files[v.Path][#files[v.Path] + 1] = v
	end
end

FILES = files
