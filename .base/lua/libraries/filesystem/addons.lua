local vfs2 = (...) or _G.vfs2

vfs2.loaded_addons = {}
vfs2.disabled_addons = {}

function vfs2.SortAddonsAfterPriority()
	table.sort(vfs2.loaded_addons, function(a,b) return a.priority > b.priority end)
end

function vfs2.GetAddonInfo(addon)
	for _, info in pairs(vfs2.loaded_addons) do
		if info.name == addon then
			return info
		end
	end

	return {}
end

function vfs2.AutorunAddon(addon, folder, force)
	local info =  type(addon) == "table" and addon or vfs2.GetAddonInfo(addon)
	if force or info.load ~= false and not info.core then			
		_G.INFO = info
			
			local function run()
				if info.startup then
					if not info.startup_launched then
						include(info.path .. "lua/" .. info.startup)
						info.startup_launched = true
					end
				end
				
				-- autorun folders			
				for path in vfs2.Iterate(info.path .. "lua/autorun/" .. folder) do
					if path:find("%.lua") then
						local ok, err = xpcall(include, system.OnError, info.path .. "lua/autorun/" .. folder .. "/" ..  path)
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

function vfs2.GetMountedAddons()
	return vfs2.loaded_addons
end

function vfs2.AutorunAddons(folder, force)
	for _, info in pairs(vfs2.GetMountedAddons()) do
		vfs2.AutorunAddon(info, folder, force)
	end
end

function vfs2.MountAddon(path, force)									
	local func, msg = loadfile(path .. "info.lua")
	
	local info = {}
	
	if func then
		info = func() or {}
	end
	
	local folder = path:match(".+/(.+)/")

	info.path = path
		info.file_info = folder
		info.name = info.name or folder
		info.folder = folder
		info.priority = info.priority or -1
	table.insert(vfs2.loaded_addons, info)

	e["ADDON_" .. info.name:upper()] = info
	
	vfs2.SortAddonsAfterPriority()
	
	if info.load == false and not force then
		table.insert(vfs2.disabled_addons, info)
		return false
	end
	
	vfs2.Mount(path)
	
	return true
end

return vfs2
