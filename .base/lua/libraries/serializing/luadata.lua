local luadata = _G.luadata or {}
local encode_table

luadata.Types =
{
	number = function(var)
		return ("%s"):format(var)
	end,
	string = function(var)
		return ("%q"):format(var)
	end,
	boolean = function(var)
		return var and "true" or "false"
	end,
	table = function(tbl, context)
		local str
		
		context.tab = context.tab + 1
		
		if context.tab == 0 then 	
			str = {}
		else
			str = {"{\n"} 
		end
		
		if table.isarray(tbl) then
			for i = 1, #tbl do
				str[#str+1] = ("%s%s,\n"):format(("\t"):rep(context.tab), luadata.ToString(tbl[i], context))
				
				if context.yield then 
					coroutine.yield() 
				end
			end
		else
			for key, value in pairs(tbl) do
				value = luadata.ToString(value, context)
				
				if value then	
					if type(key) == "string" and key:find("^%a[%w_]+$") then
						str[#str+1] = ("%s%s = %s,\n"):format(("\t"):rep(context.tab), key, value)
					else
						key = luadata.ToString(key, context)
						
						if key then
							str[#str+1] = ("%s[%s] = %s,\n"):format(("\t"):rep(context.tab), key, value)
						end
					end
				end

				if context.yield then 
					coroutine.yield() 
				end
			end
		end
		
		if context.tab == 0 then
			str[#str+1] = "\n"
		else
			str[#str+1] = ("%s}"):format(("\t"):rep(context.tab))
		end
			
		context.tab = context.tab - 1
		
		return table.concat(str, "")
	end,
	cdata = function(var)
		return tostring(var)
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

function luadata.ToString(var, context)
	context = context or {}
	context.tab = context.tab or -1
	context.out = context.out or {}
	
	local func = luadata.Types[luadata.Type(var)]
	return func and func(var, context)
end

function luadata.FromString(str)
	local func = assert(loadstring("return " .. str))
	return func()
end

function luadata.Encode(tbl, callback, speed)
	if callback then
		local co = coroutine.create(function() 
			return luadata.ToString(tbl, {yield = true})
		end)
		event.CreateThinker(function()
			local ok, data = coroutine.resume(co)
			if ok then
				if data then
					xpcall(callback, system.OnError, data)
					return true
				end
			else
				xpcall(callback, system.OnError, false, data)
				return true
			end
		end, speed)
	else
		return luadata.ToString(tbl)
	end
end

function luadata.Decode(str)
	if not str then return {} end

	local func, err = loadstring("return {\n" .. str .. "\n}")
	
	if not func then
		logn("luadata syntax error:")
		logn(err)		
		return {}
	end
	
	local ok, err = xpcall(func, system.OnError)
	
	if not ok then
		logn("luadata runtime error:")
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