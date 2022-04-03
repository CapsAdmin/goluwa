local vfs = (...) or _G.vfs

vfs.loaded_addons = vfs.loaded_addons or {}
vfs.disabled_addons = vfs.disabled_addons or {}

local whitelist
(os.getenv("GOLUWA_ARG_LINE") or ""):gsub("--addons (%S+)", function(line)
	whitelist = whitelist or {}
	for _, name in ipairs(line:split(",")) do
		llog("loading ", name)
		whitelist[name:lower():trim()] = true
	end
end)

function vfs.FetchBniariesForAddon(addon, callback)
	local signature = jit.os:lower() .. "_" .. jit.arch:lower()
	local signature_path = "shared/binaries_downloaded_" .. addon ..  "_" .. signature

	if vfs.IsFile(signature_path) then
		if callback then
			callback()
		end
		if CLI then return end
		if VERBOSE then
			llog("fetching binary updates for %s", addon)
		end
	else
		llog("fetching binaries for %s", addon)
	end

	local function handle_content(found)
		if VERBOSE then
			llog("found %s binaries for %s", #found, addon)
		end

		local relative_bin_dir = addon .. "/bin/" .. signature .. "/"
		local bin_dir = e.ROOT_FOLDER .. relative_bin_dir
		vfs.CreateDirectoriesFromPath("os:"..bin_dir)

		local done = #found

		for i, v in ipairs(found) do
			local to = bin_dir .. v.path:sub(#relative_bin_dir + 1)
			if not vfs.IsFile(signature_path) and vfs.IsFile(to) then
				llog("%q already exists before a fetch was ran, skipping", to:sub(#e.ROOT_FOLDER+1))
				done = done - 1

				if done == 0 then
					if not vfs.IsFile(signature_path) then
						vfs.Write(signature_path, "")
						llog("finished downloading binaries for %s", addon)
						if callback then
							callback()
						end
					end
				end
			else
				resource.Download(v.url, nil,nil, true):Then(function(file_path, modified)
					local name = vfs.GetFileNameFromPath(v.path)

					if modified or not vfs.IsFile(to) then
						local ok = vfs.CopyFileFileOnBoot(file_path, to)
						if ok == "deferred" then
							llog("%q will be replaced after restart. (%i downloads left)", to:sub(#e.ROOT_FOLDER+1), done)
						else
							if VERBOSE then
								llog("%q was added (%i downloads left)", to:sub(#e.ROOT_FOLDER+1), done)
							end
						end
					end

					done = done - 1
					
					if done == 0 then
						if not vfs.IsFile(signature_path) then
							vfs.Write(signature_path, "")
							llog("finished downloading binaries for %s", addon)
							if callback then
								callback()
							end
						else
							if VERBOSE then
								llog("everything is up to date for %s", addon)
							end
						end
					end
				end):Catch(function(err)
					llog(err)
				end)
			end
		end
	end

	local found = {}
	local page = "1"
	local base_url = "https://gitlab.com/CapsAdmin/goluwa-binaries/raw/master/"

	local function paged_request()
		local url = "https://gitlab.com/api/v4/projects/CapsAdmin%2Fgoluwa-binaries/repository/tree?recursive=1&per_page=200&page=" .. page

		http.Download(url)
		:Subscribe("header", function(header)
			if header["x-next-page"] and header["x-next-page"] ~= "" then
				page = header["x-next-page"]
				paged_request()
			end
		end)
		:Then(function(content)
			for path in content:gmatch("\"path\":\"(.-)\"") do
				local ext = vfs.GetExtensionFromPath(path)
				if (ext ~= "" or vfs.GetFileNameFromPath(path):startswith("luajit")) and path:find(signature, nil, true) then
					if path:startswith(addon) then
						table.insert(found, {url = base_url .. path, path = path})
					end
				end
			end

			if #found == 0 then
				llog("no binaries found for %s", addon)
			else
				handle_content(found)
			end
		end)
		:Catch(function(err)
		llog(err)
	end)
	end

	paged_request()
end

function vfs.MountAddons(dir)
	for info in vfs.Iterate(dir, true, nil, nil, nil, true) do
		if info.name ~= e.INTERNAL_ADDON_NAME then
			if
				vfs.IsDirectory(info.full_path:sub(#info.filesystem + 2)) and
				not info.name:startswith(".") and
				not info.name:startswith("__") and
				(not whitelist or whitelist[info.name:lower():trim()]) and
				(info.name ~= "data" and info.filesystem == "os")
			then
				vfs.MountAddon(info.full_path:sub(#info.filesystem + 2) .. "/")
			end
		end
	end
end

function vfs.SortAddonsAfterPriority()
	local vfs_loaded_addons = copy

	local found = {}
	local not_found = {}
	local done = {}

	local function sort_dependencies(info)
		if done[info] then return end
		done[info] = true

		local found_addon = false

		if info.dependencies then
			for _, name in ipairs(info.dependencies) do
				for _, info in ipairs(vfs.loaded_addons) do
					if info.name == name and info.dependencies then
						sort_dependencies(info)
						found_addon = true
						break
					end
				end
			end
		end

		if found_addon then
			table.insert(found, info)
		else
			table.insert(not_found, info)
		end
	end

	for _, info in ipairs(vfs.loaded_addons) do
		sort_dependencies(info)
	end

	table.sort(not_found, function(a,b) return a.priority > b.priority end)

	table.add(found, not_found)

	vfs.loaded_addons = found
end

function vfs.GetAddonInfo(addon)
	for _, info in pairs(vfs.loaded_addons) do
		if info.name == addon then
			return info
		end
	end

	return {}
end

local function check_dependencies(info, what)
	if info.dependencies then
		for i, name in ipairs(info.dependencies) do
			local found = false
			for i,v in ipairs(vfs.loaded_addons) do
				if v.name == name then
					found = true
					break
				end
			end
			if not found then
				if what then llog(info.name, ": could not ", what ," because it depends on ", name) end
				return false
			end
		end
	end

	return true
end

function vfs.InitAddons(callback)

	for _, info in pairs(vfs.GetMountedAddons()) do
		if info.pre_load and not info.loaded then
			info.load_callback = function()
				info.loaded = true
				vfs.InitAddons(callback)
			end
			info:pre_load()
			return
		end
	end

	for _, info in pairs(vfs.GetMountedAddons()) do
		if info.startup and check_dependencies(info, "init") then
			runfile(info.startup)
		end
	end

	callback()
end

function vfs.AutorunAddon(addon, folder, force)
	local info =  type(addon) == "table" and addon or vfs.GetAddonInfo(addon)
	if force or info.load ~= false and not info.core then
		_G.INFO = info

			local function run()
				if not check_dependencies(info, "run autorun " .. folder .. "*") then
					return
				end

				-- autorun folders
				for path in vfs.Iterate(info.path .. "lua/autorun/" .. folder, true) do
					if path:find("%.lua") then
						local ok, err = system.pcall(vfs.RunFile, path)
						if not ok then
							wlog(err)
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
	if VERBOSE then
		utility.PushTimeWarning()
	end
	for _, info in pairs(vfs.GetMountedAddons()) do
		vfs.AutorunAddon(info, folder, force)
	end
	if VERBOSE then
		utility.PopTimeWarning("autorun " .. folder .. "*", 0.1)
	end
end

function vfs.MountAddon(path, force)
	local info = {}

	if vfs.IsFile(path .. "config.lua") then
		local func, err = vfs.LoadFile(path .. "config.lua")
		if func then
			info = func() or info
		else
			wlog(err)
		end
	end

	if vfs.IsFile(path .. "addon.json") then
		info.load = false
		info.gmod_addon = true
	end

	local folder = path:match(".+/(.+)/") or path:match(".-:(.+)/")

	info.path = path
	info.file_info = folder
	info.name = info.name or folder
	info.folder = folder
	info.priority = info.priority or -1

	if not info.startup and vfs.IsFile(path .. "lua/init.lua") then
		info.startup = path .. "lua/init.lua"
	end

	if info.dependencies and type(info.dependencies) == "string" then
		info.dependencies = {info.dependencies}
	end

	table.insert(vfs.loaded_addons, info)

	e["ADDON_" .. info.name:upper()] = info

	vfs.SortAddonsAfterPriority()

	if info.load == false and not force then
		table.insert(vfs.disabled_addons, info)
		return false
	end

	vfs.Mount(path)

	if vfs.IsDirectory(path .. "addons") then
		vfs.MountAddons(path .. "addons/")
	end

	return true
end

return vfs
