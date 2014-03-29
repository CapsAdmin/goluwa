local base = steam.GetGamePath("GarrysMod")

-- mount the base source engine
vfs.Mount(base .. "sourceengine")

for path in vfs.Iterate(base .. "sourceengine/.-_dir%.vpk", nil, true) do 
	vfs.Mount(path)
end

-- mount gmod
vfs.Mount(base .. "garrysmod")

for path in vfs.Iterate(base .. "garrysmod/.-_dir%.vpk", nil, true) do 
	vfs.Mount(path)
end

-- and all the addons

for path in vfs.Iterate(base .. "garrysmod/addons/", nil, true) do 
	if vfs.IsDir(path) then 
		vfs.Mount(path) 
	end 
end