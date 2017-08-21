local resource = _G.resource or {}

resource.providers = {}

local etags_file = "resource_etags.txt"
e.DOWNLOAD_FOLDER = e.DATA_FOLDER .. "downloads/"

vfs.CreateFolder("os:" .. e.DOWNLOAD_FOLDER)
vfs.Mount("os:" .. e.DOWNLOAD_FOLDER, "os:downloads")

function resource.AddProvider(provider, no_autodownload)
	for i,v in ipairs(resource.providers) do
		if v == provider then
			table.remove(resource.providers, i)
			break
		end
	end

	table.insert(resource.providers, provider)

	if no_autodownload then return end

	if not SOCKETS then return end

	sockets.Download(provider .. "auto_download.txt", function(str)
		for _,v in ipairs(serializer.Decode("newline", str)) do
			resource.Download(v)
		end
	end)
end

local function download(from, to, callback, on_fail, on_header, check_etag, etag_path_override, need_extension)
	if check_etag then
		local etag = serializer.GetKeyFromFile("luadata", etags_file, etag_path_override or from)

		--llog("checking if ", etag_path_override or from, " has been modified. etag is: ", etag)

		sockets.Request({
			method = "HEAD",
			url = from,
			callback = function(data)
				local res = data.header.etag or data.header["last-modified"]

				if not res then return end

				if res ~= etag then
					llog(from, ": etag has changed ", res)
					download(from, to, callback, on_fail, on_header, nil, etag_path_override, need_extension)
				else
					--llog(from, ": etag is the same")
					check_etag()
				end
			end,
		})

		return
	end

	local file

	return sockets.Download(
		from,
		function()
			file:Close()
			local full_path = R("os:" .. e.DOWNLOAD_FOLDER .. to .. ".temp")
			if full_path then
				local ok, err = vfs.Rename(full_path, (full_path:gsub(".+/(.+).temp", "%1")))

				if not ok then
					wlog("unable to rename %q: %s", full_path, err)
					on_fail()
					return
				end

				local full_path = R("os:" .. e.DOWNLOAD_FOLDER .. to)

				if full_path then
					resource.BuildCacheFolderList(full_path:match(".+/(.+)"))

					callback(full_path)

					--llog("finished donwnloading ", from)
				else
					wlog("resource download error: %q not found!", "data/downloads/" .. to)
					on_fail()
				end
			else
				wlog("resource download error: %q not found!", "data/downloads/" .. to)
				on_fail()
			end
		end,
		function(...)
			on_fail(...)
		end,
		function(chunk)
			file:Write(chunk)
		end,
		function(header)
			if need_extension then
				local ext = header["content-type"] and (header["content-type"]:match(".-/(.-);") or header["content-type"]:match(".-/(.+)")) or "dat"
				if ext == "jpeg" then ext = "jpg" end
				to = to .. "." .. ext
			end

			vfs.CreateFolders("os", e.DOWNLOAD_FOLDER .. to)
			local file_, err = vfs.Open("os:" .. e.DOWNLOAD_FOLDER .. to .. ".temp", "write")
			file = file_

			if not file then
				wlog("resource download error: ", err, 2)
				on_fail()
				return false
			end

			local etag = header.etag or header["last-modified"]

			if etag then
				serializer.SetKeyValueInFile("luadata", etags_file, etag_path_override or from, etag)
			end

			on_header(header)
		end
	)
end

local function download_from_providers(path, callback, on_fail, check_etag)

	if event.Call("ResourceDownload", path, callback, on_fail) ~= nil then
		return
	end

	if #resource.providers == 0 then
		on_fail("[resource] no providers added\n")
		return
	end

	if not SOCKETS then return end

	if not check_etag then
		--llog("downloading ", path)
	end

	local failed = 0

	for _, provider in ipairs(resource.providers) do
		download(
			provider .. path,
			path,
			callback,
			function(...)
				failed = failed + 1
				if failed == #resource.providers then
					on_fail(...)
				end
			end,
			function(header)
				for _, other_provider in ipairs(resource.providers) do
					if provider ~= other_provider then
						sockets.AbortDownload(other_provider .. path)
					end
				end
			end,
			check_etag,
			path
		)
	end
end

local cb = utility.CreateCallbackThing()
local ohno = false

