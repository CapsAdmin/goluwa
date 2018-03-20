local resource = _G.resource or {}

resource.providers = resource.providers or {}
e.DOWNLOAD_FOLDER = e.DATA_FOLDER .. "downloads/"
local etags_file = e.DOWNLOAD_FOLDER .. "resource_etags.txt"

--os.execute("rm -rf " .. R(e.DOWNLOAD_FOLDER))

local ok, err = vfs.CreateDirectory("os:" .. e.DOWNLOAD_FOLDER)
if not ok then wlog(err) end

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

local function download(from, to, callback, on_fail, on_header, check_etag, etag_path_override, need_extension, ext_override)
	if check_etag then
		local etag = serializer.GetKeyFromFile("luadata", etags_file, etag_path_override or from)

		--llog("checking if ", etag_path_override or from, " has been modified.")

		sockets.Request({
			method = "HEAD",
			url = from,
			error_callback = function(reason)
				llog(from, ": unable to fetch etag, socket error: ", reason)
				check_etag()
			end,
			callback = function(data)
				if data.code ~= 200 then
					llog(from, ": unable to fetch etag, server returned code ", data.code)
					check_etag()
					return
				end

				local res = data.header.etag or data.header["last-modified"]

				if not res then return end

				if res ~= etag then
					if etag then
						llog(from, ": etag has changed ", res)
					else
						llog(from, ": no previous etag stored", res)
					end
					download(from, to, callback, on_fail, on_header, nil, etag_path_override, need_extension, ext_override)
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
					on_fail(llog("unable to rename %q: %s", full_path, err))
					return
				end

				local full_path = R("os:" .. e.DOWNLOAD_FOLDER .. to)

				if full_path then
					callback(full_path)

					--llog("finished donwnloading ", from)
				else
					on_fail(llog("open error: %q not found!", "data/downloads/" .. to))
				end
			else
				on_fail(llog("open error: %q not found!", "data/downloads/" .. full_path))
			end
		end,
		function(...)
			on_fail(...)
		end,
		function(chunk)
			file:Write(chunk)
		end,
		function(header)
			local dir = to

			if ext_override then
				to = to .. "/file." .. ext_override
			elseif need_extension then

				local ext =
					header["content-type"] and
					(header["content-type"]:match(".-/(.-);") or header["content-type"]:match(".-/(.+)")) or
					"dat"

				if ext == "dat" or ext == "octet-stream" then
					ext = from:match("%.([%a%d]+)$") or from:match("%.([%a%d]+)%?") or ext
				end

				if ext == "jpeg" then
					ext = "jpg"
				end

				to = to .. "/file." .. ext
			end

			local ok, err = vfs.CreateDirectoriesFromPath("os:" .. e.DOWNLOAD_FOLDER .. to)

			if not ok then
				on_fail(llog("unable to create directories %q download error: %s", "os:" .. e.DOWNLOAD_FOLDER .. to, err))
				return false
			end

			if resource.debug then
				serializer.WriteFile("luadata", "os:" .. e.DOWNLOAD_FOLDER .. dir .. "info.txt", {header = header, url = from})
			end

			local file_, err = vfs.Open("os:" .. e.DOWNLOAD_FOLDER .. to .. ".temp", "write")
			file = file_

			if not file then
				on_fail(llog("unable to open file for writing %q: %s", "os:" .. e.DOWNLOAD_FOLDER .. to .. ".temp", err))
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
		on_fail("ResourceDownload hook returned not nil\n")
		return
	end

	if #resource.providers == 0 then
		on_fail("no providers added\n")
		return
	end

	if not SOCKETS then return end

	if not check_etag then
		--llog("downloading ", path)
	end

	local failed = 0
	local max = #resource.providers
	-- this does not work very well if a resource provider is added during download

	for _, provider in ipairs(resource.providers) do
		download(
			provider .. path,
			path,
			callback,
			function(...)
				failed = failed + 1
				if failed == max then
					on_fail(...)
				end
			end,
			function(header)
				for _, other_provider in ipairs(resource.providers) do
					if provider ~= other_provider then
						sockets.StopDownload(other_provider .. path)
						event.Call("DownloadStop", url, nil, "download found in " .. provider)
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

function resource.Download(path, callback, on_fail, crc, mixed_case, check_etag, ext)
	local tr = not on_fail and debug.traceback()
	on_fail = on_fail or function(reason) llog(path, ": ", reason) logn(tr) end

	if resource.virtual_files[path] then
		resource.virtual_files[path](callback, on_fail)
		return true
	end

	local url
	local existing_path

	if path:find("^.-://") then
		url = path
		local crc = (crc or crypto.CRC32(path))
		local found = vfs.Find("os:" .. e.DOWNLOAD_FOLDER .. "url/" .. crc .. "/file", true)

		if platform == "gmod" and found[1] and vfs.IsDirectory(found[1]) then
			llog("deleting bad cache data")
			for _, path in ipairs(vfs.Find("os:" .. e.DOWNLOAD_FOLDER .. "url/" .. crc .. "/", true)) do
				vfs.Delete(path)
			end
		end

		path = "url/" .. crc

		if found[1] then
			existing_path = found[1]
		else
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
			true,
			ext
		)
	elseif not resource.skip_providers then
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
			vfs.CreateDirectory("os:" .. e.DOWNLOAD_FOLDER .. where)
			local ok, err = vfs.Write("os:" .. e.DOWNLOAD_FOLDER ..  where, vfs.Read(path))
			if not ok then
				on_error(err)
			else
				on_success(where)
			end
		end, on_error)
	end
end

function resource.ValidateCache()
	for _, path in ipairs(vfs.Find("os:" .. e.DOWNLOAD_FOLDER .. "url/", true)) do
		if vfs.IsFile(path) then
			local crc, ext = path:match(".+/(%d+)(.+)")
			if crc then
				local data = vfs.Read(path)
				local new_path = "os:" .. e.DOWNLOAD_FOLDER .. "url/" .. crc .. "/file" .. ext
				if vfs.CreateDirectoriesFromPath(new_path) then
					llog("moving %s -> %s", path, new_path)
					vfs.Delete(path)
					vfs.Write(new_path, data)
				end
			else
				llog("bad file in downloads/url folder: %s", path)
				vfs.Delete(path)
			end
		else

		end
	end
end

return resource