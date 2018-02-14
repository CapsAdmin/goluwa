local META = gmod.FindMetaTable("File")
local file_obj_Write = META.Write
local file_obj_Read = META.Read
local file_obj_Size = META.Size
local file_obj_Close = META.Close
local file_obj_Flush = META.Flush
local file_obj_Seek = META.Seek
local file_obj_Tell = META.Tell

local file_Open = gmod.file.Open
local Msg = gmod.Msg
local GoluwaToGmodPath = GoluwaToGmodPath

local dprint = function(...) if DEBUG then gmod.print("[goluwa] io: ", ...) end end

local io = ... or _G.io

do -- file
	local META = {}
	META.__index = META

	function META:__tostring()
		return ("file (%p)"):format(self)
	end

	function META:write(...)

		local str = ""

		for i = 1, select("#", ...) do
			str = str .. tostring((select(i, ...)))
		end

		dprint("file " .. self.__path .. ":write: ", #str)

		file_obj_Write(self.__file, str)

		if self.uncache_on_write then
			fs.uncache(self.uncache_on_write)
		end
	end

	local function read(self, format)
		if type(format) == "number" then
			return file_obj_Read(self.__file, format)
		elseif format:sub(1, 2) == "*a" then
			return file_obj_Read(self.__file, file_obj_Size(self.__file))
		elseif format:sub(1, 2) == "*l" then
			local str = ""
			for i = 1, file_obj_Size(self.__file) do
				local char = file_obj_Read(self.__file, 1)
				if char == "\n" then break end
				str = str .. char
			end
			return str ~= "" and str or nil
		elseif format:sub(1, 2) == "*n" then
			local str = file_obj_Read(self.__file, 1)
			if tonumber(str) then
				return tonumber(str)
			end
		end
	end

	function META:read(...)
		dprint("file " .. self.__path .. ":read: ", ...)

		local args = {}

		for i = 1, select("#", ...) do
			args[i] = read(self, select(i, ...))
		end

		return unpack(args)
	end

	function META:close()
		file_obj_Close(self.__file)
	end

	function META:flush()
		file_obj_Flush(self.__file)
	end

	function META:seek(whence, offset)
		offset = offset or 0

		if whence == "set" then
			file_obj_Seek(self.__file, offset)
		elseif whence == "end" then
			file_obj_Seek(self.__file, file_obj_Size(self.__file))
		elseif whence == "cur" then
			file_obj_Seek(self.__file, file_obj_Tell(self.__file) + offset)
		end

		return file_obj_Tell(self.__file)
	end

	function META:lines()
		return function()
			return self:Read("*line")
		end
	end

	function META:setvbuf()

	end

	function io.open(path, mode)
		mode = mode or "r"

		local original_path = path

		local self = setmetatable({}, META)

		local path, where = GoluwaToGmodPath(path)

		local f = file_Open(path, mode, where)
		dprint("file.Open: ", f, path, mode, where)

		if not f then
			return nil, path .. " " .. mode .. " " .. where .. ": No such file", 2
		end

		if mode:find("w") then
			self.uncache_on_write = original_path
		end

		self.__file = f
		self.__path = path
		self.__mode = mode

		return self
	end
end

local current_file = io.stdin

function io.input(var)
	if io.type(var) == "file" then
		current_file = var
	else
		current_file = io.open(var)
	end

	return current_file
end

function io.type(var)
	if getmetatable(var) == META then
		return "file"
	end

	return nil
end

function io.write(...)
	local str = ""

	for i = 1, select("#", ...) do
		str = str .. tostring(select(i, ...))
	end

	Msg(str)
end

function io.read(...)
	return current_file:read(...)
end

function io.lines(...)
	return current_file:lines(...)
end

function io.flush(...)
	return current_file:flush(...)
end

function io.popen(...)
	dprint("io.popen: ", ...)
end

function io.close(...)
	return current_file:close(...)
end

function io.tmpfile(...)
	return io.open(os.tmpname(), "w")
end