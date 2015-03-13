local steam = ... or steam 

for k, v in pairs(requirew("libraries.ffi.steamworks")) do
	steam[k] = v
end

function steam.GetFriends()
	local out = {}
	
	for i = 0, steam.friends.GetFriendCount(65535) - 1 do
		local id = steam.friends.GetFriendByIndex(i, 65535)
		out[i+1] = {id = id, nick = steam.GetNickFromSteamID(id)}
	end
	
	return out
end

function steam.GetNickFromSteamID(id)
	return ffi.string(steam.friends.GetFriendPersonaName(id))
end

function steam.GetClientSteamID()
	return steamworks.user.GetSteamID()
end

function steam.SendChatMessage(id, msg)
	return steam.friends.ReplyToFriendMessage(id, msg)
end

--void * pvData, int cubData, SteamWorks_EChatEntryType * peChatEntryType

do
	local str = ffi.new("char[512]", 0)
	local type = ffi.new("SteamWorks_EChatEntryType[1]")
	
	function steam.GetChatMessage(id, message_id)
		local length = steam.friends.GetFriendMessage(id, message_id, str, 512, type)
		if length > 0 then
			return ffi.string(str), type[0]
		end
	end
	
	local last = {}
	
	function steam.GetLastChatMessage(id)
		if steam.friends.GetFriendMessage(id, 0, str, 512, type) == 0 then return end
		
		local i = last[tostring(id)] or 0
		
		while true do
			type[0] = 0
			
			local length = steam.friends.GetFriendMessage(id, i, str, 512, type)
			
			if type[0] == 0 and length == 0 then break end
			
			i = i + 1
		end
		
		last[tostring(id)] = i 
		
		return steam.GetChatMessage(id, i - 1)
	end
	
	do return end
	
	local last = {}
	
	event.CreateTimer("steam_friends", 0.25, 0, function()
		for i = 0, steam.friends.GetFriendCount(65535) - 1 do
			local id = steam.friends.GetFriendByIndex(i, 65535)
			local message = steam.GetLastChatMessage(id)
			if message then
				if last[tostring(id)] ~= message then
					event.Call("SteamFriendsMessage", id, message)
				end
				last[tostring(id)] = message
			end
		end
	end)
end