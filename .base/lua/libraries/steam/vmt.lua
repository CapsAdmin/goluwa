local steam = ... or _G.steam

local path_translate = {
	DiffuseTexture = "basetexture",
	Diffuse2Texture = "basetexture2",
	NormalTexture = "bumpmap",
	Normal2Texture = "bumpmap2",
	RoughnessTexture = "envmapmask",
}

local property_translate = {
	IlluminationColor = {"selfillumtint"},
	DetailScale = {"detailscale"},
	DetailBlendFactor = {"detailblendfactor"},
	NoCull = {"nocull"},
	Translucent = {"alphatest", "translucent", function(num) return num == 1 end},
	AlphaSpecular = {"normalmapalphaenvmapmask", "basealphaenvmapmask", function(num) return num == 1 end},
	RoughnessMultiplier = {"phongexponent", function(num) return num/255 end},
	MetallicMultiplier = {"phongboost", function(num) return num/100 end},
}

function steam.LoadMaterial(path, material)
	local fail = 0
	local errors = {}
	
	resource.Download(
		path,  
		function(path)
			local vmt, err = steam.VDFToTable(vfs.Read(path), function(key) return (key:lower():gsub("%$", "")) end)
			
			if err then	
				material:SetError(err)
				return
			end
			
			local k,v = next(vmt)
			
			if type(k) ~= "string" or type(v) ~= "table" then
				material:SetError("bad material " .. path)
				return
			end
			
			vmt = v
			vmt.shader = k
			vmt.fullpath = path
			
			for key, info in pairs(property_translate) do
				for i,v in ipairs(info) do
					local val = vmt[v]
					if val then
						local func = info[#info]
						
						material["Set" .. key](material, (type(func) == "function" and func(val)) or val)
						
						break
					end
				end
			end

			for key, field in pairs(path_translate) do
				if vmt[field] then 					
					local new_path = vfs.FixPath("materials/" .. vmt[field])
					if not new_path:endswith(".vtf") then
						new_path = new_path .. ".vtf"
					end
					resource.Download(
						new_path,
						function(path)
							vmt[field] = path
							material["Set" .. key](material, render.CreateTexture(path))
						end
					)
				end
			end
			
			material.vmt = vmt	
		end, 
		function()
			material:SetError("material "..path.." not found")
		end
	)
end