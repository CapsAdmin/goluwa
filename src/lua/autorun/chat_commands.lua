commands.Add("l", function(line)
	if NETWORK then commands.SetLuaEnvironmentVariable("me", commands.GetClient()) end
	commands.RunLua(line)
end)

commands.Add("print", function(line)
	if NETWORK then commands.SetLuaEnvironmentVariable("me", commands.GetClient()) end
	commands.RunLua(("print(%s)"):format(line), true)
end)

commands.Add("table", function(line)
	if NETWORK then commands.SetLuaEnvironmentVariable("me", commands.GetClient()) end
	commands.RunLua(("table.print(%s)"):format(line))
	if NETWORK then commands.SetLuaEnvironmentVariable("me", nil) end
end)

commands.Add("rcon", function(line)
	commands.RunString(line)
end)

if not NETWORK then return end

commands.Add("printc", function(line)
	clients.BroadcastLua(("network.PrintOnServer(%s)"):format(line))
end)

commands.Add("lc", function(line)
	clients.BroadcastLua(("commands.SetLuaEnvironmentVariable('me', clients.GetByUniqueID(%q)) commands.RunLua(%q)"):format(commands.GetClient():GetUniqueID(), line))
end)

commands.Add("lm", function(line)
	local client = commands.GetClient()
	client:SendLua(line)
end)

commands.Add("cmd", function(line)
	local client = commands.GetClient()
	client:SendLua(("commands.SetLuaEnvironmentVariable('me', clients.GetByUniqueID(%q)) commands.RunLua(%q)"):format(commands.GetClient():GetUniqueID(), line))
end)

event.AddListener("ClientChat", "chat_commands", function(client, txt)
	if CLIENT and network.IsConnected() then return end

	local cmd, symbol = commands.IsCommandStringValid(txt)

	if cmd and symbol ~= "" then
		commands.SetClient(client)
			commands.RunString(txt, true, true)
		commands.SetClient(NULL)
	end
end)