local steam = ... or steam

local textures = {
	basetexture = true,
	basetexture2 = true,
	texture = true,
	texture2 = true,
	bumpmap = true,
	bumpmap2 = true,
	envmapmask = true,
	phongexponenttexture = true,
	blendmodulatetexture = true,
	selfillummask = true,
}

local special_textures = {
	_rt_fullframefb = "error",
	[1] = "error", -- huh
}

function steam.LoadVMT(path, on_property, on_error, on_shader)
	resource.Download(
		path,
		function(path)
			if path:endswith(".vtf") then
				on_property("basetexture", path, path, {})
				-- default normal map?
				return
			end

			local vmt, err = utility.VDFToTable(vfs.Read(path), function(key) return (key:lower():gsub("%$", "")) end)

			if err then
				on_error(path .. " utility.VDFToTable : " .. err)
				return
			end

			local k,v = next(vmt)

			if type(k) ~= "string" or type(v) ~= "table" then
				on_error("bad material " .. path)
				table.print(vmt)
				return
			end

			if on_shader then
				on_shader(k)
			end

			if k == "patch" then
				if not vfs.IsFile(v.include) then
					v.include = vfs.FindMixedCasePath(v.include) or v.include
				end

				local vmt2, err2 = utility.VDFToTable(vfs.Read(v.include), function(key) return (key:lower():gsub("%$", "")) end)

				if err2 then
					on_error(err2)
					return
				end

				local k2,v2 = next(vmt2)

				if type(k2) ~= "string" or type(v2) ~= "table" then
					on_error("bad material " .. path)
					table.print(vmt)
					return
				end

				table.merge(vmt2, v.replace)

				vmt = vmt2
				v = v2
				k = k2
			end

			vmt = v
			local fullpath = path

			for k, v in pairs(vmt) do
				if type(v) == "string" and (special_textures[v] or special_textures[v:lower()]) then
					vmt[k] = special_textures[v]
				end
			end

			if not vmt.bumpmap and vmt.basetexture and not special_textures[vmt.basetexture] then
				local new_path = vfs.FixPathSlashes(vmt.basetexture)
				if not new_path:endswith(".vtf") then
					new_path = new_path .. ".vtf"
				end
				new_path = new_path:gsub("%.vtf", "_normal.vtf")
				if vfs.IsFile("materials/" .. new_path) then
					vmt.bumpmap = new_path
				else
					new_path = new_path:lower()
					if vfs.IsFile("materials/" .. new_path) then
						vmt.bumpmap = new_path
					end
				end
			end

			for k,v in pairs(vmt) do
				if type(v) == "string" and textures[k] and (not special_textures[v] and not special_textures[v:lower()]) then
					local new_path = vfs.FixPathSlashes("materials/" .. v)
					if not new_path:endswith(".vtf") then new_path = new_path .. ".vtf" end
					resource.Download(new_path, function(path) on_property(k, path, fullpath, vmt) end, on_error and function() on_error("texture " .. k .. " " .. new_path .. " not found") end or nil, nil, true)
				else
					on_property(k, v, fullpath, vmt)
				end
			end
		end,
		function()
			on_error("material "..path.." not found")
		end,
		nil,
		true
	)
end