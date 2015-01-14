local steam = ... or _G.steam

function solve_path(name, extensions, directory_hint)
	extensions = extensions or {".vmt"}
	
	local tries = {}
	
	do
		local temp = {
			"materials/" .. name, 
			"textures/" .. name,
		}
		
		if directory_hint then
		
			table.insert(temp, 1, "materials/" .. directory_hint .. name)
			table.insert(temp, 1, "textures/" .. directory_hint .. name)
		
			local dir = directory_hint:match("(.+/)")
			local dir2 = directory_hint:match("(.+)%.")
			
			if dir then
				table.insert(temp, "materials/" .. dir .. "/" .. name)
				table.insert(temp, "textures/" .. dir .. "/" .. name)
			end
			
			if dir2 then
				table.insert(temp, "materials/" .. dir2 .. "/" .. name)
				table.insert(temp, "textures/" .. dir2 .. "/" .. name)
			end
		end
			
		for _, ext in ipairs(extensions) do
			for i, path in ipairs(temp) do
				table.insert(tries, path .. ext)
			end
		end
	end
	
	for i, path in ipairs(tries) do
		path = vfs.FixPath(path)
		if vfs.IsFile(path) then
			return path
		end
		tries[i] = path -- so it looks nicer in the error
	end
		
	return nil, "material \"" .. name .. "\" could not be found in:\n\t" .. table.concat(tries, "\n\t")
end

local path_fields = {
	"basetexture",
	"basetexture2",
	"basetexture3",
	"detail",
	"bumpmap",
	"normalmap",
}

function steam.LoadMaterial(name, directory_hint)
	local path, err = solve_path(name, {".vmt", ".vtf", "_01.vmt", "_02.vmt"}, directory_hint)
	
	if err then	
		return {
			error = err,
			basetexture = "error",
		}
	end
		
	if path:endswith(".vtf") then
		return {
			fullpath = path,
			basetexture = path,
		}
	else
		local vmt, err = steam.VDFToTable(vfs.Read(path), function(key) return (key:lower():gsub("%$", "")) end)
		
		if err then	
			return {
				fullpath = path,
				error = path .. ": " .. err,
				basetexture = "error",
			}
		end
		
		local k,v = next(vmt)
		
		if type(k) ~= "string" or type(v) ~= "table" then
			return {
				fullpath = path,
				error = "bad material " .. path,
				basetexture = "error",
			}
		end
		
		vmt = v
		vmt.shader = k
	
		for i, field in ipairs(path_fields) do
			if vmt[field] then 
				vmt[field] = solve_path(vmt[field], {".vtf", ""}) or vmt[field]
			end
		end
		
		vmt.fullpath = path
		
		return vmt
	end
end