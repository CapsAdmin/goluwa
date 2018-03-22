local chatsounds = _G.chatsounds or {}

runfile("list_parsing.lua", chatsounds)
runfile("repositories.lua", chatsounds)

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
					for k,v in ipairs(data.modifiers) do
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
	echo = {
		args = {
			function(delay) return tonumber(delay) or 0.25 end,
			function(feedback) return tonumber(feedback) or 0.5 end,
		},
		init = function(self, delay, feedback)
			self.overlap = true
			self.snd.obj:SetEcho(true)
			self.snd.obj:SetEchoDelay(delay)
			self.snd.obj:SetEchoFeedback(feedback)
		end,
	},
	lfopitch = {
		args = {
			function(time) return tonumber(time) or 5 end,
			function(amount) return tonumber(amount) or 0.1 end,
		},
		init = function(self, time, amount)
			self.snd.obj:SetPitchLFOAmount(amount)
			self.snd.obj:SetPitchLFOTime(time)
		end,
	},
	lfovolume = {
		args = {
			function(time) return tonumber(time) or 5 end,
			function(amount) return tonumber(amount) or 0.1 end,
		},
		init = function(self, time, amount)
			self.snd.obj:SetVolumeLFOAmount(amount)
			self.snd.obj:SetVolumeLFOTime(time)
		end,
	},
	lowpass = {
		args = {
			function(num) return tonumber(num) or 0.5 end,
		},
		init = function(self, num)
			self.snd.obj:SetFilterType(1)
			self.snd.obj:SetFilterFraction(num)
		end,
	},
	highpass = {
		args = {
			function(num) return tonumber(num) or 0.5 end,
		},
		init = function(self, num)
			self.snd.obj:SetFilterType(2)
			self.snd.obj:SetFilterFraction(num)
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
		end,
	},
	legacyduration = {
		init = function(self, time, um)

			-- legacy modifier workaround..
			-- =0.125
			if um then
				time = tonumber(time .. "." .. um)
			end

			self.duration = time or self.duration
			self.overlap = true
		end,
	},
	overlap = {
		init = function(self, b)
			self.overlap = tonumber(b) ~= 0
		end,
	},
	loop = {
		init = function(self, b)
			self.snd:SetLooping(tonumber(b) ~= 0)
		end,
	},
	pitch = {
		init = function(self, num)
			num = tonumber(num) or 1
			self.duration = self.duration / math.abs(num)
		end,
		think = function(self, num)
			num = tonumber(num) or 1

			self.snd:SetPitch(num)
		end,
	},
	volume = {
		think = function(self, num)
			num = tonumber(num) or 1

			self.snd:SetGain(num)
		end,
	},
	legacyvolume = {
		init = function(self, volume, endvolume)
			volume = tonumber(volume) or 100
			endvolume = tonumber(endvolume) or volume

			self.endvolume = endvolume
		end,

		think = function(self, vol)
			vol = tonumber(vol) or 100

			local f = (system.GetElapsedTime() - self.start_time) / self.duration
			local vol = math.lerp(f, vol, self.endvolume) / 100

			self.snd:SetGain(vol)
		end,
	},
	legacypitch = {
		init = function(self, pitch, endpitch)
			pitch = tonumber(pitch) or 100
			endpitch = tonumber(endpitch) or pitch

			self.duration = self.duration / (math.abs(pitch) / 100)
			self.endpitch = endpitch

			self.snd:SetLooping(true)
		end,

		think = function(self, pitch)
			pitch = tonumber(pitch) or 100

			local f = (system.GetElapsedTime() - self.start_time) / self.duration
			local pitch = math.lerp(f, pitch, self.endpitch) / 100

			self.snd:SetPitch(pitch)

			if self.overlap and f >= 1 then
				self.snd:Stop()
			end
		end,
	},
	realm = {
		pre_init = function(realm)
			chatsounds.last_realm = realm
		end,
	}
}

