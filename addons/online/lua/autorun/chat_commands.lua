console.AddCommand("l", function(line)
	easylua.RunLua(SERVER and console.GetServerPlayer() or NULL, line, nil, true)
end)

console.AddCommand("print", function(line)
	easylua.RunLua(SERVER and console.GetServerPlayer() or NULL, ("log(%s)"):format(line), nil, true)
end)

console.AddCommand("printc", function(line)
	players.BroadcastLua(("easylua.PrintOnServer(%s)"):format(line))
end)

console.AddCommand("lc", function(line)
	players.BroadcastLua(line)
end)

local prefix = "[!|/|%.]" 

event.AddListener("OnPlayerChat", "chat_commands", function(ply, txt) 
	if txt:sub(1, 1):find(prefix) then
		local cmd = txt:match(prefix.."(.-) ") or txt:match(prefix.."(.+)") or ""
		local line = txt:match(prefix..".- (.+)") or ""
		
		cmd = cmd:lower()
				
		-- when calling server commands, the player is null
		-- but with console.SetServerPlayer(ply) we can change that
		if SERVER then console.SetServerPlayer(ply) end
			console.RunString(cmd .. " " .. line)
		if SERVER then console.SetServerPlayer(NULL) end
	end
end)