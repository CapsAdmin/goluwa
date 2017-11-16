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
				vfs.Write(path, assert(serializer.ReadFile("lzma", path)))
				callback(data, path)
			end, nil,nil,nil,nil,"gma")
		end,
	})
end

function steam.DownloadWorkshopCollection(id, callback)
	sockets.Request({
		method = "POST",
		url = "http://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v0001/",
		post_data = "itemcount=1&publishedfileids[0]="..id.."&collectioncount=1&format=json",
		header = {
			["Content-Type"] = "application/x-www-form-urlencoded",
		},
		callback = function(data)
			local data = serializer.Decode("json", data.content)
			for i,v in ipairs(data.response.collectiondetails[1].children) do
				data.response.collectiondetails[1].children[i] = v.publishedfileid
			end
			callback(data.response.collectiondetails[1].children)
		end,
	})
end

local ok, err = pcall(function()
	local steamworks_api = require("steamworks")

	for k,v in pairs(steamworks_api) do
		if not steam[k] then
			steam[k] = v
		end
	end
end)

if not ok then
	llog(err)
end

--[[
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
end
]]

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

steam.appids = {
	[0] = "Base Goldsource Shared Binaries",
	[1] = "Base Goldsource Shared Content",
	[2] = "Base Goldsource Shared Content Localized (deprecated)",
	[6] = "Base Goldsource Low Violence",
	[96] = "Half-Life High Definition Content",
	[10] = "Counter-Strike",
	[11] = "Counter-Strike Base Content",
	[12] = "Counter-Strike French",
	[13] = "Counter-Strike Italian",
	[14] = "Counter-Strike German",
	[15] = "Counter-Strike Spanish",
	[16] = "Counter-Strike Korean (Teen)",
	[17] = "Counter-Strike Simplified Chinese",
	[18] = "Counter-Strike Korean (Adult)",
	[19] = "Counter-Strike Traditional Chinese",
	[20] = "Team Fortress Classic",
	[21] = "Team Fortress Classic Base Content",
	[22] = "Team Fortress Classic French",
	[23] = "Team Fortress Classic Italian",
	[24] = "Team Fortress Classic German",
	[25] = "Team Fortress Classic Spanish",
	[30] = "Day of Defeat",
	[31] = "Day of Defeat Base Content",
	[32] = "Day of Defeat French",
	[33] = "Day of Defeat Italian",
	[34] = "Day of Defeat German",
	[35] = "Day of Defeat Spanish",
	[40] = "Deathmatch Classic",
	[41] = "Deathmatch Classic Base Content",
	[42] = "Deathmatch Classic French",
	[43] = "Deathmatch Classic Italian",
	[44] = "Deathmatch Classic German",
	[45] = "Deathmatch Classic Spanish",
	[50] = "Opposing Force",
	[51] = "Opposing Force Base Content",
	[52] = "Opposing Force German",
	[53] = "Opposing Force French",
	[56] = "Opposing Force Korean",
	[60] = "Ricochet",
	[61] = "Ricochet Base Content",
	[62] = "Ricochet French",
	[63] = "Ricochet Italian",
	[64] = "Ricochet German",
	[65] = "Ricochet Spanish",
	[70] = "Half-Life",
	[72] = "Half-Life French",
	[73] = "Half-Life Italian",
	[74] = "Half-Life German",
	[75] = "Half-Life Spanish",
	[76] = "Half-Life Korean (Teen)",
	[77] = "Half-Life Simplified Chinese",
	[78] = "Half-Life Korean (Adult)",
	[79] = "Half-Life Traditional Chinese",
	[80] = "Condition Zero",
	[81] = "Condition Zero Base Content",
	[82] = "Condition Zero French",
	[83] = "Condition Zero Italian",
	[84] = "Condition Zero German",
	[85] = "Condition Zero Spanish",
	[86] = "Condition Zero Korean (Teen)",
	[87] = "Condition Zero Simplified Chinese",
	[88] = "Condition Zero Korean (Adult)",
	[89] = "Condition Zero Traditional Chinese",
	[95] = "Condition Zero Models",
	[90] = "Counter-Strike 1.6 dedicated server",
	[100] = "Condition Zero Deleted Scenes",
	[101] = "Condition Zero Deleted Scenes Base Content",
	[102] = "Condition Zero Deleted Scenes Models",
	[103] = "Condition Zero Deleted Scenes Sounds",
	[104] = "Condition Zero Deleted Scenes French",
	[105] = "Condition Zero Deleted Scenes Italian",
	[106] = "Condition Zero Deleted Scenes German",
	[107] = "Condition Zero Deleted Scenes Spanish",
	[108] = "Condition Zero Deleted Scenes Korean (Teen)",
	[109] = "Condition Zero Deleted Scenes Simplified Chinese",
	[110] = "Condition Zero Deleted Scenes Korean (Adult)",
	[111] = "Condition Zero Deleted Scenes Traditional Chinese",
	[130] = "Half-Life: Blue Shift",
	[131] = "Half-Life: Blue Shift French",
	[132] = "Half-Life: Blue Shift German",
	[200] = "Base Source Shared",
	[201] = "Source Engine 64bit (for AMD64 CPU/OS)",
	[202] = "Source Init (VAC)",
	[203] = "Source Shared Securom",
	[206] = "Base Source Shared Materials",
	[207] = "Base Source Shared Models",
	[208] = "Base Source Shared Sounds",
	[209] = "Source Low Violence",
	[212] = "Base Source Engine 2",
	[216] = "Source 2007 Binaries",
	[217] = "Multiplayer OB Binaries",
	[220] = "Half-Life 2",
	[221] = "Half-Life 2 Base Content",
	[223] = "Half-Life 2 French",
	[224] = "Half-Life 2 Italian",
	[225] = "Half-Life 2 German",
	[226] = "Half-Life 2 Spanish",
	[227] = "Half-Life 2 Simplified Chinese",
	[228] = "Half-Life 2 Korean (Teen)",
	[229] = "Half-Life 2 Korean (Adult)",
	[230] = "Half-Life 2 Traditional Chinese",
	[231] = "Half-Life 2 Japanese",
	[232] = "Half-Life 2 Russian",
	[233] = "Half-Life 2 Thai",
	[234] = "Half-Life 2 Portuguese",
	[236] = "Half-Life 2 Game Dialog",
	[240] = "Counter-Strike: Source",
	[241] = "Counter-Strike: Source Base Content",
	[242] = "Counter-Strike: Source Shared Content",
	[243] = "Counter-Strike: Source French",
	[244] = "Counter-Strike: Source Italian",
	[245] = "Counter-Strike: Source German",
	[246] = "Counter-Strike: Source Spanish",
	[247] = "Counter-Strike: Source Simplified Chinese",
	[248] = "Counter-Strike: Source Korean (Teen)",
	[249] = "Counter-Strike: Source Korean (Adult)",
	[250] = "Counter-Strike: Source Traditional Chinese",
	[251] = "Counter-Strike: Source Japanese",
	[252] = "Counter-Strike: Source Russian",
	[253] = "Counter-Strike: Source Thai",
	[260] = "Counter-Strike: Source Beta",
	[280] = "Half-Life: Source",
	[281] = "Half-Life: Source Base Content",
	[283] = "Half-Life: Source French",
	[284] = "Half-Life: Source Italian",
	[285] = "Half-Life: Source German",
	[286] = "Half-Life: Source Spanish",
	[287] = "Half-Life: Source Simplified Chinese",
	[288] = "Half-Life: Source Korean (Teen)",
	[289] = "Half-Life: Source Korean (Adult)",
	[290] = "Half-Life: Source Traditional Chinese",
	[291] = "Half-Life: Source Japanese",
	[292] = "Half-Life: Source Russian",
	[293] = "Half-Life: Source Thai",
	[300] = "Day of Defeat: Source",
	[301] = "Day of Defeat: Source Base Content",
	[305] = "Source 2007 Shared Materials",
	[306] = "Source 2007 Shared Models",
	[307] = "Source 2007 Shared Sounds",
	[308] = "Episodic 2007 Shared",
	[312] = "|all_source_engine_paths|hl2",
	[320] = "Half-Life 2: Deathmatch",
	[321] = "Half-Life 2: Deathmatch",
	[340] = "Half-Life 2: Lost Coast",
	[341] = "Half-Life 2: Lost Coast Content",
	[342] = "Half-Life 2: Lost Coast French",
	[343] = "Half-Life 2: Lost Coast German",
	[344] = "Half-Life 2: Lost Coast Italian",
	[345] = "Half-Life 2: Lost Coast Korean (Teen)",
	[346] = "Half-Life 2: Lost Coast Korean (Adult)",
	[347] = "Half-Life 2: Lost Coast Russian",
	[348] = "Half-Life 2: Lost Coast Simplified Chinese",
	[349] = "Half-Life 2: Lost Coast Spanish",
	[350] = "Half-Life 2: Lost Coast Traditional Chinese",
	[360] = "Half-Life Deathmatch: Source",
	[363] = "Half-Life Deathmatch: Source Client",
	[380] = "Half-Life 2: Episode One",
	[381] = "Half-Life 2: Episode One Content",
	[213] = "Half-Life 2: Episode One Shared",
	[400] = "Portal",
	[401] = "Portal Content",
	[405] = "Portal English",
	[420] = "Half-Life 2: Episode Two",
	[421] = "Half-Life 2: Episode Two Content",
	[422] = "Half-Life 2: Episode Two Materials",
	[423] = "Half-Life 2: Episode Two Maps",
	[428] = "Half-Life 2: Episode Two English",
	[440] = "Team Fortress 2",
	[441] = "Team Fortress 2 Content",
	[442] = "Team Fortress 2 Materials",
	[443] = "Team Fortress 2 Client Content",
	[500] = "Left 4 Dead",
	[501] = "Left 4 Dead binaries",
	[502] = "Left 4 Dead base",
	[503] = "Left 4 Dead client binary",
	[504] = "Left 4 Dead sound",
	[550] = "Left 4 Dead 2",
	[590] = "Left 4 Dead 2 Demo",
	[570] = "Dota 2 Beta",
	[571] = "Dota 2 Beta content",
	[572] = "Dota 2 Beta client",
	[573] = "Dota 2 Beta Win32 content",
	[620] = "Portal 2",
	[630] = "Alien Swarm",
	[640] = "Alien Swarm SDK Launcher",
	[730] = "Counter-Strike: Global Offensive",
	[731] = "Counter Strike Global Offensive Beta Common Content",
	[732] = "Counter Strike Global Offensive Beta Win32 Content",
	[870] = "Left 4 Dead 2 Downloadable content",
	[1300] = "SiN Episodes: Emergence",
	[1301] = "SiN Episodes Materials",
	[1302] = "SiN Episodes Models",
	[1303] = "SiN Episodes Sounds",
	[1304] = "SiN Episodes Core",
	[1305] = "SiN Episodes: Emergence Content",
	[1306] = "SiN Episodes: Emergence German",
	[1307] = "SiN Episodes: Emergence German Preload",
	[1315] = "SiN Episodes: Emergence Russian",
	[1308] = "SiN Episodes Arena",
	[1316] = "SiN Episodes Unabridged",
	[1800] = "Counter-Strike: Global Offensive",
	[2100] = "Dark Messiah of Might and Magic",
	[2130] = "Dark Messiah Might and Magic Multi-Player",
	[2400] = "The Ship",
	[2401] = "The Ship",
	[2402] = "The Ship Common",
	[2412] = "The Ship Shared",
	[2430] = "The Ship Tutorial",
	[2406] = "The Ship Tutorial Content",
	[2405] = "The Ship Single Player Content",
	[2450] = "Bloody Good Time",
	[2600] = "Vampire The Masquerade - Bloodlines",
	[4000] = "Garry's Mod",
	[4001] = "Garry's Mod Content",
	[4020] = "Garry's Mod Dedicated Server",
	[17500] = "Zombie Panic! Source",
	[17510] = "Age of Chivalry",
	[17520] = "Synergy",
	[17530] = "D.I.P.R.I.P.",
	[17550] = "Eternal Silence",
	[17570] = "Pirates, Vikings, & Knights II",
	[17580] = "Dystopia",
	[17700] = "Insurgency",
	[17710] = "Nuclear Dawn",
	[17730] = "Smashball",
	[222880] = "Insurgency 2",
	[238430] = "Contagion",
	[294420] = "7 Days to Die Dedicated Server",
	[302550] = "Assetto Corsa Dedicated Server",
	[17515] = "Age of Chivalry Dedicated Server",
	[635] = "Alien Swarm Dedicated Server",
	[34120] = "Aliens vs Predator Dedicated Server",
	[13180] = "America's Army 3 Dedicated Server",
	[13160] = "America's Army 3 Dedicated Server Beta",
	[203300] = "America's Army: Proving Grounds Dedicated Server",
	[376030] = "ARK: Survival Evolved Dedicated Server",
	[445400] = "ARK: Survival of the Fittest Dedicated Server",
	[33905] = "ARMA 2 Dedicated Server",
	[33935] = "Arma 2: Operation Arrowhead Dedicated Server",
	[233780] = "Arma 3 Dedicated Server",
	[346680] = "Black Mesa: Deathmatch Dedicated Server",
	[228780] = "Blade Symphony Dedicated Server",
	[72310] = "Breach Dedicated Server",
	[475370] = "BrainBread 2 Dedicated Server",
	[72780] = "Brink Dedicated Server",
	[332850] = "BlazeRush Dedicated Server",
	[42750] = "Call of Duty: Modern Warfare 3 Dedicated Server",
	[258680] = "Chivalry: Deadliest Warrior Dedicated server",
	[220070] = "Chivalry: Medieval Warfare Dedicated Server",
	[443030] = "Conan Exiles Dedicated Server",
	[238430] = "Contagion Dedicated Server",
	[90] = "Counter-Strike 1.6 Dedicated Server",
	[740] = "Counter-Strike Global Offensive Dedicated Server",
	[90] = "Counter-Strike: Condition Zero Dedicated Server",
	[232330] = "Counter-Strike: Source Dedicated Server",
	[17535] = "D.I.P.R.I.P. Dedicated Server",
	[2145] = "Dark Messiah of Might & Magic Dedicated Server",
	[1290] = "Darkest Hour Dedicated Server",
	[90] = "Day of Defeat Dedicated Server",
	[232290] = "Day of Defeat: Source Dedicated Server",
	[462310] = "Day of Infamy Dedicated Server",
	[90] = "Deathmatch Classic Dedicated Server",
	[70010] = "Dino D-Day Dedicated Server",
	[317800] = "Double Action Dedicated Server",
	[17585] = "Dystopia Dedicated Server",
	[419790] = "Eden Star Dedicated Server",
	[91720] = "E.Y.E - Dedicated Server",
	[460040] = "Empires Dedicated Server",
	[17555] = "Eternal Silence Dedicated Server",
	[295230] = "Fistful of Frags Server",
	[329710] = "Fortress Forever Dedicated Server",
	[4020] = "Garry's Mod Dedicated Server",
	[8730] = "GTR Evolution Demo Dedicated Server",
	[232370] = "Half-Life 2: Deathmatch Dedicated Server",
	[255470] = "Half-Life Deathmatch: Source Dedicated server",
	[90] = "Half-Life Dedicated Server",
	[90] = "Half-Life: Opposing Force Dedicated Server",
	[55280] = "Homefront Dedicated Server",
	[405100] = "Hurtworld dedicated server",
	[237410] = "Insurgency Dedicated Server",
	[17705] = "Insurgency: Modern Infantry Combat Dedicated Server",
	[261140] = "Just Cause 2: Multiplayer Dedicated Server",
	[1273] = "Killing Floor Beta Dedicated Server",
	[215350] = "Killing Floor Dedicated Server Windows",
	[232130] = "Killing Floor 2 Dedicated Server Windows",
	[265360] = "Kingdoms Rise Dedicated Server",
	[319060] = "Lambda Wars Dedicated Server",
	[222860] = "Left 4 Dead 2 Dedicated Server",
	[222840] = "Left 4 Dead Dedicated Server",
	[320850] = "Life is Feudal: Your Own Dedicated Server",
	[63220] = "Monday Night Combat Dedicated Server",
	[4940] = "Natural Selection 2 Dedicated Server",
	[96810] = "Nexuiz Dedicated Server",
	[317670] = "No More Room in Hell Dedicated Server",
	[313600] = "NEOTOKYO Dedicated Server",
	[313900] = "NS2: Combat Dedicated Server",
	[111710] = "Nuclear Dawn Dedicated Server",
	[406800] = "Out of Reach Dedicated Server",
	[230030] = "Painkiller Hell & Damnation Dedicated Server",
	[17575] = "Pirates, Vikings, and Knights II Dedicated Server",
	[224620] = "Primal Carnage Dedicated Server",
	[108600] = "Project Zomboid Dedicated Server",
	[8680] = "RACE 07 Demo - Crowne Plaza Edition Dedicated Server",
	[4270] = "RACE 07 Demo Dedicated Server",
	[8770] = "RACE On - Demo: Dedicated Server",
	[223160] = "Ravaged Dedicated Server",
	[212542] = "Red Orchestra 2 Dedicated Server",
	[223240] = "Red Orchestra Windows Dedicated Server",
	[329740] = "Reflex Dedicated Server",
	[381690] = "Reign Of Kings Dedicated Server",
	[90] = "Ricochet Dedicated Server",
	[258550] = "Rust Dedicated Server",
	[276060] = "Sven Co-op Dedicated Server",
	[41080] = "Serious Sam 3 Dedicated Server",
	[41005] = "Serious Sam HD Dedicated Server",
	[41005] = "Serious Sam Classics: Revolution Dedicated Server",
	[299310] = "Serious Sam HD: The Second Encounter Dedicated Server",
	[266910] = "Sniper Elite 3 Dedicated Server",
	[208050] = "Sniper Elite V2 Dedicated Server",
	[205] = "Source SDK Base 2006 MP Dedicated Server",
	[310] = "Source 2007 Dedicated Server",
	[205] = "Source Dedicated Server",
	[244310] = "Source SDK Base 2013 Dedicated Server",
	[298740] = "Space Engineers Dedicated Server",
	[403240] = "Squad Dedicated Server",
	[211820] = "Starbound Dedicated server",
	[210370] = "Starvoid Dedicated Server",
	[8710] = "STCC - The Game Demo Dedicated Server",
	[17525] = "Synergy Dedicated Server",
	[261020] = "Takedown: Red Sabre Dedicated Server",
	[232250] = "Team Fortress 2 Dedicated Server",
	[90] = "Team Fortress Classic dedicated server",
	[43210] = "The Haunted: Hells Reach Dedicated Server",
	[439660] = "Tower Unite Dedicated server",
	[2403] = "The Ship Dedicated Server",
	[17505] = "Zombie Panic Source Dedicated Server",
	[374980] = "Zombie Grinder Dedicated Server",
	[294420] = "7 Days to Die Dedicated Server",
	[376030] = "ARK: Survival Evolved Dedicated Server",
	[233780] = "Arma 3 Dedicated Server",
	[346680] = "Black Mesa: Deathmatch Dedicated Server",
	[346330] = "BrainBread 2 Dedicated Server",
	[228780] = "Blade Symphony Dedicated Server",
	[332850] = "BlazeRush Dedicated Server",
	[90] = "Counter-Strike Dedicated Server",
	[740] = "Counter-Strike Global Offensive Dedicated Server",
	[90] = "Counter-Strike: Condition Zero Dedicated Server",
	[232330] = "Counter-Strike: Source Dedicated Server",
	[220070] = "Chivalry Medieval Warfare Dedicated Server",
	[312070] = "Dark Horizons: Mechanized Corps Dedicated Server",
	[90] = "Day of Defeat Dedicated Server",
	[232290] = "Day of Defeat: Source Dedicated Server",
	[462310] = "Day of Infamy Dedicated Server",
	[90] = "Deathmatch Classic Dedicated Server",
	[570] = "Dota 2 Dedicated Server",
	[343050] = "Don't Starve Together Dedicated Server",
	[295230] = "Fistful of Frags Server",
	[4020] = "Garry's Mod Dedicated Server",
	[232370] = "Half-Life 2: Deathmatch Dedicated Server",
	[405100] = "Hurtworld dedicated server",
	[255470] = "Half-Life Deathmatch: Source Dedicated server",
	[90] = "Half-Life Dedicated Server",
	[90] = "Half-Life: Opposing Force Server",
	[237410] = "Insurgency 2014 Dedicated Server",
	[17705] = "Insurgency: Modern Infantry Combat Dedicated Server",
	[261140] = "Just Cause 2: Multiplayer - Dedicated Server",
	[215360] = "Killing Floor Dedicated Server - Linux",
	[222860] = "Left 4 Dead 2 Dedicated Server",
	[222840] = "Left 4 Dead Dedicated Server",
	[4940] = "Natural Selection 2 Dedicated Server",
	[313900] = "NS2: Combat Dedicated Server",
	[317670] = "No More Room In Hell Dedicated Server",
	[406800] = "[Out of Reach Dedicated Server",
	[17575] = "Pirates, Vikings, and Knights II Dedicated Server",
	[108600] = "Project Zomboid Dedicated Server",
	[223250] = "Red Orchestra Linux Dedicated Server",
	[90] = "Ricochet Dedicated Server",
	[258550] = "Rust Dedicated Server",
	[41080] = "Serious Sam 3 Dedicated Server",
	[276060] = "Sven Co-op Dedicated Server",
	[205] = "Source SDK Base 2006 MP Dedicated Server",
	[310] = "Source 2007 Dedicated Server",
	[205] = "Source Dedicated Server",
	[244310] = "Source SDK Base 2013 Dedicated Server",
	[403240] = "Squad Dedicated Server",
	[211820] = "Starbound Dedicated server",
	[232250] = "Team Fortress 2 Dedicated Server",
	[90] = "Team Fortress Classic Dedicated Server",
	[2403] = "The Ship Dedicated Server",
	[439660] = "Tower Unite Dedicated Server",
	[105600] = "Terraria Dedicated Server",
	[304930] = "Unturned Dedicated Server",
	[17505] = "Zombie Panic Source Dedicated Server",
}

