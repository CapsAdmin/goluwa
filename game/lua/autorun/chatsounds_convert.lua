--[[
mount hl2
chatsounds_build_lists -- builds non translated lists of all the sounds in sound/* depending on what games you have mounted
chatsounds_build_soundinfo -- builds translation files for chatsounds.TranslateSoundLists based on source engine soundinfo files
chatsounds_translate_lists -- translates the non translated lists based on phonemes and built (if any) soundinfo translations
chatsounds_extract -- converts lists to ogg in the chatsounds directory format
]] local chatsounds = _G.chatsounds or {}

local function get_sound_data(file, plaintext)
	local out = {}

	-- TODO
	if file:ReadBytes(4) ~= "RIFF" then return end

	local chunk = file:ReadBytes(50)
	local _, pos = chunk:find("data")

	if pos then
		file:SetPosition(pos + 4)
		file:SetPosition(file:ReadLong())
		local content = file:ReadAll()

		-- TODO
		if plaintext then
			local words = content:match("WORDS%s-{(.+)")
			local out = {}

			if words then
				for word, start, stop, phonemes in words:gmatch("WORD%s-(%S-)%s-(%S-)%s-(%S-)%s-{(.-)}") do
					table.insert(out, word)
				end

				if out[1] then return table.concat(out, " ") end
			end

			return content:match("PLAINTEXT%s-{%s+(.-)%s-}")
		end

		out.plaintext = content:match("PLAINTEXT%s-{%s+(.-)%s-}")
		local words = content:match("WORDS%s-{(.+)")

		if words then
			out.words = {}

			for word, start, stop, phonemes in words:gmatch("WORD%s-(%S-)%s-(%S-)%s-(%S-)%s-{(.-)}") do
				local tbl = {}

				for line in (phonemes .. "\n"):gmatch("(.-)\n") do
					local d = (line .. " "):split(" ")

					if #d > 2 then
						table.insert(
							tbl,
							{
								str = d[2],
								start = tonumber(d[3]),
								stop = tonumber(d[4]),
								num1 = tonumber(d[1]),
								num2 = tonumber(d[5]),
							}
						)
					end
				end

				table.insert(
					out.words,
					{word = word, start = tonumber(start), stop = tonumber(stop), phonemes = tbl}
				)
			end
		end

		return out
	end
end

local function clean_sentence(sentence)
	sentence = sentence:gsub("%u%l", " %1") -- upper, lower
	sentence = sentence:lower()
	sentence = sentence:gsub("_", " ")
	sentence = sentence:gsub("%.", " ")
	sentence = sentence:gsub("[\1-\31]", ""):gsub("[\33-\96]", ""):gsub("[\123-\255]", "")
	sentence = sentence:gsub("%s+", " ") -- spaces
	sentence = sentence:trim()
	return sentence
end

local sort = function(a, b)
	return a.key < b.key
end
local sort2 = function(a, b)
	return a.val.path < b.val.path
end

function chatsounds.TableToList(tbl)
	local str = {}

	for realm, list in table.sortedpairs(tbl, sort) do
		str[#str + 1] = "realm=" .. realm
		local done = {}

		for trigger, sounds in pairs(list) do
			for _, data in table.sortedpairs(sounds, sort2) do
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

function chatsounds.ListToTable(data)
	local list = {}
	local realm = "misc"

	for path, trigger in data:gmatch("(.-)=(.-)\n") do
		if path == "realm" then
			realm = trigger
		else
			if not list[realm] then list[realm] = {} end

			if not list[realm][trigger] then list[realm][trigger] = {} end

			table.insert(list[realm][trigger], {path = path})
		end
	end

	return list
end

function chatsounds.BuildSoundLists()
	local realm_patterns = {
		"sound/player/survivor/voice/(.-)/",
		"sound/player/vo/(.-)/",
		"vo/(aperture_ai)/[^/]+",
		"npc/(turret_floor)/turret_",
		".+/_(mo)_[^/]+",
		".+/_(al)_[^/]+",
		".+/_(kl)_[^/]+",
		".+/_(br)_[^/]+",
		".+/_(ba)_[^/]+",
		".+/_(eli)_[^/]+",
		".+/_(cit)_[^/]+",
		".+/(mo)_[^/]+",
		".+/(al)_[^/]+",
		".+/(kl)_[^/]+",
		".+/(br)_[^/]+",
		".+/(ba)_[^/]+",
		".+/(eli)_[^/]+",
		".+/(cit)_[^/]+",
		"vo/([^/]-)_[^/]+",
		"vo/(wheatley)/[^/]+",
		"vo/(mvm_.-)_[^/]+",
		"(ui)/[^/]+",
		"vo/(glados)/[^/]+",
		"npc/(.-)/",
		"vo/npc/(.-)/",
		"vo/(.-)/",
		"player/(.-)/voice/",
		"player/(.-)/",
		"mvm/(.-)/",
		"(bot)/",
		"(music)/",
		"(physics)/",
		"hl1/(fvox)/",
		"(weapons)/",
		"(commentary)/",
		"ambient/levels/(.-)/",
		"ambient/(.-)/",
	}
	local realm_translate = {
		[""] = "misc",
		eli = "hl2_eli",
		breen = "hl2_breen",
		mo = "hl2_mossman",
		al = "hl2_alyx",
		alyx = "hl2_alyx",
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
		turret_floor = "portal_turret",
		aperture_ai = "portal_ai",
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
		hl2_eli = "robert_guillaume",
		hl2_mossman = "michelle_forbes",
		hl2_alyx = "merle_dandridge",
		hl2_kleiner = "hal_robins",
		hl2_breen = "robert_culp",
		hl2_barney = "michael_shapiro_barney",
		hl2_gman = "michael_shapiro_gman",
		hl2_male = "adam_baldwin_john_patrick_lowrie",
		hl2_female = "mary_kae_irvin",
		l4d_biker = "vince_valenzuela",
		l4d_teengirl = "jen_taylor",
		l4d_gambler = "hugh_dillon",
		l4d_producer = "rochelle_aytes",
		l4d_manager = "earl_alexander",
		l4d_mechanic = "jesy_mckinney",
		l4d_namvet = "jim_french",
		turret_floor = "ellen_mclain",
		portal_ai = "ellen_mclain",
		tf2_scout = "nathan_vetterlein",
		tf2_churchguy = "nathan_vetterlein",
		tf2_virgil = "randall_newsome",
		tf2_soldier = "rick_may",
		tf2_pyro = "dennis_bateman",
		tf2_demoman = "gary_schwartz_demoman",
		tf2_heavy = "gary_schwartz_heavy",
		tf2_engineer = "grant_goodeve",
		tf2_medic = "robin_atkin_downes",
		tf2_sniper = "john_patrick_lowrie",
		tf2_announcer = "ellen_mclain",
	}

	local function realm_from_path(path)
		path = path:match("^.+/sound/(.+)$")

		for k, v in ipairs(realm_patterns) do
			local realm = path:match(v, 0)

			if realm then
				realm = realm:lower():gsub("%s+", "_")
				realm = realm:trim()
				realm = realm_translate[realm] or realm
				realm = voice_actors[realm] or realm
				return realm, v
			end
		end

		return "misc", ""
	end

	local found = {}
	local thread = tasks.CreateTask()
	thread:SetEnsureFPS(5)
	thread.debug = true
	local mounted = {}

	for i, v in pairs(steam.GetMountedSourceGames()) do
		mounted[v.filesystem.steamappid] = v.game_dir
	end

	if next(mounted) then
		logn("mounted games")
		table.print2(mounted)
	else
		logn("no games mounted")
	end

	local hl2_only = table.count(mounted) == 1 and mounted[220]
	local ep1_only = table.count(mounted) == 1 and mounted[380]

	function thread:OnStart()
		vfs.GetFilesRecursive(
			"sound/",
			{"wav", "ogg", "mp3"},
			function(path, userdata)
				if
					(
						not hl2_only and
						path:find("common/.-/hl2/")
					) or
					(
						not ep1_only and
						path:find("common/.-/episodic/")
					)
				then
					logn("skiping ", path)
					return
				end

				local sentence = path:match(".+/(.+)%.")
				sentence = clean_sentence(sentence)
				local realm = realm_from_path(path)
				local game = userdata and userdata.filesystem and tostring(userdata.filesystem.steamappid)

				if not game then
					game = path:match(".+common/(.+)/sound")
					game = game:gsub("/", "_"):lower()
					game = game:gsub("%.", " "):lower()
				end

				path = path:match(".+common.+(sound/.+)")
				found[game] = found[game] or {}
				found[game][realm] = found[game][realm] or {}
				table.insert(found[game][realm], path:lower() .. "=" .. sentence)
				--logn(path)
				--logn("\t", realm)
				--logn("\t", sentence)
				self:Wait()
			end,
			nil,
			true
		)
	end

	function thread:Save()
		logn("saving lists.. ")

		for game_name, found in pairs(found) do
			local game = {}

			for realm, sentences in table.sortedpairs(found, function(a, b)
				return a.key < b.key
			end) do
				table.insert(game, "realm=" .. realm .. "\n")

				table.sort(sentences, function(a, b)
					return a:split("=")[1] < b:split("=")[1]
				end)

				table.insert(game, table.concat(sentences, "\n") .. "\n")
			end

			local game_list = table.concat(game, "")
			log("saving ")
			local count = 0

			for k, v in pairs(found) do
				count = count + table.count(v)
			end

			log(count, " ")
			logn("sounds to chatsounds/lists/" .. game_name .. ".dat")
			vfs.Write("data/chatsounds/lists/" .. game_name .. ".dat", game_list)
		--serializer.WriteFile("msgpack", "data/chatsounds/"..game_name..".tree", chatsounds.TableToTree(chatsounds.ListToTable(game_list)))
		end
	end

	function thread:OnUpdate()
		if wait(1) then
			for game_name, found in pairs(found) do
				logn(game_name, ": ", table.count(found) .. " realms found")
				local i = 0
				local size = 0

				for k, v in pairs(found) do
					size = size + #k

					for k, v in pairs(v) do
						i = i + 1
						size = size + #v
					end
				end

				logf(game_name, ": %i sentences found (%s)\n", i, utility.FormatFileSize(size))
			end
		end

		if wait(10) then
			logn("saved")
			self:Save()
		end
	end

	function thread:OnFinish()
		self:Save()
	end

	thread:Start()
	chatsounds.build_info_thread = thread
end

function chatsounds.BuildSoundInfoTranslations()
	local thread = tasks.CreateTask()
	thread:SetEnsureFPS(5)
	thread.debug = true
	local mounted = {}

	for i, v in pairs(steam.GetMountedSourceGames()) do
		mounted[v.filesystem.steamappid] = v.game_dir
	end

	if next(mounted) then
		logn("mounted games")
		table.print2(mounted)
	else
		logn("no games mounted")
	end

	local hl2_only = table.count(mounted) == 1 and mounted[220]
	local ep1_only = table.count(mounted) == 1 and mounted[380]

	function thread:OnStart()
		local sound_info = {}
		local files = vfs.Find("scripts/", nil, nil, nil, nil, true)
		local max = #files

		for _, data in ipairs(files) do
			self:ReportProgress("reading scripts/*", max)
			self:Wait()

			if
				(
					hl2_only or
					not data.full_path:find("common/.-/hl2/")
				)
				and
				(
					ep1_only or
					not data.full_path:find("common/.-/episodic/")
				)
			then
				local id = data.userdata and
					data.userdata.filesystem and
					tostring(data.userdata.filesystem.steamappid) or
					data.userdata.game

				if id then
					local path = data.full_path
					sound_info[id] = sound_info[id] or {}

					if
						path:find("_sounds") and
						not path:find("manifest")
						and
						path:find("%.txt") and
						not path:endswith("game_sounds_vo_phonemes.txt")
					then
						local str = vfs.Read(path)

						if str then
							local t, err = utility.VDFToTable(str, true)

							if t then
								table.merge(sound_info[id], t)
							else
								print(path, err)
							end
						else
							logn("couldn't read ", path, " file is empty")
						end
					end
				end
			else
				logn("skipping ", data.full_path)
			end
		end

		for _, sound_info in pairs(sound_info) do
			for sound_name, info in pairs(sound_info) do
				sound_info[sound_name] = nil
				sound_info[sound_name:lower()] = info
				info.real_name = sound_name
			end
		end

		local captions = {}
		local files = vfs.Find("resource/", nil, nil, nil, nil, true)
		local max = #files

		for _, data in pairs(files) do
			self:ReportProgress("reading resource/*", max)
			self:Wait()

			if
				(
					hl2_only or
					not data.full_path:find("common/.-/hl2/")
				)
				and
				(
					ep1_only or
					not data.full_path:find("common/.-/episodic/")
				)
			then
				local id = data.userdata and
					data.userdata.filesystem and
					tostring(data.userdata.filesystem.steamappid) or
					data.userdata.game

				if id then
					local path = data.full_path
					captions[id] = captions[id] or {}

					if path:find("english") and path:find("%.txt") then
						local str = vfs.Read(path)
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
						-- stupid hack
						local tbl = utility.VDFToTable(str, true)

						if tbl.Lang then tbl = tbl.Lang end

						if tbl.lang then tbl = tbl.lang end

						if tbl.Tokens then tbl = tbl.Tokens end

						if tbl.tokens then tbl = tbl.tokens end

						logn("found ", table.count(tbl), " caption files in ", path)
						table.merge(captions[id], tbl)
					end
				end
			else
				logn("skipping ", data.full_path)
			end
		end

		for game, sound_info in pairs(sound_info) do
			if captions[game] then
				local max = table.count(captions[game])

				for sound_name, text in pairs(captions[game]) do
					self:ReportProgress("parsing " .. game .. " captions", max)
					self:Wait()

					if not sound_info[sound_name] and sound_name:sub(1, 1) == "#" then
						sound_name = sound_name:lower()
						sound_name = sound_name:replace("#", "")
						sound_name = sound_name:replace("\\", "/")
						sound_info[sound_name] = {
							wave = sound_name,
						}
					end

					if sound_info[sound_name] then
						if type(text) == "table" then text = text[1] end

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
									args = args:split(",")

									for k, v in pairs(args) do
										args[k] = tonumber(v) or v
									end
								else
									key = tag:match("<(.-)>")
								end

								data.tags[i] = {type = key, args = args}
							end
						end

						local name, rest = text:match("(.-):(.+)")

						if not name then name, rest = text:match("%[(.-)%] (.+)") end

						if name then
							data.name = name
							data.text = rest
						else
							data.text = text
						end

						data.text = data.text:trim()
						--logn("found caption for soundname ", sound_name, ": ", data.text)
						sound_info[sound_name].caption = data
					else

					--logn("no caption for ", sound_name)
					end
				end
			end

			local out = {}
			local max = table.count(sound_info)
			local found = 0

			for sound_name, info in pairs(sound_info) do
				self:ReportProgress("parsing " .. game .. " sound info", max)
				self:Wait()
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

				for k, path in pairs(paths) do
					path = path:lower():replace("\\", "/")
					local start_symbol

					if path:sub(1, 1):find("%p") then
						start_symbol, path = path:match("(%p+)(.+)")
					end

					path = "sound/" .. path
					local paths

					if path:find("$gender", nil, true) then
						local male = path:replace("$gender", "male")
						local female = path:replace("$gender", "female")
						out[female] = out[path]
						out[male] = out[path]
						out[path] = nil
						paths = {female, male}
					else
						paths = {path}
					end

					for _, v in ipairs(paths) do
						out[v] = out[v] or {}
						out[v].name = info.real_name
						out[v].path_symbol = start_symbol
						table.merge(out[v], info)

						if type(out[v].pitch) == "string" and out[v].pitch:find(",") then
							out[v].pitch = out[v].pitch:gsub("%s+", ""):split(",")

							for k, n in pairs(out[v].pitch) do
								out[v].pitch[k] = tonumber(n) or n
							end
						end

						out[v].operator_stacks = nil
						out[v].real_name = nil
						out[v].rndwave = nil
						out[v].wave = nil
						found = found + 1
					end
				end
			end

			game = vfs.ReplaceIllegalPathSymbols(game)
			logn("saving data/chatsounds/sound_info/" .. game .. ".dat")
			serializer.WriteFile("msgpack", "data/chatsounds/sound_info/" .. game .. ".dat", out)
			--serializer.WriteFile("luadata", "chatsounds/"..game.."_sound_info.lua", out)
			logf("found sound info for %i paths\n", found)
		end

		logn("finished building the sound info table")
	end

	thread:Start()
end

function chatsounds.TranslateSoundLists()
	local thread = tasks.CreateTask()
	thread.debug = true
	local mounted = {}

	for i, v in pairs(steam.GetMountedSourceGames()) do
		mounted[v.filesystem.steamappid] = v.game_dir
	end

	if next(mounted) then
		logn("mounted games")
		table.print2(mounted)
	else
		logn("no games mounted")
	end

	function thread:OnStart()
		for i, path in pairs(vfs.Find("data/chatsounds/lists/")) do
			local id = tonumber(path:match("(%d+)%.", 0))

			if not id or mounted[id] then
				if vfs.IsFile("data/chatsounds/sound_info/" .. path) then
					local sound_info = serializer.ReadFile("msgpack", "data/chatsounds/sound_info/" .. path)
					local list = chatsounds.ListToTable(vfs.Read("data/chatsounds/lists/" .. path))
					local phonemes = vfs.Read("scripts/game_sounds_vo_phonemes.txt")

					if phonemes then
						local tbl = {}
						local i = 0

						for chunk in phonemes:gmatch("(%S-%s-%b{})") do
							local path = chunk:match("(.-){"):trim():gsub("\\", "/")
							tbl["sound/" .. path] = clean_sentence(chunk:match("PLAINTEXT%s-{%s+(.-)%s-}"))
						end

						phonemes = tbl
					end

					local newlist = {}
					logn("translating ", path)
					local found = 0
					local max = 0

					for k, v in pairs(list) do
						for k, v in pairs(v) do
							for k, v in pairs(v) do
								max = max + 1
							end
						end
					end

					for realm, list in pairs(list) do
						newlist[realm] = newlist[realm] or {}

						for trigger, sounds in pairs(list) do
							newlist[realm][trigger] = newlist[realm][trigger] or {}

							for i, data in ipairs(sounds) do
								self:ReportProgress("translating " .. path, max)
								self:Wait()
								local translation_type = "no translation"
								local new_trigger

								if phonemes and phonemes[data.path] and phonemes[data.path] ~= "textless" then
									new_trigger = phonemes[data.path]
									translation_type = "game_sounds_vo_phonemes"
								else
									local info = sound_info[data.path:lower()]

									if info then
										if info.caption and info.caption.text and info.caption.text:trim() ~= "" then
											new_trigger = clean_sentence(info.caption.text)
											translation_type = "gamesound caption"
										elseif info.name then
											new_trigger = clean_sentence(info.name)
											translation_type = "gamesound name"
										else

										--logn("found sound info for ", data.path, " but not sure what to do with it")
										--table.print(info)
										end
									end

									if not new_trigger or data.path:endswith(".wav") then
										local file = vfs.Open(data.path)

										if file then
											local sentence = get_sound_data(file, true)

											if sentence then
												sentence = clean_sentence(sentence)

												if sentence ~= "" then
													new_trigger = sentence
													translation_type = "wav embedded caption"
												end
											end

											file:Close()
										end
									end
								end

								if TF2_CAPTIONS then
									local name = vfs.RemoveExtensionFromPath(vfs.GetFileNameFromPath(data.path))

									if TF2_CAPTIONS[name] then
										new_trigger = TF2_CAPTIONS[name]
										translation_type = "custom tf2 captions"
									elseif name:find("_mvm_m_", nil, true) then
										local try = name:replace("mvm_m_", "")

										if not TF2_CAPTIONS[name] and TF2_CAPTIONS[try] then
											new_trigger = TF2_CAPTIONS[try]
											translation_type = "custom tf2 captions"
										end
									elseif name:find("_mvm_", nil, true) then
										local try = name:replace("mvm_", "")

										if not TF2_CAPTIONS[name] and TF2_CAPTIONS[try] then
											new_trigger = TF2_CAPTIONS[try]
											translation_type = "custom tf2 captions"
										end
									else

									--print(name)
									end
								end

								new_trigger = new_trigger or trigger
								newlist[realm][new_trigger] = newlist[realm][new_trigger] or {}
								table.insert(newlist[realm][new_trigger], data)
								found = found + 1
								logn(data.path:sub(7), " - ", translation_type)
								logn("\t", new_trigger)
							end
						end
					end

					logf("translated %i paths\n", found)
					logn("saving ", path)
					local game_list = chatsounds.TableToList(newlist)
					path = vfs.ReplaceIllegalPathSymbols(path)
					vfs.Write("data/chatsounds/translated_lists/" .. path, game_list)
				--serializer.WriteFile("msgpack", "data/chatsounds/" .. path, chatsounds.TableToTree(list))
				else
					logn("sound data not found for ", path)
				end
			end
		end
	end

	thread:Start()
end

local function create_safe_path(realm, trigger)
	local path = realm .. "/"

	if #trigger > 100 then
		path = path .. "-" .. trigger:sub(0, 30):trim() .. "-" .. crypto.CRC32(trigger)
	else
		path = path .. trigger
	end

	return path
end

function chatsounds.BuildListForGithub(appid)
	local mounted = {}

	for i, v in pairs(steam.GetMountedSourceGames()) do
		mounted[v.filesystem.steamappid] = v.game_dir
	end

	if next(mounted) then
		logn("mounted games")
		table.print2(mounted)
	else
		logn("no games mounted")
	end

	local sounds = {}

	for i, path in pairs(vfs.Find("data/chatsounds/translated_lists/", true)) do
		local id = tonumber(path:match("(%d+)%.", 0))

		if not id or mounted[id] then
			for realm, triggers in pairs(chatsounds.ListToTable(vfs.Read(path))) do
				for trigger, data in pairs(triggers) do
					trigger = trigger:gsub("[^a-z0-9 ]", "")
					realm = realm:gsub("[^a-z0-9 _]", "")

					if #data == 1 then
						table.insert(
							sounds,
							{
								realm,
								trigger,
								create_safe_path(realm, trigger) .. ".ogg",
							}
						)
					else
						for i, data in ipairs(data) do
							table.insert(
								sounds,
								{
									realm,
									trigger,
									create_safe_path(realm, trigger) .. "/" .. i .. ".ogg",
								}
							)
						end
					end

					local data = sounds[#sounds]
					logn(data[3])
					logn("\t", data[1])
					logn("\t", data[2])
				end
			end
		end

		serializer.WriteFile("msgpack", "data/chatsounds/autoadd/" .. (id or "unknown") .. "/list.msgpack", sounds)
	end

	logn("finished building list files")
end

function chatsounds.ExtractSoundsFromLists()
	local soundfile = desire("libsndfile")
	local ffi = require("ffi")
	local root = R("data/")
	local buffer_len = 1024
	local buffer = ffi.new("double[?]", buffer_len)
	local skipped = 0
	local failed = 0

	local function write(game, realm, trigger, read_path, i)
		local ext = "." .. vfs.GetExtensionFromPath(read_path)
		local dir = root .. "chatsounds/autoadd/" .. "/" .. game .. "/"
		local path = dir .. create_safe_path(realm, trigger)

		if i then path = path .. "/" .. i end

		if ext == ".ogg" then
			logn("not converting ", read_path)
			vfs.CreateDirectoriesFromPath("os:" .. path)
			vfs.Write(path .. ext, vfs.Read(read_path))
		else
			path = path .. ".ogg"

			if vfs.IsFile(path) then
				skipped = skipped + 1
				return
			end

			log(
				"converting ",
				read_path:match(".*sound/(.+)"),
				" >> ",
				path:match(".+autoadd/(.+)"),
				" - "
			)
			local info = ffi.new("struct SF_INFO[1]")
			local file, err = vfs.Open(read_path)

			if not file then
				logn("FAIL: unable to open ", read_path)
				failed = failed + 1
				return
			end

			local ogg_quality = ffi.new("float[1]", 0.4)

			if
				file:PeakBytes(3) == "ID3" or
				file:PeakBytes(3) == "\xFF\xFB\x92" or
				file:PeakBytes(3) == "\xFF\xFB\x90"
			then
				local buffer, len, info = audio.Decode(file, read_path, "mpg123")

				if buffer then
					vfs.CreateDirectoriesFromPath("os:" .. path)
					local info = ffi.new(
						"struct SF_INFO[1]",
						{
							{
								format = bit.bor(soundfile.e.FORMAT_OGG, soundfile.e.FORMAT_VORBIS),
								samplerate = info.samplerate,
								channels = info.channels,
							},
						}
					)
					local file_dst = soundfile.Open(path, soundfile.e.WRITE, info)
					local err = ffi.string(soundfile.Strerror(file_dst))

					if err ~= "No Error." then
						file:Close()
						soundfile.Close(file_dst)
						logn("FAIL: [destination file] ", err)
						failed = failed + 1
						return
					end

					soundfile.Command(
						file_dst,
						soundfile.e.SET_VBR_ENCODING_QUALITY,
						ogg_quality,
						ffi.sizeof(ogg_quality)
					)
					local buffer = ffi.cast("const short *", buffer)
					local len = len / 2

					while true do
						local wrote = soundfile.WriteShort(file_dst, buffer, buffer_len)
						len = len - wrote

						if wrote == 0 or len <= 0 then break end

						buffer = buffer + wrote
					end

					soundfile.Close(file_dst)
					file:Close()
				end
			else
				if read_path:endswith(".mp3") then
					logn(
						"FAIL: [source file] ",
						"invalid header in mp3? first 4 bytes: ",
						file:PeakBytes(4):hexformat()
					)
					failed = failed + 1
					return
				end

				local file_src = soundfile.OpenVFS(file, soundfile.e.READ, info)
				local err = ffi.string(soundfile.Strerror(file_src))

				if err ~= "No Error." then
					file:Close()
					soundfile.Close(file_src)
					logn("FAIL: [source file] ", err)
					failed = failed + 1
					return
				end

				local info = ffi.new(
					"struct SF_INFO[1]",
					{
						{
							format = bit.bor(soundfile.e.FORMAT_OGG, soundfile.e.FORMAT_VORBIS),
							samplerate = info[0].samplerate,
							channels = info[0].channels,
						},
					}
				)
				vfs.CreateDirectoriesFromPath("os:" .. path)
				local file_dst = soundfile.Open(path, soundfile.e.WRITE, info)
				local err = ffi.string(soundfile.Strerror(file_dst))

				if err ~= "No Error." then
					file:Close()
					soundfile.Close(file_dst)
					logn("FAIL: [destination file] ", err)
					failed = failed + 1
					return
				end

				soundfile.Command(
					file_dst,
					soundfile.e.SET_VBR_ENCODING_QUALITY,
					ogg_quality,
					ffi.sizeof(ogg_quality)
				)

				while true do
					local readcount = soundfile.ReadDouble(file_src, buffer, buffer_len)

					if readcount == 0 then break end

					soundfile.WriteDouble(file_dst, buffer, readcount)
				end

				soundfile.Close(file_src)
				soundfile.Close(file_dst)
				file:Close()
			end

			logn("OK")
		end
	end

	local mounted = {}

	for i, v in pairs(steam.GetMountedSourceGames()) do
		mounted[v.filesystem.steamappid] = v.game_dir
	end

	if next(mounted) then
		logn("mounted games")
		table.print2(mounted)
	else
		logn("no games mounted")
	end

	for i, path in pairs(vfs.Find("data/chatsounds/translated_lists/", true)) do
		local id = tonumber(path:match("(%d+)%.", 0))

		if not id or mounted[id] then
			for realm, triggers in pairs(chatsounds.ListToTable(vfs.Read(path))) do
				for trigger, data in pairs(triggers) do
					trigger = trigger:gsub("[^a-z0-9 ]", "")
					realm = realm:gsub("[^a-z0-9 _]", "")

					if #data == 1 then
						write(id or "unknown", realm, trigger, data[1].path)
					else
						for i, data in ipairs(data) do
							write(id or "unknown", realm, trigger, data.path, i)
						end
					end
				end
			end
		end
	end

	logn("finished extracting files")
	logn("skipped ", skipped, " files that were already extracted")
	logn("failed ", failed)
end

commands.Add("chatsounds_build_lists", chatsounds.BuildSoundLists)
commands.Add("chatsounds_build_soundinfo", chatsounds.BuildSoundInfoTranslations)
commands.Add("chatsounds_translate_lists", chatsounds.TranslateSoundLists)
commands.Add("chatsounds_build_list_file", chatsounds.BuildListForGithub)
commands.Add("chatsounds_extract", chatsounds.ExtractSoundsFromLists)

commands.Add("chatsounds_build=arg_line", function(name)
	steam.MountSourceGame(name)
	chatsounds.BuildSoundLists()
	chatsounds.BuildSoundInfoTranslations()
	chatsounds.TranslateSoundLists()
	chatsounds.BuildListForGithub()
	chatsounds.ExtractSoundsFromLists()
end)

commands.Add("chatsounds_fetch_tf2_captions", function()
	resource.Download("https://gitlab.com/DBotThePony/TF2Subtitles/repository/master/archive.zip"):Then(function(path)
		assert(vfs.IsDirectory(path), "zip not supported")
		local out = {}
		local root = vfs.Find(path .. "/", true)[1] .. "/data/eng/"

		for _, dir in ipairs(vfs.Find(root)) do
			if vfs.IsDirectory(root .. dir) then
				for _, lua in ipairs(vfs.Find(root .. dir .. "/", true)) do
					local ok, res = pcall(loadstring(vfs.Read(lua)))

					if ok then
						for k, v in pairs(res) do
							if type(v) == "table" then
								for s, c in pairs(v) do
									out[k .. s] = clean_sentence(c)
									logn(k .. s, " = ", c)
								end
							else
								if lua:endswith("halloween.lua") then k = "sf14" .. k end

								out[k] = clean_sentence(v)
								logn(k, " = ", v)
							end
						end
					end
				end
			end
		end

		TF2_CAPTIONS = out
	end)
end)