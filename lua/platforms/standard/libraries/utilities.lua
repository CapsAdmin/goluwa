local utilities = _G.utilities or {}



do -- thanks etandel @ #lua!
	function utilities.SetGCCallback(t, func)
		func = func or t.Remove
		
		local ud = t.__gc or newproxy(true)
		
		debug.getmetatable(ud).__gc = function() 
			if not t.IsValid or t:IsValid() then
				return func(t) 
			end
		end
		
		t.__gc = ud  

		return t
	end
end

do
	-- http://cakesaddons.googlecode.com/svn/trunk/glib/lua/glib/stage1.lua
	local size_units = 
	{ 
		"B", 
		"KiB", 
		"MiB", 
		"GiB", 
		"TiB", 
		"PiB", 
		"EiB", 
		"ZiB", 
		"YiB" 
	}
	function utilities.FormatFileSize(size)
		local unit_index = 1
		
		while size >= 1024 and size_units[unit_index + 1] do
			size = size / 1024
			unit_index = unit_index + 1
		end
		
		return tostring(math.floor(size * 100 + 0.5) / 100) .. " " .. size_units[unit_index]
	end
end

function utilities.SafeRemove(obj, gc)
	if hasindex(obj) then
		
		if obj.IsValid and not obj:IsValid() then return end
		
		if type(obj.Remove) == "function" then
			obj:Remove()
		elseif type(obj.Close) == "function" then
			obj:Close()
		end
		
		if gc and type(obj.__gc) == "function" then
			obj:__gc()
		end
	end
end

function utilities.RemoveOldObject(obj, id)
	
	if hasindex(obj) and type(obj.Remove) == "function" then
		UTIL_REMAKES = UTIL_REMAKES or {}
			
		id = id or (debug.getinfo(2).currentline .. debug.getinfo(2).short_src)
		
		if typex(UTIL_REMAKES[id]) == typex(obj) then
			UTIL_REMAKES[id]:Remove()
		end
		
		UTIL_REMAKES[id] = obj
	end
	
	return obj
end

function utilities.OverrideUserDataMeta(udata, meta)
    local REAL = getmetatable(udata)
    local META = table.copy(REAL)

    META = table.merge(META, meta)

    function META:__index(key)
		if META[key] then
			return META[key]
		end

		return REAL.__index(self, key)
    end

    debug.setmetatable(udata, META)

    return udata
end

-- this was originally made for Texture, but it can be used for other things as well.
function utilities.UserDataToTable(udata)
	local META = getmetatable(udata)
	local udata = {udata = udata}

	for key, value in pairs(META) do
		if type(value) == "function" then
			udata[key] = function(self, ...)
				return META[key](self.udata, ...)
			end
		else
			udata[key] = value
		end
	end

	rawset(udata, "__newindex", nil)

	return udata
end

function utilities.FindMetaTable(var)
	if istype(var, "userdata", "table") then
		return getmetatable(T)
	elseif type(var) == "string" then
		return debug.getregistry()[var:lower()]
	end
end

function utilities.DeclareMetaTable(name, tbl)
	check(name, "string")
	check(tbl, "table")

	debug.getregistry()[name:lower()] = tbl
end

function utilities.DeriveMetaFromBase(meta_name, base_name, func_name)
	check(meta_name, "string", "userdata", "table")
	check(base_name, "string", "userdata", "table")
	check(func_name, "string")

	local meta = utilities.FindMetaTable(meta_name)
	local base = utilities.FindMetaTable(base_name)

	local func = meta[func_name]

	if not func then error("could not find the function name " .. func_name, 2) end
	
	local new
	for name in pairs(base) do
		if not meta[name] then
			meta[name] = base[name] or function(s, ...)
				new = func(s, ...)
				
				if new == s then
					error(("%s tried to use %s on self but returned itself"):format(meta_name, func_name))
				end
				
				return new[name](new, ...)
			end
		end
	end
end

function utilities.GetMetaTables()
	local temp = {}
	
	for key, val in pairs(debug.getregistry()) do
		if type(key) == "string" and type(val) == "table" and val.Type then
			temp[key] = val
		end
	end
	
	return temp
end

function utilities.MakeNULL(tbl)

	for k,v in pairs(tbl) do tbl[k] = nil end
	tbl.Type = "null"
	setmetatable(tbl, getmetatable(NULL))
	
	return var
end

function utilities.GetCurrentPath(level)
	return (debug.getinfo(level or 1).source:gsub("\\", "/"):sub(2):gsub("//", "/"))
end

function utilities.GeFolderFromPath(str)
	str = str or utilities.GetCurrentPath()
	return str:match("(.+/).+") or ""
end

function utilities.GetParentFolder(str, level)
	str = str or utilities.GetCurrentPath()
	return str:match("(.*/)" .. (level == 0 and "" or (".*/"):rep(level or 1))) or ""
end

