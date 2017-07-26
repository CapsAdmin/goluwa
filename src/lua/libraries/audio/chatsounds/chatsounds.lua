local chatsounds = _G.chatsounds or {}

runfile("list_parsing.lua", chatsounds)

chatsounds.max_iterations = 1000

-- utilities
local choose_realm

local function dump_script(out)
	for i, data in pairs(out) do
		if data.type == "matched" then
			local sounds = choose_realm(data.val)

			if sounds then
				local str = ""
				if data.modifiers then
					for k,v in pairs(data.modifiers) do
						str = str .. v.mod .. "(" .. table.concat(v.args, ", ") .. ")"
						if k ~= #data.modifiers then
							str = str .. ", "
						end
					end
				end
				logf("[%i] %s: %q modifiers: %s\n", i, data.type, data.val.trigger, str)
			end
		elseif data.type == "modifier" then
			logf("[%i] %s: %s(%s)\n", i, data.type, data.mod, table.concat(data.args, ", "))
		else
			logf("[%i] %s: %s\n", i, data.type, data.val)
		end
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

			self.duration = time or self.duration
			self.dont_stop = true
		end,
	},
	pitch = {
		init = function(self, pitch, endpitch)
			pitch = tonumber(pitch) or 100
			endpitch = tonumber(endpitch) or pitch

			self.duration = self.duration / (math.abs(pitch) / 100)
			self.endpitch = endpitch
		end,

		think = function(self, pitch)
			local f = (system.GetElapsedTime() - self.start_time) / self.duration
			local pitch = math.lerp(f, pitch, self.endpitch) / 100

			self.snd:SetPitch(pitch)
		end,
	},
	volume = {
		init = function(self, volume, endvolume)
			volume = tonumber(volume) or 100
			endvolume = tonumber(endvolume) or volume

			self.endvolume = endvolume
		end,

		think = function(self, vol)
			local f = (system.GetElapsedTime() - self.start_time) / self.duration
			local vol = math.lerp(f, vol, self.endvolume) / 100

			self.snd:SetGain(vol)
		end,
	},
	realm = {
		pre_init = function(realm)
			chatsounds.last_realm = realm
		end,
	}
}

chatsounds.LegacyModifiers = {
	["%%"] = "pitch",
	["%"] = "pitch",
	["^^"] = "volume",
	["^"] = "volume",
	["&"] = "dsp",
	["--"] = "cutoff",
	["#"] = "choose",
	["="] = "duration",
	["*"] = "repeat",
}

local modifiers = {}
for k,v in pairs(chatsounds.LegacyModifiers) do
	k = k:gsub("%p", "%%%1")
	table.insert(modifiers, {mod = k, func = v})