local name_translate = {
	hl1 = "Half-Life",
	hl2 = "Half-Life 2",
	css = "Counter-Strike: Source",
	cs = "Counter-Strike",
	gmod = "Garry's Mod",
	l4d = "Left 4 Dead",
	l4d2 = "Left 4 Dead 2",
	hl2ep2 = "Half-Life 2: Episode Two",
	ep2 = "Half-Life 2: Episode Two",
	hl2ep1 = "Half-Life 2: Episode One",
	ep1 = "Half-Life 2: Episode One",
	tf2 = "Team Fortress 2",
	hl2lc = "Half-Life 2: Lost Coast",
	dod = "Day of Defeat",
	dods = "Day of Defeat: Source",
	csgo = "Counter-Strike: Global Offensive",
	hl2dm = "Half-Life 2: Deathmatch",
	hl1s = "Half-Life: Source",
	hl1dm = "Deathmatch Classic",
	hl1dms = "Half-Life Deathmatch: Source",
}

function steam.GetAppIdFromName(search)
	for from, to in pairs(name_translate) do
		if search:find("^" .. from .. "%s") or search:find("^" .. from .. "$") then
			search = search:gsub("^" .. from, to)
			break
		end
	end

	if search:endswith("ds") then
		search = search:gsub("ds$", "Dedicated Server")
	end

	local sorted = {}

	for appid, name in pairs(steam.appids) do
		table.insert(sorted, {name = name, appid = appid})
	end

	table.sort(sorted, function(a, b) return #a.name < #b.name end)

	for _, data in ipairs(sorted) do
		if data.name == search then
			return data.appid, data.name
		end
	end

	for _, data in ipairs(sorted) do
		if data.name:compare(search) then
			return data.appid, data.name
		end
	end

	for _, data in ipairs(sorted) do
		if data.name:lower():gsub("%p+", " "):gsub("%s+", " "):compare(search:gsub("%p+", " "):gsub("%s+", " ")) then
			return data.appid, data.name
		end
	end
end

return steam
