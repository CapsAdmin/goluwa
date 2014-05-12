console.AddCommand("l", function(line)
	easylua.RunLua(SERVER and console.GetServerPlayer() or NULL, line, nil, true)
end)

console.AddCommand("print", function(line)
	easylua.RunLua(SERVER and console.GetServerPlayer() or NULL, ("log(%s)"):format(line), nil, true)
end)

console.AddCommand("table", function(line)
	easylua.RunLua(SERVER and console.GetServerPlayer() or NULL, ("table.print(%s)"):format(line), nil, true)
end)

console.AddCommand("printc", function(line)
	players.BroadcastLua(("easylua.PrintOnServer(%s)"):format(line))
end)

console.AddCommand("lc", function(line)
	players.BroadcastLua(line)
end)

console.AddCommand("lm", function(line)
	local ply = console.GetServerPlayer()
	ply:SendLua(line)
end)

local base_url = "http://translate.google.com/translate_a/t?client=t&sl=%s&tl=%s&ie=UTF-8&oe=UTF-8&q=%s"

console.AddCommand("t", function(line, from, to, str)
	local ply = console.GetServerPlayer()
	local url = base_url:format(from, to, luasocket.EscapeURL(str))
	
	luasocket.Get(url, function(data)
		local out = {translated = "", transliteration = "", from = ""}
		local content = data.content:match(".-%[(%b[])"):sub(2, -2)
		
		for part in content:gmatch("(%b[])") do
			local to, from, trl = part:match("%[(%b\"\"),(%b\"\"),(%b\"\")")
			out.translated = out.translated .. to:sub(2,-2)
			out.from = out.from .. from:sub(2,-2)
			out.transliteration = out.transliteration .. trl:sub(2,-2)
		end
		
		if ply:IsValid() then
			chat.PlayerSay(ply, out.translated)
		end
	end)
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
			console.RunString(cmd .. " " .. line, true, true)
		if SERVER then console.SetServerPlayer(NULL) end
	end
end)