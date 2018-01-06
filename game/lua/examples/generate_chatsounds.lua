--avoid big loop in big loop
--translate captions

local game = "csgo"

steam.UnmountAllSourceGames()
steam.MountSourceGame(game)

if game ~= "hl2" then
	-- this makes it so we don't find soundscripts from hl2 which for instance tf2 is based on
	for path, info in pairs(vfs.GetMounts()) do
		if path:find("hl2") then
			logn("unmounting ", path)
			vfs.Unmount(path)
		end

		if game ~= "ep1" then
			if path:find("episodic") then
				logn("unmounting ", path)
				vfs.Unmount(path)
			end
		end

		if game ~= "ep2" then
			if path:find("ep2") then
				logn("unmounting ", path)
				vfs.Unmount(path)
			end
		end
	end
end

local function assert(ok, err)
	if not ok then
		logn(err, "?!")
		return
	end

	return ok
end

local thread = tasks.CreateTask()
thread:SetEnsureFPS(5)
thread.debug = true

function thread:OnStart()

	local temp_data = {}
	local appid_lookup = {}

	local sound_characters = {
		["*"] = "CHAR_STREAM",
			-- Streams from the disc, get flushed soon after. Use for one-off dialogue files or music.
		["#"] = "CHAR_DRYMIX",
			-- Bypasses DSP and affected by the user's music volume setting.
		["@"] = "CHAR_OMNI",
			-- Non-directional; audible everywhere. "Default mono or stereo", whatever that means.
		[">"] = "CHAR_DOPPLER",
			-- Doppler encoded stereo: left for heading towards the listenr and right for heading away.
		["<"] = "CHAR_DIRECTIONAL",
			-- Stereo with direction: left channel for front facing, right channel for rear facing. Mixed based on listener's direction.
		["^"] = "CHAR_DISTVARIANT",
			-- Distance-variant stereo. Left channel is close, right channel is far. Transition distance is hard-coded; see below.
		[")"] = "CHAR_SPATIALSTEREO",
			-- Spatializes both channels, allowing them to be placed at specific locations within the world; see below.
			-- Note:Sometimes "(" must be used instead; see below.
		["}"] = "CHAR_FAST_PITCH",
			-- Forces low quality, non-interpolated pitch shift.
		["$"] = "CHAR_CRITICAL",
			-- Memory resident; cache locked.
		["!"] = "CHAR_SENTENCE",
			-- An NPC sentence.
			-- Bug:
			-- Only Works in Source 2009 or higher
		["?"] = "CHAR_USERVOX",
			-- Voice chat data. You shouldn't ever need to use this.
	}

	local preprocess = {
		male = "gender",
		female = "gender",
	}

	local realm_patterns = {
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
				return (realm_translate[realm] or realm)
			end
		end

		return "misc"
	end

	local function clean_sentence(sentence)

		sentence = sentence:gsub("%u%l", " %1")
		sentence = sentence:lower()
		sentence = sentence:gsub("_", " ")
		sentence = sentence:gsub("%.", " ")
		sentence = sentence:gsub("%p", "")
		sentence = sentence:gsub("%d", "")
		sentence = sentence:gsub("%s+", " ")
		sentence = sentence:trim()

		return sentence
	end

	local function get_sound_data(file, plaintext)
		-- TODO
		if file:ReadBytes(4) ~= "RIFF" then return end

		local chunk = file:ReadBytes(50)
		local _, pos = chunk:find("data")

		if pos then
			file:SetPosition(pos + 4)
			file:SetPosition(file:ReadLong())

			local content = file:ReadAll()
			return content:match("PLAINTEXT%s-{%s+(.-)%s-}")
		end
	end


	vfs.Search("sound/", {"mp3", "wav", "ogg"}, function(path, userdata)
		self:Report("searching sound/*")
		self:Wait()

		if userdata and userdata.game then
			local appid = userdata.filesystem.steamappid
			temp_data[appid] = temp_data[appid] or {full_paths = {}, soundscripts = {}, captions = {}, relative_paths = {}, phonemes = {}}
			appid_lookup[appid] = userdata

			local relative = path:match(".-/sound/(.+)"):lower()

			temp_data[appid].full_paths[relative] = path
		end
	end, {"/addons/", "/workshop/", "/download/"})

	for appid, data in pairs(temp_data) do
		logn(appid_lookup[appid].game, ": found ", #data.full_paths, " sounds in sound/*")
	end

	for _, info in ipairs(vfs.GetFiles({path = "scripts/", filter = "game_sounds_manifest.txt", plain_search = true, verbose = true})) do
		local userdata =  info.userdata
		if userdata and userdata.game then
			local str = assert(vfs.Read(info.full_path))
			local appid = userdata.filesystem.steamappid
			local not_found_count = 0

			if str then
				local manifest = assert(utility.VDFToTable(str))

				if manifest and manifest.game_sounds_manifest then
					for _, files in pairs(manifest.game_sounds_manifest) do
						files = type(files) == "string" and {files} or files
						for _, path in pairs(files) do
							self:ReportProgress("reading sound scripts", #files)
							self:Wait()
							for _, dir in ipairs(userdata.filesystem.searchpaths) do

								if not dir:endswith("/") then
									dir = dir .. "/"
								end

								local path = dir .. path
								if vfs.IsFile(path) then
									local str = assert(vfs.Read(path))

									if str then
										local tbl, err = utility.VDFToTable(str)
										if tbl then
											for sound_name, info in pairs(tbl) do
												if temp_data[appid].soundscripts[sound_name:lower()] then
													--logn("soundscript ", sound_name, " already added")
												else
													--local lol = table.copy(info)
													if info.rndwave then
														if not info.rndwave.wave then
															local k,v = next(info.rndwave)
															logn("strange symbol in rndwave for ", sound_name, " : ", k)
															info.wave = v
														else
															info.wave = info.rndwave.wave
														end
														info.rndwave = true
													end

													if type(info.wave) == "string" then
														info.wave = {info.wave}
													end

													local temp = {}

													if not info.wave then
														logn("info.wave is not set for ", sound_name)
													else
														for i, path in ipairs(info.wave) do
															if path:find("$", nil, true) then
																for k, v in pairs(preprocess) do
																	table.insert(temp, path:replace("$" .. v, k))
																end

																if temp[#temp] == path then
																	logn("unknown variables in ", path)
																end
															else
																table.insert(temp, path)
															end
														end
													end

													info.wave = temp

													for i, path in ipairs(info.wave) do
														local original = path
														local flags, path = path:match("^(%p*)(.+)")
														if path and path ~= "" then
															path = vfs.FixPathSlashes(path)

															local relative = path:lower()

															temp_data[appid].relative_paths[relative] = temp_data[appid].relative_paths[relative] or {}
															temp_data[appid].relative_paths[relative][info] = info

															local not_found

															if temp_data[appid].full_paths[relative] then
																path = temp_data[appid].full_paths[relative]
																temp_data[appid].full_paths[relative] = nil
															else
																not_found = true
																not_found_count = not_found_count + 1
															end

															info.wave[i] = {path = path, not_found = not_found, relative = relative}

															--[[
															if flags ~= "" then
																info.wave[i].flags = {}
																for i2 = 1, #flags do
																	info.wave[i].flags[i2] = sound_characters[flags:sub(i2, i2)]
																end
															end
															]]

														else
															tbl[sound_name] = nil
															logn(sound_name, " does not contain any paths?")
														end
													end
												end
											end

											local temp = {}

											for sound_name, info in pairs(tbl) do
												if not temp_data[appid].soundscripts[sound_name:lower()] then
													info.real_name = sound_name
													temp[sound_name:lower()] = info
												end
											end

											tbl = temp

											if next(temp) then
												table.merge(temp_data[appid].soundscripts, tbl)
											end
										else
											logn("couldn't parse ", path, ": ", err)
										end
									end
								end
							end
						end
					end
				end
			end
			logn(appid_lookup[appid].game, ": ", not_found_count, " paths in soundscripts were not found anywhere")
			logn(appid_lookup[appid].game, ": found ", table.count(temp_data[appid].soundscripts), " soundscripts")
			logn(appid_lookup[appid].game, ": found ", table.count(temp_data[appid].relative_paths), " relative paths in soundscripts")
		end
	end

	for _, info in ipairs(vfs.GetFiles({path = "scripts/", filter = "game_sounds_vo_phonemes.txt", plain_search = true, verbose = true})) do
		local userdata =  info.userdata
		if userdata and userdata.game then
			local appid = userdata.filesystem.steamappid

			logn("reading ", info.full_path)

			local phonemes = vfs.Read(info.full_path)

			if phonemes then
				local tbl = {}
				local i = 0
				for chunk in phonemes:gmatch("(%S-%s-%b{})") do
					local path = vfs.FixPathSlashes(chunk:match("(.-){"):trim()):lower()
					tbl[path] = clean_sentence(chunk:match("PLAINTEXT%s-{%s+(.-)%s-}"))

					if temp_data[appid].relative_paths[path] then
						for info in pairs(temp_data[appid].relative_paths[path]) do
							info.phoneme = tbl[path]
						end
					end
				end
				phonemes = tbl
			end

			temp_data[appid].phonemes = phonemes
		end
	end

	local files = vfs.GetFiles({path = "resource/", verbose = true})
	local max = #files

	local found_count = 0

	for _, info in pairs(files) do
		self:ReportProgress("reading resource/*", max)
		self:Wait()

		if info.userdata and info.userdata.game then
			local appid = info.userdata.filesystem.steamappid
			local path = info.full_path

			if path:find("english") and not path:find("/platform/") and path:endswith(".txt") then
				logn("reading ", path)
				local str = assert(vfs.Read(path))

				-- stupid hack because some caption files are encoded weirdly which would break lua patterns
				local tbl = {}
				local i = 1
				for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
					if uchar ~= "\0" then
						tbl[i] = uchar
						i = i + 1
					end
				end
				str = table.concat(tbl, "")
				str = str:gsub("//.-\n", "")

				local tbl = assert(utility.VDFToTable(str, true))

				if tbl.lang then tbl = tbl.lang end
				if tbl.tokens then tbl = tbl.tokens end

				if table.count(tbl) <= 1 then
					logn(path, " something is not right with this:")
					table.print(tbl)
				end

				for k,v in pairs(tbl) do
					if k:startswith("#") then
						local path = vfs.FixPathSlashes(k:sub(2))
						if temp_data[appid].full_paths[path] then
							temp_data[appid].soundscripts[k] = {wave = {{path = temp_data[appid].full_paths[path], relative = path}}}
						end
					end

					if temp_data[appid].soundscripts[k] then
						if type(v) == "table" then
							-- i don't understand this but lets' just select the longest word
							table.sort(v, function(a, b) return #a > #b end)
							v = v[1]
						end

						v = tostring(v)

						local original = v

						v = v:gsub("%b<>", "")
						v = clean_sentence(v)

						if v ~= "" and v ~= "textless" then
							temp_data[appid].soundscripts[k].caption = v
							found_count = found_count + 1
						elseif original:trim() ~= "" then
							logn(appid_lookup[appid].game, ": caption for ", k ," is empty? original: ", original)
						end
					else
						--logn(appid_lookup[appid].game, ": caption ", k, " could not find a soundscript: ", v)
						temp_data[appid].captions[k] = v
					end
				end
			end
		end
	end

	for appid, data in pairs(temp_data) do
		logn(appid_lookup[appid].game, ": added ", found_count, " captions to soundscripts")
		logn(appid_lookup[appid].game, ": ", table.count(data.captions), " captions did not have a corresponding soundscript")
	end

	local out = {}

	for appid, data in pairs(temp_data) do
		out[appid] = {}

		local max = table.count(data.soundscripts)

		for sound_name, info in pairs(data.soundscripts) do
			self:ReportProgress("building from soundscripts", max)
			self:Wait()

			local key = info.caption or info.phoneme

			local paths = {}

			for i, v in ipairs(info.wave) do
				if not v.not_found then
					data.full_paths[v.relative] = nil
					table.insert(paths, v.path)
				end
			end

			if not key then
				for i = #paths, 1, -1 do
					local path = paths[i]
					if path:endswith(".wav") then
						local file = assert(vfs.Open(path))
						if file then
							local plaintext = get_sound_data(file, true)
							if plaintext then
								table.remove(paths, i)
								local key = clean_sentence(plaintext)

								if out[appid][key] then
									table.insert(out[appid][key], path)
								else
									out[appid][key] = {path}
								end
							end
							file:Close()
						end
					end
				end
			end

			if paths[1] then
				if not key then
					key = clean_sentence(info.real_name)
				end

				if out[appid][key] then
					table.add(out[appid][key], paths)
				else
					out[appid][key] = paths
				end
			else
				--logn(appid_lookup[appid].game, ": soundscript ", sound_name, " contains only invalid paths")
			end
		end

		for relative_path, full_path in pairs(data.full_paths) do
			local key = clean_sentence(vfs.RemoveExtensionFromPath(vfs.GetFileNameFromPath(full_path)))
			if out[appid][key] then
				table.insert(out[appid][key], full_path)
			else
				out[appid][key] = {full_path}
			end
		end

		local unique = 0
		for k,v in pairs(out[appid]) do
			unique = unique + #v
		end

		logn(appid_lookup[appid].game, ": built ", table.count(out[appid]), " unique chatsounds with ", unique, " paths")
	end


	for appid, data in pairs(out) do
		self:ReportProgress("building list.lua") self:Wait()

		local temp = {}

		for key, paths in pairs(out[appid]) do
			for i, path in ipairs(paths) do
				local realm = realm_from_path(path)
				temp[realm] = temp[realm] or {}
				temp[realm][path] = key
			end
		end

		local list = {}

		for realm, paths in pairs(temp) do
			table.insert(list, "realm=" .. realm)
			for path, key in pairs(paths) do
				local relative = path:match(".-/(sound.+)")
				table.insert(list, relative .. "=" .. key)
			end
		end

		list = table.concat(list, "\n")

		vfs.Write("data/chatsounds/lists/" .. appid .. ".txt", list)

		list = chatsounds.ListToTable(list)
		local tree = chatsounds.TableToTree(list)
		serializer.WriteFile("msgpack", "data/chatsounds/trees/" .. appid .. ".dat", tree)
	end

	--[[

	for appid, data in pairs(temp_data) do
		self:ReportProgress("building relative_paths.lua", max) self:Wait()
		serializer.WriteFile("luadata", "data/chatsounds2/" .. appid .. "/relative_paths.lua", data.relative_paths)
		self:ReportProgress("building full_paths.lua", max) self:Wait()
		serializer.WriteFile("luadata", "data/chatsounds2/" .. appid .. "/full_paths.lua", data.full_paths)
		self:ReportProgress("building captions.lua", max) self:Wait()
		serializer.WriteFile("luadata", "data/chatsounds2/" .. appid .. "/captions.lua", data.captions)
		self:ReportProgress("building soundscripts.lua", max) self:Wait()
		serializer.WriteFile("luadata", "data/chatsounds2/" .. appid .. "/soundscripts.lua", data.soundscripts)
	end
	]]

	logn("done!")
end

thread:Start()