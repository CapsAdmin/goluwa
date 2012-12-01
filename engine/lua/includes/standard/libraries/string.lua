local meta = getmetatable("")

F = string.format

function string.FindSimple(self, find)
	return self:find(find, nil, true) ~= nil
end

function string.FindSimpleLower(self, find)
	return self:lower():find(find:lower(), nil, true) ~= nil
end

function string.Explode(str, sep, pattern)
	if not sep or sep == "" then
		local tbl = {}
		local i = 1
		for char in str:gmatch(".") do
			tbl[i] = char
			i=i+1
		end
		return tbl
	end

	local tbl = {}
	local i, last_pos = 1,1

	if not pattern then
		sep = sep:gsub("[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
	end

	for start_pos, end_pos in str:gmatch("()"..sep.."()") do
		tbl[i] = str:sub(last_pos, start_pos-1)
		last_pos = end_pos
		i=i+1
	end

	tbl[i] = str:sub(last_pos)

	return tbl
end

string.explode = string.Explode

function string.Trim(str, char)
    char = char or "%s"
    return str:gsub("^"..char.."*(.-)"..char.."*$", "%1" )
end

string.trim = string.Trim

function string.GetFolderFromPath(self)
	return self:match("(.*)/") .. "/"
end

function string.GetFileFromPath(self)
	return self:match(".*/(.*)")
end

function string.Compare(self, target)
	return
		self == target or
		self:FindSimple(target) or
		self:lower() == target:lower() or
		self:FindSimpleLower(target)
end

function string.getbyte(self, pos)
	return string.sub(self, pos, pos):byte() or 0
end