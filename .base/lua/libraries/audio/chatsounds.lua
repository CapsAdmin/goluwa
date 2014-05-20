local chatsounds = _G.chatsounds or {}

local realm_patterns = {
	".+chatsounds/autoadd/(.-)/",
	"sound/player/survivor/voice/(.-)/",
	"sound/player/vo/(.-)/",
	
	".+/(al)_[^/]+",
	".+/(kl)_[^/]+",
	".+/(br)_[^/]+",
	".+/(ba)_[^/]+",
	".+/(eli)_[^/]+",
	".+/(cit)_[^/]+",
		
	"sound/vo/([^/]-)_[^/]+",
	
	"sound/vo/(wheatley)/[^/]+",
	"sound/vo/(mvm_.-)_[^/]+",
	"sound/(ui)/[^/]+",
	"sound/vo/(glados)/[^/]+",
	
	"sound/npc/(.-)/",
	"sound/vo/npc/(.-)/",
	"sound/vo/(.-)/",
	"sound/player/(.-)/voice/",
	"sound/player/(.-)/",
	"sound/mvm/(.-)/",
	"sound/(bot)/",
	"sound/(music)/",
	"sound/(physics)/",
	"sound/hl1/(fvox)/",
	"sound/(weapons)/",
	"sound/(commentary)/",
	"sound/ambient/levels/(.-)/",
	"sound/ambient/(.-)/",	
}

local realm_translate = {
	breen = "hl2_breen",
	
	al = "hl2_alyx",
	kl = "hl2_kleiner",
	br = "hl2_breen",
	ba = "hl2_barney",
	gman = "hl2_gman",
	cit = "hl2_citizen",
	male01 = "hl2_male",
	female01 = "hl2_female",
	
	biker = "l4d_francis",
	teengirl = "l4d_zoey",
	gambler = "l4d_nick",
	producer = "l4d_rochelle",	
	manager = "l4d_louis",
	mechanic = "l4d_ellis",
	namvet = "l4d_bill",
	churchguy = "l4d2_churchguy",
	virgil = "l4d2_virgil",
	coach = "l4d2_coach",
	
	scout = "tf2_scout",
	soldier = "tf2_soldier",
	pyro = "tf2_pyro",
	demoman = "tf2_demoman",
	heavy = "tf2_heavy",
	engineer = "tf2_engineer",
	medic = "tf2_medic",
	sniper = "tf2_sniper",
	announcer = "tf2_announcer",
}


local voice_actors = {
	breen = "robert_culp",
	
	al = "merle_dandridge",
	kl = "hal_robins",
	br = "robert_culp",
	ba = "michael_shapiro_barney",
	gman = "michael_shapiro_gman",
	cit = "hl2_citizen",
	male01 = "adam_baldwin",
	female01 = "mary_kae_irvin",
	
	biker = "vince_valenzuela",
	teengirl = "jen_taylor",
	gambler = "hugh_dillon",
	producer = "rochelle_aytes",	
	manager = "earl_alexander",
	mechanic = "jesy_mckinney",
	namvet = "jim_french",
	
	scout = "nathan_vetterlein",
	churchguy = "nathan_vetterlein",
	virgil = "randall_newsome",
	soldier = "rick_may",
	pyro = "dennis_bateman",
	demoman = "gary_schwartz_demoman",
	heavy = "gary_schwartz_heavy",
	engineer = "grant_goodeve",
	medic = "robin_atkin_downes",
	sniper = "john_patrick_lowrie",
	announcer = "ellen_mclain",
}

local function realm_from_path(path)
	
	for k,v in ipairs(realm_patterns) do
		local realm = path:match(v)
		if realm then
			realm = realm:lower():gsub("%s+", "_")
			return (realm_translate[realm] or realm), v
		end
	end
	
	return "misc", ""
end	


-- utilities

local print = print

if gmod and epoe then print = epoe.Print end

local function getchartype(char)

	if char:find("%p") and char ~= "_" then
		return char
	elseif char:find("%s") then
		return "space"
	elseif char:find("%a") or char == "_" or char:find("%d") then
		return "letters"
	end

	return "unknown"
end

local table_clear

if table.clear then
	table_clear = table.clear
else
	table_clear = function(tbl) for k,v in pairs(tbl) do tbl[k] = nil end end
end

local function table_random(tbl)
	local key = math.random(1, table.count(tbl))
	local i = 1
	for _key, _val in pairs(tbl) do
		if i == key then
			return _val, _key
		end
		i = i + 1
	end
end

local function table_fixindices(tbl)
	local temp = {}
	local i = 1
	for k, v in pairs(tbl) do
		temp[i] = v
		tbl[k] = nil
		i = i + 1
	end

	for k, v in ipairs(temp) do
		tbl[k] = v
	end
