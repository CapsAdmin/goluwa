console.AddCommand("l", function(line)
	easylua.RunLua(console.GetClient(), line, nil, true)
end)

console.AddCommand("print", function(line)
	easylua.RunLua(console.GetClient(), ("log(%s)"):format(line), nil, true)
end)

console.AddCommand("table", function(line)
	easylua.RunLua(console.GetClient(), ("table.print(%s)"):format(line), nil, true)
end)

console.AddCommand("printc", function(line)
	clients.BroadcastLua(("easylua.PrintOnServer(%s)"):format(line))
end)

console.AddCommand("lc", function(line)
	clients.BroadcastLua(line)
end)

console.AddCommand("lm", function(line)
	local client = console.GetClient()
	client:SendLua(line)
end)

console.AddCommand("cmd", function(line)
	local client = console.GetClient()
	client:SendLua(("console.RunString(%q)"):format(line))
end)

console.AddCommand("rcon", function(line)
	local client = console.GetClient()
	console.RunString(line)
end)

event.AddListener("ClientChat", "chat_commands", function(client, txt) 
	local cmd, symbol = console.IsValidCommand(txt)
	if cmd and symbol ~= "" then
		console.SetClient(client)
			console.RunString(txt, true, true)
		console.SetClient(NULL)
	end
end)