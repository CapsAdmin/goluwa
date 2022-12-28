local chatsounds = ... or chatsounds

local function read_list(base_url, sounds, list_id, skip_list)
	local tree = {}
	local lst = {}
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
			lst[realm] = lst[realm] or {}
			tree[realm][trigger] = tree[realm][trigger] or {}
			list.insert(tree[realm][trigger], {
				path = path,
				base_path = base_url,
			})
			lst[realm][trigger] = path
		end
	end

	tree = chatsounds.TableToTree(tree, list_id)

	if list_id then
		chatsounds.custom = chatsounds.custom or {}
		chatsounds.custom[list_id] = {
			tree = tree,
			list = lst,
		}
	else
		chatsounds.tree = chatsounds.tree or {}
		table.merge(chatsounds.tree, tree)
		chatsounds.list = chatsounds.list or {}
		table.merge(chatsounds.list, lst, true)
	end

	chatsounds.GenerateAutocomplete()

	if list_id then
		llog("loaded " .. #sounds .. " unqiue sounds from ", base_url)
	end
end

function chatsounds.BuildFromGithub(repo, location, list_id)
	location = location or "sounds/chatsounds"
	local base_url = "https://raw.githubusercontent.com/" .. repo .. "/master/" .. location .. "/"

	resource.Download(base_url .. "list.msgpack", nil, nil, true, "msgpack"):Then(function(path)
		--llog("found list.msgpack for ", location)
		local val = vfs.Read(path)
		read_list(base_url, val, list_id)
	end):Catch(function(reason)
		if list_id then

		--llog(repo, ": unable to find list.msgpack from \"", location, "\"")
		--llog(repo, ": parsing with github api instead (slower)")
		end

		local url = "https://api.github.com/repos/" .. repo .. "/git/trees/master?recursive=1"

		resource.Download(url, nil, nil, true):Then(function(path, etag_updated)
			local cached_path = "cache/" .. crypto.CRC32(url .. location) .. ".chatsounds_tree"
			local sounds = serializer.ReadFile("msgpack", cached_path)

			if not etag_updated and sounds then
				if sounds[1] and #sounds[1] >= 3 then
					read_list(base_url, sounds, list_id)
					return
				else
					llog("found cached list but format doesn't look right, regenerating.")
				end
			end

			llog("change detected ", base_url)
			local sounds = {}
			local str = assert(io.open(path, "rb"):read("*all"))
			local i = 1

			for path in str:gmatch("\"path\":%s?\"(.-)\"[\n,}]") do
				if path:starts_with(location) and path:ends_with(".ogg") then
					path = path:sub(#location + 2) -- start character after location, and another /
					local tbl = path:split("/")
					local realm = tbl[1]
					local trigger = tbl[2]

					if not tbl[3] then trigger = trigger:sub(1, -#".ogg" - 1) end

					sounds[i] = {
						realm,
						trigger,
						path,
					}

					if trigger:starts_with("-") then
						sounds[i][2] = sounds[i][2]:sub(2)
						sounds[i][4] = realm .. "/" .. trigger .. ".txt"
					end

					i = i + 1
				end
			end

			serializer.WriteFile("msgpack", cached_path, sounds)
			read_list(base_url, sounds, list_id)
		end)
	end)
end