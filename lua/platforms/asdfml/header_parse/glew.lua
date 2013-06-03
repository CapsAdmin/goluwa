-- config

local library_path = "!/"
local headers_path = "lua/platforms/asdfml/header_parse/GLEW/"

local make_library_globals = true
local library_global_prefix = "sf"
local lowerHigher_case = false

local parse_headers = false
local cache_parse = false

local glew32 = ffi.load("glew32.dll")

local function remove_comments(str)
	str = str:gsub("//.-\n", "")
	return str
end

local function remove_whitespace(str)
	str = str:gsub("%s+", " ")
	str = str:gsub(";", ";\n")
	str = str:gsub("(%(.-%))", function(content) content:gsub("\n", "") return content end)
	return str
end

local function replace_idkwhat(str)

	str = str:gsub("extern \"C\" {", "")
	str = str:gsub("}", "")

	local idk = {}

	str = str:gsub("(.-\n)", function(line) 
		local key, val =  line:match(" ([_%d%u]+) (__.-);\n")
		
		if key and val then
			idk[key] = val
			return ""
		end
	end)
	
	str = str:gsub(" (typedef.-%(%* [_%d%u]-%) )", function(what)
		local rt, key = what:match("typedef(.-)%(%* (.-)%)")
		if rt and key and idk[key] then
			return rt .. idk[key]
		else
			print(what)
		end
	end)
	
	return str
end

local function process_header(header)
	local out = file.Read(headers_path .. header) or ""

	out = remove_whitespace(out)
	out = replace_idkwhat(out)
	
	return out
end

file.Write("test.h", process_header("glew.i"))