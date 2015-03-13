local steam = ... or steam 

for k, v in pairs(requirew("libraries.ffi.steamworks")) do
	steam[k] = v
end

steam.client = steam.GetFriendObjectFromSteamID(steam.user.GetSteamID())

function steam.GetFriends()
	local out = {}
	
	for i = 0, steam.friends.GetFriendCount(65535) - 1 do
		local id = steam.friends.GetFriendByIndex(i, 65535)
		out[i+1] = steam.GetFriendObjectFromSteamID(id)
	end
	
	return out
end

function steam.FindFriend(nick)
	for k, v in pairs(steam.GetFriends()) do
		if v:GetPersonaName():find(nick) or v.id == nick then
			return v
		end
	end
end

function steam.GetClient()
	return steam.client
end

do	
	local META = steam.steamid_meta
	
	local str = ffi.new("char[2048]", 0)
	local type = ffi.new("SteamWorks_EChatEntryType[1]")
	
	function META:GetChatMessage(message_id)
		local length = steam.friends.GetFriendMessage(self.id, message_id, str, 512, type)
		if length > 0 then
			return str, type[0]
		end
	end
	
	local last = {}
	
	function META:GetLastChatMessage()
		if steam.friends.GetFriendMessage(self.id, 0, str, 512, type) == 0 then return end
		
		local i = last[tostring(self.id)] or 0
		
		while true do
			type[0] = 0
			
			local length = steam.friends.GetFriendMessage(id, i, str, 512, type)
			
			if type[0] == 0 and length == 0 then break end
			
			i = i + 1
		end
		
		last[tostring(self.id)] = i 
		
		return steam.GetChatMessage(self.id, i - 1)
	end
	
	--[[
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
	]]
end