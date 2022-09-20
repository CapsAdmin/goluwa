sockets.webook_servers = sockets.webook_servers or {}

local function verify_signature(signature, secret, body)
	local hmac = desire("hmac")

	if not hmac then
		return false, "unable to load hmac library to verify signature"
	end

	local a = signature:sub(#"sha1=" + 1):gsub("..", function(c)
		return string.char(tonumber("0x" .. c))
	end)
	local b = hmac:new(secret, hmac.ALGOS.SHA1):final(body)

	if #a ~= #b then return false, "length of signature does not match" end

	for i = 1, #a do
		if a:sub(i, i) ~= b:sub(i, i) then
			return false, "contents of signature does not match"
		end
	end

	return true
end

function sockets.HandleWebhookRequest(client, body, content_type, secret, signature, callback)
	if secret then
		local ok, reason = verify_signature(signature, secret, body)

		if not ok then
			logn("webhook client ", client, " removed: ", reason)
			client:Remove()
			return
		end
	end

	local content = body

	if content_type:find("form-urlencoded", nil, true) then
		content = content:match("^payload=(.+)")
		content = content:gsub("%%(..)", function(hex)
			return string.char(tonumber("0x" .. hex))
		end)
	end

	client:Send("HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")
	local tbl = serializer.Decode("json", content)

	if callback then callback(tbl, self) end

	event.Call("Webhook", tbl, self)
	return tbl
end

function sockets.StartWebhookServer(port, secret, callback)
	local server = sockets.webook_servers[port]

	if not server then
		server = sockets.TCPServer()
		server:Host("*", port)
		llog("starting webhook server at port " .. port)
		sockets.webook_servers[port] = server
	end

	function server:OnClientConnected(client)
		sockets.ConnectedTCP2HTTP(client)

		function client:OnReceiveBody()
			sockets.HandleWebhookRequest(
				client,
				self.http.body,
				self.http.header["content_type"],
				secret,
				self.http.header["x-hub-signature"],
				callback
			)
		end

		return true
	end
end

function sockets.StopWebhookServer(port)
	if sockets.webook_servers[port] then
		sockets.webook_servers[port]:Remove()
		sockets.webook_servers[port] = nil
	end
end