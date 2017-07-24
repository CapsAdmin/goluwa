commands.Add("say=arg_line", function(text)
	chat.Say(text)
end)

commands.Add("lua_run=arg_line", function(code)
	commands.SetLuaEnvironmentVariable("me", clients.GetLocalClient())
	commands.ExecuteLuaString(code)
end)

commands.Add("lua_open=arg_line", function(path)
	runfile(path)
end)

if SERVER then
	commands.AddServerCommand("lua_run_sv=arg_line", function(client, code)
		logn(client:GetNick(), " ran ", code)
		commands.SetLuaEnvironmentVariable("me", client)
		commands.ExecuteLuaString(code)
	end)

	commands.AddServerCommand("lua_open_sv=arg_line", function(client, path)
		logn(client:GetNick(), " opened ", path)
		runfile(path)
	end)
end

local default_ip = "*"
local default_port = 1234

if CLIENT then
	local ip_cvar = pvars.Setup("cl_ip", default_ip)
	local port_cvar = pvars.Setup("cl_port", default_port)

	local last_ip
	local last_port

	commands.Add("retry", function()
		if last_ip then
			network.Connect(last_ip, last_port)
		end
	end)

	commands.Add("connect=string|nil,number|nil", function(ip, port)
		ip = ip or ip_cvar:Get()
		port = tonumber(port) or port_cvar:Get()

		logf("connecting to %s:%i\n", ip, port)

		last_ip = ip
		last_port = port

		network.Connect(ip, port)
	end)

	commands.Add("disconnect=arg_line", function(line)
		network.Disconnect(line)
	end)
end

if SERVER then
	local ip_cvar = pvars.Setup("sv_ip", default_ip)
	local port_cvar = pvars.Setup("sv_port", default_port)

	commands.Add("host=string|nil,number|nil", function(ip, port)
		ip = ip or ip_cvar:Get()
		port = tonumber(port) or port_cvar:Get()

		logf("hosting at %s:%i\n", ip, port)

		network.Host(ip, port)
	end)
end