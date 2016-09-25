local client = irc_socket or sockets.CreateIRCClient()
client.debug = true
client:SetNick(clients.GetLocalClient():GetNick() .. "_GoluwaClient")

local players = {}

function client:OnMessage(msg, nick)
	if nick == client:GetNick() then return end
	msg = msg:gsub("\15", "")
	msg = msg:gsub("\3%d%d", "") -- color code

	if nick:find("meta%d") then
		nick, msg = msg:match("#%d (.-): (.+)")
	end

	if not nick then return end

	local ply = players[nick]

	if not ply then
		ply = clients.Create(nick)
		ply:SetNick(nick)
		players[nick] = ply

		event.Call("ClientEntered", ply)
	end

	ply.last_said = system.GetElapsedTime()

	chat.ClientSay(ply, msg)

	for key, ply in pairs(players) do
		if (ply.last_said + 60) < system.GetElapsedTime() then
			event.Call("ClientLeft", ply:GetNick(), ply:GetNick(), "timed out", ply)
			players[key] = nil
		end
	end
end

if not irc_socket then
	client:Connect("threekelv.in")
	event.Delay(0.5, function() client:Join("#metastruct") chatsounds.Initialize() end)
end

event.AddListener("ClientChat", "metastruct_chat", function(client, msg)
	if client == clients.GetLocalClient() then
		irc_socket:Send("PRIVMSG #metastruct :" .. msg)
	end
end)

irc_socket = client