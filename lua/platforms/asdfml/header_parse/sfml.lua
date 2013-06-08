-- config

local library_path = "!/"
local headers_path = "lua/platforms/asdfml/header_parse/SFML/"

local make_library_globals = true
local library_global_prefix = "sf"
local lowerHigher_case = false

local parse_headers = false
local cache_parse = false

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
}

local function lib_translate(str)
	if translate[str] then return translate[str] end
	
	if str:find("RenderWindow") then	
		return "graphics"
	end
end

local libraries = {}
local headers = {}
local included = {}

local function load_libraries()
	for file_name in vfs.Iterate("") do
		local lib_name = file_name:match(WINDOWS and "csfml%-(.-)%-2.dll" or LINUX and "^libcsfml%-(.-)%.so$")
		if lib_name then
			local lib = ffi.load(file_name)
			libraries[lib_name] = lib
			
			if make_library_globals then 
				_G[library_global_prefix .. lib_name] = libraries[lib_name]
			end
		end
	end
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

local function generate_objects()
	local objects = {}
	local structs = {}
	local static = {}
	local enums = {}
	
	
	if parse_headers then
		logn("PARSING HEADERS ...")
		for file_name, header in pairs(headers) do
			for line in header:gmatch("(.-)\n") do
				
				local type
				
				if line:find("}") then
					type = line:match("} (.-);")
				else
					type = line:match(" (.-) sf")
				end
				
				-- enum parse
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
				
				-- struct parse
				if type then
					type = type:gsub("%*", "")
					if not type:find("%s") and type:find("%u%l", 0) then
						type = type:sub(3)
						if not objects[type] then
							local data = structs[type] or {}
							local func_name = line:match(" (sf" .. type .. "_.-)%(")
							table.insert(data, func_name)
							structs[type] = data
						end
					end
				end
			end
		end
		
		-- object parse
		for file_name, header in pairs(headers) do
			for line in header:gmatch("(.-)\n") do
				if line:find("_create") then
					local type = line:match(" (sf.-)%*")
					if type then
						type = type:sub(3)
						
						local lib = file_name:gsub("%.h", ""):lower()
						lib = lib_translate(type) or lib
						
						local tbl = objects[type] or {ctors = {}, lib = lib, funcs = {}}
						local ctor = line:match("_createFrom(.-)%(")
						
						if ctor then
							table.insert(tbl.ctors, ctor)
						end
						
						-- asdasd
						if not type:find("_") then
							objects[type] = tbl
							structs[type] = nil
						end
					end
				end
			end
		end
		
		-- static parse
		for file_name, header in pairs(headers) do
			for line in header:gmatch("(.-)\n") do
				local type = line:match(".+(sf%u.-)_")
				if type then
					type = type:sub(3)
					if not objects[type] and not structs[type] and not type:find("%s") then
						if not objects[type] then
							local data = static[type] or {funcs = {}}
							local return_type, func_name = line:match(" (.-) (sf" .. type .. "_.-)%(")
							local lib = file_name:gsub("%.h", ""):lower()
							
							lib = lib_translate(type) or lib
												
							data.lib = lib
							table.insert(data.funcs, {return_type = return_type, name = func_name})
							static[type] = data
						end
					end
				end
			end
		end
		
		-- object function parse
		for type, data in pairs(objects) do	
			for file_name, header in pairs(headers) do
				for line in header:gmatch("(.-)\n") do
					if line:find(" sf" .. type .. "_") then
						local return_type, func_name = line:match(" (.-) (sf" .. type .. "_.-)%(")
						table.insert(data.funcs, {return_type = return_type, name = func_name})
					end
				end
			end
		end
	else
		objects = luadata.ReadFile(headers_path .. "../cached_parse/objects.dat")
		structs = luadata.ReadFile(headers_path .. "../cached_parse/structs.dat")
		static = luadata.ReadFile(headers_path .. "../cached_parse/static.dat")
		enums = luadata.ReadFile(headers_path .. "../cached_parse/enums.dat")
	end
	
	if cache_parse then
		if luadata then
			luadata.WriteFile(headers_path .. "../cached_parse/objects.dat", objects)
			luadata.WriteFile(headers_path .. "../cached_parse/structs.dat", structs)
			luadata.WriteFile(headers_path .. "../cached_parse/static.dat", static)
			luadata.WriteFile(headers_path .. "../cached_parse/enums.dat", enums)
		end
	end
	
	-- enum creation
	for k,v in pairs(enums) do
		local name = k:sub(3):gsub("%u", "_%1"):upper():sub(2)
		if type(v) == "number" then
			_E[name] = v
		else
			_E[name] = libraries[v][k]
		end
	end
	
	-- static creation
	for lib_name, data in pairs(static) do
		local lib = _G[lib_name:lower()] or {}
		
		for key, func_info in pairs(data.funcs) do
			local func_name = func_info.name:gsub("sf"..lib_name.."_", "")
			
			if not lowerHigher_case then
				func_name = func_name:sub(1,1):upper() .. func_name:sub(2)
			end
			
			local func = libraries[lib_translate(func_info.name) or data.lib][func_info.name]
			
			if func_info.return_type == "sfBool" then	
				lib[func_name] = function(...) return func(...) == 1 end
			else
				lib[func_name] = func
			end
		end
		
		_G[lib_name:lower()] = lib
	end
	
	-- struct ctors
	for type, func_name in pairs(structs) do
		local declaration = "sf"..type
		_G[type] = function(...)
			return ffi.new(declaration, ...)
		end
	end
	
	-- object ctors
	for type, data in pairs(objects) do
		local META = {}
		META.__index = META
		
		local ctors = {}
		local error_string = ""
			
		_G[type] = function(typ, ...)
			local ctor = _G.typex(typ) == "string" and typ:lower()

			if ctor then
				return ctors[ctor](...)
			elseif typ and ctors[""] then
				return ctors[""](typ, ...)
			else
				return ctors[""]()
			end

			error(string.format(error_string, _G.typex(var)), 2)
		end
		
		function META:__tostring()
			return ("%s [%s]"):format(type, self)
		end
		
		-- object functions
		for _, func_info in pairs(data.funcs) do
			local func_name = func_info.name
			if func_name == "sf"..type.."_create" then
				ctors[""] = libraries[data.lib][func_name]
			end
			local name = func_name:gsub("sf"..type.."_", "")
			
			if not lowerHigher_case then
				name = name:sub(1,1):upper() .. name:sub(2)
			end
			
			if func_info.return_type == "sfBool" then
				META[name] = function(self, ...)
					return libraries[data.lib][func_name](self, ...) == 1
				end
			else
				META[name] = function(self, ...)
					return libraries[data.lib][func_name](self, ...)
				end
			end
		end
		
		for i, ctor in pairs(data.ctors) do
			ctors[ctor:lower()] = libraries[data.lib]["sf"..type .. "_createFrom" .. ctor]
			
			if #data.ctors ~= i then
				error_string = error_string .. ctor:lower() .. ", "
			else
				error_string = error_string .. ctor:lower() .. " expected got %s"
			end
		end
				
		ffi.metatype("sf" .. type, META)
	end
end

load_libraries()
generate_headers()
generate_objects()