include("network.lua")
include("message.lua")
include("easylua.lua")

include("nvars.lua")
include("players.lua")

-- some usage

include("chat.lua")


console.AddCommand("say", function(line)
	chat.Say(line)
end)

console.AddCommand("lua_run", function(line)
	logn(line)
	easylua.RunLua(players.GetLocalPlayer(), line, nil, true)
end)

console.AddCommand("lua_open", function(line)
	logn(line)
	easylua.Start(players.GetLocalPlayer())
		include(line)
	easylua.End()
end)

console.AddServerCommand("lua_run_sv", function(ply, line)
	logn(ply:GetNick(), " ran ", line)
	easylua.RunLua(ply, line, nil, true)
end)

console.AddServerCommand("lua_open_sv", function(ply, line)
	logn(ply:GetNick(), " opened ", line)
	easylua.Start(ply)
		include(line)
	easylua.End()
end)


local default_ip = "localhost"
local default_port = 1234

if CLIENT then
	logf("connecting to %s %i", default_ip, default_port)
	network.Connect(default_ip, default_port)
	
	console.AddCommand("connect", function(line, ip, port)	
		print(line, ip, port, "!?!?!?!?!")
		ip = ip or default_ip
		port = tonumber(port) or default_port
		
		logf("connecting to %s:%i", ip, port)
		
		network.Connect(ip, port)
	end)

	console.AddCommand("disconnect", function(line)	
		network.Disconnect()
	end)
end

if SERVER then
	logf("hosting server at %s %i", default_ip, default_port)
	network.Host(default_ip, default_port)
		
	console.AddCommand("host", function(line, ip, port)
		ip = ip or default_ip
		port = tonumber(port) or default_port
		
		logf("hosting at %s:%i", ip, port)
		
		network.Host(ip, port)
	end)
end