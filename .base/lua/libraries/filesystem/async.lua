local vfs = (...) or _G.vfs

local queue = {}

vfs.async_readers = {
	file = function(path, mbps, context)
		local file = vfs.Open(path)
		if file then
			local buffer = {}
			
			mbps = mbps / 2
			event.CreateThinker(function()
				--in case mbps is higher than the file size
				for i = 1, 2 do
					local str = file:ReadBytes(1048576 * mbps)					
					
					if str then
						if vfs.debug then 
							local size = 0
							for k, v in ipairs(buffer) do size = size + #v end
							logf("[vfs] async %q: read %s\n", path, utility.FormatFileSize(size))
						end
						buffer[#buffer + 1] = str
					else
						queue[path].callback(table.concat(buffer))
						file:Close()
						return false
					end
				end
			end, 1, true, true)
			return true				
		end
	end,
	sockets = function(path, mbps, context)
	
		-- for font names only
		if context:find("font") and not path:find("%p") then			
			local cache_path = "fonts/" .. path .. ".woff"
			
			if vfs.Exists(cache_path) then
				return vfs.ReadAsync(cache_path, queue[path].callback, mbps, context, "file")
			else
				if sockets.Download("http://fonts.googleapis.com/css?family=" .. path:gsub("%s", "+"), 
					function(data)
						local url = data:match("url%((.-)%)")
						if url then
							local format = data:match("format%('(.-)'%)")
							sockets.Download(url, function(data) 
								vfs.Write("fonts/" .. path .. "." .. format, data, "b")				
								queue[path].callback(data)
							end)
						else
							logf("[vfs] unable to find url for %s from google web fonts\n", path)
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
			cache_path = "download_cache/" .. crypto.CRC32(path) .. ext
		end
		
		if cache_path and vfs.Exists(cache_path) then
			return vfs.ReadAsync(cache_path, queue[path].callback, mbps, context, "file")
		else
			if sockets.Download(path, function(data)
					if cache_path then
						vfs.Write(cache_path, data, "b")			
					end
					queue[path].callback(data)
				end) 
			then
				return true
			end
		end
	end,
}

local cache = {}
local last_reported_size = 0
	
function vfs.ReadAsync(path, callback, mbps, context, reader, dont_cache)
	check(path, "string")
	check(callback, "function")
	check(mbps, "nil", "number")
	mbps = mbps or 1
	
	if vfs.debug then
		logf("[vfs] async %q: start loading\n", path)
		local size = 0
		for k, v in pairs(cache) do	size = size + #v end
		logn("[vfs] async: cache size = ", utility.FormatFileSize(size))
	end
	
	if cache[path] then
		callback(cache[path])
		return true
	end
		
	-- if it's already being downloaded, append the callback to the current download
	if queue[path] then
		local old = queue[path].callback
		queue[path].callback = function(data)
			callback(data)
			old(data)
			queue[path] = nil
		end
		return true
	end
			
	queue[path] = {callback = function(data)
		cache[path] = data
		callback(data)
		queue[path] = nil
		
		if vfs.debug then
			logf("[vfs] async %q: finish loading\n", path)
		
			local size = 0
			for k, v in pairs(cache) do	size = size + #v end
			logn("[vfs] async: cache size = ", utility.FormatFileSize(size))
		end
	end}
				
	for name, func in pairs(vfs.async_readers) do
		if (not reader or reader == name) and func(path, mbps, context or "none") then
			return true
		end
	end 
	
	queue[path] = nil
	
	logf("[vfs] async %q: not a valid path\n", path)
	
	return false
end

function vfs.UncacheAsync(path)
	cache[path] = nil
	if vfs.debug then
		logf("[VFS] vfs.UncacheAsync(%q)\n", path)
		
		local size = 0
		for k, v in pairs(cache) do	size = size + #v end
		if last_reported_size ~= size then
			logn("[vfs] async read cache size: ", utility.FormatFileSize(size))
			last_reported_size = size
		end
	end
end