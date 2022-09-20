local test = test.create()
test.expect_count = 2
local server_msg = "hello from server!"
local client_msg = "hello from client!"
local server = sockets.TCPServer()
server:Host("*", 5001)
server.OnClientConnected = function(_, client)
	client:Send(server_msg)
	client.OnReceiveChunk = function(_, str)
		test:expect("data received from client", str, client_msg)
		server:Remove()
	end
end

do
	local client = sockets.TCPClient()
	client:Connect("0.0.0.0", 5001)
	client:Send("hello from client!")
	client.OnReceiveChunk = function(_, str)
		test:expect("data received from client", str, server_msg)
		server:Remove()
	end
end