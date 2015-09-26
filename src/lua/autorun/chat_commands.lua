console.AddCommand("l", function(line)
	console.SetLuaEnvironmentVariable("me", console.GetClient())
	console.RunLua(line)
end)

console.AddCommand("print", function(line)
	console.SetLuaEnvironmentVariable("me", console.GetClient())
	console.RunLua(("print(%s)"):format(line), true)
end)

console.AddCommand("table", function(line)
	console.SetLuaEnvironmentVariable("me", console.GetClient())
	console.RunLua(("table.print(%s)"):format(line))
	console.SetLuaEnvironmentVariable("me", nil)
end)

console.AddCommand("printc", function(line)
	clients.BroadcastLua(("network.PrintOnServer(%s)"):format(line))
end)

console.AddCommand("lc", function(line)
	clients.BroadcastLua(("console.SetLuaEnvironmentVariable('me', clients.GetByUniqueID(%q)) console.RunLua(%q)"):format(console.GetClient():GetUniqueID(), line))
end)

console.AddCommand("lm", function(line)
	local client = console.GetClient()
	client:SendLua(line)
end)

console.AddCommand("cmd", function(line)
	local client = console.GetClient()
	client:SendLua(("console.SetLuaEnvironmentVariable('me', clients.GetByUniqueID(%q)) console.RunLua(%q)"):format(console.GetClient():GetUniqueID(), line))
end)

console.AddCommand("rcon", function(line)
	local client = console.GetClient()
	console.RunString(line)
end)

event.AddListener("ClientChat", "chat_commands", function(client, txt)
	if CLIENT and network.IsConnected() then return end

	local cmd, symbol = console.IsValidCommand(txt)

	if cmd and symbol ~= "" then
		console.SetClient(client)
			console.RunString(txt, true, true)
		console.SetClient(NULL)
	end
end)