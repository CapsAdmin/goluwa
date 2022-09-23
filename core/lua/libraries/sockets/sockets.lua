local sockets = {}
runfile("http.lua", sockets)
runfile("tcp_client.lua", sockets)
runfile("tcp_server.lua", sockets)
runfile("udp_client.lua", sockets)
runfile("udp_server.lua", sockets)
runfile("websocket_client.lua", sockets)
--runfile("websocket_server.lua", sockets)
runfile("http11_client.lua", sockets)
runfile("http11_server.lua", sockets)
runfile("download.lua", sockets)
sockets.pool = sockets.pool or prototype.CreateObjectPool("sockets")

timer.Repeat(
	"sockets",
	1 / 30,
	0,
	function()
		sockets.pool:call("Update")
	end,
	nil,
	function(...)
		logn(...)
		return true
	end
)

return sockets