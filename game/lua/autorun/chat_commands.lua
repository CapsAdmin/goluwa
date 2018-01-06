commands.Add("l=arg_line", function(code)
	if NETWORK then commands.SetLuaEnvironmentVariable("me", commands.GetClient()) end
	commands.ExecuteLuaString(code)
end)

commands.Add("print=arg_line", function(code)
	if NETWORK then commands.SetLuaEnvironmentVariable("me", commands.GetClient()) end
	commands.ExecuteLuaString(("print(%s)"):format(code), true)
end)

commands.Add("table=arg_line", function(code)
	if NETWORK then commands.SetLuaEnvironmentVariable("me", commands.GetClient()) end
	commands.ExecuteLuaString(("table.print(%s)"):format(code))
	if NETWORK then commands.SetLuaEnvironmentVariable("me", nil) end
end)

commands.Add("rcon=arg_line", function(str)
	commands.RunString(str)
end)

if not NETWORK then return end

commands.Add("printc=arg_line", function(code)
	clients.BroadcastLua(("network.PrintOnServer(%s)"):format(code))
end)

commands.Add("lc=arg_line", function(code)
	clients.BroadcastLua(("commands.SetLuaEnvironmentVariable('me', clients.GetByUniqueID(%q)) commands.ExecuteLuaString(%q)"):format(commands.GetClient():GetUniqueID(), code))
end)

commands.Add("lm=arg_line", function(code)
	local client = commands.GetClient()
	client:SendLua(code)
end)

commands.Add("cmd=arg_line", function(code)
	local client = commands.GetClient()
	client:SendLua(("commands.SetLuaEnvironmentVariable('me', clients.GetByUniqueID(%q)) commands.ExecuteLuaString(%q)"):format(commands.GetClient():GetUniqueID(), code))
end)

event.AddListener("ClientChat", "chat_commands", function(client, txt)
	if CLIENT and network.IsConnected() then return end

	local cmd, symbol = commands.IsCommandStringValid(txt)

	if cmd and symbol ~= "" and cmd ~= "" then
		commands.SetClient(client)
			commands.RunString(txt, true, true)
		commands.SetClient(NULL)
	end
end)