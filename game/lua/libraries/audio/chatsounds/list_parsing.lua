local chatsounds = ... or chatsounds

function chatsounds.BuildFromSoundDirectory(where)
	where = where or "sounds/chatsounds/"
	local tree = {}
	local lst = {}

	for realm in vfs.Iterate(where) do
		tree[realm] = {}
		lst[realm] = {}

		for trigger in vfs.Iterate(where .. realm .. "/") do
			local path = where .. realm .. "/" .. trigger
			trigger = trigger:match("(.+)%.")

			if vfs.IsFile(path) then
				tree[realm][trigger] = {{path = path}}
				lst[realm][trigger] = path
			else
				tree[realm][trigger] = {}

				for file_name in vfs.Iterate(path .. "/") do
					list.insert(tree[realm][trigger], path .. "/" .. file_name)
					lst[realm][trigger] = path .. "/" .. file_name
				end
			end
		end
	end

	chatsounds.list = chatsounds.list or {}
	table.merge(chatsounds.list, lst, true)
	tree = chatsounds.TableToTree(tree)
	chatsounds.tree = chatsounds.tree or {}
	table.merge(chatsounds.tree, tree)
	local lst = {}

	for _, val in pairs(chatsounds.list) do
		for key in pairs(val) do
			list.insert(lst, key)
		end
	end

	list.sort(lst, function(a, b)
		return #a < #b
	end)

	autocomplete.AddList("chatsounds", lst)
end

function chatsounds.GenerateAutocomplete()
	local function build(root_list, id)
		local lst = {}
		local done = {}

		for _, val in pairs(root_list) do
			for key in pairs(val) do
				if not done[key] then
					list.insert(lst, key)
					done[key] = true
				end
			end
		end

		list.sort(lst, function(a, b)
			return #a < #b
		end)

		autocomplete.AddList(id, lst)
	end

	if chatsounds.list then build(chatsounds.list, "chatsounds") end

	if chatsounds.custom then
		for id, data in pairs(chatsounds.custom) do
			if data.list then build(data.list, "chatsounds_custom_" .. id) end
		end
	end
end

function chatsounds.ListToTable(data)
	local lst = {}
	local realm = "misc"

	for path, trigger in data:gmatch("(.-)=(.-)\n") do
		if path == "realm" then
			realm = trigger
		else
			if not lst[realm] then lst[realm] = {} end

			if not lst[realm][trigger] then lst[realm][trigger] = {} end

			list.insert(lst[realm][trigger], {path = path})
		end
	end

	return lst
end

local sort = function(a, b)
	return a.key < b.key
end
local sort2 = function(a, b)
	return a.val.path < b.val.path
end

function chatsounds.TableToList(tbl)
	local str = {}

	for realm, list in table.sorted_pairs(tbl, sort) do
		str[#str + 1] = "realm=" .. realm
		local done = {}

		for trigger, sounds in pairs(list) do
			for _, data in table.sorted_pairs(sounds, sort2) do
				local val = data.path .. "=" .. trigger

				if not done[val] then
					str[#str + 1] = val
					done[val] = true
				end
			end
		end
	end

	return list.concat(str, "\n")
end

function chatsounds.TableToTree(tbl)
	local tree = {}

	for realm, list in pairs(tbl) do
		for trigger, sounds in pairs(list) do
			local words = {}

			for word in (trigger .. " "):gmatch("(.-)%s+") do
				list.insert(words, word)
			end

			local next = tree
			local max = #words

			for i, word in ipairs(words) do
				if not next[word] then next[word] = {} end

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
	local list_path = "data/chatsounds/lists/" .. name .. ".txt"
	local tree_path = "data/chatsounds/trees/" .. name .. ".dat"

	resource.Download(list_path, nil, nil, true):Then(function(list_path)
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
		table.merge(chatsounds.list, list, true)
		chatsounds.tree = chatsounds.tree or {}
		table.merge(chatsounds.tree, tree)

		if autocomplete then
			timer.Delay(
				0.1,
				function()
					chatsounds.GenerateAutocomplete()
				end,
				"chatsounds_autocomplete"
			)
		end
	end)
end

function chatsounds.AddSound(trigger, realm, ...)
	local data = {}

	for i, v in ipairs({...}) do
		data[i] = {path = v}
	end

	chatsounds.list = chatsounds.list or {}
	chatsounds.list[realm] = chatsounds.list[realm] or {}
	chatsounds.list[realm][trigger] = data
	local words = trigger:explode(" ")
	local next = chatsounds.tree
	local max = #words

	for i, word in ipairs(words) do
		if not next[word] then next[word] = {} end

		if i == max then
			next[word].SOUND_DATA = next[word].SOUND_DATA or {trigger = trigger, realms = {}}
			next[word].SOUND_DATA.realms[realm] = {sounds = data, realm = realm}
		end

		next = next[word]
	end

	timer.Delay(
		0.1,
		function()
			chatsounds.GenerateAutocomplete()
		end,
		"chatsounds_autocomplete"
	)
end