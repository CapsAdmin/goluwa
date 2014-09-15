local utility = _G.utility or {}

include("mesh.lua", utility)
include("packed_rectangle.lua", utility)


function utility.TableToColumns(title, tbl, columns, check, sort_key)
	local top = {}
	
	for k, v in pairs(tbl) do
		if not check or check(v) then
			table.insert(top, {key = k, val = v})
		end
	end
	
	if type(sort_key) == "function" then
		table.sort(top, function(a, b)
			return sort_key(a.val, b.val)
		end)
	else
		table.sort(top, function(a, b)
			return a.val[sort_key] > b.val[sort_key]
		end)
	end

	local max_lengths = {}
	local temp = {}
	
	for i, column in ipairs(top) do
		for key, data in ipairs(columns) do
			data.tostring = data.tostring or function(...) return ... end
			data.friendly = data.friendly or data.key
			
			max_lengths[data.key] = max_lengths[data.key] or 0
			
			local str = tostring(data.tostring(column.val[data.key], column.val, top))
			column.str = column.str or {}
			column.str[data.key] = str
			
			if #str > max_lengths[data.key] then
				max_lengths[data.key] = #str
			end			
			
			temp[key] = data
		end
	end
	
	columns = temp
	
	local width = 0
		
	for k,v in pairs(columns) do 		
		if max_lengths[v.key] > #v.friendly then 
			v.length = max_lengths[v.key]
		else 
			v.length = #v.friendly + 1
		end 
		width = width + #v.friendly + max_lengths[v.key] - 2 
	end
	
	local out = " "
		
	out = out .. ("_"):rep(width - 1) .. "\n"
	out = out .. "|" .. (" "):rep(width / 2 - math.floor(#title / 2)) .. title .. (" "):rep(math.floor(width / 2) - #title + math.floor(#title / 2)) .. "|\n"
	out = out .. "|" .. ("_"):rep(width - 1) .. "|\n"

	for k,v in ipairs(columns) do 
		out = out .. "| " .. v.friendly .. ": " .. (" "):rep(-#v.friendly + max_lengths[v.key] - 1)  -- 2 = : + |
	end 
	out = out .. "|\n"
	
	
	for k,v in ipairs(columns) do 
		out = out .. "|" .. ("_"):rep(v.length + 2) 
	end 
	out = out .. "|\n"
	
	for k,v in ipairs(top) do 
		for _,column in ipairs(columns) do 
			out = out .. "| " .. v.str[column.key] .. (" "):rep(-#v.str[column.key] + column.length + 1) 
		end 
		out = out .. "|\n"
	end 
	
	out = out .. "|"
	
	out = out .. ("_"):rep(width-1) .. "|\n"


	return out
end

do -- tree
	local META = metatable.CreateTemplate("tree")

	function META:SetEntry(str, value)		
		local keys = type(str) == "table" and str or str and str:explode(self.delimiter) or {}
		
		local next = self.tree
				
		for i, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					next[key] = {}
				end
				next = next[key]
			end
		end
		
		next.key = str
		next.value = value
	end

	function META:GetEntry(str)		
		local keys = type(str) == "table" and str or str and str:explode(self.delimiter) or {}
				
		local next = self.tree
		
		for i, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					error("key ".. key .." not found")
				end
				next = next[key]
			end
		end
		
		return next.value
	end
	
	function META:GetChildren(str)		
		local keys = type(str) == "table" and str or str and str:explode(self.delimiter) or {}
		local next = self.tree
		
		for i, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					error("not found")
				end
				next = next[key]
			end
		end
				
		return next
	end

	function utility.CreateTree(delimiter)
		local self = META:New()
		
		self.tree = {}	
		self.delimiter = delimiter
		
		return self
	end
end

function utility.TableToFlags(flags, valid_flags)
	if type(flags) == "string" then
		flags = {flags}
	end
	
	local out = 0
	
	for k, v in pairs(flags) do
		local flag = valid_flags[v] or valid_flags[k]
		if not flag then 
			error("invalid flag", 2) 
		end
		out = bit.band(out, flag)
	end
	
	return out
end

function utility.FlagsToTable(flags, valid_flags)

	if not flags then return valid_flags.default_valid_flag end
	
	local out = {}
	
	for k, v in pairs(valid_flags) do
		if bit.band(flags, v) > 0 then
			out[k] = true
		end
	end
	
	return out
end

do -- long long
	ffi.cdef [[
	  typedef union {
		char b[8];
		int64_t i;
	  } buffer_int64;
	]]

	local btl = ffi.typeof("buffer_int64")
	
	function utility.StringToLongLong(str)
		return btl(str).i
	end
end

do -- find value
	local found =  {}
	local done = {}

	local skip =
	{
		UTIL_REMAKES = true,
		ffi = true,
	}

	local keywords =
	{
		AND = function(a, func, x,y) return func(a, x) and func(a, y) end	
	}

	local function args_call(a, func, ...)
		local tbl = {...}
		
		for i = 1, #tbl do
			local val = tbl[i]
			
			if not keywords[val] then
				local keyword = tbl[i+1]
				if keywords[keyword] and tbl[i+2] then
					local ret = keywords[keyword](a, func, val, tbl[i+2])
					if ret ~= nil then
						return ret
					end
				else
					local ret = func(a, val)
					if ret ~= nil then
						return ret
					end
				end
			end
		end
	end

	local function strfind(str, ...)
		return args_call(str, string.compare, ...) or args_call(str, string.find, ...)
	end

	local function find(tbl, name, dot, level, ...)
		if level >= 3 then return end
			
		for key, val in pairs(tbl) do	
			local T = type(val)
			key = tostring(key)
				
			if not skip[key] and T == "table" and not done[val] then
				done[val] = true
				find(val, name .. "." .. key, dot, level + 1, ...)
			else
				if (T == "function" or T == "number") and strfind(name .. "." .. key, ...) then					
					
					local nice_name
					
					if type(val) == "function" then
						local params = debug.getparams(val)
						
						if dot == ":" and params[1] == "self" then
							table.remove(params, 1)
						end
					
						nice_name = ("%s%s%s(%s)"):format(name, dot, key, table.concat(params, ", "))
					else
						nice_name = ("%s = %s"):format(key, val)
					end
				
					if name == "_G" or name == "_M" then
						table.insert(found, {key = key, val = val, name = name, nice_name = nice_name})
					else
						name = name:gsub("_G%.", "")
						name = name:gsub("_M%.", "")
						table.insert(found, {key = ("%s%s%s"):format(name, dot, key), val = val, name = name, nice_name = nice_name})
					end
				end
			end
		end
	end

	function utility.FindValue(...)		
		found = {}
		done = 
		{
			[_G] = true,
			[package] = true,
			[_OLD_G] = true,
		}
			
		find(_G, "_G", ".", 1, ...)
		find(metatable.GetAll(), "_M", ":", 1, ...)
		for cmd, v in pairs(console.GetCommands()) do
			if strfind(cmd, ...) then
				local arg_line = table.concat(debug.getparams(v.callback), ", ")
				arg_line = arg_line:gsub("line, ", "")
				arg_line = arg_line:gsub("line", "")
				
				table.insert(found, {key = cmd, val = v.callback, name = ("console.GetCommands().%s.callback"):format(cmd), nice_name = ("command->%s(%s)"):format(cmd, arg_line)})
			end
		end
		
		table.sort(found, function(a, b) 
			return #a.key < #b.key
		end)
		
		return found
	end
end

do -- thanks etandel @ #lua!
	function utility.SetGCCallback(t, func)
		func = func or t.Remove
		
		if not func then 
			error("could not find remove function", 2)
		end
		
		if ffi then
			local ud = t.__gc or ffi.new("char[1]")
						
			ffi.gc(ud, function()
				if not t.IsValid or t:IsValid() then
					return func(t) 
				end
			end)
			
			t.__gc = ud
		else
			local ud = t.__gc or newproxy(true)
			
			debug.getmetatable(ud).__gc = function() 
				if not t.IsValid or t:IsValid() then
					return func(t) 
				end
			end
			
			t.__gc = ud  
		end

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
	function utility.FormatFileSize(size)
		local unit_index = 1
		
		while size >= 1024 and size_units[unit_index + 1] do
			size = size / 1024
			unit_index = unit_index + 1
		end
		
		return tostring(math.floor(size * 100 + 0.5) / 100) .. " " .. size_units[unit_index]
	end
end

function utility.SafeRemove(obj, gc)
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

function utility.RemoveOldObject(obj, id)
	
	if hasindex(obj) and type(obj.Remove) == "function" then
		UTIL_REMAKES = UTIL_REMAKES or {}
			
		id = id or (debug.getinfo(2).currentline .. debug.getinfo(2).source)
		
		if typex(UTIL_REMAKES[id]) == typex(obj) then
			UTIL_REMAKES[id]:Remove()
		end
		
		UTIL_REMAKES[id] = obj
	end
	
	return obj
end

function utility.MakeNULL(tbl)

	for k,v in pairs(tbl) do tbl[k] = nil end
	tbl.Type = "null"
	setmetatable(tbl, getmetatable(NULL))
	
	return var
end

function utility.GetCurrentPath(level)
	return (debug.getinfo(level or 1).source:gsub("\\", "/"):sub(2):gsub("//", "/"))
end

function utility.GeFolderFromPath(str)
	str = str or utility.GetCurrentPath()
	return str:match("(.+/).+") or ""
end

function utility.GetParentFolder(str, level)
	str = str or utility.GetCurrentPath()
	return str:match("(.*/)" .. (level == 0 and "" or (".*/"):rep(level or 1))) or ""
end

function utility.GetFolderNameFromPath(str)
	str = str or utility.GetCurrentPath()
	if str:sub(#str, #str) == "/" then
		str = str:sub(0, #str - 1)
	end
	return str:match(".+/(.+)") or ""
end

function utility.GetFileNameFromPath(str)
	str = str or utility.GetCurrentPath()
	return str:match(".+/(.+)") or ""
end

function utility.GetExtensionFromPath(str)
	str = str or utility.GetCurrentPath()
	return str:match(".+%.(%a+)")
end

function utility.GetFolderFromPath(self)
	return self:match("(.*)/") .. "/"
end

function utility.GetFileFromPath(self)
	return self:match(".*/(.*)")
end

do 
	local hooks = {}

	function utility.SetFunctionHook(tag, tbl, func_name, type, callback)
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
	
	function utility.RemoveFunctionHook(tag, tbl, func_name)
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

	function utility.ParseHeader(path, directories_)
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

return utility