local vfs2 = (...) or _G.vfs2

local queue = {}

vfs2.async_readers = {
	file = function(path, mbps, context)
		local file = vfs2.Open(path, "read")
		if file then
			local content = {}
			mbps = mbps / 2
			event.CreateThinker(function()
				-- in case mbps is higher than the file size
				for i = 1, 2 do
					local str = file:ReadBytes(1048576 * mbps)
					if str then
						content[#content + 1] = str
					else
						queue[path].callback(table.concat(content))
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
			
			if vfs2.Exists(cache_path) then
				return vfs2.ReadAsync(cache_path, queue[path].callback, mbps, context, "file")
			else
				if sockets.Download("http://fonts.googleapis.com/css?family=" .. path:gsub("%s", "+"), 
					function(data)
						local url = data:match("url%((.-)%)")
						local format = data:match("format%('(.-)'%)")
						sockets.Download(url, function(data) 
							vfs2.Write("fonts/" .. path .. "." .. format, data, "b")				
							queue[path].callback(data)
						end)
					end)
				then
					return true
				end
			end
		end
		
		local ext = path:match(".+(%.%a+)") or ".dat"
		local cache_path = "download_cache/" .. crypto.CRC32(path) .. ext
		if vfs2.IsFile(cache_path) then
			return vfs2.ReadAsync(cache_path, queue[path].callback, mbps, context, "file")
		else
			if sockets.Download(path, function(data) 
					vfs2.Write(cache_path, data, "b")			
					queue[path].callback(data)
				end) 
			then
				return true
			end
		end
	end,
}

local cache = {}
	
function vfs2.ReadAsync(path, callback, mbps, context, reader)
	check(path, "string")
	check(callback, "function")
	check(mbps, "nil", "number")
	mbps = mbps or 1
	
	if vfs2.debug then
		logf("[VFS] vfs2.ReadAsync(%q)\n", path)
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
		return
	end
			
	queue[path] = {callback = function(data)
		cache[path] = data
		callback(data)
		queue[path] = nil
	end}
				
	for name, func in pairs(vfs2.async_readers) do
		if (not reader or reader == name) and func(path, mbps, context or "none") then
			return true
		end
	end 
	
	queue[path] = nil
	
	return false
end