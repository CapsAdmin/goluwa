local steam = ... or _G.steam

local path_fields = {
	"basetexture",
	"basetexture2",
	"basetexture3",
	"detail",
	"bumpmap",
	"normalmap",
}

function steam.LoadMaterial(path, callback, texture_callback)
	local fail = 0
	local errors = {}
	
	resource.Download(
		path,  
		function(path)
			local vmt, err = steam.VDFToTable(vfs.Read(path), function(key) return (key:lower():gsub("%$", "")) end)
			
			if err then	
				callback({
					fullpath = path,
					error = path .. ": " .. err,
					basetexture = "error",
				})
				return
			end
			
			local k,v = next(vmt)
			
			if type(k) ~= "string" or type(v) ~= "table" then
				callback({
					fullpath = path,
					error = "bad material " .. path,
					basetexture = "error",
				})
				return
			end
			
			vmt = v
			vmt.shader = k
			vmt.fullpath = path
									
			for i, field in ipairs(path_fields) do
				if vmt[field] then 					
					local new_path = vfs.FixPath("materials/" .. vmt[field])
					if not new_path:endswith(".vtf") then
						new_path = new_path .. ".vtf"
					end
					resource.Download(
						new_path,
						function(path)
							vmt[field] = path 	
							texture_callback(field, path)
						end
					)
				end
			end
			
			callback(vmt)			
		end, 
		function()
			callback({
				error = "material "..path.." not found",
				basetexture = "error",
			})
		end
	)
end