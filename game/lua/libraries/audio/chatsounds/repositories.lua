local chatsounds = ... or chatsounds

local function read_list(base_url, sounds)
	local tree = {}
	local list = {}

	local function rebuild()
		tree = chatsounds.TableToTree(tree)
		chatsounds.tree = chatsounds.tree or {}
		table.merge(chatsounds.tree, tree)

		chatsounds.list = chatsounds.list or {}
		table.merge(chatsounds.list, list, true)
		chatsounds.GenerateAutocomplete()
	end

	local count = 0

	for i = 1, #sounds do
		local realm = sounds[i][1]
		local trigger = sounds[i][2]
		local path = sounds[i][3]
		local trigger_url = sounds[i][4]

		if trigger_url then
			count = count + 1
		else
			tree[realm] = tree[realm] or {}
			list[realm] = list[realm] or {}

			tree[realm][trigger] = tree[realm][trigger] or {}
			table.insert(tree[realm][trigger], {
				path = path,
				base_path = base_url,
			})

			list[realm][trigger] = path
		end
	end

	llog("loaded sounds from", base_url)

	event.Delay(0.5, rebuild, "rebuild_chatsounds")
end

function chatsounds.BuildFromGithub(repo, location)
	location = location or "sounds/chatsounds"

	local base_url = "https://raw.githubusercontent.com/" .. repo .. "/master/" .. location .. "/"

	resource.Download(
		base_url .. "list.msgpack",
		function(path)
			-- llog("found list.msgpack for ", location)
			read_list(base_url, serializer.ReadFile("msgpack", path))
		end,
		function()
			-- llog(repo, ": unable to find list.msgpack from \"", location, "\"")
			-- llog(repo, ": parsing with github api instead (slow)")

			local url = "https://api.github.com/repos/" .. repo .. "/git/trees/master?recursive=1"

			resource.Download(url, function(path)
				local cached_path = e.DATA_FOLDER .. "cache/" .. crypto.CRC32(url .. location) .. ".chatsounds_treecache"
				local sounds = serializer.ReadFile("msgpack", cached_path)

				if sounds then
					if sounds[1] and #sounds[1] >= 3 then
						read_list(base_url, sounds)
						return
					-- else
					-- 	llog("found cached list but format doesn't look right, regenerating.")
					end
				end

				local sounds = {}
				local str = assert(vfs.Read(path))
				local i = 1
				for path in str:gmatch('"path":%s?"(.-)"[\n,}]') do
					if path:startswith(location) and path:endswith(".ogg") then
						path = path:sub(#location + 2) -- start character after location, and another /

						local tbl = path:split("/")
						local realm = tbl[1]
						local trigger = tbl[2]

						if not tbl[3] then
							trigger = trigger:sub(1, -#".ogg" - 1)
						end

						sounds[i] = {
							realm,
							trigger,
							path,
						}

						if trigger:startswith("-") then
							sounds[i][2] = sounds[i][2]:sub(2)
							sounds[i][4] = realm .. "/" .. trigger .. ".txt"
						end

						i = i + 1
					end
				end

				serializer.WriteFile("msgpack", cached_path, sounds)

				read_list(base_url, sounds)
			end, nil, nil, nil, true)
		end,
		nil, nil, true
	)
end
