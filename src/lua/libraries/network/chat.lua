local chat = _G.chat or {}

local function getnick(client)
	return client:IsValid() and client:GetNick() or "server"
end

local enabled = console.CreateVariable("chat_timestamps", true)

function chat.AddTimeStamp(tbl)
	if not enabled:Get() then return {} end

	tbl = tbl or {}

	local time = os.date("*t")

	table.insert(tbl, 1, " - ")
	table.insert(tbl, 1, Color(1, 1, 1))
	table.insert(tbl, 1, ("%.2d:%.2d"):format(time.hour, time.min))
	table.insert(tbl, 1, ColorBytes(118, 170, 217))

	return tbl
end

function chat.GetTimeStamp()
	local time = os.date("*t")

	return ("%.2d:%.2d - "):format(time.hour, time.min)
end

function chat.Append(var, str, skip_log)

	if not str then
		str = var
		var = NULL
	end

	local client = NULL

	if typex(var) == "client" then
		client = var
		var = getnick(var)
	elseif typex(var) == "null" then
		var = "disconnected"
	elseif not network.IsConnected() then
		var = "server"
	else
		var = tostring(var)
	end

	if not skip_log then
		logf("%s%s: %s\n", chat.GetTimeStamp(), var, str)
	end

	event.Call("Chat", var, str, client)
end

if CLIENT then
	message.AddListener("say", function(client, str, seed)
		chat.ClientSay(client, str, seed)
	end)

	function chat.Say(str)
		str = tostring(str)
		if network.IsConnected() then
			message.Send("say", str)
		else
			chat.ClientSay(clients.GetLocalClient(), str)
		end
	end
end

local SEED = 0

function chat.ClientSay(client, str, skip_log, seed)
	seed = seed or SEED

	if event.Call("ClientChat", client, str, seed) ~= false then
		chat.Append(client, str, skip_log)
		if SERVER then message.Broadcast("say", client, str, seed) SEED = SEED + 1 end
	end
end

if SERVER then

	message.AddListener("say", function(client, str)
		chat.ClientSay(client, str)
	end)

	function chat.Say(str)
		str = tostring(str)
		message.Broadcast("say", NULL, str)
		chat.Append(NULL, str)
	end
end

return chat