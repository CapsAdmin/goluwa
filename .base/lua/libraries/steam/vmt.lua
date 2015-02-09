local steam = ... or _G.steam

function solve_path(name, extensions, directory_hint, on_success, on_fail)
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
				table.insert(tries, (vfs.FixPath(path .. ext)))
			end
		end
	end
	
	local fail = 0
	local errors = {}
		
	for _, path in ipairs(tries) do
		resource.Download(
			path, 
			function(path)
				on_success(path)
			end, 
			function()
				fail = fail + 1 
				if fail == #tries then 
					on_fail("material \"" .. name .. "\" could not be found in:\n\t" .. table.concat(errors, "\n\t")) 
				end 
				table.insert(errors, path)
			end
		)		
	end
end

local path_fields = {
	"basetexture",
	"basetexture2",
	"basetexture3",
	"detail",
	"bumpmap",
	"normalmap",
}

function steam.LoadMaterial(name, directory_hint, callback, texture_callback)
	solve_path(
		name, 
		{".vmt", ".vtf", "_01.vmt", "_02.vmt"}, 
		directory_hint, 
		function(path)
			if path:endswith(".vtf") then
				callback({
					fullpath = path,
					basetexture = path,
				})
				texture_callback("basetexture", path)
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
				vmt.fullpath = path
										
				for i, field in ipairs(path_fields) do
					if vmt[field] then 
						solve_path(
							vmt[field], 
							{".vtf", ""}, 
							nil, 
							function(path)
								vmt[field] = path 	
								texture_callback(field, path)
							end, 
							function(reason)
								--logn(reason)
							end
						)
					end
				end
				
				callback(vmt)
			end
			
		end, 
		function(reason)
			callback({
				error = err,
				basetexture = "error",
			})
		end
	)
end