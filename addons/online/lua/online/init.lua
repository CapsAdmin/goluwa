include("network.lua")
include("message.lua")

include("nvars.lua")
include("users.lua")

local default_ip = "localhost"
local default_port = 1234

console.AddCommand("host", function(client, line, ip, port)
	network.Host(ip or default_ip, port or default_port)
end)

console.AddCommand("connect", function(client, line, ip, port)			
	network.Connect(ip or default_ip, port or default_port)
end)

console.AddCommand("disconnect", function(client, line)	
	network.Disconnect()
end)

console.AddCommand("net_test", function()
	mmyy.CreateLuaEnvironment("server"):Send("console.RunString('host')")
	mmyy.CreateLuaEnvironment("client 1"):Send("console.RunString('connect')")
	mmyy.CreateLuaEnvironment("client 2"):Send("console.RunString('connect')")
end)	

event.AddListener("OnLineEntered", "online", function(line)
	if current_ip then
		--network.SendCommand(current_ip, current_port, line)
	end
end)

if CLIENT then
	network.Connect(default_ip, default_port)
end

if SERVER then
	network.Host(default_ip, default_port)
end