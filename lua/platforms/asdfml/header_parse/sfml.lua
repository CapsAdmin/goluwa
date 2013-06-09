-- config

local library_path = "!/"
local headers_path = "lua/platforms/asdfml/header_parse/SFML/"

local make_library_globals = true
local library_global_prefix = "sf"

local camelCase = false

-- this favors ctors to createFromMemory
-- to otherwise create from file you need to provide "file" as first argument
local ctor_favor = "memory"

local global_libray = {e = {}}
local enum_library = global_libray.e

local parse_headers = true
local cache_parse = true

local libraries = {}
local headers = {}
local included = {}

local objects = {}
local structs = {}
local static = {}
local enums = {}

-- this is needed for some types
local translate = 
{
	Window = "window",
	Context = "window",
	Thread = "system",
	Mutex = "system",
	Clock = "system",
	Joystick = "window",
	Mouse = "window",
	Keyboard = "window", 
	Time = "system", 
	VideoMode = "window", 
	RenderWindow = "graphics",
}

local function type_to_library(type)
	if translate[type] then return translate[type] end

	if type:find("RenderWindow") then
		return "graphics"
	end
end

local function convert_name(name)
	local nice_name = name:match("sf.-_(.+)")
		
	if not camelCase then
		nice_name = nice_name:sub(1,1):upper() .. nice_name:sub(2)
	end
		
	return nice_name
end

local function load_libraries()
	for file_name in vfs.Iterate("") do
		local lib_name = file_name:match(WINDOWS and "csfml%-(.-)%-2.dll" or LINUX and "^libcsfml%-(.-)%.so$")
		if lib_name then
			local lib = ffi.load(file_name)
			libraries[lib_name] = lib
			
			if global_libray ~= _G then
				global_libray.raw = global_libray.raw or {}
				global_libray.raw[lib_name] = lib
			end
		end
	end
end

local function make_function(tbl, name, info, func)	
	local nice_name = convert_name(name)
	
	local script = [[
		function LIBRARY.__NAME__(__ARG_LINE__)
			return FUNCTION(__ARGUMENTS__) __RETURN__
		end
	]]
	
	script = script:gsub("__NAME__", nice_name)
	
	local arg_line = ""
	local arguments = ""

	for i, arg in pairs(info.arguments) do
		arg_line = arg_line .. arg.name
				
		local struct = arg.type:gsub("%*", ""):trim():sub(3) 
						
		if structs[struct] then  
			local cast = ("istype(ARG, typeof(TYPE)) and ARG or cast(TYPE, ARG)")
			cast = cast:gsub("ARG", arg.name)  
			cast = cast:gsub("TYPE", ("%q"):format(arg.type))
			
			arguments = arguments .. cast						
		else
			arguments = arguments .. arg.name
		end
		
		if i ~= #info.arguments then
			arg_line = arg_line .. ", "
			arguments = arguments .. ", "
		end
	end
	
	script = script:gsub("__ARG_LINE__", arg_line)
	script = script:gsub("__ARGUMENTS__", arguments)

	if info.return_type == "sfBool" then
		script = script:gsub("__RETURN__", "== 1")
	else
		script = script:gsub("__RETURN__", "")
	end
		
	local builder, err = loadstring(script)
	
	if not builder then
		print(script)
		return
	end
	
	setfenv(builder, {FUNCTION = func, LIBRARY = tbl, cast = ffi.cast, istype = ffi.istype, typeof = ffi.typeof})
	builder()
end

local function process_include(str)
	local out = ""
	
	for line in str:gmatch("(.-)\n") do
		if not included[line] then
			if line:find("#include") then
				included[line] = true
				
				local file = line:match("#include <(.-)>")
				file = file:gsub("SFML/", "")

				out = out .. process_include(vfs.Read(headers_path .. file) or (" // missing header " .. file))
			elseif not line:find("#") then
				out = out .. line
			end
		end
		
		out = out .. "\n"
	end
	
	return out
end

local function remove_definitions(str)
	str = str:gsub("CSFML_.- ", "")
	return str
end

local function remove_comments(str)
	str = str:gsub("//.-\n", "")
	return str
