local serializer = _G.serializer or {}

serializer.libraries = {}

function serializer.AddLibrary(id, encode, decode, lib)
	serializer.libraries[id] = {encode = encode, decode = decode, lib = lib}
end

function serializer.GetAvailible()
	return serializer.libraries
end

function serializer.GetLibrary(name)
	return serializer.libraries[name] and serializer.libraries[name].lib
end

function serializer.Encode(lib, ...)
	lib = lib or "luadata"

	local data = serializer.libraries[lib]

	if not data then
		error("serializer " .. lib .. " not found", 2)
	end

	if data.encode then
		return data.encode(serializer.GetLibrary(lib), ...)
	end

	error("encoding not supported", 2)
end

function serializer.Decode(lib, ...)
	lib = lib or "luadata"

	local data = serializer.libraries[lib]

	if not data then
		error("serializer " .. lib .. " not found", 2)
	end

	if data.decode then
		return data.decode(serializer.GetLibrary(lib), ...)
	end

	error("decoding not supported", 2)
end

do -- vfs extension
	function serializer.WriteFile(lib, path, ...)
		return vfs.Write(path, serializer.Encode(lib, ...))
	end

	function serializer.ReadFile(lib, path, ...)
		local str = vfs.Read(path)
		if str then
			return serializer.Decode(lib, str)
		end
		return false, "no such file"
	end

	function serializer.StoreInFile(lib, path, key, value)
		local tbl = serializer.ReadFile(lib, path) or {}
		tbl[key] = value
		serializer.WriteFile(lib, path, tbl)
	end

	function serializer.GetKeyValuesInFile(lib, path)
		local tbl = serializer.ReadFile(lib, path) or {}
		return tbl
	end

	function serializer.LookupInFile(lib, path, key, def)
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

runfile("lua/libraries/serializers/*", serializer)

return serializer