chat = {}

local function getnick(ply)
	return ply:IsValid() and ply:GetNick() or "server"
end

local enabled = console.CreateVariable("chat_timestamps", true)

function chat.AddTimeStamp(tbl)
	if not enabled:Get() then return end
	
	tbl = tbl or {}
	
	local time = os.date("*t")
	
	table.insert(tbl, 1, " - ")
	table.insert(tbl, 1, Color(255, 255, 255))
	table.insert(tbl, 1, ("%.2d:%.2d"):format(time.hour, time.min))
	table.insert(tbl, 1, Color(118, 170, 217))

	return tbl
end

function chat.GetTimeStamp()
	local time = os.date("*t")

	return ("%.2d:%.2d - "):format(time.hour, time.min)
end

function chat.Append(var, str)

	if chathud then
		local tbl = chat.AddTimeStamp()
		table.insert(tbl, var)
		table.insert(tbl, Color(255, 255, 255, 255))
		table.insert(tbl, ": ")
		table.insert(tbl, str)
		chathud.AddText(unpack(tbl))
	end

	if typex(var) == "player" then
		var = getnick(var)
	elseif typex(var) == "null" then
		var = "server"
	else
		var = tostring(var)
	end	

	logf("%s%s: %s", chat.GetTimeStamp(), var, str)
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
		if not network.IsStarted() then return end
	
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