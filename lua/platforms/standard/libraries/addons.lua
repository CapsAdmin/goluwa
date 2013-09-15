local addons = {}

addons.Root = "addons/"
addons.Info = {}

function addons.SortAfterPriority()
	table.sort(addons.Info, function(a,b) return a.priority > b.priority end)
end

function addons.AutorunAll(folder)	
				
	if folder then 
		folder = folder .. "/" 
	else
		folder = "/"
	end
		
	for _, info in ipairs(addons.Info) do
		if info.load ~= false then			
			_G.INFO = info
				
				if info.startup then
					if not info.startup_launched then
						-- we want to make sure the addon loads the correct startup file (or do we???)
						-- update:
						-- if we use include in the startup file, it won't work.. we need to
						-- include it instead so it pushes the path to the include stack
						include(e.BASE_FOLDER .. info.path .. "lua/" .. info.startup)
												
						info.startup_launched = true
					end
				end
								
				-- autorun folders			
				for path in vfs.Iterate(info.path .. "lua/autorun" .. folder, nil, true) do
					local ok, err = xpcall(dofile, mmyy.OnError, path)
					if not ok then
						logn(err)
					end
				end
			_G.INFO = nil	
		else
			--logf("the addon %q does not want to be loaded", addon)
		end
	end
end

function addons.GetInfo(addon)
	for _, info in pairs(addons.Info) do
		if info.name == addon then
			return info
		end
	end

	return {}
end

function addons.GetAll()
	return addons.Info
end

function addons.LoadAll()
	for folder in vfs.Iterate(addons.Root .. ".") do		
		local path = addons.Root ..folder .. "/"
				
		local func, msg = loadfile(e.BASE_FOLDER .. path .. "info.lua")
		
		if func then
			local info = func and func() or {}
				info.path = path
				info.file_info = folder
				info.name = info.name or folder
				info.folder = folder
				info.priority = info.priority or -1
			table.insert(addons.Info, info)

			_E["ADDON_" .. info.name:upper()] = info
		else
			local info = {}
				info.path = path
				info.file_info = folder
				info.name = folder
				info.folder = folder
				info.priority = -1
			table.insert(addons.Info, info)
			_E["ADDON_" .. info.name:upper()] = info
			
		end
	end

	addons.SortAfterPriority()

	for _, info in ipairs(addons.Info) do
		if info.load ~= false then
			vfs.Mount(e.BASE_FOLDER .. info.path)
		else
			--logf("the addon %q does not want to be loaded", addon)
		end
	end

end

return addons
