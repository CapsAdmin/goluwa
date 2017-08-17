local steam = _G.steam or {}

steam.source2meters = 0.01905

runfile("mount.lua", steam)
runfile("vmt.lua", steam)

function steam.DownloadWorkshop(id, callback)
	sockets.Request({
		method = "POST",
		url = "http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v0001/",
		post_data = "itemcount=1&publishedfileids[0]="..id.."&format=json",
		header = {
			["Content-Type"] = "application/x-www-form-urlencoded"
		},
		callback = function(data)
			local data = serializer.Decode("json", data.content)
			resource.Download(data.response.publishedfiledetails[1].file_url, function(path)
				callback(data, path)
			end)
		end,
	})
end

--runfile("steamworks.lua", steam)

--[[local steamfriends = desire("ffi.steamfriends")

if steamfriends then
	for k,v in pairs(steamfriends) do
		if k ~= "Update" and k ~= "OnChatMessage" then
			steam[k] = v
		end
	end

	event.Timer("steam_friends", 0, 0.2, function()
		steamfriends.Update()
	end)

	function steamfriends.OnChatMessage(sender_steam_id, text, receiver_steam_id)
		event.Call("SteamFriendsMessage", sender_steam_id, text, receiver_steam_id)
	end
end]]

function steam.IsSteamClientAvailible()
	return steamfriends
end

function steam.SteamIDToCommunityID(id)
	if id == "BOT" or id == "NULL" or id == "STEAM_ID_PENDING" or id == "UNKNOWN" then
		return 0
	end

	local parts = id:Split(":")
	local a, b = parts[2], parts[3]

	return tostring("7656119" .. 7960265728 + a + (b*2))
end

function steam.CommunityIDToSteamID(id)
	local s = "76561197960"
	if id:sub(1, #s) ~= s then
		return "UNKNOWN"
	end

	local c = tonumber( id )
	local a = id % 2 == 0 and 0 or 1
	local b = (c - 76561197960265728 - a) / 2

	return "STEAM_0:" .. a .. ":" .. (b+2)
end

return steam
