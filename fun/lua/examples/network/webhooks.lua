
if not server then
	server = sockets.CreateServer("tcp")
	server:Host("*", 27020) server.debug = true
end

function server:OnClientConnect(client)
	sockets.SetupReceiveHTTP(client)

	print(client)

	client.debug = true
	server.debug = true

	function client:OnReceiveHTTP(data)
		local header = sockets.TableToHeader({
			["Content-Length"] = "0",
			["Content-Type"] = "text/html; charset=utf-8",
		})

		client:Send("HTTP/1.1 200 OK\r\n" .. header .. "\r\n")
		table.print(data)
	end

	return true
end