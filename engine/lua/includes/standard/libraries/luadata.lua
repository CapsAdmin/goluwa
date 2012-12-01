luadata = luadata or {} local s = luadata

luadata.EscapeSequences = {
	[("\a"):byte()] = [[\a]],
	[("\b"):byte()] = [[\b]],
	[("\f"):byte()] = [[\f]],
	[("\t"):byte()] = [[\t]],
	[("\r"):byte()] = [[\r]],
	[("\v"):byte()] = [[\v]],
}

local tab = 0

luadata.Types =
{
	number = function(var)
		return ("%s"):format(var)
	end,
	string = function(var)

		local str = ""

		for char in var:gmatch(".") do
			str = str  .. (s.EscapeSequences[str:byte()] or char)
		end

		if str:find('"', nil, true) then
			str = "'" .. str .. "'"
		else
			str = '"' .. str .. '"'
		end

		return str
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
	["function"] = function(var, key)
		--[[local str = "function " .. key .. "("
		local args = {}

		for i=1, math.huge do
			local key = debug.getupvalue(var, i)
			if key then
				table.insert(args, key)
			else
				break
			end
		end

		str = str .. table.concat(args, ", ") .. ") end"]]

		return "function() end"
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
	local func = s.Types[s.Type(var)]
	return func and func(var, key)
end

function luadata.FromString(str)
	local func = loadstring("return " .. str .. "luadata")
	return func()
end

function luadata.Encode(tbl, __brackets)
	local str = __brackets and "{\n" or ""

	for key, value in pairs(tbl) do
		value = s.ToString(value, key)
		key = s.ToString(key)
		
		if key and value and key ~= "__index" and value ~= _R then
			str = str .. ("\t"):rep(tab) ..  ("[%s] = %s,\n"):format(key, value)
		end
	end

	str = str .. ("\t"):rep(tab-1) .. (__brackets and "}" or "")

	return str
end

function luadata.Decode(str)
	if not str then return {} end
	local func, err = loadstring("return {\n" .. str .. "\n}", "luadata")
	if not func then
		error(err)
		return
	end
	return func()
end

do -- file extension

	function luadata.WriteFile(path, tbl, root)
		file.Write(path, luadata.Encode(tbl), root)
	end

	function luadata.ReadFile(path, root)
		return luadata.Decode(file.Read(path, root))
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