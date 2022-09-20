local sockets = ... or _G.sockets
local ljsocket = require("ljsocket")
local META = prototype.CreateTemplate("socket", "udp_server")

function META:assert(val, err)
	if not val then self:Error(err) end

	return val, err
end

function META:__tostring2()
	return "[" .. tostring(self.socket) .. "]"
end

function META:Initialize(socket)
	self:SocketRestart(socket)
	sockets.pool:insert(self)
end

function META:SocketRestart(socket)
	self.socket = socket or ljsocket.create("inet", "dgram", "udp")

	if not self:assert(self.socket:set_blocking(false)) then return end
end

function META:OnRemove()
	sockets.pool:remove(self)
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

function META:Update()
	local chunk, err = self.socket:receive_from(self.address)

	if chunk then
		self:OnReceiveChunk(chunk, err)
	else
		if err == "closed" then
			self:OnClose("receive")
		elseif err ~= "timeout" then
			self:Error(err)
		end
	end
end

function META:Error(message, ...)
	local tr = debug.traceback()
	self:OnError(message, tr, ...)
	return false
end

function META:OnReceiveChunk(chunk, address) end

META:Register()

function sockets.UDPServer(socket)
	local self = META:CreateObject()
	self:Initialize(socket)
	return self
end

if RELOAD then
	local udp = sockets.UDPServer()
	udp:SetAddress("0.0.0.0", 31337)

	function udp:OnReceiveChunk(chunk, address)
		print(chunk)
		print(address:get_ip(), address:get_port())
	end

	udp:Send("hello")
end