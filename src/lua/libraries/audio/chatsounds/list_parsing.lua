local chatsounds = ... or chatsounds

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

		if plaintext then return content:match("PLAINTEXT%s-{%s+(.-)%s-}") end

		out.plaintext = content:match("PLAINTEXT%s-{%s+(.-)%s-}")

		local words = content:match("WORDS%s-{(.+)")

		if words then
			out.words = {}

			for word, start, stop, phonemes in words:gmatch("WORD%s-(%S-)%s-(%S-)%s-(%S-)%s-{(.-)}") do
				local tbl = {}

				for line in (phonemes .. "\n"):gmatch("(.-)\n") do
					local d = (line .. " "):split(" ")
					if #d > 2 then
						table.insert(tbl, {str = d[2], start = tonumber(d[3]), stop = tonumber(d[4]), num1 = tonumber(d[1]),  num2 = tonumber(d[5])})
					end
				end

				table.insert(out.words, {word = word, start = tonumber(start), stop = tonumber(stop), phonemes = tbl})
			end
		end

		return out
	end
end

function chatsounds.BuildFromSoundDirectory(where)
	where = where or "sounds/chatsounds/"
	local tree = {}
	local list = {}

	for realm in vfs.Iterate(where) do
		tree[realm] = {}
		list[realm] = {}
		for trigger in vfs.Iterate(where .. realm .. "/") do
			local path = where .. realm .. "/" .. trigger
			trigger = trigger:match("(.+)%.")

			if vfs.IsFile(path) then
				tree[realm][trigger] = {{path = path}}
				list[realm][trigger] = path
			else
				tree[realm][trigger] = {}
				for file_name in vfs.Iterate(path .. "/") do
					table.insert(tree[realm][trigger], path .. "/" .. file_name)
					list[realm][trigger] = path .. "/" .. file_name
				end
			end
		end
	end

	chatsounds.list = chatsounds.list or {}
	table.merge(chatsounds.list, list)

	tree = chatsounds.TableToTree(tree)
	chatsounds.tree = chatsounds.tree or {}
	table.merge(chatsounds.tree, tree)

	local list = {}

	for _, val in pairs(chatsounds.list) do
		for key in pairs(val) do
			table.insert(list, key)
		end
	end

	table.sort(list, function(a, b) return #a < #b end)

	autocomplete.AddList("chatsounds", list)
end

function chatsounds.BuildFromGmodChatsounds(addon_dir)
	if not addon_dir then
		steam.MountSourceGames()

		local addons = steam.GetGamePath("GarrysMod") .. "garrysmod/addons/"
		local addon_dir = addons .. "chatsounds"

		for dir in vfs.Iterate(addons, true) do
			if dir:lower():find("chatsound") then
				addon_dir = dir
				break
			end
		end

		addon_dir = addon_dir .. "/"
	end

	local list = {}
	local tree = {}

	local nosend = addon_dir .. "lua/chatsounds/lists_nosend/"
	local send = addon_dir .. "lua/chatsounds/lists_send/"

	local function parse(path)
		local func = assert(loadfile(path))
		local realm = path:match(".+/(.-)%.lua")
		local L = list[realm] or {}

		setfenv(func, {c = {StartList = function() end, EndList = function() end, LoadCachedList = function() end}, L = L})
		func()

		for trigger, sounds in pairs(L) do
			if type(sounds) == "table" then
				for _, info in ipairs(sounds) do
					info.path = addon_dir .. "sound/" .. info.path
				end
			end
		end

		list[realm] = L
	end

	for dir in vfs.Iterate(send, true) do
		for path in vfs.Iterate(dir .. "/", true) do
			parse(path)
		end
	end

	for path in vfs.Iterate(nosend, true) do
		parse(path)
	end

	for realm, sounds in pairs(list) do
		if realm ~= "" then
			for trigger, data in pairs(sounds) do
				trigger = trigger:gsub("%p", "")

				local words = {}
				for word in (trigger .. " "):gmatch("(.-)%s+") do
					table.insert(words, word)
				end

				local next = tree
				local max = #words

				for i, word in ipairs(words) do
					if not next[word] then next[word] = {} end

					if i == max then
						next[word].SOUND_DATA = next[word].SOUND_DATA or {}
						next[word].SOUND_DATA.trigger = next[word].SOUND_DATA.trigger or trigger
						next[word].SOUND_DATA.realms = next[word].SOUND_DATA.realms or {}

						next[word].SOUND_DATA.realms[realm] = {sounds = data, realm = realm}
					end

					next = next[word]
				end
			end
		end
	end

	chatsounds.list = list
	chatsounds.tree = tree

	chatsounds.BuildAutocomplete()
end

function chatsounds.BuildFromGithub(repo, location)
	local url = "https://api.github.com/repos/"..repo.."/git/trees/master?recursive=1"
	location = location or "sounds/chatsounds"

	resource.Download(url, function(path)

		local tree = {}
		local list = {}

		local str = vfs.Read(path)
		for path in str:gmatch('"path":%s-"('..location..'/.-)"') do
			local realm, trigger, file_name = path:match(location .. "/(.-)/(.-)/(.+)%.")
			if not file_name then
				realm, trigger = path:match(location .. "/(.-)/(.+)%.")
			end

			path = path:gsub(" ", "%%20")
			path = "https://raw.githubusercontent.com/"..repo.."/master/" .. path

			if realm then
				tree[realm] = tree[realm] or {}
				list[realm] = list[realm] or {}

				tree[realm][trigger] = tree[realm][trigger] or {}
				table.insert(tree[realm][trigger], {path = path})
				list[realm][trigger] = path
			end
		end

		chatsounds.list = chatsounds.list or {}
		table.merge(chatsounds.list, list)
		chatsounds.BuildAutocomplete()

		tree = chatsounds.TableToTree(tree)
		chatsounds.tree = chatsounds.tree or {}
		table.merge(chatsounds.tree, tree)
	end, nil, nil, nil, true)
end

function chatsounds.BuildAutocomplete()
	local list = {}
	local done = {}

	for _, val in pairs(chatsounds.list) do
		for key in pairs(val) do
			if not done[key] then
				table.insert(list, key)
				done[key] = true
			end
		end
	end

	table.sort(list, function(a, b) return #a < #b end)

	autocomplete.AddList("chatsounds", list)
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

function chatsounds.BuildSoundInfo()
	local thread = tasks.CreateTask()
	thread:SetEnsureFPS(5)
	thread.debug = true

	function thread:OnStart()
		local out = {}

		local sound_info = {}

		local files = vfs.Find("scripts/", nil,nil,nil,nil, true)
		local max = #files

		for _, data in ipairs(files) do
			self:ReportProgress("reading scripts/*", max)
			self:Wait()

			if data.userdata and data.userdata.game then
				local path = data.full_path
				sound_info[data.userdata.game] = sound_info[data.userdata.game] or {}

				if path:find("_sounds") and not path:find("manifest") and path:find("%.txt") then
					local str = vfs.Read(path)

					if str then
						local t, err = utility.VDFToTable(str)
						if t then
							table.merge(sound_info[data.userdata.game], t)
						else
							print(path, err)
						end
					else
						logn("couldn't read ", path, " file is empty")
					end
				end
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
		local files = vfs.Find("resource/", nil,nil,nil,nil, true)
		local max = #files

		for _, data in pairs(files) do
			self:ReportProgress("reading resource/*", max)
			self:Wait()

			if data.userdata and data.userdata.game then
				local path = data.full_path
				captions[data.userdata.game] = captions[data.userdata.game] or {}

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

					local tbl = utility.VDFToTable(str)
					if tbl.Lang then tbl = tbl.Lang end
					if tbl.lang then tbl = tbl.lang end
					if tbl.Tokens then tbl = tbl.Tokens end
					if tbl.tokens then tbl = tbl.tokens end

					table.merge(captions[data.userdata.game], tbl)
				end
			end
		end

		for game, sound_info in pairs(sound_info) do
			if not vfs.IsFile("data/chatsounds/sound_info/"..game..".dat") then
				if captions[game] then
					local max = table.count(captions[game])

					for sound_name, text in pairs(captions[game]) do
						self:ReportProgress("parsing "..game.." captions", max)
						self:Wait()

						if not sound_info[sound_name] and sound_name:sub(1,1) == "#" then
							sound_name = sound_name:lower()
							sound_name = sound_name:gsub("#", "")
							sound_name = sound_name:gsub("\\", "/")
							sound_info[sound_name] = {
								wave = sound_name,
							}
						end

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
										args = args:split(",")
										for k,v in pairs(args) do args[k] = tonumber(v) or v end
									else
										key = tag:match("<(.-)>")
									end

									data.tags[i] = {type = key, args = args}
								end
							end

							local name, rest = text:match("(.-):(.+)")

							if not name then
								name, rest = text:match("%[(.-)%] (.+)")
							end

							if name then
								data.name = name
								data.text = rest
							else
								data.text = text
							end

							data.text = data.text:trim()

							sound_info[sound_name].caption = data
						end
					end
				end

				local out = {}
				local max = table.count(sound_info)

				for sound_name, info in pairs(sound_info) do
					self:ReportProgress("parsing "..game.." sound info", max)
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

					for k, v in pairs(paths) do
						v = v:lower()
						v = v:gsub("\\", "/")

						local start_symbol

						if v:sub(1, 1):find("%p") then
							start_symbol, v = v:match("(%p+)(.+)")
						end

						v = "sound/" .. v

						out[v] = out[v] or {}

						if v:find("%.wav") then
							local file = vfs.Open(v)

							if file then
								out[v].sound_data = get_sound_data(file)

								out[v].byte_size = file:GetSize()
								file:Close()
							end
						else
							out[v].file_not_found = true
						end

						out[v].name = info.real_name
						out[v].path_symbol = start_symbol

						table.merge(out[v], info)

						if type(out[v].pitch) == "string" and out[v].pitch:find(",") then
							out[v].pitch = out[v].pitch:gsub("%s+", ""):split(",")
							for k,n in pairs(out[v].pitch) do out[v].pitch[k] = tonumber(n) or n end
						end

						out[v].operator_stacks = nil
						out[v].real_name = nil
						out[v].rndwave = nil
						out[v].wave = nil
					end
				end

				game = vfs.FixIllegalCharactersInPath(game)

				logn("saving data/chatsounds/sound_info/"..game..".dat")
				serializer.WriteFile("msgpack", "data/chatsounds/sound_info/"..game..".dat", out)
				--serializer.WriteFile("luadata", "chatsounds/"..game.."_sound_info.lua", out)
			else
				logn("sound info for " .. game .. " already exists. skipping")
			end
		end

		logn("finished building the sound info table")
		logf("found sound info for %i paths\n", table.count(out))
	end

	thread:Start()
end

function chatsounds.BuildSoundLists()

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
				return (realm_translate[realm] or realm), v
			end
		end

		return "misc", ""
	end

	local found = {}

	local thread = tasks.CreateTask()
	thread:SetEnsureFPS(5)

	thread.debug = true

	function thread:OnStart()
		vfs.Search("sound/", {"wav", "ogg", "mp3"}, function(path, userdata)
			local sentence = path:match(".+/(.+)%.")

			sentence = clean_sentence(sentence)

			local realm = realm_from_path(path)
			local game = userdata.game

			if not game then
				game = path:match(".+common/(.+)/sound")
				game = game:gsub("/", "_"):lower()
				game = game:gsub("%.", " "):lower()
			end

			path = path:match(".+common.+(sound/.+)")

			found[game] = found[game] or {}
			found[game][realm] = found[game][realm] or {}

			table.insert(found[game][realm], path:lower() .. "=" .. sentence)

			self:Wait()
		end)
	end

	function thread:Save()
		logn("saving..")

		for game_name, found in pairs(found) do
			local game = {}

			for realm, sentences in pairs(found) do
				table.insert(game, "realm="..realm .. "\n")
				table.insert(game, table.concat(sentences, "\n") .. "\n")
			end

			local game_list = table.concat(game, "")

			game_name = vfs.FixIllegalCharactersInPath(game_name)

			vfs.Write("data/chatsounds/lists/"..game_name..".dat", game_list)
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

function chatsounds.TranslateSoundListsFromSoundInfo()
	local thread = tasks.CreateTask()

	thread.debug = true

	function thread:OnStart()

		for i, path in pairs(vfs.Find("data/chatsounds/lists/")) do
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

				for k,v in pairs(list) do
					for k,v in pairs(v) do
						for k,v in pairs(v) do
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

							if phonemes then
								trigger = phonemes[data.path] or trigger
							else
								local file = vfs.Open(data.path)

								if file then
									local sentence = get_sound_data(file, true)
									if sentence then
										sentence = clean_sentence(sentence)
										trigger = sentence
									end
									file:Close()
								else
									local info = sound_info[data.path:lower()]
									if info and info.name then
										trigger = info.name
									end
								end
							end

							newlist[realm][trigger] = newlist[realm][trigger] or {}

							table.insert(newlist[realm][trigger], data)
						end
					end
				end
				logf("translated %i paths\n", found)

				logn("saving ", path)
				local game_list = chatsounds.TableToList(newlist)

				path = vfs.FixIllegalCharactersInPath(path)

				vfs.Write("data/chatsounds/lists/" .. path, game_list)

				--serializer.WriteFile("msgpack", "data/chatsounds/" .. path, chatsounds.TableToTree(list))
			else
				logn("sound data not found for ", path)
			end
		end
	end

	thread:Start()
end

function chatsounds.ListToTable(data)
	local list = {}
	local realm = "misc"
	for path, trigger in data:gmatch("(.-)=(.-)\n") do
		if path == "realm" then
			realm = trigger
		else
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
			for _, data in ipairs(sounds) do
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

			local next = tree
			local max = #words

			for i, word in ipairs(words) do
				if not next[word] then
					next[word] = {}
				end

				if i == max then
					next[word].SOUND_DATA = next[word].SOUND_DATA or {trigger = trigger, realms = {}}
					if next[word].SOUND_DATA.realms then
						next[word].SOUND_DATA.realms[realm] = {sounds = sounds, realm = realm}
					else
						logn(word) -- ???
					end
				end

				next = next[word]
			end
		end
	end

	return tree
end

function chatsounds.LoadListFromAppID(name)
	name = tostring(name)

	local list_path = "data/chatsounds/lists/"..name..".txt"
	local tree_path = "data/chatsounds/trees/"..name..".dat"

	resource.Download(list_path, function(list_path)
		local list
		local tree

		if vfs.IsFile(list_path) then
			list = chatsounds.ListToTable(vfs.Read(list_path))
		end

		if vfs.IsFile(tree_path) then
			tree = serializer.ReadFile("msgpack", tree_path)
		elseif list then
			tree = chatsounds.TableToTree(list)
			serializer.WriteFile("msgpack", "data/chatsounds/trees/" .. name, tree)
		end

		local v = table.random(table.random(table.random(list))).path

		if not vfs.IsFile(v) then
			wlog("chatsounds data for %s not found: %s doesn't exist", name, v, 2)
			return
		end

		chatsounds.list = chatsounds.list or {}

		for k,v in pairs(list) do
			if chatsounds.list[k] then
				table.merge(chatsounds.list[k], v)
			else
				chatsounds.list[k] = v
			end
		end

		chatsounds.tree = chatsounds.tree or {}
		table.merge(chatsounds.tree, tree)

		if autocomplete then
			event.Delay(0, function()
				chatsounds.BuildAutocomplete()
			end, nil, "chatsounds_autocomplete")
		end
	end, nil, nil, nil, true)
end

function chatsounds.AddSound(trigger, realm, ...)
	local tree = chatsounds.tree

	local data = {}

	for i, v in ipairs({...}) do
		data[i] = {path = v}
	end

	local words = trigger:explode(" ")

	local next = tree
	local max = #words
	for i, word in ipairs(words) do
		if not next[word] then next[word] = {} end

		if i == max then
			next[word].SOUND_DATA = next[word].SOUND_DATA or {trigger = trigger, realms = {}}

			next[word].SOUND_DATA.realms[realm] = {sounds = data, realm = realm}
		end

		next = next[word]
	end
end