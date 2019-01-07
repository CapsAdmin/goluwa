local sockets = (...) or _G.sockets

function sockets.EscapeURL(str)
	local protocol, rest = str:match("^(.-://)(.+)$")
	if not protocol then
		protocol = ""
		rest = str
	end

	rest = rest:gsub("([^A-Za-z0-9_/])", function(char)
		return ("%%%02x"):format(string.byte(char))
	end)

	return protocol .. rest
end

function sockets.HeaderToTable(header)
	local tbl = {}

	if not header then return tbl end

	for _, line in ipairs(header:split("\n")) do
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


function sockets.SetupReceiveHTTP(socket, info)
	if not info then
		info = {}
		info.callback = function(...)
			if socket:IsValid() then
				socket:OnReceiveHTTP(...)
			end
		end
	end

	local header = {}
	local content = {}
	local length = 0
	local in_header = true

	local protocol
	local code
	local code_desc

	local function done()
		content = table.concat(content, "")
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

		if info.remove_socket_on_finish then
			socket:Remove()
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

			local _, split_pos = str:find("\r\n\r\n", 0, true)

			local header_data = split_pos and str:sub(0, split_pos)
			local content_data = split_pos and str:sub(split_pos + 1)

			-- just the header?
			if not header_data then
				header_data = str
			end

			if header_data then
				header = sockets.HeaderToTable(header_data)

				-- redirection
				if header.location and info.url then
					local protocol, host, location = header.location:match("(.+)://(.-)/(.+)")

					if not location then
						if header.location:startswith("//") then
							protocol = info.protocol
							host, location = header.location:match("^//(.-)/(.*)")
						else
							protocol, host = header.location:match("(.+)://(.*)")
						end
					end

					if not location then
						location = info.location:match("^(.+/).+$") .. header.location
						host = info.host
						protocol = info.protocol
					end

					info.location = location
					info.host = host
					info.protocol = protocol

					sockets.Request(info)
					self:Remove()

					return
				end

				str = content_data

				in_header = false

				if info.header_callback and info.header_callback(header) == false then
					self:Remove()
					return
				end

				if info.method == "HEAD" or header["content-length"] == 0 then
					done(self)
					return
				end
			end
		end

		if str then
			length = length + #str

			if info.on_chunks then
				info.on_chunks(str, length, header)
			end

			table.insert(content, str)

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
end

local multipart_boundary = "Goluwa" .. os.time()
local multipart = string.format('multipart/form-data;boundary=%q', multipart_boundary)

