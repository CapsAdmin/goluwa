local socket = sockets.CreateWebsocketClient()

socket:Connect("wss://echo.websocket.org")
socket:Send("asdf")

function socket:OnReceive(message, opcode)
	print(message, opcode)
end
