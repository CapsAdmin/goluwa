local vfs = (...) or _G.vfs

function vfs.GetFiles(info)
	local out = {}

	if info.verbose then
		local i = 1

		for _, data in ipairs(vfs.TranslatePath(info.path, true)) do
			local found = data.context:CacheCall("GetFiles", data.path_info)

			if found then
				local prefix = data.context.Name .. ":" .. data.path_info.full_path

				for _, name in ipairs(found) do
					if not info.filter or name:find(info.filter, info.filter_pos, info.filter_plain) then
						out[i] = {
							name = name,
							filesystem = data.context.Name,
							full_path = prefix .. name,
							userdata = data.userdata,
						}
						i = i + 1
					end
				end
			end
		end

		if not info.no_sort then
			if info.reverse_sort then
				list.sort(out, function(a, b)
					return a.full_path:lower() > b.full_path:lower()
				end)
			else
				list.sort(out, function(a, b)
					return a.full_path:lower() < b.full_path:lower()
				end)
			end
		end
	else
		local done = {}
		local i = 1

		for _, data in ipairs(vfs.TranslatePath(info.path, true)) do
			local found = data.context:CacheCall("GetFiles", data.path_info)

			if found then
				for _, name in ipairs(found) do
					if not done[name] then
						done[name] = true

						if info.full_path then name = data.path_info.full_path .. name end

						if not info.filter or name:find(info.filter, info.filter_pos, info.filter_plain) then
							out[i] = name
							i = i + 1
						end
					end
				end
			end
		end

		done = nil

		if not info.no_sort then
			if info.reverse_sort then
				list.sort(out, function(a, b)
					return a:lower() > b:lower()
				end)
			else
				list.sort(out, function(a, b)
					return a:lower() < b:lower()
				end)
			end
		end
	end

	return out
end

function vfs.Find(path, full_path, reverse_sort, start, plain, verbose)
	local path_, filter = path:match("(.+)/(.*)")

	if filter then path = path_ end

	if filter == "" then filter = nil end

	return vfs.GetFiles(
		{
			path = path,
			filter = filter,
			filter_pos = start,
			filter_plain = plain,
			verbose = verbose,
			full_path = full_path,
			reverse_sort = reverse_sort,
			no_filter = reverse_sort == nil,
		}
	)
end

function vfs.Iterate(path, ...)
	local tbl = vfs.Find(path, ...)
	local i = 1
	return function()
		local val = tbl[i]
		i = i + 1

		if val then return val end
	end
end

do
	local out

	local function search(path, ext, callback, dir_blacklist, include_directories, userdata)
		for _, v in ipairs(vfs.GetFiles({path = path, verbose = true, no_sort = true})) do
			local is_dir = vfs.IsDirectory(v.full_path)

			if (not ext or v.name:ends_with_these(ext)) and (not is_dir or include_directories) then
				if callback then
					if callback(v.full_path, v.userdata or userdata, v) ~= nil then
						return
					end
				else
					list.insert(out, v.full_path)
				end
			end

			if is_dir then
				local okay = true

				if dir_blacklist then
					for i, v2 in ipairs(dir_blacklist) do
						if v.full_path:find(v2) then
							okay = false

							break
						end
					end
				end

				if okay then
					search(
						v.full_path .. "/",
						ext,
						callback,
						dir_blacklist,
						include_directories,
						v.userdata or userdata
					)
				end
			end
		end
	end

	function vfs.GetFilesRecursive(path, ext, callback, dir_blacklist)
		out = {}
		search(path, ext, callback, dir_blacklist, include_directories)
		return out
	end
end