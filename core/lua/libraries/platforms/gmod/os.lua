local file_Exists = gmod.file.Exists
local file_Read = gmod.file.Read
local file_Write = gmod.file.Write
local file_Delete = gmod.file.Delete
local util_CRC = gmod.util.CRC
local RealTime = gmod.RealTime
local util_RelativePathToFull = gmod.util.RelativePathToFull
local LocalPlayer = gmod.LocalPlayer

local dprint = function() end

local os = ... or _G.os

function os.getenv(var)
	var = tostring(var):lower()

	if var == "path" then
		return (util_RelativePathToFull("lua/includes/init.lua"):gsub("\\", "/"):gsub("lua/includes/init.lua", ""))
	end

	if var == "username" then
		return SERVER and "server" or LocalPlayer():Nick()
	end
end

function os.setlocale(...)
	dprint("os.setlocale: ", ...)
end

function os.execute(...)
	dprint("os.execute: ", ...)
end

function os.exit(...)
	dprint("os.exit: ", ...)
end

function os.remove(path)
	fs.uncache(path)

	local path, where = GoluwaToGmodPath(path)

	if file_Exists(path, where) then
		file_Delete(path, where)
		return true
	end

	return nil, filename .. ": No such file or directory", 2
end

function os.rename(a, b)
	fs.uncache(a)
	fs.uncache(b)

	local a, where_a = GoluwaToGmodPath(a)
	local b, where_b = GoluwaToGmodPath(b)

	dprint("os.rename: " .. a .. " >> " .. b)

	if file_Exists(a, where_a) then
		local str = file_Read(a, where_a)
		dprint("file.Read", a, where_a, type(str), str and #str)

		if not str then return nil, a .. ": exists but file.Read returns nil" end

		dprint("file.Delete", a, where_a)
		file_Delete(a, where_a)

		dprint("file.Write", b, #str)
		file_Write(b, str)
		return true
	end

	return nil, a .. ": No such file or directory", 2
end

function os.tmpname()
	return "os_tmpname_" .. util_CRC(RealTime())
end