end

local function remove_whitespace(str)
	str = str:gsub("%s+", " ")
	str = str:gsub(";", ";\n")
	return str
end

local function process_header(header)
	local str = vfs.Read(headers_path .. header) or ""

	local out = process_include(str)
	out = remove_definitions(out)
	out = remove_comments(out)
	out = remove_whitespace(out)
	
	return out
end
	
local function generate_headers()
	for file_name in vfs.Iterate(headers_path) do
		if file_name:find(".h", nil, true) then
			local header = process_header(file_name)
			ffi.cdef(header)
			headers[file_name] = header
		end
	end
end

local function parse_args(line)
	local args = {}
	
	line = line .. ","
	
	for arg in line:gmatch("(.-),") do
		arg = arg:trim()
		
		local type, name = arg:match("(.-)([%a%d_]-)$")
		
		type = type:trim()
		name = name:trim()
		
		if type == "" and name then
			type = name
			name = "none"
		end		
		
		table.insert(args, {type = type, name = name})
	end
	
	return args
end 

if parse_headers then
	logn("PARSING HEADERS ...")
	
	generate_headers()
	
	-- enum parse
	for file_name, header in pairs(headers) do
		for line in header:gmatch("(.-)\n") do			
			if line:find("^ sf(%u%l-) sf(%u%l-);") then
				enums[line:match("%l (sf%u%l-);")] = file_name:gsub("%.h", ""):lower()
			end
			
			if line:find("enum") then
				line = line:gsub(" typedef", "")
				local i = 0
				for enum in (line:match(" enum {(.-)}") .. ","):gmatch(" (.-),") do
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
	end
	
	-- object parse
	do	
		-- first find all the constructors
		for file_name, header in pairs(headers) do
			for line in header:gmatch("(.-)\n") do
				if line:find("_create") then
					local type = line:match(" sf(.-)%*")
					if type then
						local ctor, arg_line = line:match("(sf"..type.."_create.-)%((.+)%);")
						
						if ctor then			
							local data = objects[type] or {} 
							
							data.lib = file_name:gsub("%.h", ""):lower()
							data.ctors = data.ctors or {}
							data.ctors[ctor] = parse_args(arg_line)
							
							objects[type] = data
						end
					end
				end
			end
		end
		
		-- then find all the functions
		for file_name, header in pairs(headers) do
			for line in header:gmatch("(.-)\n") do
				local type = line:match("sf([%a%d_]-)_")
				
				if objects[type] and not line:find("_create") then
					local return_type, func_name, arg_line = line:match("^ (.-) (sf" .. type .. "_.+)%((.+)%);")
					
					-- inconsitencies!
					if not return_type and not func_name and not arg_line then
						return_type, func_name = line:match("^ (.-) (sf" .. type .. "_.+)%(")
						arg_line = "void"
					end
					
					if return_type and func_name and arg_line then
						local data = objects[type]
						
						data.functions = data.functions or {}
						data.functions[func_name] = {return_type = return_type, arguments = parse_args(arg_line)}
						
						objects[type] = data
					end
				end
			end
		end
	end

	-- struct parse 
	do
		-- find all the constructors
		for file_name, header in pairs(headers) do
			for line in header:gmatch("(.-)\n") do
				
				local type
				
				if line:find("}") then
					type = line:match("} sf(.-);")
				else
					type = line:match("^ sf(.-) sf")
				end
				
				--if line:find("sfEvent") and line:find("union") then print(line) end
					
				if type then
					type = type:gsub("%*", "")
					
					if not objects[type] then
					
						local return_type, func_name, arg_line = line:match("^ (.-) (sf" .. type .. "_.+)%((.+)%);")
															
						if return_type and func_name and arg_line then
							-- if it has _create it's an object, not a struct
							if not func_name:find("_create") then
								local data = structs[type] or {}
								data[func_name] = {return_type = return_type, arguments = parse_args(arg_line)}
								structs[type] = data
							end
						else
							structs[type] = {}
						end
					end
				end
			end
		end
					
		-- then find all the functions
		for file_name, header in pairs(headers) do
			for line in header:gmatch("(.-)\n") do
				local type = line:match("sf([%a%d_]-)_")

				if structs[type] then
					local return_type, func_name, arg_line = line:match("^ (.-) (sf" .. type .. "_.+)%((.+)%);")
											
					-- inconsitencies!
					if not return_type and not func_name and not arg_line then
						return_type, func_name = line:match("^ (.-) (sf" .. type .. "_.+)%(")
						arg_line = "void"
					end
					
					if return_type and func_name and arg_line then
						local data = structs[type]
						
						data.lib = file_name:gsub("%.h", ""):lower()
						data.functions = data.functions or {}
						data.functions[func_name] = {return_type = return_type, arguments = parse_args(arg_line)}
						
						structs[type] = data
					end
				end
			end
		end			
		
		-- get rid of all the typedefs and enums
		for file_name, header in pairs(headers) do
			for line in header:gmatch("(.-)\n") do					
				local type = line:match(" typedef.-sf(.-);$")
			
				if type then
					structs[type] = nil
				end
				
				local type = line:match(" enum {.-} sf(.-);$")					
				
				if type then
					structs[type] = nil
				end
			end
		end
	end

	-- static parse
	for file_name, header in pairs(headers) do
		for line in header:gmatch("(.-)\n") do
			local type = line:match(".+sf(%u.-)_")
			if type then
				if not objects[type] and not structs[type] and not type:find("%s") then
					local return_type, func_name, arg_line = line:match("^ (.-) (sf" .. type .. "_.+)%((.+)%);")
					
					-- inconsitencies!
					if not return_type and not func_name and not arg_line then
						return_type, func_name = line:match("^ (.-) (sf" .. type .. "_.+)%(")
						arg_line = "void"
					end
					
					if return_type and func_name and arg_line then
						local data = static[type] or {}
						
						data.lib = file_name:gsub("%.h", ""):lower()
						
						data.functions = data.functions or {}
						data.functions[func_name] = {return_type = return_type, arguments = parse_args(arg_line)}
						
						static[type] = data
					end
				end
			end
		end
	end
	
	logn("PARSING DONE ...")
