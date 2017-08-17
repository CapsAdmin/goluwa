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