chatsounds.LegacyModifiers = {
	["%%"] = "legacypitch",
	["%"] = "legacypitch",
	["^^"] = "legacyvolume",
	["^"] = "legacyvolume",
	["--"] = "cutoff",
	["#"] = "choose",
	["="] = "legacyduration",
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
			local protect = {}
			str = str:gsub("%b[]", function(val) table.insert(protect, val) return "____PROTECT_" .. #protect end)
			str = str:gsub(val.mod.."([%d%.]+)", function(str) str = str:gsub("%.", ",") return ":"..val.func.."("..str..")" end)
			for i,v in ipairs(protect) do
				str = str:gsub("____PROTECT_" .. i, v)
			end
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
		local exp = false
		local exp_level = 0
		local capture_exp = true
		local bracket_level = 0

		for i = 1, #str + 1 do
			local char = str:sub(i,i)
			local next = str:sub(i+1, i+1)
			local type = string.getchartype(char)

			if type ~= "space" then

				-- 0.1234
				if
					(last == "digit" and char == ".") or
					((char == "-" or char == ".") and next and string.getchartype(next) == "digit") or
					(char == "-" and next == "." and str:sub(i+2, i+2) and string.getchartype(str:sub(i+2, i+2)) == "digit")
				then
					type = "digit"
				end

				if type == "digit" and (last == "letters" or string.getchartype(next) == "letters") then type = "letters" end

				if bracket_level > 0 then
					if char == "[" then
						exp = true
						exp_level = exp_level + 1
						capture_exp = true
					elseif char == "]" then
						exp = false
						exp_level = exp_level - 1
						capture_exp = true
						table.insert(temp, char)
						char = ""
					end
				end

				if char == "(" then
					bracket_level = bracket_level + 1
				elseif char == ")" then
					bracket_level = bracket_level - 1
				end

				if not exp and (type ~= last or char == ":" or char == ")" or char == "(" or char == ",") or capture_exp then
					local word = table.concat(temp, "")
					if #word > 0 then
						table.insert(words, table.concat(temp, ""))
						table.clear(temp)
					end
					capture_exp = nil
				end

				table.insert(temp, char)
			end

			last = type
		end

		return words
	end

	local function find_modifiers(words)

		local count = #words

		local level = 0

		for i = 1, chatsounds.max_iterations do
			local word = words[i]

			if word == ":" then

				local args = {}
				local mod = words[i + 1]

				words[i] = nil
				words[i+2] = nil
				words[i+1] = nil

				level = level + 1

				for i2 = i + 3, i + 10 do
					local word = words[i2]
					words[i2] = nil

					if word == "(" then
						level = level + 1
					end

					if word == ")" then
						level = level - 1
					end

					if level == 0 then break end

					if word then
						if word:startswith("[") and word:endswith("]") then
							local ok, func = expression.Compile(word:sub(2, -2))
							if ok then
								table.insert(args, func)
							else
								wlog("failed to compile expression: ", func)
							end
						elseif word ~= "," then
							table.insert(args, word)
						end
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

				local repetitions = math.clamp(tonumber(chunk.args[1]) - 1, 1, 100)

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

	chatsounds.script_cache = table.weak()

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

local function get_arg(data, i)
	local val = data.args[i]
	if type(val) == "function" then
		local ok, v = pcall(val, {i = i})
		if ok then
			return v
		else
			wlog(v)
		end
	else
		return val
	end
end

local function unpack_args(data)
	local args = {}
	for i = 1, #data.args do
		args[i] = get_arg(data, i)
	end
	return unpack(args)
end

function chatsounds.PlayScript(script)

	local sounds = {}

	for _, chunk in ipairs(script) do
		if chunk.type == "matched" then

			if chunk.modifiers then
				for _, data in ipairs(chunk.modifiers) do
					local mod = chatsounds.Modifiers[data.mod]
					if mod and mod.args then
						for i, func in ipairs(mod.args) do
							data.args[i] = func(data.args[i])
						end
					end
				end
			end

			if chunk.modifiers then
				for _, data in ipairs(chunk.modifiers) do
					local mod = chatsounds.Modifiers[data.mod]
					if mod and mod.pre_init then
						mod.pre_init(unpack(data.args))
					end
				end
			end

			local data = choose_realm(chunk.val)

			if data then
				local info

				if chunk.modifiers then
					for _, v in ipairs(chunk.modifiers) do
						if v.mod == "choose" then
							if chunk.val.realms[v.args[2]] then
								data = chunk.val.realms[v.args[2]]
								info = data.sounds[math.clamp(tonumber(v.args[1]) or 1, 1, #data.sounds)]
							else
								local temp = {}
								for realm, data in pairs(chunk.val.realms) do
									for _, sound in ipairs(data.sounds) do
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
							for _, sound in ipairs(data.sounds) do
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
					if info.base_path then
						path = info.base_path .. path
					end

					local sound = {}

					sound.snd = audio.CreateSource(path)
					sound.duration = chunk.val.duration
					sound.trigger = chunk.val.trigger
					sound.modifiers = chunk.modifiers

					--print("DURATION", path, sound.duration)

					sound.call = function(self, func_name)
						if not self.modifiers then return end
						for _, data in ipairs(self.modifiers) do
							local mod = chatsounds.Modifiers[data.mod]
							if mod and mod[func_name] then
								local ok, err = pcall(mod[func_name], self, unpack_args(data))
								if not ok then
									wlog(err)
								end
							end
						end
					end

					sound.play = function(self)
						self:call("start")

						self.snd:Play()
					end

					sound.remove = function(self)
						self:call("stop")

						if not self.overlap then
							self.snd:Stop()
						end
					end

					if sound.modifiers then
						sound.think = function(self)
							self:call("think")
						end
					end

					table.insert(sounds, sound)

					chatsounds.last_trigger = chunk.val.trigger
				-- else
				-- 	print("huh")
				end
			-- else
			-- 	print(data, chunk.trigger, chunk.realm)
			end
		end
	end

	local timeout = system.GetElapsedTime() + 20

	local function cb()
		local time = system.GetElapsedTime()

		if time > timeout then
			llog("timeout waiting for sounds to get ready")
			dump_script(script)

			for _, sound in ipairs(sounds) do
				sound.snd:Remove()
			end

			for i, v in ipairs(chatsounds.queue_calc) do
				if v == cb then
					table.remove(chatsounds.queue_calc, i)
					break
				end
			end
			return
		end

		for _, sound in ipairs(sounds) do
			if not sound.snd:IsReady() then
				return
			end
		end

		local duration = 0
		local track = {}

		for _, sound in ipairs(sounds) do

			sound.duration = sound.duration or sound.snd:GetDuration()

			-- init modifiers
			sound:call("init")

			-- this is when the sound starts
			sound.start_time = time + duration
			duration = duration + sound.duration
			sound.stop_time = time + duration

			table.insert(track, sound)
		end

		table.insert(chatsounds.active_tracks, track)

		return true
	end


	table.insert(chatsounds.queue_calc, cb)

	chatsounds.last_realm = nil
end

function chatsounds.Panic()
	for _, track in pairs(chatsounds.active_tracks) do
		for _, sound in pairs(track) do
			sound:remove()
		end
	end

	chatsounds.active_tracks = {}
	chatsounds.queue_calc = {}
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

	for i, track in ipairs(chatsounds.active_tracks) do
		for i, sound in ipairs(track) do
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
	for _, v in ipairs(vfs.Find("data/chatsounds/lists/")) do
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
