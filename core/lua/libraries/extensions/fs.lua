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
            fs.create_directory(current_path)
        end

        return true
    end

    return fs.create_directory(path)
end

function fs.Remove(path)
    if path:endswith("/") then
        return fs.remove_directory(path)
    end

    return fs.remove_file(path)
end

function fs.RemoveRecursively(path)
	local files, err = fs.get_files_recursive(path)
    if files then
        local errors = {}
		table.sort(files, function(a, b) return #a > #b end)
        for _, path in ipairs(files) do
            local ok, err = fs.Remove(path)
            if not ok then
                table.insert(errors, err)
            end
        end
        if errors[1] then
            return nil, table.concat(errors, "\n")
        end
        return true
    end

    return files, err
end

function fs.CopyRecursively(path, to)
	local files, err = fs.get_files_recursive(path)
    if files then
        local errors = {}
		table.sort(files, function(a, b) return #a > #b end)
        for _, path in ipairs(files) do
            local ok, err = fs.copy(path, to)
            if not ok then
                table.insert(errors, err)
            end
        end
        if errors[1] then
            return nil, table.concat(errors, "\n")
        end
        return true
    end

    return files, err
end

function fs.GetFilesRecursive(path, blacklist)
    local cb

    if type(blacklist) == "string" then
        blacklist = {blacklist}
    end

    if type(blacklist) == "table" then
        cb = function(path)
            for _, v in ipairs(blacklist) do
                if path:endswith(v) then
                    return false
                end
            end
        end
    end

    return fs.get_files_recursive(path, cb)
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

function fs.Write(path, content)
    local f, err = io.open(path, "wb")
    if not f then return err end
    f:write(content)
    return f:close()
end

function fs.Read(path)
    local f, err = io.open(path, "rb")
    if not f then return err end
    local content = f:read("*all")
    f:close()
    return content
end

fs.Copy = fs.copy

function fs.Link(from, to)
    if fs.get_type(from) == "directory" then
        return fs.link(from, to, true)
    end

    return fs.link(from, to, false)
end