function sockets.Request(info)
	local a,b,c = event.Call("SocketRequest", info)
	if a ~= nil then
		return a,b,c
	end

	if info.url then
		local protocol, host, location = info.url:match("(.+)://(.-)/(.+)")

		if not location then
			protocol, host = info.url:match("(.+)://(.+)")
		end

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

		if info.location then
			info.location = info.location:gsub(" ", "%%20")
		end
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
	info.user_agent = info.user_agent or "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0"
	info.connection = info.connection or "Keep-Alive"
	info.receive_mode = info.receive_mode or "all"
	info.timeout = info.timeout or 5
	info.callback = info.callback or table.print
	if info.remove_socket_on_finish == nil then
		info.remove_socket_on_finish = true
	end

	if not info.files and (info.method == "POST" or info.method == "PATCH" or info.method == "PUT") and not info.post_data then
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

	function socket:OnTimedOut()
		if info.timedout_callback then
			info.timedout_callback("timed out (" .. self:GetTimeout() .. " seconds)")
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

	if not info.header or not info.header["User-Agent"] then socket:Send(("User-Agent: %s\r\n"):format(info.user_agent)) end
	if not info.header or not info.header["Connection"] then socket:Send(("Connection: %s\r\n"):format(info.connection)) end

	if info.files then
		local body = ""

		for i, v in ipairs(info.files) do
			body = body .. '\r\n--' .. multipart_boundary
			body = body .. '\r\nContent-Disposition: form-data; name="' .. v.name .. '"'
			if v.filename then
				body = body .. ';filename="' .. v.filename .. '"'
			end
			body = body .. '\r\nContent-Type:' .. (v.type or "application/octet-stream")
			body = body .. '\r\n\r\n' .. v.data
		end

		body = body .. "\r\n--" .. multipart_boundary .. "--"

		info.post_data = body
		info.header = info.header or {}
		info.header["Content-Type"] = multipart
	end

	if info.username and info.token then
		info.header = info.header or {}
		info.header.Authorization = "Basic " .. crypto.Base64Encode(info.username..":"..info.token)
	end

	if info.header then
		for k,v in pairs(info.header) do
			socket:Send(("%s: %s\r\n"):format(k, v))
		end
	end

	if info.method == "POST" or info.method == "PATCH" or info.method == "PUT" then
		local str = info.post_data
		if type(info.post_data) == "table" then
			str = ""
			for k,v in pairs(info.post_data) do
				str = str .. ("%s: %s\r\n"):format(k, v)
			end
		end

		if not info.header or not info.header["Content-Type"] then
			socket:Send("Content-Type: application/json\r\n")
		end
		if not info.header or not info.header["Content-Length"] then
			socket:Send(("Content-Length: %i\r\n"):format(#str))
		end
		socket:Send("\r\n")
		socket:Send(str)
	else
		socket:Send("\r\n")
	end

	sockets.SetupReceiveHTTP(socket, info)

	return socket
end

do
	local function no_callback(data, url)
		logn(url, ":")
		logn("\tsize:", utility.FormatFileSize(#data))
		logn("\tcrc32:", crypto.CRC32(data))
	end

	sockets.active_downloads = sockets.active_downloads or {}

	function sockets.Download(url, callback, on_fail, on_chunks, on_header)
		if not url:find("^(.-)://") then return end

		local last_downloaded = 0
		local last_report = system.GetElapsedTime() + 4

		callback = callback or no_callback

		event.Call("DownloadStart", url)

		local socket
		socket = sockets.Request({
			url = url,
			receive_mode = (1024 * 1024) * 2, -- 2 mb
			on_chunks = function(...)
				event.Call("DownloadChunkReceived", url, ...)

				on_chunks(...)
			end,
			callback = function(data)
				event.Call("DownloadStop", url, data)

				if not data then
					on_fail("data is nil")
				elseif data.header["content-length"] == 0 then
					on_fail("content length is zero")
				else
					if sockets.debug_download then
						llog("finished downloading ", url)
					end
					callback(data.content, url, header)
				end

				socket:Remove()
			end,
			header_callback = function(header)
				event.Call("DownloadHeaderReceived", url, header)

				if on_header(header) == false then
					socket:Remove()
					return false
				end

				if sockets.debug_download then
					if header["content-length"] then
						llog("size of ", url, " is ", utility.FormatFileSize(header["content-length"]))
					else
						llog("size of ", url, " is unkown!")
					end
				end
			end,
			code_callback = function(code)
				if code == 404 or code == 400 then
					event.Call("DownloadStop", url, nil, "recevied code " .. code)

					on_fail("error code " .. tostring(code))
					socket:Remove()
					return false
				else
					event.Call("DownloadCodeReceived", url, code)
				end

				if sockets.debug_download then llog("downloading ", url) end
			end,
			error_callback = function(reason)
				on_fail(reason)
				if socket then socket:Remove() end
			end,
			timedout_callback = function(msg)
				on_fail(msg)
				if socket then socket:Remove() end
			end,
		})

		sockets.active_downloads[url] = socket

		return socket
	end

	function sockets.StopDownload(url)
		local socket = sockets.active_downloads[url] or NULL
		if socket:IsValid() then
			sockets.active_downloads[url]:Remove()
		end
		sockets.active_downloads[url] = nil
	end
end
