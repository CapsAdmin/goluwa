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
				if header.location and info.url then
					info.protocol = nil
					info.location = nil
					info.host = nil

					info.url = header.location

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
				info.on_chunks(str)
			end

			table.insert(content, str)

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
end

local multipart_boundary = "Goluwa" .. os.time()
local multipart = string.format('multipart/form-data;boundary=%q', multipart_boundary)

function sockets.Request(info)

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
	info.timeout = info.timeout or 2
	info.callback = info.callback or table.print

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
			info.timedout_callback()
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

local active_downloads = table.weak()

local count = 0
local queue = {}

local function push_download(...)
	if count >= 1 then
		table.insert(queue, table.pack(...))
		llog("too many downloads (queue size: %s)", #queue)
	else
		count = count + 1
		return true
	end
end

local function pop_download()
	count = count - 1
	if #queue > 0 then
		sockets.Download(table.unpack(table.remove(queue)))
	end
end

local cb = utility.CreateCallbackThing()

function sockets.Download(url, callback, on_fail, on_chunks, on_header)
	if not url:find("^(.-)://") then return end

	local last_downloaded = 0
	local last_report = system.GetElapsedTime() + 4

	if cb:check(url, callback, {on_fail = on_fail, on_chunks = on_chunks, on_header = on_header}) then return true end

	if not push_download(url, callback, on_fail, on_chunks, on_header) then return true, "queued" end

	cb:start(url, callback, {on_fail = on_fail, on_chunks = on_chunks, on_header = on_header})

	event.Call("DownloadStart", url)

	sockets.Request({
		url = url,
		on_chunks = function(...)
			event.Call("DownloadChunkReceived", url, ...)

			cb:callextra(url, "on_chunks", ...)
		end,
		callback = function(data)
			event.Call("DownloadStop", url, data)

			if not data then
				cb:callextra(url, "on_fail", "data is nil")
			elseif data.header["content-length"] == 0 then
				cb:callextra(url, "on_fail", "content length is zero")
			else
				if sockets.debug_download then
					llog("finished downloading ", url)
				end
				cb:stop(url, data.content)
			end

			cb:uncache(url)

			pop_download()
		end,
		header_callback = function(header)
			event.Call("DownloadHeaderReceived", url, header)

			if cb:callextra(url, "on_header", header) == false then
				cb:uncache(url)
				pop_download()
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
				event.Call("DownloadStop", url, nil, "recevied code " .. code)

				cb:callextra(url, "on_fail", "error code " .. tostring(code))
				cb:uncache(url)
				pop_download()
				return false
			else
				event.Call("DownloadCodeReceived", url, code)
			end

			if sockets.debug_download then llog("downloading ", url) end
		end,
		error_callback = function(reason)
			cb:callextra(url, "on_fail", reason)
			cb:uncache(url)
			pop_download()
		end,
		timedout_callback = function()
			cb:callextra(url, "on_fail", "timed out")
			cb:uncache(url)
			pop_download()
		end,
	})

	return true
end

function sockets.AbortDownload(url)
	event.Call("DownloadStop", url, nil, "aborted")
	cb:uncache(url)
	pop_download()
	if sockets.debug_download then llog("download aborted ", url) end
end

function sockets.DownloadFirstFound(urls, callback, on_fail)
	local found = function(found_url)
		for _, other_url in ipairs(urls) do
			if found_url ~= other_url then
				sockets.AbortDownload(other_url)
			end
		end
	end

	local fails = {}

	for _, url in ipairs(urls) do
		sockets.Download(
			url,
			function(...)
				callback(url, ...)
			end,
			function(reason)
				table.insert(fails, "failed to download " .. url .. ": " .. reason .. "\n")
				if #fails == #urls then
					local reason = ""
					for _, str in ipairs(fails) do
						reason = reason .. str
					end
					on_fail(reason)
				end
			end,
			nil,
			function(header)
				if header["content-length"] > 0 then
					found(url)
				end
			end
		)
	end
end

function sockets.Get(url, callback, timeout, user_agent, binary, debug)
	return sockets.Request({
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

	return sockets.Request({
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