end

local function math_clamp(self, min, max)
	return math.max(math.min(self, max),min)
end

if gmod then
	chatsounds.GetTime = RealTime
else
	chatsounds.GetTime = timer.GetElapsedTime
end

local choose_realm

local function dump_script(out)
	for i, data in pairs(out) do
		if data.type == "matched" then
			local sounds = choose_realm(data.val)

			if sounds then
				local str = ""
				if data.modifiers then
					for k,v in pairs(data.modifiers) do str = str .. v.mod .. ", " end
				end
				print(i, data.type, data.val.trigger, "\t\t\t", str)
			end
		elseif data.type == "modifier" then
			print(i, data.type, data.mod .. "(" .. table.concat(data.args, ", ") .. ")")
		else
			print(i, data.type, data.val)
		end
	end
end
   
 
-- sound utils
if gmod then
	function chatsounds.CreateSound(path, udata)
		local self = {csp = CreateSound(udata or LocalPlayer(), path), udata = udata, path = path}

		function self:Play()
			self.csp:Play()
		end

		function self:Stop()
			self.csp:Stop()
		end

		function self:SetPitch(pitch, time)
			pitch = math.clamp(tonumber(pitch) or 100, 0, 255)

			self.csp:ChangePitch(pitch, time)
		end

		function self:SetVolume(volume, time)
			volume = math.clamp(tonumber(volume) or 100, 0, 100)

			if self.udata == LocalPlayer() then
				volume = volume / 2
			end

			self.csp:ChangeVolume(volume / 100, time)
		end

		function self:SetDSP(i)
			LocalPlayer():SetDSP(math_clamp(tonumber(i) or 0, 0, 128))
		end

		function self:GetDuration()
			return SoundDuration(self.path) or 2
		end

		return self
	end
else        
	function chatsounds.CreateSound(path, udata)
		local self = {csp = Sound(path), udata = udata, path = path}

		function self:Play()
			self.csp:Play()
		end

		function self:Stop()
			self.csp:Stop()
			self.csp:Remove()
		end

		function self:SetPitch(pitch, time)
			self.csp:SetPitch(pitch / 100)
		end

		function self:SetVolume(volume, time)
			self.csp:SetGain(volume / 100)
		end

		function self:SetDSP(i)
			logn("setdsp ", i)
		end

		function self:GetDuration()
			if self.csp.decode_info then
				if self.csp.decode_info.duration then
					return self.csp.decode_info.duration
				elseif self.csp.decode_info.frames then
					return tonumber(self.csp.decode_info.frames) / self.csp.decode_info.samplerate
				end
			end
			return 0
		end

		return self
	end
end

-- modifiiers

chatsounds.Modifiers = {
	dsp = {
		start = function(self, dsp)
			self.snd:SetDSP(dsp)
		end,

		stop = function(self, dsp)
			self.snd:SetDSP(0)
		end,
	},
	cutoff = {
		args = {
			function(stop_percent) return tonumber(stop_percent) or 100 end
		},

		init = function(self, stop_percent)
			self.duration = self.duration * (stop_percent / 100)
		end,
	},
	duration = {
		init = function(self, time, um)

			-- legacy modifier workaround..
			-- =0.125
			if um then
				time = tonumber(time .. "." .. um)
			end

			self.duration = time
		end,
	},
	pitch = {
		args = {
			[2] = function(time) return tonumber(time) or 0 end
		},
		init = function(self, pitch, time)
			self.duration = self.duration / (pitch / 100)
			self.duration = self.duration + time
		end,

		think = function(self, pitch, time)
			if self.snd then
				self.snd:SetPitch(pitch, time)
			end
		end,
	},
	volume = {
		args = {
			[2] = function(time) return time or 0 end
		},
		think = function(self, volume, time)
			if self.snd then
				self.snd:SetVolume(volume, time)
			end
		end,
	}
}

chatsounds.LegacyModifiers = {
	["%"] = "pitch",
	["^"] = "volume",
	["&"] = "dsp",
	["-%-"] = "cutoff",
	["#"] = "choose",
	["="] = "duration",
}

