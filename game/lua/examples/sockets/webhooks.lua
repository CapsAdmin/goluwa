local port = 27020
local secret = nil
local hmac

if secret then
	hmac = require("openssl.hmac").new(gserv.webhook_secret:Get(), "sha1")
end

local function verify_signature(hub_sign, body)
	local a = hub_sign:sub(#"sha1=" + 1):gsub("..", function(c)
		return string.char(tonumber("0x" .. c))
	end)
	local b = hmac:final(body)
	local equal = #a == #b

	if equal then
		for i = 1, #a do
			if a:sub(i, i) ~= b:sub(i, i) then return end
		end

		return true
	end
end

local server = webhook_server

if not server then
	server = sockets.CreateServer("tcp")
	server:Host("*", port)
	webhook_server = server
end

function server:OnClientConnected(client)
	sockets.SetupReceiveHTTP(client)

	function client:OnReceiveHTTP(data)
		if secret then
			if not verify_signature(data.header["x-hub-signature"], data.content) then
				client:Remove()
				return
			end
		end

		local content = data.content

		if data.header["content-type"]:find("form-urlencoded", nil, true) then
			content = content:match("^payload=(.+)")
			content = content:gsub("%%(..)", function(hex)
				return string.char(tonumber("0x" .. hex))
			end)
		end

		table.print(serializer.Decode("json", content))
		client:Send("HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")
	end

	return true
end