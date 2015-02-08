local resource = _G.resource or {}

resource.download_queue = {}
resource.cache = {}
resource.file_queue = {}
resource.async_readers = {}
resource.downloading = {}

vfs.CreateFolder("data/download/")
vfs.Mount(R("data/download/"))

do -- vfs extension for reading large files
	local function update()
		local data = resource.file_queue[1]
		if data then
			local ok, res = pcall(data.update_reader)
			
			if ok then
				if res ~= nil then
					table.remove(resource.file_queue, 1)
				end
			else
				if resource.debug or resource.debug_async then logf("[resource] failed to read %s: %s\n", data.path, res) end
				table.remove(resource.file_queue, 1)
				data.callback(nil, res)
			end
		end	
	end


	local function queue_reader(update_reader, path, callback)
		table.insert(resource.file_queue, {update_reader = update_reader, path = path, callback = callback})
		event.AddListener("Update", "resource_file_read", update)
		update()
	end

	function resource.async_readers.file(path, mbps, context)
		local file = vfs.Open(path)
		if file then	
			local buffer = {}
						
			mbps = mbps / 2
			local read_size = 1048576 * mbps
			queue_reader(function()
				--in case mbps is higher than the file size
				for i = 1, 2 do
					local str = file:ReadBytes(read_size)					
					
					if str then
						if resource.debug or resource.debug_async then 
							local size = 0
							for k, v in ipairs(buffer) do size = size + #v end
							logf("[resource] async %q: read %s\n", path, utility.FormatFileSize(size))
						end
						buffer[#buffer + 1] = str
					else
						resource.download_queue[path].callback(table.concat(buffer))
						file:Close()
						return false
					end
				end
			end, path, resource.download_queue[path].callback)
			
			if read_size >= file:GetSize()  then
				update()
				update()
			end
			
			return true				
		end
	end
end

function resource.async_readers.sockets(path, mbps, context)
	-- for font names only
	if context:find("font") and not path:find("%p") then			
		local cache_path = "data/download_cache/" .. crypto.CRC32(path)
		local found = vfs.Find(cache_path, nil, true)	
		
		if #found == 1 then
			return resource.Read(found[1], function(...) return resource.download_queue[path].callback(...) end, mbps, context, "file")
		else
			if 	
				sockets.Download("http://fonts.googleapis.com/css?family=" .. path:gsub("%s", "+"), function(data)
					local url = data:match("url%((.-)%)")
					if url then
						local format = data:match("format%('(.-)'%)")
						sockets.Download(url, function(data)
							vfs.Write("data/download_cache/" .. crypto.CRC32(path) .. "." .. format, data)				
							resource.download_queue[path].callback(data)
						end)
					else
						resource.download_queue[path].callback(nil, ("unable to find url for %s from google web fonts"):format(path))
					end
				end)
			then
				return true
			end
		end
	end
	
	local ext = path:match(".+(%.%a+)") or ".dat"
	local cache_path
	

	-- if it's a path like
	-- http://sounds.msgpluslive.net/esnd/snd/random?catId=5&lngId=3
	-- we skip caching
	-- (FIX ME??)
	if not path:find("?", nil, true) then
		cache_path = "data/download_cache/" .. crypto.CRC32(path) .. ext
	end
			
	if cache_path and vfs.Exists(cache_path) then
		return resource.Read(cache_path, function(...) return resource.download_queue[path].callback(...) end, mbps, context, "file")
	elseif
		sockets.Download(path, function(data)
			if cache_path then
				vfs.Write(cache_path, data)			
			end
			resource.download_queue[path].callback(data)
		end)  		
	then
		return true
	end
end

function resource.Read(path, callback, mbps, context, reader, dont_cache)
	check(path, "string")
	check(callback, "function")
	check(mbps, "nil", "number")
	mbps = mbps or 1
	
	if resource.debug or resource.debug_async then
		logf("[resource] async %q: start loading\n", path)
		local size = 0
		for k, v in pairs(resource.cache) do if v[1] then size = size + #v[1] end end
		logn("[resource] async: resource.cache size = ", utility.FormatFileSize(size))
	end
	
	if resource.cache[path] then
		callback(unpack(resource.cache[path]))
		return true
	end
		
	-- if it's already being downloaded, append the callback to the current download
	if resource.download_queue[path] then
		local old = resource.download_queue[path].callback
		resource.download_queue[path].callback = function(...)
			old(...)
			callback(...)
		end
		return true
	end
			
	resource.download_queue[path] = {callback = function(...)
		resource.cache[path] = {...}
		callback(...)
		resource.download_queue[path] = nil
		
		if resource.debug or resource.debug_async then
			logf("[resource] async %q: finish loading\n", path)
		
			local size = 0
			for k, v in pairs(resource.cache) do if v[1] then size = size + #v[1] end end
			logn("[resource] async: resource.cache size = ", utility.FormatFileSize(size))
		end
	end}
				
	for name, func in pairs(resource.async_readers) do
		if (not reader or reader == name) and func(path, mbps, context or "none") then
			return true
		end
	end 
	
	resource.download_queue[path] = nil
	
	logf("[resource] async %q: not a valid path\n", path)
	
	return false, "not a valid path"
end

local last_reported_size = 0

function resource.RemoveResourceFromMemory(path)
	resource.cache[path] = nil
	if resource.debug or resource.debug_async then
		logf("[resource] resource.UncacheAsync(%q)\n", path)
		
		local size = 0
		for k, v in pairs(resource.cache) do	size = size + #v end
		if last_reported_size ~= size then
			logn("[resource] async read resource.cache size: ", utility.FormatFileSize(size))
			last_reported_size = size
		end
	end
end

function resource.Download(from, to, callback)
	resource.downloading[to] = true
	sockets.Download(from, function(data)	
		resource.downloading[to] = false
		vfs.Write("data/download/" .. to, data)
		if callback then
			callback(data)
		end
	end)  		
end

if RELOAD then
	resource.Download("https://dl.dropboxusercontent.com/u/244444/alert.wav", "sounds/alert.wav")
end

return resource