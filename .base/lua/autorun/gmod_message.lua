if not CAPSADMIN then return end

local allowed_ips = {
	["88.191.104.162"] = true, 
	["88.191.109.120"] = true
}

local meta_ip = "88.191.104.162"
local meta_port = 27122

intermsg.StartServer("*", 1234, function(event, ip, port, data)
	if event == "message" and allowed_ips[ip] then
		meta_ip = ip
		 
		local ok, err = console.RunString(data)
		
		if not ok then 
			logn(err) 
		end 
	end
end, "udp")

event.AddListener("OnConsolePrint", "gmod", function(str)
	if meta_ip then
		intermsg.Send(meta_ip, meta_port, str, "udp") 
	end
end) 

-- cause the online addon isnt mounted unless we have a client context
dofile("../../../../online/lua/autorun/client/chathud.lua")

function gmchat(nick, str)
	--print(nick, ": ", str)
	
	if chathud and chathud.AddText then 
	
		local num = 0 
		nick:gsub("(.)", function(s) num = (num + s:byte())%255 end)
		num = num / 255
	
		chathud.AddText(HSVToColor(num), nick, Color(1,1,1,1), ": ", str)
	end	
end