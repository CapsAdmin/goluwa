setfenv(1, _G)
chatsounds2 = chatsounds2 or {}
local chatsounds = chatsounds2

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
	chatsounds.GetTime = timer.GetTotalTime
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
			return SoundDuration(self.path) or 0
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
				return tonumber(self.csp.decode_info.frames) / self.csp.decode_info.samplerate
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

function chatsounds.BuildLists()
	local list = {}

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
		local addons = steam.GetGamePath("GarrysMod") .. "garrysmod/addons/"
		local addon_dir = addons .. "chatsounds"

		for dir in vfs.Iterate(addons, nil, true) do
			if dir:lower():find("chatsound") then
				addon_dir = dir
				break
			end
		end

		addon_dir = addon_dir .. "/"

		vfs.Mount(addon_dir)

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
		
				
		vfs.Mount(steam.GetGamePath("left 4 dead") .. "/left4dead/")
		vfs.Mount(steam.GetGamePath("left 4 dead 2") .. "/left4dead2/") 
		
		vfs.Mount(steam.GetGamePath("Half-Life 2") .. "/ep2/ep2_pak_dir.vpk")
		vfs.Mount(steam.GetGamePath("Half-Life 2") .. "/episodic/ep1_pak_dir.vpk")
		vfs.Mount(steam.GetGamePath("Team Fortress 2") .. "tf/tf2_sound_vo_english_dir.vpk")
		vfs.Mount(steam.GetGamePath("Counter-Strike Source") .. "/cstrike/cstrike_pak_dir.vpk")  
		vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_sound_vo_english_dir.vpk") 
		vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_sound_misc_dir.vpk")     
	   
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

					if not gmod then
						path = "sound/" .. path
					end

					local sound = {}

					sound.snd = chatsounds.CreateSound(path, udata)
					sound.duration = (chunk.val.duration or sound.snd:GetDuration())
					sound.trigger = chunk.val.trigger
					sound.modifiers = chunk.modifiers

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
					print("huh")
				end
			else
				print(data, chunk.trigger, chunk.realm)
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

	print("panic!")
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
					if not gmod then
						system.SetWindowTitle(sound.trigger, "chatsounds")
					end
				end
			end

			if sound.started then
				if sound.think then
					sound:think()
				end

				if sound.stop_time < time then
					sound:remove()
					table.remove(track, i)

					if not gmod then
					--	system.SetWindowTitle(nil, "chatsounds")
					end
				end
			end
		end

		if #track == 0 then
			table.remove(chatsounds.active_tracks, i)
		end
	end
end

function chatsounds.Say(ply, str, seed)

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

if not chatsounds.list then
	chatsounds.BuildLists()
end


if gmod then
	hook.Add("Think",1,chatsounds.Update)

	hook.Add("OnPlayerChat",1, function(ply, text)
		--if ply == LocalPlayer() then
		--	chatsounds.Say(ply, text, CurTime())
		--end
	end)
else
	event.AddListener("OnConsolePrint", 1, function(line)
		chatsounds.Say(nil, line, tonumber(crypto.CRC32(line)))
	end)

	event.AddListener("OnUpdate", "lol", chatsounds.Update)
end

 
if true then 
	chatsounds.Say(nil, [[hi cdi%150--4 cdi%130--4 cdi%120--4 cdi%50--4 nice of the princess to invite
	us over for a picnic eh luigi cdi%130--1 cdi%50--1 cdi%180--1 cdi%115--1 cdi%170--1
	i hope she made lots of spaghetti luigi look its from bowser dear pesky plumbers
	the koopalings and i have taken over the mushroom kingdom^1000 the princess is now a permanent
	guest%50 at one of my seven (koopa hotels):pitch(50) i dare you to find her if you can we gotta
	find the princess and you gotta help us if you need instructions on how to get through
	the hotels check out the enclosed instruction book]], 0)
else

chatsounds.Say(caps, [[
	button:choose(6,buttons)%100=0.125
	button:choose(6,buttons)%100=0.125
	button:choose(6,buttons)%50=0.5
	button:choose(6,buttons)%50=0.5
	button:choose(6,buttons)%50=0.35
	button:choose(6,buttons)%50=0.40
	button:choose(6,buttons)%100=0.125
	button:choose(6,buttons)%100=0.125
	button:choose(6,buttons)%50=0.5
	button:choose(6,buttons)%50=0.5
	button:choose(6,buttons)%25=0.35
	button:choose(6,buttons)%50=0.4
	button:choose(6,buttons)%25=0.25
	button:choose(6,buttons)%25=0.25
	button:choose(6,buttons)%25=0.125
	button:choose(6,buttons)%25=0.25
	button:choose(6,buttons)%25=0.125
	button:choose(6,buttons)%50=0.35
	button:choose(6,buttons)%50=0.40
	button:choose(6,buttons)%50=0.40
	button:choose(6,buttons)%25=0.25
	button:choose(6,buttons)%25=0.125
	button:choose(6,buttons)%25=0.25
	button:choose(6,buttons)%25=0.125
	button:choose(6,buttons)%50=0.35
	button:choose(6,buttons)%50=0.40
	button:choose(6,buttons)%50=0.40
	button:choose(6,buttons)%100=0.125
	button:choose(6,buttons)%100=0.125
	button:choose(6,buttons)%50=0.5
	button:choose(6,buttons)%50=0.5
	button:choose(6,buttons)%50=0.35
	button:choose(6,buttons)%50=0.40
	;
	hitbod#1%150=0.25^0
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=0.5
	hitbod#1%150=1
	hitbod#1%150=1
	;
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	spark:choose(3,ambient)%255=0.125^100
	spark:choose(3,ambient)%255=0.125^75
	spark:choose(3,ambient)%255=0.125^50
	spark:choose(3,ambient)%255=0.125^25
	;
	radiorandom#3%100=0.5
	radiorandom#3%100=0.5
	radiorandom#3%100=0.5
	radiorandom#3%100=0.5
	radiorandom#3%100=0.5
	radiorandom#3%100=0.5
	radiorandom#3%100=0.5
	radiorandom#3%100=0.5
	;
	fleshstriderimpactbullet#3%255=0.75^0
	fleshstriderimpactbullet#3%150=1^0
	fleshstriderimpactbullet#3%150=1^0
	fleshstriderimpactbullet#3%150=1^0
	fleshstriderimpactbullet#3%150=1^0
	fleshstriderimpactbullet#3%150=1
	fleshstriderimpactbullet#3%150=1
	fleshstriderimpactbullet#3%150=1
	fleshstriderimpactbullet#3%150=0.125
	fleshstriderimpactbullet#3%150=0.5]], 0)
end