do -- list parsing
	function chatsounds.MountPaks()
		local addons = steam.GetGamePath("GarrysMod") .. "garrysmod/addons/"

		for path in vfs.Iterate(addons, nil, true) do 
			if vfs.IsDir(path) and path:lower():find("chatsound") then 
				vfs.Mount(path)
			end 
		end
		
		vfs.Mount(steam.GetGamePath("Team Fortress 2") .. "/tf/tf2_misc_dir.vpk")
		vfs.Mount(steam.GetGamePath("Team Fortress 2") .. "/tf/tf2_sound_misc_dir.vpk")
		vfs.Mount(steam.GetGamePath("Team Fortress 2") .. "/tf/tf2_sound_vo_english_dir.vpk")
	
		vfs.Mount(steam.GetGamePath("Left 4 Dead") .. "/left4dead/")
		vfs.Mount(steam.GetGamePath("Left 4 Dead") .. "/left4dead_dlc3/")
		vfs.Mount(steam.GetGamePath("Left 4 Dead") .. "/left4dead/pak01_dir.vpk")
		vfs.Mount(steam.GetGamePath("Left 4 Dead") .. "/left4dead_dlc3/pak01_dir.vpk")
		
		vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "/left4dead2/") 
		vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "/left4dead2_dlc1/") 
		vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "/left4dead2_dlc2/") 
		vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "/left4dead2_dlc3/") 
		
		vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "/left4dead2/pak01_dir.vpk") 
		vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "/left4dead2_dlc1/pak01_dir.vpk") 
		vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "/left4dead2_dlc2/pak01_dir.vpk") 
		vfs.Mount(steam.GetGamePath("Left 4 Dead 2") .. "/left4dead2_dlc3/pak01_dir.vpk") 

		vfs.Mount(steam.GetGamePath("Counter-Strike Global Offensive") .. "/csgo/pak01_dir.vpk")
		vfs.Mount(steam.GetGamePath("Counter-Strike Global Offensive") .. "/csgo/")
		
		vfs.Mount(steam.GetGamePath("Portal 2") .. "/portal2/")
		vfs.Mount(steam.GetGamePath("Portal 2") .. "/portal2_dlc1/")
		vfs.Mount(steam.GetGamePath("Portal 2") .. "/portal2/pak01_dir.vpk")
		
		vfs.Mount(steam.GetGamePath("Portal") .. "/portal/")
		vfs.Mount(steam.GetGamePath("Portal") .. "/portal/portal_pak_dir.vpk")
		
		vfs.Mount(steam.GetGamePath("Half-Life 2") .. "/ep2/ep2_pak_dir.vpk")
		vfs.Mount(steam.GetGamePath("Half-Life 2") .. "/ep2/")
		
		vfs.Mount(steam.GetGamePath("Half-Life 2") .. "/episodic/ep1_pak_dir.vpk")
		vfs.Mount(steam.GetGamePath("Half-Life 2") .. "/episodic/")
		
		vfs.Mount(steam.GetGamePath("Counter-Strike Source") .. "/cstrike/")  
		vfs.Mount(steam.GetGamePath("Counter-Strike Source") .. "/cstrike/cstrike_pak_dir.vpk")  

		vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/") 
		vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_sound_vo_english_dir.vpk") 
		vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_sound_misc_dir.vpk")     
	end
		
	function chatsounds.GetSoundData(snd)
		local out = {}
		local content = snd:match(".+VDAT.-(VERSION.+)")
		out.plaintext = content:match("PLAINTEXT%s-{%s+(.-)%s-}")
		
		out.words = {}
		for word, start, stop, phonemes in content:match("WORDS%s-{(.+)"):gmatch("WORD%s-(%S-)%s-(%S-)%s-(%S-)%s-{(.-)}") do
			local tbl = {}
			for line in (phonemes .. "\n"):gmatch("(.-)\n") do
				local d = (line .. " "):explode(" ")
				if #d > 2 then
					table.insert(tbl, {str = d[2], start = tonumber(d[3]), stop = tonumber(d[4]), num1 = tonumber(d[1]),  num2 = tonumber(d[5])})
				end
			end
			table.insert(out.words, {word = word, start = tonumber(start), stop = tonumber(stop), phonemes = tbl})
		end
		
		return out
	end 
	
	local function clean_sentence(sentence)

		sentence = sentence:lower()
		sentence = sentence:gsub("_", " ")
		sentence = sentence:gsub("%p", "")
		sentence = sentence:gsub("%s+", " ")
		
		return sentence
	end
	
	function chatsounds.BuildSoundInfo()
		local out = {}

		local co = coroutine.create(function()
			local sound_info = {}
			for path in vfs.Iterate("scripts/", nil, true) do
				if path:find("_sounds") and not path:find("manifest") and path:find("%.txt") then
					local t, err = steam.VDFToTable(vfs.Read(path))
					if t then
						table.merge(sound_info, t)
					else
						print(path, err)
					end
					coroutine.yield("reading /scripts/*")
				end 
			end
			
			for sound_name, info in pairs(sound_info) do
				--if type(info) == "table" then 
					sound_info[sound_name] = nil
					sound_info[sound_name:lower()] = info
					info.real_name = sound_name
				--else
				--	sound_info[sound_name] = nil
				--end
			end
			
			local captions = {}
			for path in vfs.Iterate("resource/", nil, true) do
				if path:find("english") and path:find("%.txt") then
				
				
					local str = vfs.Read(path)
					-- stupid hack because some caption files are encoded weirdly which would break lua patterns
					local tbl = {}
					for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
						if uchar ~= "\0" then
							tbl[#tbl + 1] = uchar
						end
					end
					str = table.concat(tbl, "")	
					str = str:gsub("//.-\n", "")
					-- stupid hack
										
					local tbl = steam.VDFToTable(str)
					table.merge(captions, tbl)
					coroutine.yield("reading /resource/*")
				end 
			end
			
			if captions.lang then				
				local found = 0
				local lost = 0
				
				for sound_name, text in pairs(captions.lang.Tokens) do
					sound_name = sound_name:lower()
					
					if sound_info[sound_name] then
						if type(text) == "table" then
							text = text[1]
						end
						
						local data = {}
											
						text = text:gsub("(<.->)", function(tag)
							data.tags = data.tags or {}
							table.insert(data.tags, tag)
							
							return ""
						end)
						
						if data.tags then
							for i, tag in ipairs(data.tags) do
								local key, args = tag:match("<(.-):(.+)>")
								if key and args then
									args = args:explode(",")
									for k,v in pairs(args) do args[k] = tonumber(v) or v end
								else
									key = tag:match("<(.-)>")
								end
								
								data.tags[i] = {type = key, args = args}
							end
						end
						
						local name, rest = text:match("(.-):(.+)")
						
						if name then
							data.name = name
							data.text = rest
						else
							data.text = text
						end
						
						data.text = data.text:trim()
						
						sound_info[sound_name].caption = data
						found = found + 1
					else
						lost = lost + 1
					end
				end
				
				logf("%i captions matched sound info but %i captions are unknown\n", found, lost)
			else
				logn("no captions found!")
			end
			
			for sound_name, info in pairs(sound_info) do
				local paths
				
				if info.rndwave then
					if type(info.rndwave.wave) == "table" then
						paths = info.rndwave.wave
					else
						paths = {info.rndwave.wave} -- ugh
					end
				elseif type(info.wave) == "table" then
					paths = info.wave
				else
					paths = {info.wave} -- ugh
				end
									
				for k, v in pairs(paths) do
					v = v:lower()
					v = v:gsub("\\", "/")
					
					local start_symbol
					
					if v:sub(1, 1):find("%p") then
						start_symbol, v = v:match("(%p+)(.+)")
					end
					
					v = "sound/" .. v
					
					out[v] = out[v] or {}
					
					out[v].name = info.real_name
					out[v].path_symbol = start_symbol
					
					table.merge(out[v], info)
					
					if type(out[v].pitch) == "string" and out[v].pitch:find(",") then 
						out[v].pitch = out[v].pitch:gsub("%s+", ""):explode(",")
						for k,n in pairs(out[v].pitch) do out[v].pitch[k] = tonumber(n) or n end
					end
					
					out[v].operator_stacks = nil
					out[v].real_name = nil
					out[v].rndwave = nil
					out[v].wave = nil
				end
				
				coroutine.yield("building table")
			end
			
			local list = chatsounds.ListToTable(vfs.Read("data/chatsounds/game.list"))
				
			logn("translating game.list")
			local found = 0
			for realm, list in pairs(list) do
				for trigger, sounds in pairs(list) do	
					for i, data in ipairs(sounds) do
						local info = out[data.path:lower()]
						if info and info.caption then
							local text = clean_sentence(info.caption.text)
							if text ~= "" then
								list[trigger] = nil
								list[text] = sounds
								found = found + 1
							end
						end
					end
				end
			end
			logf("translated %i paths\n", found)
			
			logn("saving game list")
			local game_list = chatsounds.TableToList(list)				
			vfs.Write("data/chatsounds/game.list", game_list)				
			vfs.Write("data/chatsounds/game.tree", serializer.Encode("msgpack", chatsounds.TableToTree(list)), "b")

			
			logn("finished building the sound info table")
			logf("found sound info for %i paths\n", table.count(out))
			
			vfs.Write("data/chatsounds/sound_info.table", serializer.Encode("msgpack", out))
			vfs.Write("data/chatsounds/sound_info.lua", serializer.Encode("luadata", out))
			
			chatsounds.sound_info = out
		end) 
		
		event.AddListener("Update", "chatsounds_soundinfo", function()
			local ok, msg = coroutine.resume(co)		
			
			if ok then 
				if wait(1) then
					print(msg)
				end			
			elseif msg == "cannot resume dead coroutine" then
				return e.EVENT_DESTROY
			else
				error(msg) 
			end
		end)
	end
	
	function chatsounds.BuildListFromMountedContent()
		
		window.Close()
		chatsounds.MountPaks()
		
		local found = {}
			
		local function callback()
			vfs.Search("sound/", {"wav", "ogg", "mp3"}, function(path) 			
				local sentence
				
				if path:find("%.wav") then
					local ok, data = pcall(vfs.Read, path, "b")
					sentence = data:match("PLAINTEXT%s{%s(.-)%s}%s")
				end
				
				if not sentence or sentence == "" then
					sentence = path:match(".+/(.+)%.")
				end
				
				sentence = clean_sentence(sentence)
				
				if sentence == "" then
					sentence = path:match(".+/(.+)%.")
					sentence = clean_sentence(sentence)
				end
				
				local realm = realm_from_path(path)
				
				if path:find("chatsounds/autoadd/", nil, true) then
					realm = "custom_sounds_" .. realm
				end
				
				found[realm] = found[realm] or {}
				
				table.insert(found[realm], path:lower() .. "=" .. sentence)
				
				coroutine.yield()
			end)
		end
			   
		local co = coroutine.create(function() return xpcall(callback, system.OnError) end)

		event.AddListener("Update", "chatsounds_search", function()
			local ok, err = coroutine.resume(co)
			
			if wait(1) then
				print(table.count(found) .. " realms found")
				local i = 0
				for k,v in pairs(found) do for k,v in pairs(v) do i = i + 1 end end
				
				print(i .. " sentences found")
			end
			
			if wait(10) or not ok then
				print("saving..")
				local custom = {}
				local game = {}
				
				for realm, sentences in pairs(found) do
					if realm:find("custom_sounds_") then
						realm = realm:gsub("custom_sounds_", "")
						table.insert(custom, "realm="..realm .."\n")
						table.insert(custom, table.concat(sentences, "\n") .. "\n")
					else
						table.insert(game, "realm="..realm .. "\n")
						table.insert(game, table.concat(sentences, "\n") .. "\n")
					end
				end
				
				local game_list = table.concat(game, "")
				local custom_list = table.concat(custom, "")
				
				vfs.Write("data/chatsounds/game.list", game_list)
				vfs.Write("data/chatsounds/custom.list", custom_list)
				
				vfs.Write("data/chatsounds/game.tree", serializer.Encode("msgpack", chatsounds.TableToTree(chatsounds.ListToTable(game_list))), "b")
				vfs.Write("data/chatsounds/custom.tree", serializer.Encode("msgpack", chatsounds.TableToTree(chatsounds.ListToTable(custom_list))), "b")
			end
			
			if not ok then
				if err == "cannot resume dead coroutine" then 
					chatsounds.BuildSoundInfo()
					print("done!")					
					return e.EVENT_DESTROY
				else
					error(err) 
				end
			end
		end) 
	end
		
	function chatsounds.ListToTable(data)
		local list = {}
		local realm = "misc"
		for path, trigger in data:gmatch("(.-)=(.-)\n") do
			if path == "realm" then
				realm = trigger
			else
				if path:find("sound/chatsounds/autoadd/", nil, true) then
					trigger = path:match("sound/chatsounds/autoadd/[^/]-/(.-)/[^/]-%.") or trigger
				end
				
				if not list[realm] then
					list[realm] = {}
				end
				
				if not list[realm][trigger] then
					list[realm][trigger] = {}
				end
				
				table.insert(list[realm][trigger], {path = path})
			end
		end
		return list
	end
	
	function chatsounds.TableToList(tbl)
		local str = {}
		for realm, list in pairs(tbl) do
			str[#str + 1] = "realm="..realm
			local done = {}
			for trigger, sounds in pairs(list) do
				for i, data in ipairs(sounds) do
					local val = data.path .. "=" .. trigger
					if not done[val] then
						str[#str + 1] = val
						done[val] = true
					end
				end
			end
		end
		return table.concat(str, "\n")
	end
		
	function chatsounds.TableToTree(tbl)
		local tree = {}
		
		for realm, list in pairs(tbl) do
			for trigger, sounds in pairs(list) do
				local words = {}
				
				for word in (trigger .. " "):gmatch("(.-)%s+") do
					table.insert(words, word)
				end

				local prev = tree
				local max = #words
				
				for i, word in ipairs(words) do
					if not prev[word] then 
						prev[word] = {} 
					end

					if i == max then
						prev[word].SOUND_FOUND = true
						prev[word].LEVEL = max
						prev[word].data = prev[word].data or {trigger = trigger, realms = {}}
						if prev[word].data.realms then
							prev[word].data.realms[realm] = {sounds = sounds, realm = realm}
						else
							print(word) -- ???
						end
					end

					prev = prev[word]
				end
			end
		end

		return tree
	end
		
	function chatsounds.BuildTreeFromCache(list_data, tree_data)
		local list, tree
		
		if not tree_data then
			list = chatsounds.ListToTable(list_data)
			tree = chatsounds.TableToTree(list)
		else
			list = chatsounds.ListToTable(list_data)
			tree = serializer.Decode("msgpack", tree_data)
		end
		
		chatsounds.list = chatsounds.list or {}
		
		for k,v in pairs(list) do
			chatsounds.list[k] = v
		end
		
		chatsounds.tree = chatsounds.tree or {}
		table.merge(chatsounds.tree, tree)
	end 	
	
	function chatsounds.BuildTree(name)
		local list = "data/chatsounds/"..name..".list"
		local tree = "data/chatsounds/"..name..".tree"
		
		if vfs.Exists(list) and vfs.Exists(tree) then
			chatsounds.BuildTreeFromCache(vfs.Read(list), vfs.Read(tree, "b"))
		elseif vfs.Exists(list) then
			chatsounds.BuildTreeFromCache(vfs.Read(list))
		else
			chatsounds.BuildTreeFromAddon()
		end
	end

	function chatsounds.BuildTreeFromAddon()
		if gmod then
			local nosend = "chatsounds/lists_nosend/"
			local send = "chatsounds/lists_send/"

			local function parse(path)
				local func = CompileFile(path)
				local realm = path:match(".+/(.-)%.lua")

				local L = list[realm] or {}

				setfenv(func, {c = {StartList = function() end, EndList = function() end}, L = L})
				func()

				list[realm] = L
			end

			local _, folders = file.Find(send .. "*", "LUA")

			for _, dir in pairs(folders) do
				for _, path in pairs(file.Find(send .. dir .. "/*", "LUA")) do
					parse(send .. dir .. "/" .. path)
				end
			end

			for _, path in pairs(file.Find(nosend .. "*", "LUA")) do
				parse(nosend .. path)
			end
		else
			chatsounds.MountPaks()
			
			local addons = steam.GetGamePath("GarrysMod") .. "garrysmod/addons/"
			local addon_dir = addons .. "chatsounds"

			for dir in vfs.Iterate(addons, nil, true) do
				if dir:lower():find("chatsound") then
					addon_dir = dir
					break
				end
			end
			
			addon_dir = addon_dir .. "/"

			local nosend = addon_dir .. "lua/chatsounds/lists_nosend/"
			local send = addon_dir .. "lua/chatsounds/lists_send/"

			local function parse(path)
				local func = assert(loadfile(path))
				local realm = path:match(".+/(.-)%.lua")

				local L = list[realm] or {}

				setfenv(func, {c = {StartList = function() end, EndList = function() end}, L = L})
				func()

				list[realm] = L
			end 
			  
			for dir in vfs.Iterate(send, nil, true) do
				for path in vfs.Iterate(dir .. "/", nil, true) do
					parse(path)
				end
			end

			for path in vfs.Iterate(nosend, nil, true) do
				parse(path)
			end
		end

		local tree = {}

		for realm, sounds in pairs(list) do
			if realm ~= "" then
				for trigger, data in pairs(sounds) do
					trigger = trigger:gsub("%p", "")

					local words = {}
					for word in (trigger .. " "):gmatch("(.-)%s+") do
						table.insert(words, word)
					end

					local prev = tree
					local max = #words
					for i, word in ipairs(words) do
						if not prev[word] then prev[word] = {} end

						if i == max then
							prev[word].SOUND_FOUND = true
							prev[word].LEVEL = max
							prev[word].data = prev[word].data or {trigger = trigger, realms = {}}

							prev[word].data.realms[realm] = {sounds = data, realm = realm}
						end

						prev = prev[word]
					end
				end
			end
		end

		chatsounds.list = list
		chatsounds.tree = tree
	end
end

do
	local function preprocess(str)
		-- old style pitch to new

		for old, new in pairs(chatsounds.LegacyModifiers) do
			str = str:gsub("%"..old.."([%d%.]+)", function(str) str = str:gsub("%.", ",") return ":"..new.."("..str..")" end)
		end

		str = str:lower()
		str = str:gsub("'", "")

		return str
	end

	local function build_word_list(str)
		local words = {}
		local temp = {}
		local last = getchartype(str:sub(1,1))

		for i = 1, #str + 1 do
			local char = str:sub(i,i)
			local type = getchartype(char)

			if type ~= "space" then

				if type ~= last then
					local word = table.concat(temp, "")
					if #word > 0 then
						table.insert(words, table.concat(temp, ""))
						table_clear(temp)
					end
				end

				table.insert(temp, char)
			end

			last = type
		end

		return words
	end

	local function find_modifiers(words)

		local count = #words

		for i = 1, 1000 do
			local word = words[i]

			if word == ":" then

				local args = {}
				local mod = words[i + 1]

				words[i] = nil
				words[i+2] = nil
				words[i+1] = nil

				for i2 = i + 3, i + 10 do
					local word = words[i2]
					words[i2] = nil

					if word ~= ")" then
						if word ~= "," then
							table.insert(args, word)
						end
					else
						break
					end
				end

				table_fixindices(words)
				table.insert(words, i, {type = "modifier", mod = mod, args = args})

				i = 1
			end

			if i > count+1 then break end
		end

		return words
	end

	local function find_sounds(words)
		local count = #words

		local prev = chatsounds.tree
		local i = 1

		local out = {}
		local found = {}
		
		local function hmm(word)
			prev = chatsounds.tree

			for offset, node in ipairs(found) do
				offset = i - offset
				if node.data.SOUND_FOUND then
					table.insert(out, offset, {type = "matched", val = node.data.data})
					break
				elseif prev[node.word] and prev[node.word].SOUND_FOUND then
					table.insert(out, offset, {type = "matched", val = prev[node.word].data})
				else
					if type(node.word) == "string" then
						table.insert(out, offset, {type = "unmatched", val = node.word})
					else
						table.insert(out, offset, node.word)
					end
				end
			end

			if prev[word] and prev[word].SOUND_FOUND then
				i = i - 1
			elseif type(word) == "string" then
				table.insert(out, i-1, {type = "unmatched", val = word})
			end

			table_clear(found)
		end

		for _ = 1, 5000 do
			local word = words[i]

			if not word or type(word) == "string" then
				if prev[word] then
					prev = prev[word]
					table.insert(found, 1, {data = prev, word = word})
				else
					hmm(word)
				end
			elseif type(word) == "table" then
				table.insert(out, i-1, word)
				hmm(word)

				--table.insert(found, 1, {data = prev, word = word})
			end

			i = i + 1

			if i > count+1 then break end
		end

		return out
	end

	local function apply_modifiers(script)
		local i = 1

		for _ = 1, 1000 do
			local chunk = script[i]

			if not chunk or i > #script+1 then break end

			if chunk.type == "modifier" then
				if script[i - 1] then
					if script[i - 1].val == ")" then
						local i2 = i - 2

						for _ = 1, 100 do
							local chunk2 = script[i2]

							if chunk2 and chunk2.val ~= "(" then
								if chunk2.type == "matched" then
									chunk2.modifiers = chunk2.modifiers or {}
									table.insert(chunk2.modifiers, chunk)
								end
							else
								break
							end

							i2 = i2 - 1
						end

					elseif script[i - 1].type == "matched" then
						script[i - 1].modifiers = script[i - 1].modifiers or {}
						table.insert(script[i - 1].modifiers, chunk)
					end

					script[i] = nil

					if script[i + 1] and script[i + 1].type == "modifier" then
						i = i - 1
					end

					table_fixindices(script)
				end
			end

			i = i + 1
		end

		table_fixindices(script)

		return script
	end

	chatsounds.script_cache = {}

	function chatsounds.GetScript(str)

		if chatsounds.script_cache[str] then
			return chatsounds.script_cache[str]
		end

		str = preprocess(str)

		local words = build_word_list(str)

		if str:find(":") then
			words = find_modifiers(words)
		end

		local script = find_sounds(words)

		script = apply_modifiers(script)


		--chatsounds.script_cache[str] = script

		return script
	end

end

local last_realm

function choose_realm(data)
	local sounds

	if last_realm and data.realms[last_realm] then
		sounds = data[last_realm]
	end

	if not sounds then
		sounds = table_random(data.realms)
		last_realm = sounds.realm
	end

	return sounds
end

function chatsounds.PlayScript(script, udata)

	local sounds = {}

	for i, chunk in pairs(script) do
		if chunk.type == "matched" then
			local data = choose_realm(chunk.val)
			if data then
				local info

				if chunk.modifiers then
					for k, v in pairs(chunk.modifiers) do
						if v.mod == "choose" then
							if chunk.val.realms[v.args[2]] then
								data = chunk.val.realms[v.args[2]]
							end

							info = data.sounds[math_clamp(tonumber(v.args[1]) or 1, 1, #data.sounds)]
							break
						end
					end
				end

				if not info then
					info = table_random(data.sounds)
				end

				local path = info.path

				if path then
					local sound = {}

					sound.snd = chatsounds.CreateSound(path, udata)
					sound.duration = (chunk.val.duration or sound.snd:GetDuration())
					sound.trigger = chunk.val.trigger
					sound.modifiers = chunk.modifiers
					
					--print("DURATION", path, sound.duration)

					sound.play = function(self)
						if self.modifiers then
							for i, data in pairs(self.modifiers) do
								local mod = chatsounds.Modifiers[data.mod]
								if mod and mod.start then
									mod.start(self, unpack(data.args))
								end
							end
						end

						self.snd:Play()
						
						--print("START", path)
					end

					sound.remove = function(self)
						if self.modifiers then
							for i, data in pairs(self.modifiers) do
								local mod = chatsounds.Modifiers[data.mod]
								if mod and mod.stop then
									mod.stop(self, unpack(data.args))
								end
							end
						end

						self.snd:Stop()
						
						--print("STOP", path)
					end

					if sound.modifiers then
						-- if args is defined use it to default and clamp the arguments
						for i, data in pairs(sound.modifiers) do
							local mod = chatsounds.Modifiers[data.mod]
							if mod and mod.args then
								for i, func in pairs(mod.args) do
									data.args[i] = func(data.args[i])
								end
							end
						end

						sound.think = function(self)
							for i, data in pairs(self.modifiers) do
								local mod = chatsounds.Modifiers[data.mod]
								if mod and mod.think then
									mod.think(self, unpack(data.args))
								end
							end
						end
					end

					table.insert(sounds, sound)
				else
					--print("huh")
				end
			else
			--	print(data, chunk.trigger, chunk.realm)
			end
		end
	end

	local duration = 0
	local track = {}
	local time = chatsounds.GetTime()

	for i, sound in ipairs(sounds) do

		-- let it be able to think once first so we can modify duration and such when changing pitch
		if sound.think then
			sound:think()
		end

		-- init modifiers
		if sound.modifiers then
			for mod, data in pairs(sound.modifiers) do
				local mod = chatsounds.Modifiers[data.mod]
				if mod and mod.init then
					mod.init(sound, unpack(data.args))
				end
			end
		end

		-- this is when the sound starts
		sound.start_time = time + duration
		duration = duration + sound.duration
		sound.stop_time = time + duration

		table.insert(track, sound)
	end

	table.insert(chatsounds.active_tracks, track)
end

function chatsounds.Panic()
	for i, track in pairs(chatsounds.active_tracks) do
		for i, sound in pairs(track) do
			sound:remove()
		end
	end

	chatsounds.active_tracks = {}

	if gmod then
		RunConsoleCommand("stopsound")
	end
end

if chatsounds.active_tracks then
	chatsounds.Panic()
end

chatsounds.active_tracks = {}

function chatsounds.Update()
	local time = chatsounds.GetTime()

	for i, track in pairs(chatsounds.active_tracks) do
		for i, sound in pairs(track) do
			if sound.start_time < time then
				if not sound.started then
					sound:play()
					sound.started = true
				end
			end

			if sound.started then
				if sound.think then
					sound:think()
				end

				if sound.stop_time < time then
					sound:remove()
					table.remove(track, i)
				end
			end
		end

		if #track == 0 then
			table.remove(chatsounds.active_tracks, i)
		end
	end
end

function chatsounds.Say(ply, str, seed)
	if type(ply) == "string" then
		seed = str
		str = ply
		ply = nil
	end
	
	str = str:lower()

	if str == "sh" or (str:find("sh%s") and not str:find("%Ssh")) or (str:find("%ssh") and not str:find("sh%S")) then
		chatsounds.Panic()
	end

	if str:find(";") then
		str = str .. ";"
		for line in str:gmatch("(.-);") do
			chatsounds.Say(ply, line, seed)
		end
		return
	end

	if seed then math.randomseed(seed) end

	local script = chatsounds.GetScript(str)
	chatsounds.PlayScript(script, ply)
end

function chatsounds.Initialize()
	if chatsounds.tree then return end
	
	chatsounds.MountPaks()
	
	chatsounds.BuildTree("game")
	chatsounds.BuildTree("custom")
	
	if autocomplete then
		local temp = {}

		for realm, sounds in pairs(chatsounds.list) do
			for key, val in pairs(sounds) do
				temp[key] = true
			end
		end

		local list = {}

		for k,v in pairs(temp) do
			table.insert(list, k)
		end
		
		table.sort(list, function(a, b) return #a < #b end)

		autocomplete.AddList("chatsounds", list)
	end
	
	event.AddListener("Update", "chatsounds", chatsounds.Update)
end

return chatsounds