function string.safeformat(str, ...)
	local count = select(2, str:gsub("(%%)", ""))
	local copy = {}
	for i = 1, count do
		table.insert(copy, tostringx(select(i, ...)))
	end
	return string.format(str, unpack(copy))
end

function string.findsimple(self, find)
	return self:find(find, nil, true) ~= nil
end

function string.findsimplelower(self, find)
	return self:lower():find(find:lower(), nil, true) ~= nil
end

function string.compare(self, target)
	return
		self == target or
		self:findsimple(target) or
		self:lower() == target:lower() or
		self:findsimplelower(target)
end

function string.trim(self, char)
    char = char or "%s"
    return self:gsub("^"..char.."*(.-)"..char.."*$", "%1" )
end

function string.getchar(self, pos)
	return string.sub(self, pos, pos)
end

function string.getbyte(self, pos)
	return self:getchar(pos):byte() or 0
end

function string.ulen(self)
	local len = 0
	
	for uchar in self:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		len = len + 1
    end
	
	return len
end

function string.usplit(self)
	local tbl = {}
	local len = 0
	local count = #uchar
	
	for uchar in self:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		tbl[#tbl + 1] = uchar
		len = len + count
	end
	
	return tbl
end

function string.explode(self, sep, pattern)
	if not sep or sep == "" then
		local tbl = {}
		local i = 1
		for char in self:gmatch(".") do
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

	for start_pos, end_pos in self:gmatch("()"..sep.."()") do
		tbl[i] = self:sub(last_pos, start_pos-1)
		last_pos = end_pos
		i=i+1
	end

	tbl[i] = self:sub(last_pos)

	return tbl
end

function string.count(self, pattern)
	return select(2, self:gsub(pattern, ""))
end

function string.containsonly(self, pattern)
	return self:gsub(pattern, "") == ""
end