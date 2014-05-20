local serializer = _G.serializer or {}

serializer.libraries = {}

function serializer.AddLibrary(id, encode, decode, lib)
	serializer.libraries[id] = {encode = encode, decode = decode, lib = lib}
end

function serializer.GetAvailible()
	return serializer.libraries
end

function serializer.GetLibrary(lib)
	return serializer.libraries[lib].lib
end

function serializer.Encode(lib, ...)
	lib = lib or "luadata"
	
	local data = serializer.libraries[lib]
	return data.encode(...)
end

function serializer.Decode(lib, ...)
	lib = lib or "luadata"
	
	local data = serializer.libraries[lib]
	return data.decode(...)
end

do -- vfs extension
	function serializer.WriteFile(lib, path, ...)
		vfs.Write(path, serializer.Encode(lib, ...), "b")
	end

	function serializer.ReadFile(lib, path, ...)
		return serializer.Decode(lib, vfs.Read(path, "b"))
	end

	function serializer.SetKeyValueInFile(lib, path, key, value)
		local tbl = serializer.ReadFile(lib, path)
		tbl[key] = value
		serializer.WriteFile(lib, path, tbl)
	end

	function serializer.GetKeyFromFile(lib, path, key, def)
		return serializer.ReadFile(lib, path)[key] or def
	end

	function serializer.AppendToFile(lib, path, value)
		local tbl = serializer.ReadFile(lib, path)
		table.insert(tbl, value)
		serializer.WriteFile(lib, path, tbl)
	end

end

local msgpack = require("msgpack")
serializer.AddLibrary("msgpack", function(...) return msgpack.Encode(...) end, function(...) return msgpack.Decode(...) end, msgpack)

local json = require("json")
serializer.AddLibrary("json", function(...) return json.encode(...) end, function(...) return json.decode(...) end, json)

local von = require("von")
serializer.AddLibrary("von", function(...) return von.serialize(...) end, function(...) return von.deserialize(...) end, von)

local luadata = include("luadata.lua")
serializer.AddLibrary("luadata", function(...) return luadata.Encode(...) end, function(...) return luadata.Decode(...) end, luadata)

local sigh = include("sigh.lua")
serializer.AddLibrary("sigh", function(...) return sigh.Encode(...) end, function(...) return sigh.Decode(...) end, sigh)

return serializer