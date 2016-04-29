local steam = _G.steam or {}

include("mdl.lua", steam)
include("vmt.lua", steam)
include("bsp.lua", steam)
include("web_api.lua", steam)
include("server_query.lua", steam)
include("mount.lua", steam)
include("steamworks.lua", steam)

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

function steam.VDFToTable(str, lower_or_modify_keys, preprocess)
	if not str or str == "" then return nil, "data is empty" end
	if lower_or_modify_keys == true then lower_or_modify_keys = string.lower end

	str = str:gsub("http://", "___L_O_L___")
	str = str:gsub("https://", "___L_O_L_2___")

	str = str:gsub("//.-\n", "")

	str = str:gsub("___L_O_L___", "http://")
	str = str:gsub("___L_O_L_2___", "https://")

	str = str:gsub("(%b\"\"%s-)%[$(%S-)%](%s-%b{})", function(start, def, stop)
		if def ~= "WIN32" then
			return ""
		end

		return start .. stop
	end)

	str = str:gsub("(%b\"\"%s-)(%b\"\"%s-)%[$(%S-)%]", function(start, stop, def)
		if def ~= "WIN32" then
			return ""
		end
		return start .. stop
	end)


	local tbl = {}

	for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		tbl[#tbl + 1] = uchar
	end

	local in_string = false
	local capture = {}
	local no_quotes = false

	local out = {}
	local current = out
	local stack = {current}

	local key

	for i = 1, #tbl do
		local char = tbl[i]

		if (char == [["]] or (no_quotes and char:find("%s"))) and tbl[i-1] ~= "\\" then
			if in_string then

				if key then
					if lower_or_modify_keys then
						key = lower_or_modify_keys(key)
					end

					local val = table.concat(capture, "")

					if preprocess and val:find("|") then
						for k, v in pairs(preprocess) do
							val = val:gsub("|" .. k .. "|", v)
						end
					end

					if val:lower() == "false" then
						val = false
					elseif val:lower() ==  "true" then
						val =  true
					elseif val:find("%b{}") then
						local values = val:match("{(.+)}"):trim():split(" ")
						if #values == 3 or #values == 4 then
							val = ColorBytes(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]), values[4] or 255)
						end
					elseif val:find("%b[]") then
						local values = val:match("%[(.+)%]"):trim():split(" ")
						if #values == 3 and tonumber(values[1]) and tonumber(values[2]) and tonumber(values[3]) then
							val = Vec3(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]))
						end
					else
						val = tonumber(val) or val
					end

					if type(current[key]) == "table" then
						table.insert(current[key], val)
					elseif current[key] then
						current[key] = {current[key], val}
					else
						if key:find("+", nil, true) then
							for _, key in ipairs(key:split("+")) do
								if type(current[key]) == "table" then
									table.insert(current[key], val)
								elseif current[key] then
									current[key] = {current[key], val}
								else
									current[key] = val
								end

							end
						else
							current[key] = val
						end
					end

					key = nil
				else
					key = table.concat(capture, "")
				end

				in_string = false
				no_quotes = false
				table.clear(capture)
			else
				in_string = true
			end
		else
			if in_string then
				table.insert(capture, char)
			elseif char == [[{]] then
				if key then
					if lower_or_modify_keys then
						key = lower_or_modify_keys(key)
					end

					table.insert(stack, current)
					current[key] = {}
					current = current[key]
					key = nil
				else
					return nil, "stack imbalance"
				end
			elseif char == [[}]] then
				current = table.remove(stack) or out
			elseif not char:find("%s") then
				in_string = true
				no_quotes = true
				table.insert(capture, char)
			end
		end
	end

	return out
end

return steam
