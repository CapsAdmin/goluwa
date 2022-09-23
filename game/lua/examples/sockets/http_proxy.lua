if not PROXY_SERVER then
	local server = sockets.TCPServer()
	server:Host("*", 4123)
	PROXY_SERVER = server
end

function PROXY_SERVER:OnClientConnected(client)
	function client:OnReceiveChunk(str)
		local url = str:match("GET %/(%S+) HTTP/1%.")
		local ip, port = client.socket:get_name()

		if url ~= "favicon.ico" then
			llog("%s:%s wants to request %s", ip, port, url)
		end

		if not url or not url:starts_with("https://gitlab.com/CapsAdmin/") then
			client:Remove()
			return
		end

		local http = sockets.HTTPClient()
		http:Request("GET", url)

		function http:OnReceiveChunk(chunk)
			client:Send(chunk)
		end
	end
end