function resource.Download(path, callback, on_fail, crc, mixed_case, check_etag)
	on_fail = on_fail or function(reason) llog(path, ": ", reason) end

	if resource.virtual_files[path] then
		resource.virtual_files[path](callback, on_fail)
		return true
	end

	local url
	local existing_path

	if path:find("^.-://") then
		if not resource.url_cache_lookup then
			resource.BuildCacheFolderList()
		end

		url = path
		local crc = (crc or crypto.CRC32(path))

		if resource.url_cache_lookup[crc] then
			path = "cache/" .. resource.url_cache_lookup[crc]
			existing_path = R(path)
		else
			path = "cache/" .. crc
			existing_path = false
		end
	else
		existing_path = R(path) or R(path:lower())

		if mixed_case and not existing_path then
			existing_path = vfs.FindMixedCasePath(path)
		end
	end

	if not existing_path then
		check_etag = nil
	end

	if not ohno then
		local old = callback
		callback = function(path)
			if event.Call("ResourceDownloaded", path, url) ~= false then
				if old then old(path) end
			end
		end
	end

	if existing_path and not check_etag then
		ohno = true
		callback(existing_path)
		ohno = false
		return true
	end

	if check_etag then
		check_etag = function()
			if ohno then return end
			ohno = true
			cb:callextra(path, "check_etag", existing_path)
			ohno = false
			cb:stop(path, existing_path)
			cb:uncache(path)
		end
	end

	if cb:check(path, callback, {on_fail = on_fail, check_etag = check_etag}) then return true end

	cb:start(path, callback, {on_fail = on_fail, check_etag = check_etag})

	if not SOCKETS then
		cb:callextra(path, "on_fail", "sockets not availble")
		cb:uncache(path)
		return false
	end

	if url then
		if not check_etag then
			-- llog("downloading ", url)
		end

		download(
			url,
			path,
			function(...)
				cb:stop(path, ...)
				cb:uncache(path)
			end,
			function(...)
				cb:callextra(path, "on_fail", ... or path .. " not found")
				cb:uncache(path)
			end,
			function(header)
				-- check file crc stuff here/
				return true
			end,
			check_etag,
			nil,
			true
		)
	else
		download_from_providers(
			path,
			function(...)
				cb:stop(path, ...)
				cb:uncache(path)
			end,
			function(...)
				cb:callextra(path, "on_fail", ... or path .. " not found")
				cb:uncache(path)
			end,
			check_etag
		)
	end

	return true
end

function resource.BuildCacheFolderList(file_name)
	if file_name then
		resource.url_cache_lookup[file_name:match("(.-)%.")] = file_name
	else
		local tbl = {}
		for _, file_name in ipairs(vfs.Find("os:" .. e.DOWNLOAD_FOLDER .. "cache/")) do
			tbl[file_name:match("(.-)%.")] = file_name
		end
		resource.url_cache_lookup = tbl
	end
end

function resource.ClearDownloads()
	local dirs = {}

	vfs.Search("os:" .. e.DOWNLOAD_FOLDER, nil, function(path)
		if vfs.IsDirectory(path) then
			table.insert(dirs, path)
		else
			vfs.Delete(path)
		end
	end)

	table.sort(dirs, function(a, b) return #a > #b end)

	for _, dir in ipairs(dirs) do
		vfs.Delete(dir.."/")
	end

	resource.BuildCacheFolderList()
end

function resource.CheckDownloadedFiles()
	local files = serializer.ReadFile("luadata", etags_file)
	local count = table.count(files)

	llog("checking " .. count .. " files for updates..")

	local i = 0

	for path, etag in pairs(files) do
		resource.Download(path, function() i = i + 1 if i == count then llog("done checking for file updates") end end, llog, nil, nil, true)
	end
end

resource.virtual_files = {}

function resource.CreateVirtualFile(where, callback)
	resource.virtual_files[where] = function(on_success, on_error)
		callback(function(path)
			vfs.CreateFolders("os", e.DOWNLOAD_FOLDER .. where)
			local ok, err = vfs.Write("os:" .. e.DOWNLOAD_FOLDER ..  where, vfs.Read(path))
			if not ok then
				on_error(err)
			else
				on_success(where)
			end
		end, on_error)
	end
end

return resource