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

local function request(info)

	if info.url then
		local protocol, host, location = info.url:match("(.+)://(.-)/(.+)")

		local _host, port = host:match("(.+):(.+)")

		if _host and port then
			host = _host
			info.port = tonumber(port)
		end

		if not protocol then
			host, location = info.url:match("(.-)/(.+)")
			protocol = "http"
		end

		info.location = info.location or location
		info.host = info.host or host
		info.protocol = info.protocol or protocol

		info.location = info.location:gsub(" ", "%%20")
	end

	if info.protocol == "https" and not info.ssl_parameters then
		info.ssl_parameters = "https"
	end

	if info.ssl_parameters and not info.protocol then
		info.protocol = "https"
	end

	if not info.port then
		if info.protocol == "https" then
			info.port = 443
		else
			info.port = 80
		end
	end

	info.method = info.method or "GET"
	info.user_agent = info.user_agent or "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36"
	info.connection = info.connection or "Keep-Alive"
	info.receive_mode = info.receive_mode or "all"
	info.timeout = info.timeout or 2
	info.callback = info.callback or table.print

	if info.method == "POST" and not info.post_data then
		error("no post data!", 2)
	end

	if sockets.debug then
		logn("sockets request:")
		table.print(info)
	end

	local socket = sockets.CreateClient("tcp")
	socket.debug = info.debug

	function socket:OnError(reason)
		if info.error_callback then
			info.error_callback(reason)
		end
	end

	socket:SetTimeout(info.timeout)

	if info.ssl_parameters then
		socket:SetSSLParams(info.ssl_parameters)
	end

	socket:Connect(info.host, info.port)
	socket:SetReceiveMode(info.receive_mode)

	socket:Send(("%s /%s HTTP/1.1\r\n"):format(info.method, info.location))
	socket:Send(("Host: %s\r\n"):format(info.host))

	if not info.header or not info.header.user_agent then socket:Send(("User-Agent: %s\r\n"):format(info.user_agent)) end
	if not info.header or not info.header.user_agent then socket:Send(("Connection: %s\r\n"):format(info.connection)) end

	if info.header then
		for k,v in pairs(info.header) do
			socket:Send(("%s: %s\r\n"):format(k, v))
		end
	end

	if info.method == "POST" then
		socket:Send(("Content-Length: %i"):format(#info.post_data))
		socket:Send(info.post_data)
	end

	socket:Send("\r\n")

	local header = {}
	local content = {}
	local length = 0
	local in_header = true

	local protocol
	local code
	local code_desc

	local function done(self)
		if info.on_chunks then system.pcall(info.callback) return end

		local content = table.concat(content, "")
		local length = header["content-length"]

		if sockets.debug then
			print(protocol, code, code_desc)
			table.print(header)
		end

		if (not length and #content ~= 0) or (length and #content == length) or info.method == "HEAD" then
			system.pcall(info.callback, {content = content, header = header, protocol = protocol, code = code, code_desc = code_desc})
		elseif info.on_fail then
			system.pcall(info.on_fail, content)
		end
	end

	function socket:OnReceive(str)
		if in_header then
			protocol, code, code_desc = str:match("^(%S-) (%S-) (.+)\n")
			code = tonumber(code)

			if info.code_callback and info.code_callback(code) == false then
				if info.on_fail then
					system.pcall(info.on_fail, "bad code")
				end
				self:Remove()
				return
			end

			local header_data, content_data = str:match("(.-\r\n\r\n)(.+)")

			-- just the header?
			if not header_data then
				header_data = str
			end

			if header_data then
				header = sockets.HeaderToTable(header_data)

				 -- redirection
				if header.location then
					info.protocol = nil
					info.location = nil
					info.host = nil

					info.url = header.location

					request(info)
					self:Remove()

					return
				end

				str = content_data

				in_header = false

				if info.header_callback and info.header_callback(header) == false then
					self:Remove()
					return
				end

				if info.method == "HEAD" then
					done(self)
					return
				end
			end
		end

		if str then
			length = length + #str

			if info.on_chunks then
				info.on_chunks(str)
			else
				table.insert(content, str)
			end

			if info.progress_callback then
				info.progress_callback(content, str, length, header)
			end

			if header["content-length"] then
				if length >= header["content-length"] then
					done(self)
				end
			elseif header["transfer-encoding"] == "chunked" then
				if str:sub(-5) == "0\r\n\r\n" then
					done(self)
				end
			end
		end
	end

	return socket
end

local active_downloads = utility.CreateWeakTable()
local cb = utility.CreateCallbackThing()

function sockets.Download(url, callback, on_fail, on_chunks, on_header)
	if not url:find("^(.-)://") then return end

	if cb:check(url, callback) then return true end

	local last_downloaded = 0
	local last_report = system.GetElapsedTime() + 4

	cb:start(url, callback)

	active_downloads[url] = sockets.Request({
		url = url,
		on_chunks = on_chunks,
		callback = function(data)
			if sockets.debug_download then logn("[sockets] finished downloading ", url) end
			cb:stop(url, data and data.content)
			cb:uncache(url)
			active_downloads[url] = nil
		end,
		header_callback = function(header)
			if on_header and on_header(header) == false then
				return false
			end

			if sockets.debug_download then
				if header["content-length"] then
					logn("[sockets] size of ", url, " is ", utility.FormatFileSize(header["content-length"]))
				else
					logn("[sockets] size of ", url, " is unkown!")
				end
			end
		end,
		progress_callback = function(_, _, current_length, header)
			if not header["content-length"] then return end

			if sockets.debug_download then
				if last_report < system.GetElapsedTime() then
					logn(url, ":")
					logn("\tprogress: ", math.round((current_length / header["content-length"]) * 100, 3), "%")
					logn("\tspeed: ", utility.FormatFileSize(current_length - last_downloaded))
					last_downloaded = current_length
					last_report = system.GetElapsedTime() + 4
				end
			end
		end,
		code_callback = function(code)
			if code == 404 or code == 400 then
				cb:uncache(url)

				if on_fail then
					on_fail()
				end

				return false
			end

			if sockets.debug_download then logn("[sockets] downloading ", url) end
		end,
		error_callback = function(reason)
			if on_fail then
				on_fail(reason)
			end
		end,
	})

	return true
end

function sockets.AbortDownload(url)
	if active_downloads[url] then
		cb:uncache(url)
		active_downloads[url].just_remove = true
		active_downloads[url]:Remove()
		active_downloads[url] = nil
		if sockets.debug_download then logn("[sockets] download aborted ", url) end
	end
end

function sockets.Get(url, callback, timeout, user_agent, binary, debug)
	return request({
		url = url,
		callback = callback,
		method = "GET",
		timeout = timeout,
		user_agent = user_agent,
		receive_mode = binary and "all",
		debug = debug
	})
end

function sockets.Post(url, post_data, callback, timeout, user_agent, binary, debug)
	if type(post_data) == "table" then
		post_data = sockets.TableToHeader(post_data)
	end

	return request({
		url = url,
		callback = callback,
		method = "POST",
		timeout = timeout,
		post_data = post_data,
		user_agent = user_agent,
		receive_mode = binary and "all",
		debug = debug
	})
end

sockets.Request = request