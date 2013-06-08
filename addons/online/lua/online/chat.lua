chat = {}

local function add_0(n)	return n < 10 and "0"..n or n end
local function getnick(ply)
	return ply:IsValid() and ply:GetNick() or "server"
end

function chat.Append(var, str)	

	if typex(var) == "player" then
		var = getnick(var)
	elseif typex(var) == "null" then
		var = "server"
	else
		var = tostring(var)
	end
	
	local time = os.date("*t")

	logf("%s:%s - %s: %s", add_0(time.hour), add_0(time.min), var, str)
end

if CLIENT then	
	message.AddListener("say", function(ply, str)
		if event.Call("OnPlayerChat", ply, str) ~= false then
			chat.Append(ply, str)
		end
	end)
	
	function chat.Say(str)
		str = tostring(str)		
		message.Send("say", str)
		chat.Append(players.GetLocalPlayer(), str)
	end	
		
	event.AddListener("OnLineEntered", "chat", function(line)
		if not console.RunString(line, true) then
			chat.Say(line)
		end
		
		return false
	end)
end

if SERVER then
	message.AddListener("say", function(ply, str)
		if event.Call("OnPlayerChat", ply, str) ~= false then
			chat.Append(ply, str)
			message.Send("say", message.PlayerFilter():AddAllExcept(ply), ply, str)
		end
	end)

	function chat.Say(str)
		str = tostring(str)		
		message.Broadcast("say", NULL, str)
		chat.Append(NULL, str)
	end
end