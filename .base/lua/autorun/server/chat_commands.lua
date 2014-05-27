console.AddCommand("l", function(line)
	easylua.RunLua(console.GetPlayer(), line, nil, true)
end)

console.AddCommand("print", function(line)
	easylua.RunLua(console.GetPlayer(), ("log(%s)"):format(line), nil, true)
end)

console.AddCommand("table", function(line)
	easylua.RunLua(console.GetPlayer(), ("table.print(%s)"):format(line), nil, true)
end)

console.AddCommand("printc", function(line)
	players.BroadcastLua(("easylua.PrintOnServer(%s)"):format(line))
end)

console.AddCommand("lc", function(line)
	players.BroadcastLua(line)
end)

console.AddCommand("lm", function(line)
	local ply = console.GetPlayer()
	ply:SendLua(line)
end)

console.AddCommand("cmd", function(line)
	local ply = console.GetPlayer()
	ply:SendLua(("console.RunString(%q)"):format(line))
end)

event.AddListener("PlayerChat", "chat_commands", function(ply, txt) 
	local cmd, symbol = console.IsValidCommand(txt)
	if cmd and symbol ~= "" then
		console.SetPlayer(ply)
			console.RunString(txt, true, true)
		console.SetPlayer(NULL)
	end
end)