local http = _G.http or {}

do
	local start = callback.WrapKeyedTask(function(self, url)
		local socket = sockets.Download(
			url,
			self.callbacks.resolve,
			self.callbacks.reject,
			self.callbacks.chunks,
			self.callbacks.header
		)
		self.on_stop = function()
			if socket:IsValid() then socket:Remove() end
		end
		self.socket = socket
	end, 20, function(what, cb, key, queue)
		if what == "push" then
			llog("queueing %s (too many active downloads %s)", key, #queue)
		end
	end)

	function http.Download(url)
		return start(url)
	end
end

do
	local start = callback.WrapKeyedTask(function(self, key, urls)
		local resolve = self.callbacks.resolve
		local reject = self.callbacks.reject
		local cbs = {}
		local fails = {}

		local function fail(url, reason)
			list.insert(fails, "failed to download " .. url .. ": " .. reason .. "\n")

			if #fails == #urls then
				local reason = ""

				for _, str in ipairs(fails) do
					reason = reason .. str
				end

				reject(reason)
			end
		end

		for i, url in ipairs(urls) do
			cbs[i] = http.Download(url):Then(function(...)
				resolve(url, ...)
			end):Catch(function(reason)
				fail(url, reason or "no reason")
			end):Subscribe("header", function(header)
				if
					(
						not header["content-length"] or
						header["content-length"] == 0
					)
					and
					not header["content-type"]
				then
					return false, "download length is 0"
				end

				for _, cb in ipairs(cbs) do
					if cb ~= cbs[i] then cb:Stop() end
				end
			end)
		end

		return true
	end)

	function http.DownloadFirstFound(urls)
		return start(list.concat(urls), urls)
	end
end

do
	function http.Get(url, callback, timeout, binary, debug)
		return sockets.Request({
			method = "GET",
			url = url,
			callback = callback,
		})
	end
end

function http.Post(url, body, callback)
	sockets.Request({
		method = "POST",
		url = url,
		callback = callback,
		body = body,
	})
end

do
	local multipart_boundary = "Goluwa" .. os.time()
	local multipart = string.format("multipart/form-data;boundary=%q", multipart_boundary)

	function sockets.Request(tbl, no_task)
		if not no_task then
			local a, b, c = event.Call("SocketRequest", tbl)

			if a ~= nil then return a, b, c end
		end

		local client = sockets.HTTPClient()
		client.socket:set_option("keepalive", true)
		client.NoCodeError = true
		client.OnReceiveStatus = function(_, code, status)
			if tbl.code_callback then
				return tbl.code_callback(tonumber(code), status)
			end
		end
		client.OnReceiveHeader = function(_, header)
			if tbl.header_callback then tbl.header_callback(header) end
		end
		client.OnReceiveBodyChunk = function(_, chunk)
			if tbl.on_chunks then tbl.on_chunks(chunk, length, header) end
		end
		client.OnReceiveBody = function(_, body)
			tbl.callback(
				{
					body = client.http.body,
					content = client.http.body,
					header = client.http.header,
					code = tonumber(client.http.code),
				}
			)
		end
		client.OnError = function(_, err, tr)
			if tbl.error_callback then
				tbl.error_callback(err)
			else
				llog("sockets.Request: " .. err)
				logn(tr)
			end
		end

		if tbl.files then
			local body = ""

			for i, v in ipairs(tbl.files) do
				body = body .. "\r\n--" .. multipart_boundary
				body = body .. "\r\nContent-Disposition: form-data; name=\"" .. v.name .. "\""

				if v.filename then
					body = body .. ";filename=\"" .. v.filename .. "\""
				end

				body = body .. "\r\nContent-Type:" .. (v.type or "application/octet-stream")
				body = body .. "\r\n\r\n" .. v.data
			end

			body = body .. "\r\n--" .. multipart_boundary .. "--"
			tbl.post_data = body
			tbl.header = tbl.header or {}
			tbl.header["Content-Type"] = multipart
		end

		client:Request(tbl.method or "GET", tbl.url, tbl.header, tbl.post_data)
		return client
	end
end

do
	local start = callback.WrapKeyedTask(function(self, url, data, method)
		local reject = self.callbacks.reject
		local resolve = self.callbacks.resolve
		local post_data

		if data then
			if
				data.headers and
				table.lowecase_lookup(data.headers, "content-type") and
				table.lowecase_lookup(data.headers, "content-type"):starts_with("application/json")
			then
				post_data = serializer.Encode("json", data.body)
			else
				post_data = data.body
			end
		end

		local socket
		socket = sockets.Request(
			{
				url = url,
				method = method,
				header_callback = self.callbacks.header,
				on_chunks = self.callbacks.chunks,
				callback = function(data)
					if
						table.lowecase_lookup(data.header, "content-type"):starts_with("application/json")
					then
						resolve(serializer.Decode("json", data.body))
					else
						resolve(data.body)
					end
				end,
				code_callback = function(code, status)
					if not tostring(code):starts_with("2") and not tostring(code):starts_with("3") then
						socket:Remove()
						reject(status .. "(" .. code .. ") url:" .. url)
						return false
					end
				end,
				error_callback = function(err)
					if socket then socket:Remove() end

					reject(err)
				end,
				post_data = post_data,
				header = data and data.headers,
				files = data and data.files,
			},
			true
		)
		self.on_stop = function()
			if socket:IsValid() then socket:Remove() end
		end
	end)
	local methods = {
		"GET",
		"HEAD",
		"POST",
		"PUT",
		"DELETE",
		"CONNECT",
		"OPTIONS",
		"TRACE",
		"PATCH",
	}

	for _, method in ipairs(methods) do
		http[method] = function(url, data)
			if tasks.GetActiveTask() then return start(url, data, method):Get() end

			return start(url, data, method)
		end
	end

	function http.CreateAPI(base_url, default_headers)
		local api = {}

		for _, method in ipairs(methods) do
			api[method] = function(url, data)
				data = data or {}
				data.headers = data.headers or {}

				if default_headers then
					local default_headers = default_headers

					if type(default_headers) == "function" then
						default_headers = default_headers(data)
					end

					for k, v in pairs(default_headers) do
						data.headers[k] = data.headers[k] or v
					end
				end

				--table.print(data)
				--print(base_url .. url)
				if tasks.GetActiveTask() then
					return start(base_url .. url, data, method):Get()
				end

				return start(base_url .. url, data, method)
			end
		end

		return api
	end
end

function http.async(func)
	tasks.enabled = true
	tasks.CreateTask(func)
end

function http.query(url, tbl)
	return url .. http.EncodeQuery(tbl)
end

function http.EncodeQuery(tbl)
	local str = "?"

	for k, v in pairs(tbl) do
		str = str .. k .. "=" .. v .. "&"
	end

	if str:ends_with("&") then str = str:sub(0, -2) end

	return str
end

if RELOAD then
	--print("!?")
	--http.DownloadFirstFound({"https://dl.dafont.com/dl/?f=helveticaaDAWDAWD", "https://dl.dafont.com/dl/?f=helvetica"}):Then(function(url, data)
	---print("?!?!")
	--end)
	--sockets.Download("https://gitlab.com/CapsAdmin/goluwa-assets/raw/master/extras/roboto italic")
	local api = http.CreateAPI("https://jsonplaceholder.typicode.com/")

	http.async(function()
		local data = api.POST(
			"posts",
			{
				headers = {
					["content-type"] = "application/json",
				},
				body = {
					title = "foo",
					body = "bar",
					userId = 1,
				},
			}
		)
		table.print(data)
	end)
end

return http