else
	logn("LOADING CACHED RESULTS...")

	objects = luadata.ReadFile(headers_path .. "../cached_parse/objects.dat")
	structs = luadata.ReadFile(headers_path .. "../cached_parse/structs.dat")
	static = luadata.ReadFile(headers_path .. "../cached_parse/static.dat")
	enums = luadata.ReadFile(headers_path .. "../cached_parse/enums.dat")
end
	
load_libraries()
	
if cache_parse then
	logn("SAVING RESULT")
	
	if luadata then
		luadata.WriteFile(headers_path .. "../cached_parse/objects.dat", objects)
		luadata.WriteFile(headers_path .. "../cached_parse/structs.dat", structs)
		luadata.WriteFile(headers_path .. "../cached_parse/static.dat", static)
		luadata.WriteFile(headers_path .. "../cached_parse/enums.dat", enums)
	end
end

logn("CREATING GLOBALS FROM RESULT")

-- enums
for k,v in pairs(enums) do
	local name = k:sub(3):gsub("%u", "_%1"):upper():sub(2)
	if type(v) == "number" then
		enum_library[name] = v
	else
		enum_library[name] = libraries[v][k]
	end
end
	
-- static
for lib_name, data in pairs(static) do
	local lib = global_libray[lib_name:lower()] or {}
	
	for name, info in pairs(data.functions) do		
		local module = type_to_library(name) or type_to_library(lib_name) or data.lib
		make_function(lib, name, info, libraries[module][name])
	end
	
	global_libray[lib_name:lower()] = lib
end

-- structs
for type, data in pairs(structs) do
	local declaration = "sf"..type
	
	local META = {}
	META.__index = META 
	
	function META:__tostring()
		return ("%s [%p]"):format(type, self)
	end
	
	if data.functions then
		for name, info in pairs(data.functions) do
			make_function(META, name, info, libraries[type_to_library(type) or data.lib][name])
		end
	end		
	
	local obj = ffi.metatype(declaration, META)
	
	global_libray[type] = function(...)
		return obj(...)
	end
