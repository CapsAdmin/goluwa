local addons = {}

addons.Root = "addons/"
addons.Info = {}

function addons.SortAfterPriority()
	table.sort(addons.Info, function(a,b) return a.priority > b.priority end)
end

function addons.Autorun(addon, autorun_folder)
	local info = addons.GetInfo(addon)
	local folder = info.folder
		
	if folder then
		local path = addons.Root .. folder  .. "/lua/autorun/"
			
		if autorun_folder then
			path = path .. autorun_folder .. "/"
		end
						
		for file_name in pairs(file.Find(path .. "*")) do
			if file_name ~= "." and file_name ~= ".." and file_name:sub(-4) == ".lua" then
				local fullpath = BASE_FOLDER .. path .. file_name
				
				_G.INFO = info
				local ok, msg = pcall(require, fullpath)
				_G.INFO = nil
				if not ok then
					print(msg)
				end
			end
		end
	end
end

function addons.AutorunAll(folder)
	addons.SortAfterPriority()
	for _, info in pairs(addons.Info) do
		addons.Autorun(info.name, folder)
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
	for folder in pairs(file.Find(addons.Root .. "*")) do
		local path = addons.Root .. folder  .. "/"
		
		if file.Exists(path .. "info.lua") then
			local func, msg = loadfile(BASE_FOLDER .. path .. "info.lua")

			local info = func and func() or {}
				info.path = path
				info.file_info = folder
				info.name = info.name or folder
				info.folder = folder
				info.priority = info.priority or -1
			table.insert(addons.Info, info)

			_G["ADDON_" .. info.name:upper()] = info
		else
			local info = {}
				info.path = path
				info.file_info = folder
				info.name = folder
				info.folder = folder
				info.priority = -1
			table.insert(addons.Info, info)
			_G["ADDON_" .. info.name:upper()] = info
			
		end
	end

	addons.SortAfterPriority()

	for _, info in ipairs(addons.Info) do
		if info.load ~= false then
			if info.startup then
				_G.INFO = info
					require(info.startup)
				_G.INFO = nil
			end

			addons.Autorun(info.name)
		else
			--printf("the addon %q does not want to be loaded", addon)
		end
	end

end

function addons.HandleLoader(path)
	local out = {}
	for key, data in ipairs(addons.Info) do
		table.insert(out, BASE_FOLDER .. data.path .. "lua/" .. path)
	end
	
	return out
end

return addons