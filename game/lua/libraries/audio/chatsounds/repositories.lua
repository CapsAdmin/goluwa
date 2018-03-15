local chatsounds = ... or chatsounds

function chatsounds.BuildFromGithub(repo, location)
	location = location or "sounds/chatsounds"

	local url = "https://api.github.com/repos/"..repo.."/git/trees/master?recursive=1"

	resource.Download(url, function(path)
		local cached_path = "data/cache/" .. crypto.CRC32(url .. location) .. ".chatsounds_treecache"
		local cached_list = serializer.ReadFile("msgpack", cached_path)

		local data

		if cached_list and false then
			data = cached_list
		else
			local base_url = "https://raw.githubusercontent.com/"..repo.."/master/" .. location .. "/"

			data = {sounds = {}, base_url = base_url}

			local str = vfs.Read(path)
			local count = 0
			local i = 1
			for _, chunk in ipairs(str:split(PLATFORM == "gmod" and [["path":"]] or [["path": "]])) do
				if chunk:startswith(location) then
					local start = chunk:find('"', 1, true)
					local path = chunk:sub(#location + 2, start - 1)
					if path:endswith(".ogg") then
						local tbl = path:split("/")
						local realm = tbl[1]
						local trigger = tbl[2]

						if not tbl[3] then
							trigger = trigger:sub(1, -#".ogg" - 1)
						end

						if trigger:startswith("-") then
							local trigger_url = realm .. "/" .. trigger .. ".txt"

							data.sounds[i] = {
								t = trigger:sub(2),
								tu = trigger_url,
								r = realm,
								p = path,
							}
							i = i + 1
						else
							data.sounds[i] = {
								t = trigger,
								r = realm,
								p = path,
							}
							i = i + 1
						end
					end
				end
			end

			serializer.WriteFile("msgpack", cached_path, data)
		end

		local tree = {}
		local list = {}

		local function rebuild()
			tree = chatsounds.TableToTree(tree)
			chatsounds.tree = chatsounds.tree or {}
			table.merge(chatsounds.tree, tree)

			chatsounds.list = chatsounds.list or {}
			table.merge(chatsounds.list, list, true)
			chatsounds.GenerateAutocomplete()

			llog("rebuilt chatsounds lists")
		end

		local count = 0

		for i = 1, #data.sounds do
			local realm = data.sounds[i].r
			local path = data.sounds[i].p
			local trigger = data.sounds[i].t
			local trigger_url = data.sounds[i].tu

			if trigger_url then
				count = count + 1
			else
				tree[realm] = tree[realm] or {}
				list[realm] = list[realm] or {}

				tree[realm][trigger] = tree[realm][trigger] or {}
				table.insert(tree[realm][trigger], {path = path, base_path = data.base_url})

				list[realm][trigger] = path
			end
		end

		llog("loaded sounds from https://www.github.com/", repo, "/", location)

		if count ~= 0 then
			llog("\tcould not add ", count, " sounds due to a (temporary) design problem with chatsounds and too long paths")
		end

		event.Delay(0.5, rebuild, "rebuild_chatsounds")
	end, nil, nil, nil, true)
end