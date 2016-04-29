local vfs = (...) or _G.vfs

function vfs.GetFiles(info)
	local out = {}

	if info.verbose then
		for _, data in ipairs(vfs.TranslatePath(info.path, true)) do
			local found = data.context:CacheCall("GetFiles", data.path_info)
			if found then
				for _, name in ipairs(found) do
					if not info.filter or name:find(info.filter, info.filter_pos, info.filter_plain) then
						table.insert(out, {
							name = name,
							filesystem = data.context.Name,
							full_path = data.context.Name .. ":" .. data.path_info.full_path .. name,
							full_path2 = data.path_info.full_path .. name,
							userdata = data.userdata,
						})
					end
				end
			end
		end

		if info.reverse_sort then
			table.sort(out, function(a, b) return a.full_path > b.full_path end)
		else
			table.sort(out, function(a, b) return a.full_path < b.full_path end)
		end
	else
		local done = {}

		for _, data in ipairs(vfs.TranslatePath(info.path, true)) do
			local found = data.context:CacheCall("GetFiles", data.path_info)
			if found then
				for _, name in ipairs(found) do
					if not done[name] then
						done[name] = true
						if info.full_path then
							name = data.path_info.full_path .. name
						end

						if not info.filter or name:find(info.filter, info.filter_pos, info.filter_plain) then
							table.insert(out, name)
						end
					end
				end
			end
		end

		done = nil

		if info.reverse_sort then
			table.sort(out, function(a, b) return a > b end)
		else
			table.sort(out, function(a, b) return a < b end)
		end
	end

	return out
end

function vfs.Find(path, full_path, reverse_sort, start, plain, verbose)
	local path_, filter = path:match("(.+)/(.*)")
	if filter then path = path_ end

	if filter == "" then filter = nil end

	return vfs.GetFiles({
		path = path,

		filter = filter,
		filter_pos = start,
		filter_plain = plain,

		verbose = verbose,
		full_path = full_path,
		reverse_sort = reverse_sort,
	})
end

function vfs.Iterate(path, ...)
	local tbl = vfs.Find(path, ...)
	local i = 1

	return function()
		local val = tbl[i]

		i = i + 1

		if val then
			return val
		end
	end
end

function vfs.Traverse(path, callback, level)
	level = level or 1

	local attributes = vfs.GetAttributes(path)

	if attributes then
		callback(path, attributes, level)

		if attributes.type == "directory" then
			for child in vfs.Iterate(path) do
				if child ~= "." and child ~= ".." then
					vfs.Traverse(path .. "/" .. child, callback, level + 1)
				end
			end
		end
	end
end

do
	local out
	local function search(path, ext, callback)
		for _, v in ipairs(vfs.Find(path, nil,nil,nil,nil, true)) do
			if not ext or v.name:endswith(ext) then
				if callback then
					if callback(v.full_path, v.userdata) ~= nil then
						return
					end
				else
					table.insert(out, v.full_path)
				end
			end

			if vfs.IsDirectory(path .. v.name) then
				search(path .. v.name .. "/", ext, callback)
			end
		end
	end

	function vfs.Search(path, ext, callback)
		out = {}
		search(path, ext, callback)
		return out
	end
end