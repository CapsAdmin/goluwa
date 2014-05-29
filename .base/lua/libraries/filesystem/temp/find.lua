
function vfs.Find(path, invert, full_path, start, plain, dont_sort)
	check(path, "string")
	path = vfs.ParseVariables(path)
	
	-- if the path ends just with an "/"
	-- make it behave like /*
	if path:sub(-1) == "/" then
		path = path .. "."
	end
	
	local dir, pattern = path:match("(.+)/(.+)")
	
	-- if there is no pattern after "/"
	-- the path itself becomes the pattern and 
	-- plain search is used
	if not dir then
		pattern = path
		dir = ""
		plain = true
	end
	
	if path == "." or path == "/." or path == "" then
		pattern = "."
		plain = false
		dir = ""
	end
	
	local unique = {}
	
	if vfs.IsPathAbsolute(path) then
		pcall(function()
			for file_name in lfs.dir(dir) do
				if file_name ~= "." and file_name ~= ".." then
					if full_path then
						file_name = dir .. "/" .. file_name
					end
					unique[file_name] = true
				end
			end
		end)
	else
		for _, full_dir in ipairs(vfs.paths) do		
			local files = {}
	
			local res = full_dir.callback("find", full_dir.root .. "/" .. dir)

			if res then
				for i, file_name in pairs(res) do
					table.insert(files, file_name)
				end
			end
			
			for _, path in pairs(files) do
				if full_path then
					path = full_dir.root .. "/" .. dir .. "/" .. path
				end
				unique[path] = true
			end
		end
	end
			
	if not next(unique) then
		return unique
	end	
	
	local list = {}
	
	for path in pairs(unique) do
		local found = path:lower():find(pattern, start, plain)
		
		if invert then
			found = not found
		end
		
		if found then
			list[#list + 1] = vfs.FixPath(path)
		end
	end

	if not dont_sort then
		table.sort(list)
	end

	return list
end

function vfs.Iterate(path, ...)
	check(path, "string")
	
	local dir = path:match("(.+/)") or ""
	local tbl = vfs.Find(path, ...)
	local i = 1
	
	return function()
		local val = tbl[i]
		
		i = i + 1
		
		if val then 
			return val, dir .. val
		end
	end
end

function vfs.Traverse(path, callback, level)
	level = level or 1

	local attributes = vfs.GetAttributes(path)

	if attributes then
		callback(path, attributes, level)

		if attributes.mode == "directory" then
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
		for _,v in pairs(vfs.Find(path)) do
			if not ext or v:endswith(ext) then
				if callback and callback(path .. v) ~= nil then
					return
				end
				
				table.insert(out, path .. v)
			end
			
			if vfs.GetAttributes(path .. v).mode == "directory" then
				search(path .. v .. "/", ext, callback)
			end
		end
	end

	function vfs.Search(path, ext, callback)
		out = {}
		search(path, ext, callback)
		return out
	end
end