local ffi = require("ffi")
local ljsocket = require("ljsocket")
local port = 5001

local answerStart = [[HTTP/1.1 200 OK
Server: masrv/0.1.0
Date: Thu, 28 Mar 2013 22:16:09 GMT
Content-Type: text/html
Connection: Keep-Alive
Content-Length: ]]
local answerEnd = [[

Last-Modified: Wed, 21 Sep 2011 14:34:51 GMT
Accept-Ranges: bytes

]]  -- do not remove empty lines inside [[ ]]

answerEnd = answerEnd:gsub("\n", "\r\n")
answerStart = answerStart:gsub("\n", "\r\n")
local content = [[<html><body><h1>It works - stuta!</h1></body></html>]]
content = content:gsub("\n", "\r\n") -- is this needed?

local header = answerStart..tostring(#content)..answerEnd
content = header..content

local server_socket = ljsocket.tcp.listen(port)
local ptr = ffi.new("struct timeval", {tv_sec = 0, tv_usec = 0})

print(ljsocket.socket.setsockopt(server_socket, ffi.C.SOL_SOCKET, ffi.C.SO_SNDTIMEO, ptr))
print(ljsocket.socket.setsockopt(server_socket, ffi.C.SOL_SOCKET, ffi.C.SO_RCVTIMEO, ptr))

local clients = {}

local function close(sock)
	ljsocket.tcp.close(sock)
	clients[sock] = nil
end


event.AddListener("Update", "test", function()
	local client_socket = ljsocket.tcp.accept(server_socket)

	if client_socket > 0 then
		ljsocket.socket.set_nonblock(client_socket, 1)
		clients[client_socket] = client_socket
	end

	for _, client_socket in pairs(clients) do
		local recvbuf = ffi.new("char[?]", 16384)
		local result = ljsocket.socket.recv(client_socket, recvbuf, ffi.sizeof(recvbuf), 0)

		if result > 0 then
			local send_result = ljsocket.socket.send(client_socket, content, #content, 0)

			if send_result < 0 then
				ljsocket.socket.cleanup(client_socket, send_result, "ljsocket.socket.send failed with error: ")
			end
		elseif not ljsocket.socket.wouldblock() then
			print("error!", system.LastOSError(), ffi.errno())
			close(client_socket)
		end
	end
end)

print("http://127.0.0.1:"..port.."/")
--system.OpenURL("http://127.0.0.1:"..port.."/")