function utilities.GetFolderNameFromPath(str)
	str = str or utilities.GetCurrentPath()
	if str:sub(#str, #str) == "/" then
		str = str:sub(0, #str - 1)
	end
	return str:match(".+/(.+)") or ""
end

function utilities.GetFileNameFromPath(str)
	str = str or utilities.GetCurrentPath()
	return str:match(".+/(.+)") or ""
end

function utilities.GetExtensionFromPath(str)
	str = str or utilities.GetCurrentPath()
	return str:match(".+%.(%a+)")
end

function utilities.GetFolderFromPath(self)
	return self:match("(.*)/") .. "/"
end

function utilities.GetFileFromPath(self)
	return self:match(".*/(.*)")
end

do 
	local hooks = {}

	function utilities.SetFunctionHook(tag, tbl, func_name, type, callback)
		local old = hooks[tag] or tbl[func_name]
		
		if type == "pre" then
			tbl[func_name] = function(...)
				local args = {callback(old, ...)}
				
				if args[1] == "abort_call" then return end
				if #args == 0 then return old(...) end
				
				return unpack(args)
			end
		elseif type == "post" then
			tbl[func_name] = function(...)
				local args = {old(...)}
				if callback(old, unpack(args)) == false then return end
				return unpack(args)
			end
		end
		
		return old
	end
	
	function utilities.RemoveFunctionHook(tag, tbl, func_name)
		local old = hooks[tag]
		
		if old then
			tbl[func_name] = old
			hooks[tag] = nil
		end
	end
end

do -- header parse
	local directories

	local function read_file(path)
		for _, dir in pairs(directories) do
			local str = vfs.Read(dir .. path)
			if str then
				return str
			end
		end
		
		for _, dir in pairs(directories) do
			local str = vfs.Read(dir .. path .. ".in")
			if str then
				return str
			end
		end
	end
	
	local macros = {}
	
	local function process_macros(str)
		for line in str:gmatch("(.-\n)") do
			if line:find("#") then
				local type = line:match("#%s-([%l%d_]+)()")
			
				print(type, line)
			end
		end
		
		return str
	end

	local included = {}

	local function process_include(str)
		local out = ""
		
		for line in str:gmatch("(.-\n)") do
			if not included[line] then
				if line:find("#include") then
					included[line] = true
					
					local path = line:match("%s-#include.-<(.-)>")
					
					if path then
						local content = read_file(path)
						
						if content then
							out = out .. "// HEADER: " .. path .. ";"
							out = out .. process_include(content)
						else
							out = out .. "// missing header " .. path .. ";"
						end
					end
				else 
					out = out .. line
				end
			end
			
			out = out
		end
		
		return out
	end

	local function remove_comments(str)
		str = str:gsub("/%*.-%*/", "")
		
		return str
	end

	local function remove_whitespace(str)
		str = str:gsub("%s+", " ")
		str = str:gsub(";", ";\n")
		
		return str
	end

	local function solve_definitions(str)
		local definitions = {}
		
		str = str:gsub("\\%s-\n", "")
		
		for line in str:gmatch("#define(.-)\n") do
			local key, val = line:match("%s-(%S+)%s-(%S+)")
			if key and val then
				definitions[key] = tonumber(val)
			end
		end
		 
		return str, definitions
	end
	 
	local function solve_typedefs(str)
		
		local typedefs = {}
			
		for line in str:gmatch("typedef(.-);") do
			if not line:find("enum") then
				local key, val = line:match("(%S-)%s-(%S+)$")
				if key and val then
					typedefs[key] = val
				end
			end
		end 
		
		return str, typedefs
	end

	local function solve_enums(str)
		local enums = {}
		
		for line in str:gmatch("(.-)\n") do

			if line:find("enum%s-{") then
				local i = 0
				local um = line:match(" enum {(.-)}")
				if not um then print(line) end
				for enum in (um .. ","):gmatch(" (.-),") do
					if enum:find("=") then
						local left, operator, right = enum:match(" = (%d) (.-) (%d)")
						enum = enum:match("(.-) =")
						if not operator then
							enums[enum] = enum:match(" = (%d)")
						elseif operator == "<<" then
							enums[enum] = bit.lshift(left, right)
						elseif operator == ">>" then
							enums[enum] = bit.rshift(left, right)
						end
					else
						enums[enum] = i
						i = i + 1
					end
				end
			end
		end
		
		return str, enums
	end

	function utilities.ParseHeader(path, directories_)
		directories = directories_

		local header, definitions, typedefs, enums

		header = read_file(path)

		header = process_macros(header)
		header = process_include(header)
		header = remove_comments(header)
		header = remove_whitespace(header)
		 
		header, definitions = solve_definitions(header)
		header, typedefs = solve_typedefs(header)
		header, enums = solve_enums(header)
		
		return {
			header = header, 
			definitions = definitions, 
			typedefs = typedefs, 
			enums = enums,
		}
	end
end

return utilities