end
table.sort(modifiers, function(a, b) return #a.mod > #b.mod end)

do
	local function preprocess(str)
		-- old style pitch to new
		-- hello%50 > hello:pitch(50)

		if chatsounds.debug then
			logn(">>> ", str)
		end

		for _, val in ipairs(modifiers) do
			str = str:gsub(val.mod.."([%d%.]+)", function(str) str = str:gsub("%.", ",") return ":"..val.func.."("..str..")" end)
		end

		str = str:lower()
		str = str:gsub("'", "")

		if chatsounds.debug then
			logn(">>> ", str)
		end

		return str
	end

	local function build_word_list(str)
		local words = {}
		local temp = {}
		local last = string.getchartype(str:sub(1,1))

		for i = 1, #str + 1 do
			local char = str:sub(i,i)
			local next = str:sub(i+1, i+1)
			local type = string.getchartype(char)

			if type ~= "space" then

				-- 0.1234
				if last == "digit" and char == "." or (char == "-" and next and string.getchartype(next) == "digit") then
					type = "digit"
				end

				if type == "digit" and last == "letters" then type = "letters" end

				if type ~= last or char == ":" or char == ")" or char == "(" then
					local word = table.concat(temp, "")
					if #word > 0 then
						table.insert(words, table.concat(temp, ""))
						table.clear(temp)
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

		for i = 1, chatsounds.max_iterations do
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

				table.fixindices(words)
				table.insert(words, i, {type = "modifier", mod = mod, args = args})

				i = 1
			end

			if i > count+1 then break end
		end

		return words
	end

	local function find_sounds(words)
		local word_count = #words
		local node = chatsounds.tree
		local reached_end = false
		local out = {}
		local matched = {}

		local i = 1

		for _ = 1, chatsounds.max_iterations do
			local word = words[i]

			if type(word) == "string" then
				if node[word] then
					node = node[word]
					table.insert(matched, {node = node, word = word})
				else
					if #matched == 0 then
						table.insert(out, {type = "unmatched", val = word})

						if word == ")" then
							for i = i + 1, word_count do
								if type(words[i]) ~= "table" then break end
								table.insert(out, words[i])
							end
						end
					else
						reached_end = true
					end
				end
			else
				reached_end = true
			end

			if reached_end then
				reached_end = false
				local found

				for match_i = #matched, 1, -1 do
					local info = matched[match_i]

					i = i - 1

					if info.node.SOUND_DATA then
						found = info
						break
					end
				end

				if found then
					table.insert(out, {type = "matched", val = found.node.SOUND_DATA})

					for i2 = i + 1, word_count do
						local mod = words[i2]
						if type(mod) ~= "table" then break end
						table.insert(out, mod)
					end
				else
					for _, info in ipairs(matched) do
						table.insert(out, {type = "unmatched", val = info.word})
					end
				end

				node = chatsounds.tree
				table.clear(matched)
			end

			i = i + 1

			if i > word_count + 1 then
				break
			end
		end

		return out
	end

	local function apply_modifiers(script)
		local i = 1

		for _ = 1, chatsounds.max_iterations do
			local chunk = script[i]

			if not chunk or i > #script+1 then break end

			if chunk.type == "matched" and script[i + 1] and script[i + 1].type == "modifier" then
				chunk.modifiers = chunk.modifiers or {}
				for offset = 1, 100 do
					local mod = script[i + offset]

					if not mod or mod.type ~= "modifier" then
						break
					end
					if mod.mod ~= "repeat" then
						table.insert(chunk.modifiers, mod)
					end
				end
			elseif chunk.val == "(" then
				local start = i + 1
				local stop

				for offset = 1, 100 do
					local chunk2 = script[i + offset]
					if not chunk2 then break end

					if chunk2.val == ")" then
						stop = i + offset - 1
						break
					end
				end

				if stop then
					for offset = 2, 100 do
						local mod = script[stop + offset]

						if not mod or mod.type ~= "modifier" then
							break
						end

						for i = start, stop do
							script[i].modifiers = script[i].modifiers or {}
							if mod.mod ~= "repeat" then
								table.insert(script[i].modifiers, mod)
							end
						end
					end
				end
			end

			i = i + 1
		end

		for i = 1, #script do
			local chunk = script[i]
			if chunk.type == "modifier" and chunk.mod ~= "repeat" then
				script[i] = nil
			end
		end
		table.fixindices(script)

		local i = 1
		for _ = 1, chatsounds.max_iterations do
			local chunk = script[i]

			if chunk and chunk.type == "modifier" and chunk.mod == "repeat" then
				table.remove(script, i)

				local repetitions = tonumber(chunk.args[1]) - 1

				if script[i - 1] then
					if script[i - 1].type == "matched" then
						for _ = 1, repetitions do
							table.insert(script, i, table.copy(script[i - 1]))
						end
					elseif script[i - 1].val == ")" then
						local temp = {}
						for offset = 1, 10 do
							local chunk = script[i - offset - 1]
							if not chunk or chunk.val == "(" then
								break
							end
							table.insert(temp, chunk)
						end
						for _ = 1, repetitions do
							for _, chunk in ipairs(temp ) do
								table.insert(script, i - 1, table.copy(chunk))
							end
						end
					end
				end
			end
			i = i + 1
		end

		return script
	end

	chatsounds.script_cache = utility.CreateWeakTable()

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

function choose_realm(data)
	local sounds

	if chatsounds.last_realm and data.realms[chatsounds.last_realm] and chatsounds.last_trigger ~= data.trigger then
		sounds = data.realms[chatsounds.last_realm]
	end

	if not sounds then
		sounds = table.random(data.realms)
		chatsounds.last_realm = sounds.realm
	end

	return sounds
end

chatsounds.queue_calc = {}

function chatsounds.PlayScript(script)

	local sounds = {}

	for _, chunk in pairs(script) do
		if chunk.type == "matched" then

			if chunk.modifiers then
				for _, data in pairs(chunk.modifiers) do
					local mod = chatsounds.Modifiers[data.mod]
					if mod and mod.args then
						for i, func in pairs(mod.args) do
							data.args[i] = func(data.args[i])
						end
					end
				end
			end

			if chunk.modifiers then
				for mod, data in pairs(chunk.modifiers) do
					mod = chatsounds.Modifiers[data.mod]
					if mod and mod.pre_init then
						mod.pre_init(unpack(data.args))
					end
				end
			end

			local data = choose_realm(chunk.val)

			if data then
				local info

				if chunk.modifiers then
					for _, v in pairs(chunk.modifiers) do
						if v.mod == "choose" then
							if chunk.val.realms[v.args[2]] then
								data = chunk.val.realms[v.args[2]]
								info = data.sounds[math.clamp(tonumber(v.args[1]) or 1, 1, #data.sounds)]
							else
								local temp = {}
								for realm, data in pairs(chunk.val.realms) do
									for _, sound in pairs(data.sounds) do
										table.insert(temp, {sound = sound, realm = realm})
									end
								end
								-- needs to be sorted in some way so it will be equal for all clients
								table.sort(temp, function(a,b) return a.sound.path > b.sound.path end)
								local res = temp[math.clamp(tonumber(v.args[1]) or 1, 1, #temp)]
								info = res.sound
								chatsounds.last_realm = res.realm
							end

							break
						end
					end
				end

				if not info then
					local temp = {}
					for realm, data in pairs(chunk.val.realms) do
						if not chatsounds.last_realm or chatsounds.last_realm == realm then
							for _, sound in pairs(data.sounds) do
								table.insert(temp, {sound = sound, realm = realm})
							end
						end
					end
					-- needs to be sorted in some way so it will be equal for all clients
					table.sort(temp, function(a,b) return a.sound.path > b.sound.path end)
					local res = table.random(temp)
					info = res.sound
					chatsounds.last_realm = res.realm
				end

				local path = info.path

				if path then
					local sound = {}

					sound.snd = audio.CreateSource(path)
					sound.duration = chunk.val.duration
					sound.trigger = chunk.val.trigger
					sound.modifiers = chunk.modifiers

					--print("DURATION", path, sound.duration)

					sound.play = function(self)
						if self.modifiers then
							for _, data in pairs(self.modifiers) do
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
							for _, data in pairs(self.modifiers) do
								local mod = chatsounds.Modifiers[data.mod]
								if mod and mod.stop then
									mod.stop(self, unpack(data.args))
								end
							end
						end

						if not self.dont_stop then
							self.snd:Stop()
						end
					end

					if sound.modifiers then
						sound.think = function(self)
							for _, data in pairs(self.modifiers) do
								local mod = chatsounds.Modifiers[data.mod]
								if mod and mod.think then
									mod.think(self, unpack(data.args))
								end
							end
						end
					end

					table.insert(sounds, sound)

					chatsounds.last_trigger = chunk.val.trigger
				else
					--print("huh")
				end
			else
			--	print(data, chunk.trigger, chunk.realm)
			end
		end
	end


	table.insert(chatsounds.queue_calc, function()
		for _, sound in ipairs(sounds) do
			if not sound.snd:IsReady() then
				return
			end
		end

		local duration = 0
		local track = {}
		local time = system.GetElapsedTime()

		for _, sound in ipairs(sounds) do

			sound.duration = sound.duration or sound.snd:GetDuration()

			-- init modifiers
			if sound.modifiers then
				for mod, data in pairs(sound.modifiers) do
					mod = chatsounds.Modifiers[data.mod]
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

		return true
	end)

	chatsounds.last_realm = nil
end

function chatsounds.Panic()
	for _, track in pairs(chatsounds.active_tracks) do
		for _, sound in pairs(track) do
			sound:remove()
		end
	end

	chatsounds.active_tracks = {}
end

if chatsounds.active_tracks then
	chatsounds.Panic()
end

chatsounds.active_tracks = {}

function chatsounds.Update()
	if chatsounds.queue_calc[1] then
		for i,v in ipairs(chatsounds.queue_calc) do
			if v() == true then
				table.remove(chatsounds.queue_calc, i)
				break
			end
		end
	end

	local time = system.GetElapsedTime()

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

function chatsounds.Say(str, seed)
	if not chatsounds.tree then return end

	str = str:lower()

	if str == "sh" or (str:find("sh%s") and not str:find("%Ssh")) or (str:find("%ssh") and not str:find("sh%S")) then
		chatsounds.Panic()
	end

	if str:find(";") then
		str = str .. ";"
		for line in str:gmatch("(.-);") do
			chatsounds.Say(line, seed)
		end
		return
	end

	str = str:gsub("<rep=(%d+)>(.-)</rep>", function(count, str)
		count = math.min(math.max(tonumber(count), 1), 500)

		if #str:rep(count):gsub("<(.-)=(.-)>", ""):gsub("</(.-)>", ""):gsub("%^%d","") > 500 then
			return "rep limit reached"
		end

		return str:rep(count)
	end)


	if seed then math.randomseed(seed) end

	local script = chatsounds.GetScript(str)
	if chatsounds.debug then dump_script(script) end
	chatsounds.PlayScript(script)
end

function chatsounds.GetLists()
	local out = {}
	for _, v in pairs(vfs.Find("data/chatsounds/lists/")) do
		table.insert(out, v:sub(0,-5))
	end
	return out
end

function chatsounds.Initialize()
	event.AddListener("Update", "chatsounds", chatsounds.Update)
end

function chatsounds.Shutdown()
	autocomplete.RemoveList("chatsounds")
	event.RemoveListener("Update", "chatsounds")
end

return chatsounds