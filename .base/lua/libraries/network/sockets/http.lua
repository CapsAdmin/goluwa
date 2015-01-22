local sockets = (...) or _G.sockets

function sockets.EscapeURL(str)
	return str:gsub("([^A-Za-z0-9_])", function(char)
		return ("%%%02x"):format(string.byte(char))
	end)
end

function sockets.HeaderToTable(header)
	local tbl = {}
	
	if not header then return tbl end

	for line in header:gmatch("(.-)\n") do
		local key, value = line:match("(.+):%s+(.+)\r")

		if key and value then
			tbl[key:lower()] = tonumber(value) or value
		end
	end

	return tbl
end

function sockets.TableToHeader(tbl)
	local str = ""

	for key, value in pairs(tbl) do
		str = str .. tostring(key) .. ": " .. tostring(value) .. "\r\n"
	end

	return str
end

local function request(url, callback, method, timeout, post_data, user_agent, binary, debug)
	local ssl = url:sub(0, 5) == "https"
	
	url = url:match("^.-://(.+)")
	
	callback = callback or table.print
	method = method or "GET"
	user_agent = user_agent or "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36"

	local host, location = url:match("(.-)/(.+)")

	if not location then
		host = url:gsub("/", "")
		location = ""
	end
		
	local socket = sockets.CreateClient("tcp")
	socket.debug = debug
	socket:SetTimeout(timeout or 2)
	
	if ssl then 
		socket:SetSSLParams("https") 
		socket:Connect(host, 443)
	else
		socket:Connect(host, 80)
	end
	
	socket:Send(("%s /%s HTTP/1.1\r\n"):format(method, location))
	socket:Send(("Host: %s\r\n"):format(host))
	socket:Send(("User-Agent: %s\r\n"):format(user_agent))
	socket:Send("Connection: Keep-Alive\r\n")
	socket:SetReceiveMode(61440)
				
	if binary then
		socket:SetReceiveMode("all")
	end		
	
	if method == "POST" then
		socket:Send(("Content-Length: %i"):format(#post_data))
		socket:Send(post_data)
	end

	socket:Send("\r\n")

	local header = {}
	local content = {}
	local temp = {}
	local length = 0
	local in_header = true
	
	function socket:OnReceive(str)
		if in_header then
			table.insert(temp, str)
			
			local str = table.concat(temp, "")
			local header_data, content_data = str:match("(.-\r\n\r\n)(.+)")
			if header_data then
				header = sockets.HeaderToTable(header_data)
				
				if header.location then
					if header.location:sub(0, 5) == "https" then header.location = "http" .. header.location:sub(6) end
					
					if header.location ~= "" then
						request(header.location, callback, method, timeout, post_data, user_agent, binary)
						self:Remove()
						return
					end
				end
				
				if content_data then
					table.insert(content, content_data)
					length = length + #content_data
				end
									
				in_header = false
			end
		else
			table.insert(content, str)
			length = length + #str
		end
		
		table.print(header)

		if header["content-length"] then
			if length >= header["content-length"] then
				self:Remove()
			end
		elseif header["transfer-encoding"] == "chunked" then
			if str:sub(-5) == "0\r\n\r\n" then 
				self:Remove()
			end
		end
	end

	
	function socket:OnClose()			
		local content = table.concat(content, "")

		if content ~= "" then
			local ok, err = xpcall(callback, system.OnError, {content = content, header = header})
			
			if err then
				warning(err)
			end
		else
			--warning("no content was found")
		end
	end
end

function sockets.Get(url, callback, timeout, user_agent, binary, debug)
	check(url, "string")
	check(callback, "function", "nil", "false")
	check(user_agent, "nil", "string")
	
	return request(url, callback, "GET", timeout, nil, user_agent, binary, debug)
end

function sockets.Post(url, post_data, callback, timeout, user_agent, binary, debug)
	check(url, "string")
	check(callback, "function", "nil", "false")
	check(post_data, "table", "string")
	check(user_agent, "nil", "string")
	
	if type(post_data) == "table" then
		post_data = sockets.TableToHeader(post_data)
	end
	
	return request(url, callback, "POST", timeout, post_data, user_agent, binary, debug)
end

function sockets.Download(url, callback)
	if url:sub(0, 4) == "http" then					
		if callback then
			sockets.Get(url, function(data) callback(data.content) end, nil, nil, true)
			return true
		else
			return {Download = function(_, callback) sockets.Get(url, function(data) callback(data.content, data.header) end, nil, nil, true) end}
		end
	end
	
	return false
end