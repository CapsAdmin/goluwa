local META = {}
META.__index = META

function META:__tostring()
	return ("file (%p)"):format(self)
end

function META:write(...)
	local str = ""

	for i = 1, select("#", ...) do
		str = str .. tostring(select(i, ...))
	end

	return self.env.callback("file", "write", self.udata, str)
end

local function read(self, format)
	format = format or "*line"

	if type(format) == "number" then	
		return self.env.callback("file", "read", self.udata, "bytes", format)
	elseif format:sub(1, 2) == "*a" then
		return self.env.callback("file", "read", self.udata, "all")
	elseif format:sub(1, 2) == "*l" then
		return self.env.callback("file", "read", self.udata, "line")
	elseif format:sub(1, 2) == "*n" then
		return self.env.callback("file", "read", self.udata, "newline")
	end
end

function META:read(...)
	local args = {...}

	for k, v in ipairs(args) do
		args[k] = read(self, v) or nil
	end

	return unpack(args) or nil
end

function META:close()
	self.env.callback("file", "close", self.udata)
end

function META:flush()
	self.env.callback("file", "flush", self.udata)
end

function META:seek(whence, offset)
	whence = whence or "cur"
	offset = offset or 0

	return self.env.callback("file", "seek", self.udata, whence, offset)
end

function META:lines()
	return self.env.callback("file", "read", self.udata, "lines")
end

function META:setvbuf()
	self.env.callback("file", "read", self.udata, "setvbuf")
end

function vfs.CreateDummyFile(udata, env)
	mode = mode or "r"

	local self = setmetatable({}, META)
	
	self.udata = udata
	self.env = env
	self.__mode = mode

	return self
end