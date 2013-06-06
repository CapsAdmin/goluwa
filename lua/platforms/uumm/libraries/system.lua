local system = {}

client_socket = NULL

USER_JOIN = 1
USER_CHAT = 2

function system.Connect(ip, port)
	if client_socket:IsValid() then
		client_socket:Remove()
	end
	
	client_socket = luasocket.Client()
	client_socket:SetTimeout()
	client_socket:Connect(ip, port)
	
	client_socket:Send(luadata.Encode({USER_JOIN, {name = os.getenv("USERNAME")}}))
end

function system.SendMessage(str)
	if not client_socket:IsValid() then return end
	
	client_socket:Send(str, true)
end

function system.Say(str)
	if not client_socket:IsValid() then return end
	
	client_socket:Send(luadata.Encode({USER_CHAT, str}), true)
end

function system.StartServer(ip, port)
	local server = luasocket.Server()
	server:Host(ip, port)

	server.OnClientConnected = function(self, client, ip, port)
		logf("%s:%s connected", ip, port)

		return true
	end
	
	server.OnClientClosed = function(client)
		local user = users.GetUserFromSocket(client)
		if user:IsValid() then
			logf("user %s (%s:%s) left", user:GetName(), client:GetIP(), client:GetPort())
			
			event.Call("UserLeft", user)
		end
	end
	
	server.OnReceive = function(self, str, client)
		local type, data = unpack(luadata.Decode(str))		
		
		local user = users.CreateUserFromSocket(client, data)
		
		if type == USER_JOIN then
			logf("user %s (%s:%s) joined", user:GetName(), client:GetIP(), client:GetPort())
			
			if event.Call("UserJoin", user) == false then
				client:Remove()
			end
		elseif type == USER_CHAT then
			logf("%s: %s", user:GetName(), data)
			event.Call("UserChat", data)
		else
			logf("unhandled message from user %ss %q", user:GetName(), str)
		end
	end
	
end

return system