local chatsounds = ... or chatsounds

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

function chatsounds.BuildFromLegacyChatsoundsDirectory(addon_dir)
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

	chatsounds.GenerateAutocomplete()
end

function chatsounds.BuildFromURL(url, callback)
	resource.Download(url, function(path)
		local tree = {}
		local list = {}

		local function rebuild()
			chatsounds.list = chatsounds.list or {}
			table.merge(chatsounds.list, list)
			chatsounds.GenerateAutocomplete()

			tree = chatsounds.TableToTree(tree)
			chatsounds.tree = chatsounds.tree or {}
			table.merge(chatsounds.tree, tree)
		end

		callback(vfs.Read(path), function(realm, trigger, path)
			tree[realm] = tree[realm] or {}
			list[realm] = list[realm] or {}

			tree[realm][trigger] = tree[realm][trigger] or {}
			table.insert(tree[realm][trigger], {path = path})
			list[realm][trigger] = path

			event.Delay(0.1, rebuild, "rebuild_chatsounds")
		end)
	end, nil, nil, nil, true)
end

function chatsounds.BuildFromGithub(repo, location)
	local url = "https://api.github.com/repos/"..repo.."/git/trees/master?recursive=1"
	location = location or "sounds/chatsounds"

	chatsounds.BuildFromURL(url, function(str, add_sound)
		for path in str:gmatch('"path":%s-"('..location..'/.-)"') do
			if not path:endswith(".txt") then
				local realm, trigger, file_name = path:match(location .. "/(.-)/(.-)/(.+)%.")

				if not file_name then
					realm, trigger = path:match(location .. "/(.-)/(.+)%.")
				end

				if trigger and trigger:startswith("-") then
					local url = "https://raw.githubusercontent.com/"..repo.."/master/"

					if not file_name then
						url = url .. path:gsub(" ", "%%20"):gsub("(.+)(%..-)$", "%1.txt")
					else
						url = url .. (location.."/"..realm.."/"..trigger):gsub(" ", "%%20") .. ".txt"
					end

					resource.Download(url, function(trigger_file)
						trigger = vfs.Read(trigger_file)

						path = path:gsub(" ", "%%20")
						path = "https://raw.githubusercontent.com/"..repo.."/master/" .. path

						if realm then
							add_sound(realm, trigger, path)
						end
					end)
				else
					path = path:gsub(" ", "%%20")
					path = "https://raw.githubusercontent.com/"..repo.."/master/" .. path

					if realm then
						add_sound(realm, trigger, path)
					end
				end
			end
		end
	end)
end





function chatsounds.GenerateAutocomplete()
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
				chatsounds.GenerateAutocomplete()
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