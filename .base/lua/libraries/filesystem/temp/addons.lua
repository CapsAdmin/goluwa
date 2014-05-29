local vfs = (...) or _G.vfs

vfs.loaded_addons = {}
vfs.disabled_addons = {}

function vfs.SortAddonsAfterPriority()
	table.sort(vfs.loaded_addons, function(a,b) return a.priority > b.priority end)
end

local function autorun_addon(folder, info)
	if info.load ~= false and not info.core then			
		_G.INFO = info
			
			local function run()
				if info.startup then
					if not info.startup_launched then
						-- we want to make sure the addon loads the correct startup file (or do we???)
						-- update:
						-- if we use include in the startup file, it won't work.. we need to
						-- include it instead so it pushes the path to the include stack
						include(e.ROOT_FOLDER .. info.path .. "lua/" .. info.startup)
												
						info.startup_launched = true
					end
				end
				
				-- autorun folders			
				for path in vfs.Iterate(e.ROOT_FOLDER .. info.path .. "lua/autorun/" .. folder, nil, true) do
					if path:find("%.lua") then
						local ok, err = xpcall(include, system.OnError, path)
						if not ok then
							logn(err)
						end
					end
				end
			end
			
			if info.event then
				event.AddListener(info.event, "addon_" .. folder, function() 
					run() 
					return e.EVENT_DESTROY 
				end)
			else
				run()
			end
			
		_G.INFO = nil	
	else
		--logf("the addon %q does not want to be loaded\n", info.name)
	end
end

function vfs.AutorunAllAddons(folder)	
				
	if folder then 
		folder = folder .. "/" 
	else
		folder = ""
	end
	
	for _, info in ipairs(vfs.loaded_addons) do
		autorun_addon(folder,  info)
	end
end

function vfs.GetAddonInfo(addon)
	for _, info in pairs(vfs.loaded_addons) do
		if info.name == addon then
			return info
		end
	end

	return {}
end

function vfs.GetAllAddons()
	return vfs.loaded_addons
end

function vfs.LoadAllAddons()
	for folder in vfs.Iterate(e.ROOT_FOLDER .. ".") do
		if folder:sub(1, 1) ~= "." or folder == ".base" then
			local path = folder .. "/"
					
			if vfs.IsDir(e.ROOT_FOLDER .. path) then					
				local func, msg = loadfile(e.ROOT_FOLDER .. path .. "info.lua")
				
				local info = {}
				
				if func then
					info = func() or {}
				end
			
				info.path = path
					info.file_info = folder
					info.name = info.name or folder
					info.folder = folder
					info.priority = info.priority or -1
				table.insert(vfs.loaded_addons, info)

				e["ADDON_" .. info.name:upper()] = info
			end
		end
	end

	vfs.SortAddonsAfterPriority()

	for _, info in ipairs(vfs.loaded_addons) do
		if info.load ~= false then
			vfs.Mount(e.ROOT_FOLDER .. info.path)
		else
			table.insert(vfs.disabled_addons, info)
		end
	end

end

function vfs.ReloadAddons()
	for key, info in pairs(vfs.disabled_addons) do
		
		-- try to load the config again
		local func, msg = loadfile(e.ROOT_FOLDER .. info.path .. "info.lua")
		
		if func then
			table.merge(info, func())
		end
		
		if info.load ~= false then
			vfs.Mount(e.ROOT_FOLDER .. info.path)
			vfs.disabled_addons[key] = nil
			autorun_addon("", info)
		end
	end
end

return vfs
