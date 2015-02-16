local resource = _G.resource or {}

resource.download_queue = {}
resource.cache = {}
resource.file_queue = {}
resource.async_readers = {}
resource.downloading = {}
resource.providers = {}

vfs.CreateFolder("data/download/")
vfs.Mount(R("data/download/"))

function resource.AddProvider(provider)
	for i,v in ipairs(resource.providers) do 
		if v == provider then 
			table.remove(resource.providers, i) 
			break 
		end
	end
	
	table.insert(resource.providers, provider)
end

local function download(from, to, callback, on_fail, on_header)
	local file

	return sockets.Download(
		from, 
		function()			
			file:Close()
			local full_path = R("data/download/" .. to)
			if full_path then
				callback(full_path)
				logn("[resource] finished donwnloading ", from)
			else
				warning("resource download error: %q not found!", "data/download/" .. to)
				on_fail()
			end
		end, 
		function()
			on_fail()			
		end, 
		function(chunk)
			file:Write(chunk)
		end,
		function(header)			
			vfs.CreateFolders("os", "data/download/" .. to)
			file, err = vfs.Open("data/download/" .. to, "write")
							
			if not file then
				warning("resource download error: ", err)
				on_fail()
				return false
			end
			
			on_header(header)
		end
	)	
end

local function download_from_providers(path, callback, on_fail, file)
	if #resource.providers == 0 then
		on_fail("[resource] no providers added\n")
	return end
	
	local failed = 0
	
	for i, provider in ipairs(resource.providers) do
		download(
			provider .. path, 
			path, 
			callback,
			function()
				failed = failed + 1
				if failed == #resource.providers then
					on_fail()
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
	check(callback, "function")
	on_fail = on_fail or logn
		
	local url
	
	if path:find("^(.-)://") then 
		url = path
		local ext = url:match(".+(%.%a+)") or ".dat"
		path = "cache/" .. (crc or crypto.CRC32(path)) .. ext
	end
	
	local path2 = R(path)

	if path2 and vfs.IsFile(path2) then
		callback(path2)
		return true
	end

	if cb:check(path, callback, {on_fail = on_fail}) then return true end
	
	cb:start(path, callback, {on_fail = on_fail})
	
	if url then	
		logn("[resource] donwnloading ", url)

		download(
			url, 
			path, 
			function(...) 
				cb:stop(path, ...)
				cb:uncache(path)
			end, 
			function(...) 
				cb:callextra(path, "on_fail", path .. " not found")
				cb:uncache(path)
			end, 
			function()
				-- check file crc stuff here
				return true
			end
		)
	else
		if #resource.providers > 0 then
			logn("[resource] donwnloading ", path)
		end
		download_from_providers(
			path, 
			function(...)
				cb:stop(path, ...)
				cb:uncache(path)
			end,
			function()
				cb:callextra(path, "on_fail", path .. " not found")
				cb:uncache(path)
			end
		)
	end
	
	return true
end

return resource