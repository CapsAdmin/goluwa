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
		vfs.Write(path, serializer.Encode(lib, ...))
	end

	function serializer.ReadFile(lib, path, ...)
		if vfs.IsFile(path) then
			return serializer.Decode(lib, vfs.Read(path))
		end
	end

	function serializer.SetKeyValueInFile(lib, path, key, value)
		local tbl = serializer.ReadFile(lib, path) or {}
		tbl[key] = value
		serializer.WriteFile(lib, path, tbl)
	end

	function serializer.GetKeyFromFile(lib, path, key, def)
		local tbl = serializer.ReadFile(lib, path)
		
		if tbl then
			local val = serializer.ReadFile(lib, path)[key]
			
			if val == nil then
				return def
			end
			
			return val
		end
		
		return def
	end

	function serializer.AppendToFile(lib, path, value)
		local tbl = serializer.ReadFile(lib, path) or {}
		table.insert(tbl, value)
		serializer.WriteFile(lib, path, tbl)
	end

end

local msgpack = require("luajit-msgpack-pure")
serializer.AddLibrary("msgpack", function(...) return msgpack.pack({...}) end, function(var) return unpack(select(2, msgpack.unpack(var))) end, msgpack)

local json = require("json")
serializer.AddLibrary("json", function(...) return json.encode(...) end, function(...) return json.decode(...) end, json)

local von = require("von")
serializer.AddLibrary("von", function(...) return von.serialize(...) end, function(...) return von.deserialize(...) end, von)

local gz = require("deflatelua")
serializer.AddLibrary("gunzip", function() end, function(str) 
	local out = {}
	local i = 1
	
	gz.gunzip({input = str, output = function(byte) 
		out[i] = string.char(byte) 
		i = i + 1 
	end, disable_crc = true})
		
	return table.concat(out)
end, gz)

local luadata = include("luadata.lua")
serializer.AddLibrary("luadata", function(...) return luadata.Encode(...) end, function(...) return luadata.Decode(...) end, luadata)


local simple = include("simple.lua")
serializer.AddLibrary("simple", function(...) return simple.Encode(...) end, function(...) return simple.Decode(...) end, simple)

local newline = include("newline.lua")
serializer.AddLibrary("newline", function(...) return newline.Encode(...) end, function(...) return newline.Decode(...) end, newline)

local sigh = include("sigh.lua")
serializer.AddLibrary("sigh", function(...) return sigh.Encode(...) end, function(...) return sigh.Decode(...) end, sigh)

return serializer