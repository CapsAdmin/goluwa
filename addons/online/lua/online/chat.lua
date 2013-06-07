chat = {}

local function add_0(n)	return n < 10 and "0"..n or n end

function chat.Append(nick, str)
	local time = os.date("*t")

	logf("%s:%s - %s: %s", add_0(time.hour), add_0(time.min), nick, str)
end

if CLIENT then	
	message.AddListener("say", function(nick, str)
		chat.Append(nick, str)
	end)
	
	function chat.Say(str)
		str = tostring(str)
		local nick = os.getenv("USERNAME")
		
		message.Send("say", nick, str)
		chat.Append(nick, str)
	end	
		
	event.AddListener("OnLineEntered", "chat", function(line)
		chat.Say(line)
		
		return false
	end)
end

if SERVER then
	message.AddListener("say", function(ply, name, str)
		chat.Append(name, str)
		message.Send("say", message.PlayerFilter():AddAllExcept(ply), name, str)
	end)

	function chat.Say(str)
		str = tostring(str)
		local nick = "server"
		
		message.Broadcast("say", nick, str)
		chat.Append(nick, str)
	end
end