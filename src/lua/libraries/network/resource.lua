local resource = _G.resource or {}

resource.download_queue = {}
resource.cache = {}
resource.file_queue = {}
resource.async_readers = {}
resource.downloading = {}
resource.providers = {}

e.DOWNLOAD_FOLDER = e.DATA_FOLDER .. "downloads/"

vfs.CreateFolder(e.DOWNLOAD_FOLDER)
vfs.Mount("os:" .. e.DOWNLOAD_FOLDER, "downloads")

function resource.AddProvider(provider)
	for i,v in ipairs(resource.providers) do
		if v == provider then
			table.remove(resource.providers, i)
			break
		end
	end

	table.insert(resource.providers, provider)

	sockets.Download(provider .. "auto_download.txt", function(str)
		for i,v in ipairs(serializer.Decode("newline", str)) do
			resource.Download(v)
		end
	end)
end

local function download(from, to, callback, on_fail, on_header)
	local file

	return sockets.Download(
		from,
		function()
			file:Close()
			local full_path = R("os:" .. e.DOWNLOAD_FOLDER .. to)
			if full_path then
				callback(full_path)
				llog("finished donwnloading ", from)
			else
				warning("resource download error: %q not found!", "data/downloads/" .. to)
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
			vfs.CreateFolders("os", e.DOWNLOAD_FOLDER .. to)
			file, err = vfs.Open("os:" .. e.DOWNLOAD_FOLDER .. to, "write")

			if not file then
				warning("resource download error: ", err)
				on_fail()
				return false
			end

			on_header(header)
		end
	)
end

local function download_from_providers(path, callback, on_fail)

	if event.Call("ResourceDownload", path, callback, on_fail) ~= nil then
		return
	end

	if #resource.providers == 0 then
		on_fail("[resource] no providers added\n")
	return end

	local failed = 0

	for i, provider in ipairs(resource.providers) do
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
			function()
				for i, other_provider in ipairs(resource.providers) do
					if provider ~= other_provider then
						sockets.AbortDownload(other_provider .. path)
					end
				end
			end
		)
	end
end


local cb = utility.CreateCallbackThing()

function resource.Download(path, callback, on_fail, crc)
	check(path, "string")
	on_fail = on_fail or logn

	local url

	if path:find("^(.-)://") then
		url = path
		local ext = url:match(".+(%.%a+)") or ".dat"
		path = "cache/" .. (crc or crypto.CRC32(path)) .. ext
	end

	local path2 = R(path)

	if not path2 then
		local path = R(path:lower())
		if path then
			path2 = path
		end
	end

	do
		local old = callback
		callback = function(path)
			if event.Call("ResourceDownloaded", path) ~= false then
				if old then old(path) end
			end
		end
	end

	if path2 then
		callback(path2)
		return true
	end

	if cb:check(path, callback, {on_fail = on_fail}) then return true end

	cb:start(path, callback, {on_fail = on_fail})

	if url then
		llog("donwnloading ", url)

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
			function()
				-- check file crc stuff here/
				return true
			end
		)
	else
		if #resource.providers > 0 then
			llog("donwnloading ", path)
		end

		download_from_providers(
			path,
			function(...)
				cb:stop(path, ...)
				cb:uncache(path)
			end,
			function(...)
				cb:callextra(path, "on_fail", ... or path .. " not found")
				cb:uncache(path)
			end
		)
	end

	return true
end

return resource