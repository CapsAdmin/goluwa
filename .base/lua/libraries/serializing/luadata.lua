local luadata = _G.luadata or {}
local encode_table

local env = {}

luadata.Types = {}

function luadata.SetModifier(type, callback, global_ctor)
	luadata.Types[type] = callback
	
	if global_ctor then 
		env[global_ctor] = _G[global_ctor]
	end
end

luadata.SetModifier("rect", function(var) return ("Rect(%f, %f, %f, %f)"):format(var:Unpack()) end, "Rect")
luadata.SetModifier("color", function(var) return ("Color(%f, %f, %f, %f)"):format(var:Unpack()) end, "Color")
luadata.SetModifier("quat", function(var) return ("Quat(%f, %f, %f, %f)"):format(var:Unpack()) end, "Quat")
luadata.SetModifier("vec3", function(var) return ("Vec3(%f, %f, %f)"):format(var:Unpack()) end, "Vec3")
luadata.SetModifier("vec2", function(var) return ("Vec2(%f, %f)"):format(var:Unpack()) end, "Vec2")
luadata.SetModifier("ang3", function(var) return ("Ang3(%f, %f, %f)"):format(var:Unpack()) end, "Ang3")

luadata.SetModifier("cdata", function(var) return tostring(var) end)
luadata.SetModifier("cdata", function(var) return tostring(var) end)

luadata.SetModifier("number", function(var) return ("%s"):format(var) end)
luadata.SetModifier("string", function(var) return ("%q"):format(var) end)
luadata.SetModifier("boolean", function(var) return var and "true" or "false" end)
luadata.SetModifier("table", function(tbl, context)
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
			
			if context.thread then thread:Sleep() end
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

			if context.thread then thread:Sleep() end
		end
	end
	
	if context.tab == 0 then
		str[#str+1] = "\n"
	else
		str[#str+1] = ("%s}"):format(("\t"):rep(context.tab))
	end
		
	context.tab = context.tab - 1
	
	return table.concat(str, "")
end)

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
	setfenv(func, env)
	return func()
end

function luadata.Encode(tbl, callback, speed)
	if callback then
		local thread = utility.CreateThread()
		
		function thread:OnStart()
			return luadata.ToString(tbl, {thread = self})
		end
		
		function thread:OnFinish(...)
			callback(...)
		end
		
		function thread:OnError(msg)
			callback(false, msg)
		end
		
		thread:SetIterationsPerTick(speed)
		thread:Start()
	else
		return luadata.ToString(tbl)
	end
end

function luadata.Decode(str, skip_error)
	if not str then return {} end

	local func, err = loadstring("return {\n" .. str .. "\n}")
	
	if not func then
		if not skip_error then warning("luadata syntax error: ", err) end
		return {}
	end
	
	setfenv(func, env)
	
	local ok, err
	
	if not skip_error then 
		ok, err = xpcall(func, system.OnError)
	else 
		ok, err = pcall(func)
	end
	
	if not ok then
		if not skip_error then warning("luadata runtime error: ", err) end
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