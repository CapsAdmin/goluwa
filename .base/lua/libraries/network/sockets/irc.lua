local sockets = ... or {}

local META = prototype.CreateTemplate("irc_client")

META:GetSet("Nick", e.USERNAME:gsub("^(.)", string.upper) .. "Bot")

function META:SetNick(str)
	self.Nick = str
	self:NICK(str)
end

function META:Connect(address, port)
	address = address or "chat.freenode.net"
	port = port or 6667

	do
		local socket = sockets.CreateClient()
		
		socket:Connect(address, port)
		socket:SetKeepAlive(true)
		socket:SetTimeout(math.huge)
		socket:SetReceiveMode("line")
		
		socket.OnReceive = function(s, line) 
			self:OnReceive(line)
			
			if line:startswith("PING :") then	
				self:PONG()
			end		
		end
		
		self.socket = socket
	end
	
	self:USER(self.Nick .. " " .. self.Nick .. " irc.freenode.net :realname")
	self:SetNick(self:GetNick())
end

function META:Send(line)
	logn("<< ", line)
	self.socket:Send(("%s\r\n"):format(line))
end

function META:OnReceive(line)
	logn(">> ", line)
end

function META:__index2(key)
	if key ==  key:upper() then
		return function(s, line)
			if line then
				self:Send(key .. " " .. line)
			else
				self:Send(key)
			end
		end
	end
end

function META:OnRemove()
	self:QUIT(":object removed")
	self.socket:Remove()
end

prototype.Register(META)

function sockets.CreateIRCClient()
	return prototype.CreateObject(META)
end

if RELOAD then
	prototype.SafeRemove(IRC_CLIENT)
	
	local client = sockets.CreateIRCClient()
	client:Connect("chat.freenode.net")	
	client:JOIN("#goluwa")
	client:PRIVMSG("#goluwa :hi")

	IRC_CLIENT = client
end