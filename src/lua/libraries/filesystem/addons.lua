local vfs = (...) or _G.vfs

vfs.loaded_addons = {}
vfs.disabled_addons = {}

function vfs.MountAddons(dir)
	for info in vfs.Iterate(dir, nil, true, nil, nil, true) do
		if vfs.IsDirectory(info.full_path2) and not info.name:startswith(".") then
			vfs.MountAddon(info.full_path2 .. "/")
		end
	end
end

function vfs.SortAddonsAfterPriority()
	table.sort(vfs.loaded_addons, function(a,b) return a.priority > b.priority end)
end

function vfs.GetAddonInfo(addon)
	for _, info in pairs(vfs.loaded_addons) do
		if info.name == addon then
			return info
		end
	end

	return {}
end

function vfs.AutorunAddon(addon, folder, force)
	local info =  type(addon) == "table" and addon or vfs.GetAddonInfo(addon)
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
				for path in vfs.Iterate(info.path .. "lua/autorun/" .. folder) do
					if path:find("%.lua") then
						local ok, err = system.pcall(include, info.path .. "lua/autorun/" .. folder .. "/" ..  path)
						if not ok then
							warning(err)
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

function vfs.GetMountedAddons()
	return vfs.loaded_addons
end

function vfs.AutorunAddons(folder, force)
	folder = folder or ""
	for _, info in pairs(vfs.GetMountedAddons()) do
		vfs.AutorunAddon(info, folder, force)
	end
end

function vfs.MountAddon(path, force)
	local func, msg = vfs.loadfile(path .. "info.lua")

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
	table.insert(vfs.loaded_addons, info)

	e["ADDON_" .. info.name:upper()] = info

	vfs.SortAddonsAfterPriority()

	if info.load == false and not force then
		table.insert(vfs.disabled_addons, info)
		return false
	end

	vfs.Mount(path)

	return true
end

return vfs
