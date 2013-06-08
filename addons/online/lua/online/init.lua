include("network.lua")
include("message.lua")
include("easylua.lua")

include("nvars.lua")
include("players.lua")

-- some usage

console.AddCommand("say", function(line)
	chat.Say(line)
end)

console.AddCommand("lua_run", function(line)
	easylua.RunLua(players.GetLocalPlayer(), line, nil, true)
end)

console.AddCommand("lua_open", function(line)
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
	local ip_cvar = console.CreateVariable("cl_ip", default_ip)
	local port_cvar = console.CreateVariable("cl_port", default_port)
		
	console.AddCommand("connect", function(line, ip, port)	
		ip = ip or ip_cvar:Get()
		port = tonumber(port) or port_cvar:Get()
		
		logf("connecting to %s:%i", ip, port)
		
		network.Connect(ip, port)
	end)

	console.AddCommand("disconnect", function(line)	
		network.Disconnect()
	end)
end

if SERVER then
	local ip_cvar = console.CreateVariable("sv_ip", default_ip)
	local port_cvar = console.CreateVariable("sv_port", default_port)
			
	console.AddCommand("host", function(line, ip, port)
		ip = ip or ip_cvar:Get()
		port = tonumber(port) or port_cvar:Get()
		
		logf("hosting at %s:%i", ip, port)
		
		network.Host(ip, port)
	end)
end