end
	
-- objects
for type, data in pairs(objects) do
	local declaration = "sf"..type
			
	local META = {}
	META.__index = META
	
	function META:__tostring()
		return ("%s [%p]"):format(type, self)
	end
						
	-- object functions		
	if data.functions then
		for name, info in pairs(data.functions) do
			make_function(META, name, info, libraries[type_to_library(type) or data.lib][name])
		end
	end
	
	ffi.metatype(declaration, META)
	
	-- ctors
	do
		local script = 
			"return function(__ARG_LINE__)\n"..
			"__TYPE_CHECK__\n"..
			"end"
							
		local no_ctors = false
		
		if table.count(data.ctors) == 1 then
			for name, arguments in pairs(data.ctors) do
				if #arguments == 1 and arguments[1].type == "void" then
					no_ctors = name
				end
			end
		end
		
		local types = {}
		
		if no_ctors then
			script = script:gsub("__ARG_LINE__", "")
			script = script:gsub("__TYPE_CHECK__", ("\treturn\n\t\tLIBRARY[%q].%s()\n\t"):format(type_to_library(type) or data.lib, no_ctors))
		else
			local void_ctor
			local type_check = ""

			local arg_count = 2  
		
			for name, arguments in pairs(data.ctors) do
				arg_count = math.max(arg_count, arg_count + 1)
			end
			
			local arg_line = ""
			
			for i = 1, arg_count do					
				arg_line = arg_line .. "a" .. i
				
				if i ~= arg_count then
					arg_line = arg_line .. ", "
				end
			end
			
			script = script:gsub("__ARG_LINE__", arg_line)
			
			for name, arguments in pairs(data.ctors) do
				local module = type_to_library(type) or data.lib
				local nice_name = name:match("^sf%u.-_create(.+)")
						
				if nice_name then
					nice_name = nice_name:lower()
					nice_name = nice_name:gsub("^from", "")
					types[nice_name] = true
				end
					
				local arg_line = ""
				
				local count = #arguments
				
				if nice_name and nice_name ~= ctor_favor then
					count = count + 1
				end
				
				for i, arg in pairs(arguments) do
					i = i + 1
					
					if not nice_name or nice_name == ctor_favor then
						i = i - 1
					end
					
					local struct = arg.type:gsub("%*", ""):trim():sub(3) 
					
					if structs[struct] then  
						local cast = ("istype(ARG, typeof(TYPE)) and ARG or cast(TYPE, ARG)")
						cast = cast:gsub("ARG", "a" .. i) 
						cast = cast:gsub("TYPE", ("%q"):format(arg.type))
						
						arg_line = arg_line .. cast						
					else
						arg_line = arg_line .. "a" .. i
					end
					
					if i ~= count then
						arg_line = arg_line .. ", "
					end
				end
				
				if nice_name == ctor_favor then
					type_check = ("\tif not TYPES[a1] and TYPES[\""..ctor_favor.."\"] then\n\t\t\treturn\n\t\t\tLIBRARY[%q].%s(%s)\n\t\tend \n"):format(module, name, arg_line) .. type_check
				end					
				
				if nice_name then
					type_check = type_check .. ("\tif a1 == %q then\n\t\treturn\n\t\tLIBRARY[%q].%s(%s)\n\tend\n"):format(nice_name, module, name, arg_line)
				else
					void_ctor = ("\treturn\n\t\tLIBRARY[%q].%s(%s)\n\t"):format(module, name, arg_line)
				end 
			end	

			if void_ctor then
				type_check = type_check .. void_ctor
			else
				type_check = type_check .. "\terror('invalid arguments!', 2)\n"
			end
			
			script = script:gsub("__TYPE_CHECK__", type_check)
		end
					
		local builder, err = loadstring(script)
		if not builder then
			print(script)
			print(err)
		else 
			setfenv(builder, {TYPES = types, LIBRARY = libraries, cast = ffi.cast, typeof = ffi.typeof, istype = ffi.istype, error = error})
				
			global_libray[type] = builder()
		end
	end
end

return global_libray