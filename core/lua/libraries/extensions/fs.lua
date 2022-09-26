do
	fs.SetWorkingDirectory = fs.set_current_directory
	fs.GetWorkingDirectory = fs.get_current_directory
	utility.MakePushPopFunction(fs, "WorkingDirectory")
end

fs.GetAttributes = fs.get_attributes

function fs.CreateDirectory(path, force)
	if force then
		local current_path = ""

		for _, chunk in ipairs(path:split("/")) do
			current_path = current_path .. chunk .. "/"
			fs.create_directory(current_path)
		end

		return true
	end

	local ok, err = fs.create_directory(path)

	if not ok and err == "File exists" then return true end

	return ok, err
end

function fs.Remove(path)
	if path:ends_with("/") then return fs.remove_directory(path) end

	return fs.remove_file(path)
end

function fs.RemoveRecursively(path)
	local files, err = fs.get_files_recursive(path)

	if files then
		local errors = {}

		list.sort(files, function(a, b)
			return #a > #b
		end)

		for _, path in ipairs(files) do
			local ok, err = fs.Remove(path)

			if not ok then list.insert(errors, err) end
		end

		if errors[1] then return nil, list.concat(errors, "\n") end

		return true
	end

	return files, err
end

function fs.CopyRecursively(from, to, verbose)
	local files, err = fs.get_files_recursive(from)

	if not files then return nil, err end

	local ok, err = fs.CreateDirectory(to, true)

	if not ok then return nil, err end

	local errors = {}

	list.sort(files, function(a, b)
		return a:ends_with("/") and not b:ends_with("/")
	end)

	for i, path in ipairs(files) do
		local new_path = to .. path:sub(#from + 1)
		local ok, err

		if path:ends_with("/") then
			-- TODO: force creating directories shouldn't be nesseceary
			-- the sorting mechanism further up probably doesn't work correctly
			ok, err = fs.CreateDirectory(new_path, true)
		else
			ok, err = fs.copy(path, new_path)
		end

		if not ok and err ~= "File exists" then list.insert(errors, err) end

		if verbose then
			if ok then
				logn("created directory " .. new_path)
			else
				logn("failed to create directory " .. new_path)
				logn(err)
			end
		end
	end

	if errors[1] then return nil, list.concat(errors, "\n") end

	return true
end

do
	function fs.NormalizePath(path, relative)
		if not relative and not path:starts_with("/") and path:sub(2, 2) ~= ":" then
			local abs = fs.NormalizePath(fs.GetWorkingDirectory())

			if not abs:ends_with("/") then abs = abs .. "/" end

			path = abs .. path
		end

		local preserved_prefix = ""

		if path:starts_with([[\\?\]]) then
			preserved_prefix = [[\\?\]]
			path = path:sub(5)
		elseif path:starts_with([[\\]]) then
			preserved_prefix = [[\\]]
			path = path:sub(3)
		elseif path:sub(2, 2) == ":" then
			preserved_prefix = path:sub(1, 2)
			path = path:sub(3)
		end

		if path:find("\\", nil, true) then path = path:replace("\\", "/") end

		if path:find("//", nil, true) then
			path = path:replace("//", "/")
			path = path:replace("///", "/")
		end

		if path:sub(1, 2) == "./" then path = path:sub(3) end

		local slices = path:split("/")
		local count = #slices
		local normalized = preserved_prefix
		local consequtive_dots = slices[1] == ".."

		for i = 1, count do
			local slice = slices[i]

			if slice ~= ".." and slices[i + 1] == ".." then

			elseif slice ~= ".." or consequtive_dots then
				normalized = normalized .. slice

				if i ~= count then normalized = normalized .. "/" end
			end

			consequtive_dots = consequtive_dots and slice == ".."
		end

		return normalized
	end
end

function fs.Write(path, content, force)
	if force then fs.CreateDirectory(vfs.GetFolderFromPath(path), true) end

	local f, err = io.open(path, "wb")

	if not f then return nil, err end

	f:write(content)
	return f:close()
end

function fs.Read(path)
	local f, err = io.open(path, "rb")

	if not f then return nil, err end

	local content = f:read("*all")
	f:close()
	return content
end

fs.Copy = fs.copy
fs.GetFiles = fs.get_files

function fs.Link(from, to)
	if fs.get_type(from) == "directory" then return fs.link(from, to, true) end

	return fs.link(from, to, false)
end

function fs.IsFile(path)
	return fs.get_type(path) == "file"
end

function fs.IsDirectory(path)
	return fs.get_type(path) == "directory"
end
