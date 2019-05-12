do
	fs.SetWorkingDirectory = fs.set_current_directory
	fs.GetWorkingDirectory = fs.get_current_directory

    utility.MakePushPopFunction(fs, "WorkingDirectory")
end

fs.GetAttributeus = fs.get_attributes

function fs.CreateDirectory(path, force)
    if force then
        local current_path = ""
        for _, chunk in ipairs(path:split("/")) do
            current_path = current_path .. chunk .. "/"
            local ok, err = fs.create_directory(current_path)
            if not ok then
                return ok, err
            end
        end

        return true
    end

    return fs.create_directory(path)
end

function fs.Remove(path)
    return fs.remove(path)
end

function fs.RemoveRecursively(path)
	local files = fs.get_files_recursive(path)
	if files then
		table.sort(files, function(a, b) return #a > #b end)
        for _, path in ipairs(files) do
            print(fs.NormalizePath(path))
			--assert(fs.Remove(path))
		end
	end
end

do
    function fs.NormalizePath(path, relative)
        if not relative and not path:startswith("/") and path:sub(2, 2) ~= ":" then
            local abs = fs.NormalizePath(fs.GetWorkingDirectory())
            if not abs:endswith("/") then
                abs = abs .. "/"
            end
            path = abs .. path
        end

        local preserved_prefix = ""

        if path:startswith([[\\?\]]) then
            preserved_prefix = [[\\?\]]
            path = path:sub(5)
        elseif path:startswith([[\\]]) then
            preserved_prefix = [[\\]]
            path = path:sub(3)
        elseif path:sub(2, 2) == ":" then
            preserved_prefix = path:sub(1, 2)
            path = path:sub(3)
        end

        if path:find("\\", nil, true) then
            path = path:replace("\\", "/")
        end

        if path:find("//", nil, true) then
            path = path:replace("//", "/")
            path = path:replace("///", "/")
        end

        if path:sub(1, 2) == "./" then
            path = path:sub(3)
        end

        local slices = path:split("/")
        local count = #slices
        local normalized = preserved_prefix
        local consequtive_dots = slices[1] == ".."

        for i = 1, count do
            local slice = slices[i]
            if slice ~= ".." and slices[i + 1] == ".." then

            elseif slice ~= ".." or consequtive_dots then
                normalized = normalized .. slice
                if i ~= count then
                    normalized = normalized .. "/"
                end
            end

            consequtive_dots = consequtive_dots and slice == ".."
        end

        return normalized
    end
end

if RELOAD then
    profiler.MeasureFunction(function()
        fs.RemoveRecursively("metastruct_addons")
    end, 1)
end