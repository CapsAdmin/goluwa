local socket = LOL

if not socket or not socket:IsValid() then
	socket = sockets.CreateWebsocketClient()
	LOL = socket
	socket:Connect("10.0.0.54", 27020)
end

local str = {}
for i = 1, 300000 do
	str[i] = tostring(i)
end

str = table.concat(str, " ") .. "THE END"
print("sending " .. utility.FormatFileSize(#str), #str, str:sub(-100))
socket:Send(str)

function socket:OnReceive(message, opcode)
	print("received " .. utility.FormatFileSize(#message), #message, message:sub(-100))
end