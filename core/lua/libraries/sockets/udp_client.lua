local sockets = ... or _G.sockets
local ljsocket = require("ljsocket")
local META = prototype.CreateTemplate("socket", "udp_client")

function META:assert(val, err)
	if not val then self:Error(err) end

	return val, err
end

function META:__tostring2()
	return "[" .. tostring(self.socket) .. "]"
end

function META:Initialize(socket)
	self:SocketRestart(socket)
end

function META:SocketRestart(socket)
	self.socket = socket or ljsocket.create("inet", "dgram", "udp")
end

function META:OnRemove()
	self.socket:close()
end

function META:Close(reason)
	self:Remove()
end

function META:SetAddress(host, port)
	self.address = ljsocket.find_first_address(host, port)
end

function META:Send(data, host, port)
	local address = self.address

	if host then address = ljsocket.find_first_address(host, port) end

	return self.socket:send_to(address, data)
end

function META:Error(message, ...)
	local tr = debug.traceback()
	self:OnError(message, tr, ...)
	return false
end

META:Register()

function sockets.UDPClient(socket)
	local self = META:CreateObject()
	self:Initialize(socket)
	return self
end

do
	local client

	function sockets.SendDatagram(data, ip, port)
		client = client or sockets.UDPClient()
		client:Send(data, ip, port)
	end
end