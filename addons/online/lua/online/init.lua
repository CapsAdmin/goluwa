include("network.lua")
include("message.lua")

include("nvars.lua")
include("players.lua")

-- some usage

include("chat.lua")

local default_ip = "localhost"
local default_port = 1234

if CLIENT then
	logf("connecting to %s %i", default_ip, default_port)
	network.Connect(default_ip, default_port)
	
	console.AddCommand("connect", function(client, line, ip, port)			
		network.Connect(ip or default_ip, port or default_port)
	end)

	console.AddCommand("disconnect", function(client, line)	
		network.Disconnect()
	end)
end

if SERVER then
	logf("hosting server at %s %i", default_ip, default_port)
	network.Host(default_ip, default_port)
		
	console.AddCommand("host", function(client, line, ip, port)
		network.Host(ip or default_ip, port or default_port)
	end)
end
