local CompileString = gmod.CompileString
local file_Read = gmod.file.Read
local file_Exists = gmod.file.Exists

function loadstring(str, chunkname)
	local var = CompileString(str, chunkname or "loadstring", false)
	if type(var) == "string" then
		return nil, var, 2
	end
	return setfenv(var, getfenv(1))
end

function loadfile(path)
	if not file_Exists(path, "LUA") then
		return nil, path .. ": No such file", 2
	end

	local lua = file_Read(path, "LUA")

	return env.loadstring(lua, path)
end

function dofile(filename)
	return assert(env.loadfile(filename))()
end