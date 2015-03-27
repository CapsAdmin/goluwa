local xml = vfs.Read("gl.xml")

local manual_enum_group_fixup = {
	texture = {
		target = "TextureTarget",
		pname = "GetTextureParameter",
	}
}

local enum_group_name_strip = {
	texture = "texture",
}

local enums = {}

for value, enum in xml:gmatch("<enum value=\"(.-)\" name=\"(.-)\"") do 
	if #value < 18 then
		enums[enum] = tonumber(value)
	end
end

local enum_groups = {}

for group, enums_ in xml:gmatch("<group name=\"(.-)\"(.-)</group>") do 
	enum_groups[group] = {}
	for enum in enums_:gmatch("name=\"(.-)\"/>") do
		local friendly = enum:lower():sub(4)
		
		for k,v in pairs(enum_group_name_strip) do
			if group:lower():find(k, nil, true) then
				friendly = friendly:gsub(v, ""):trim("_")
				break
			end
		end
		
		enum_groups[group][friendly] = enums[enum]
	end
end

local friendly_enums = {}
for k,v in pairs(enums) do
	friendly_enums[k:lower():sub(4)] = v
end

enum_groups.not_found = friendly_enums

local functions = {}

for str in xml:gmatch("<command>(.-)</command>") do
	local func_str = str:match("<proto.-</proto>")
	local name = func_str:match("<name>(.-)</name>")
	local type = func_str:match("<ptype>(.-)</ptype>")
	local group = func_str:match("group=\"(.-)\"")
	
	local func_name = str:match("<proto.-<name>(.-)</name></proto>")
	local args = {}
	local i = 1
		
	local cast_str = (str:match("<proto.->(.-)<name>") or str:match("<ptype.->(.-)</ptype>")) .. "(*)("
	
	if cast_str:find("ptype", nil, true) then
		cast_str = cast_str:gsub("<ptype>", "")
		cast_str = cast_str:gsub("</ptype>", "")
	end
	
	for param in str:gmatch("<param.-</param>") do
		local name = param:match("<name>(.-)</name>")
		local type = param:match("<param.->(.-)<name>")
		type = type:gsub("<ptype>", "")
		type = type:gsub("</ptype>", "")
		type = type:trim()
		local group = param:match("group=\"(.-)\"")
		
		if not group then
			for k,v in pairs(manual_enum_group_fixup) do
				if func_name:lower():find(k, nil, true) then
					group = v[name]
				end
			end
		end
				
		if name == "end" then name = "_end" end
		if name == "in" then name = "_in" end
				
		local group_name = group
		group = enum_groups[group]
		
		if type == "GLenum" then
			type = "GL_LUA_ENUMS"
		end
				
		cast_str = cast_str .. type .. ", "
				
		args[i] = {	
			type = type, 
			group = group, 
			group_name = group_name, 
			name = name
		}
		
		i = i + 1
	end
	
	cast_str = cast_str:sub(0,-3) .. ")"
	
	if cast_str:endswith("(*)") then cast_str = cast_str .. "()" end
	
	local get_function
	
	if func_name:find("Get", nil, true) and args[1] and args[#args].type:endswith("*") and not args[#args].type:find("void") then
		get_function = true
	end
	
	functions[func_name] = {
		args = args, 
		type = type, 
		group = group, 
		name = name, 
		cast_str = cast_str, 
		get_function = get_function,
	}
end

local objects = {}

for name, str in xml:gmatch("<require comment=\"(.-) object functions\">(.-)</require>") do
	if not name:find("\n") then
		name = name:gsub("%s+", "")
		
		objects[name] = {}
		
		local found = {}

		local name2
		if str:find("Named" .. name, nil, true) then
			name2 = "Named" .. name
		end
		
		for func_name in str:gmatch("<command name=\"(.-)\"/>") do
			local friendly = func_name:sub(3):gsub(name2 or name, "")
			if friendly ~= "Creates" then 
				found[friendly] = functions[func_name]
			end
		end
		
		for func_name,v in pairs(functions) do
			if v.args[1] and v.args[1].group_name == name then
				local friendly = func_name:sub(3):gsub(name2 or name, ""):gsub(name, "")
				
				if not friendly:startswith("Create") then 
					found[friendly] = v
				end
			end
		end
		
		for k,v in pairs(found) do
			if found["Get" .. k] or found["Get" .. k .. "v"] then
				k = "Set" .. k
			end
			
			if k:endswith("EXT") and not found[k:sub(0,-4)] then
				k = k:sub(0,-4)
			end
			
			objects[name][k] = v
		end
	end
end

local gl = require("graphics.ffi.opengl")

local lua = {}
local i = 1
local insert = function(s) lua[i] = s i=i+1 end

insert"local gl = {}"
insert""
insert"ffi.cdef[["

local done = {}

for line in xml:match("<types>.-</types>"):gmatch("<type(.-)</type>") do
	local cdef = line:match("(typedef.+;)")
	if cdef and not cdef:find("\n") and not cdef:find("khronos_") then
		cdef = cdef:gsub("<name>", "")
		cdef = cdef:gsub("</name>", "")
		cdef = cdef:gsub("<apientry/>", "")
		
		if not done[cdef] then
			insert(cdef)
			done[cdef] = true
		end
	end
end

insert("typedef enum GL_LUA_ENUMS {")
local max = table.count(enums)
local i = 1
for name, val in pairs(enums) do
	local line = "\t" .. name .. " = " .. val
	
	if i ~= max then
		line = line .. ", "
	end
	
	insert(line)
		
	i = i + 1
end
insert("} GL_LUA_ENUMS;")

insert"]]"

insert"function gl.Initialize(get_proc_address)"
insert"\tif type(get_proc_address) == \"function\" then"
insert"\t\tgl.GetProcAddress = get_proc_address"
insert"\tend"

for k, func_info in pairs(functions) do
	local nice = func_info.name:sub(3)
	
	local arg_line = ""
	
	--http://stackoverflow.com/questions/15442615/how-to-determine-the-size-of-opengl-output-buffers-compsize
	
	for i, arg in ipairs(func_info.args) do
		local name = arg.name
		
		arg_line = arg_line .. name
		if i ~= #func_info.args then
			arg_line = arg_line .. ", "
		end
	end
	
	insert"\tdo"
	insert("\t\tlocal func = gl.GetProcAddress(\""..func_info.name.."\")")
	insert"\t\tif func ~= nil then"
	insert("\t\t\tlocal ok, func = pcall(ffi.cast, '"..func_info.cast_str.."', func)")
	insert"\t\t\tif ok then"
		
	insert("\t\t\t\tgl." .. nice .. " = func")
	
	if func_info.name:find("Gen%a-s$") then
		insert("\t\t\tgl." .. nice:sub(0,-2) .. " = function() local id = ffi.new('GLint[1]') func(1, id) return id[0] end")
	end
	
	insert"\t\t\tend"
	insert"\t\tend"
	insert"\tend"
	
	func_info.arg_line = arg_line
end

for name, object_functions in pairs(objects) do
	local create = functions["glCreate" .. name .. "s"]
	local delete = functions["glDelete" .. name .. "s"]
	
	if create and delete then
		insert("\tdo -- " .. name)
		insert"\t\tlocal META = {}"
		insert"\t\tMETA.__index = META"
		
		for friendly, info in pairs(object_functions) do
			local arg_line = info.arg_line:match(".-, (.+)") or ""
			insert("\t\tfunction META:" .. friendly .. "(" .. arg_line .. ")")
				if arg_line ~= "" then arg_line = ", " .. arg_line end
				insert("\t\t\treturn gl." .. info.name:sub(3) .. "(self.id" .. arg_line .. ")")
			insert"\t\tend"
		end
		
		
		insert("\t\tlocal ctype = ffi.typeof('struct { int id; }')")
		insert"\t\tffi.metatype(ctype, META)"
		
		insert("\t\tlocal temp = ffi.new('GLuint[1]')")
		
		insert"\t\tfunction META:Delete()"
		insert"\t\t\ttemp[0] = self.id"
		insert("\t\t\tgl." .. delete.name:sub(3) .. "(1, temp)")
		insert"\t\tend"
		
		local arg_line = create.arg_line:match("(.+),.-,+") or ""
		
		insert("\t\tfunction gl.Create" .. name .. "(" .. arg_line .. ")")
		if arg_line ~= "" then arg_line = arg_line .. ", " end
		insert("\t\t\tgl." .. create.name:sub(3) .. "(" .. arg_line .. "1, temp)")
		insert"\t\t\tlocal self = ffi.new(ctype)"
		insert"\t\t\tself.id = temp[0]"
		insert"\t\t\treturn self"
		insert"\t\tend"
		
		insert"\tend"
	end
end

insert("end")

insert("gl.e = setmetatable({}, {__index = function(_, key) return tonumber(ffi.cast(\"GL_LUA_ENUMS\", key)) end})")

insert("return gl")
--collectgarbage()
local code = table.concat(lua, "\n")
vfs.Write(R"lua/libraries/graphics/ffi/opengl/init.lua", code)

package.loaded["graphics.ffi.opengl"] = nil
require("graphics.ffi.opengl")