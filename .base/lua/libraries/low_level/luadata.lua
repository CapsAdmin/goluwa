local luadata = _G.luadata or {}

local tab = 0

luadata.Types =
{
	number = function(var)
		return ("%s"):format(var)
	end,
	string = function(var)
		return ("%q"):format(var)
	end,
	boolean = function(var)
		return ("%s"):format(var and "true" or "false")
	end,
	table = function(var)
		tab = tab + 1
		local str = luadata.Encode(var, true)
		tab = tab - 1
		return str
	end,
}

function luadata.SetModifier(type, callback)
	luadata.Types[type] = callback
end

function luadata.Type(var)
	local t = typex(var)

	if t == "table" then
		if var.LuaDataType then
			t = var.LuaDataType
		end
	end

	return t
end

function luadata.ToString(var, key)
	local func = luadata.Types[luadata.Type(var)]
	return func and func(var, key)
end

function luadata.FromString(str)
	local func = assert(loadstring("return " .. str))
	return func()
end

function luadata.Encode(tbl, __brackets)
	local str = {__brackets and "{\n" or ""}

	for key, value in pairs(tbl) do
		value = luadata.ToString(value, key)
		key = luadata.ToString(key)
		
		if key and value and key ~= "__index" and value ~= _R then
			str[#str+1] = ("%s[%s] = %s,\n"):format(("\t"):rep(tab), key, value)
		end
	end

	str[#str+1] = (__brackets and "%s}\n" or "%s\n"):format(("\t"):rep(tab-1))

	return table.concat(str, "")
end

function luadata.Decode(str)
	if not str then return {} end

	local func = loadstring("return {\n" .. str .. "\n}")
	
	if type(func) == "string" then
		logn("luadata decode error:")
		logn(err)
		
		return {}
	end
	
	local ok, err = xpcall(func, mmyy.OnError)
	
	if not ok then
		logn("luadata decode error:")
		logn(err)
		return {}
	end
	
	return err
end

do -- vfs extension

	function luadata.WriteFile(path, tbl, ...)
		vfs.Write(path, luadata.Encode(tbl), ...)
	end

	function luadata.ReadFile(path, ...)
		return luadata.Decode(vfs.Read(path, ...))
	end

	function luadata.SetKeyValueInFile(path, key, value)
		local tbl = luadata.ReadFile(path)
		tbl[key] = value
		luadata.WriteFile(path, tbl)
	end

	function luadata.GetKeyFromFile(path, key, def)
		return luadata.ReadFile(path)[key] or def
	end

	function luadata.AppendToFile(path, value)
		local tbl = luadata.ReadFile(path)
		table.insert(tbl, value)
		luadata.WriteFile(path, tbl)
	end

end

return luadata