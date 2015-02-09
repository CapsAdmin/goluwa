local steam = ... or _G.steam

local path_fields = {
	"basetexture",
	"basetexture2",
	"basetexture3",
	"detail",
	"bumpmap",
	"normalmap",
}

local function solve_path(path, extensions, on_success, on_fail)		
	local fail = 0
	local errors = {}
		
	for _, ext in ipairs(extensions) do
		resource.Download(
			path .. ext, 
			function(path)
				on_success(path)
			end, 
			function()
				fail = fail + 1 
				if fail == #extensions then 
					on_fail("material \"" .. path .. "\" could not be found in:\n\t" .. table.concat(errors, "\n\t")) 
				end 
				table.insert(errors, path)
			end
		)		
	end
end

function steam.LoadMaterial(path, callback, texture_callback)
	solve_path(
		path, 
		{".vmt", ".vtf"}, 
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
					callback({
						fullpath = path,
						error = path .. ": " .. err,
						basetexture = "error",
					})
				end
				
				local k,v = next(vmt)
				
				if type(k) ~= "string" or type(v) ~= "table" then
					callback({
						fullpath = path,
						error = "bad material " .. path,
						basetexture = "error",
					})
				end
				
				vmt = v
				vmt.shader = k
				vmt.fullpath = path
										
				for i, field in ipairs(path_fields) do
					if vmt[field] then 
						solve_path(
							vfs.FixPath("materials/" .. vmt[field]), 
							{".vtf", ""}, 
							function(path)
								vmt[field] = path 	
								texture_callback(field, path)
							end, 
							logn
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