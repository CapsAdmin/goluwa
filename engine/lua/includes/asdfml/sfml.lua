
sfml = {}
sfml.library_path = "lua/includes/asdfml/bin32/"

function sfml.LoadLibraries()
	for file_name in pairs(file.Find(sfml.library_path .. "*", true)) do
		local lib_name = file_name:match("sfml%-(.-)%-2.dll")
		sfml[lib_name] = ffi.load("../" .. sfml.library_path .. file_name)
		printf("loaded library %s", file_name)
	end
end

do -- header parse

	sfml.headers_path = "lua/includes/asdfml/headers/"
	
	local function read_header(path)
		return file.Read("../" .. sfml.headers_path .. path, nil, true)
	end
	
	local included = {}

	local function parse_headers(str)
		local out = ""
		
		for line in str:gmatch("(.-)\n") do
			if included[line] then
			elseif line:find("#include") then
				local file = line:match("#include <(.-)>")
				file = file:gsub("SFML/", "")
				included[line] = true
				out = out .. parse_headers(read_header(file) or (" // missing header " .. file))
			elseif not line:find("#") then
				out = out .. line
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
	
	function sfml.ParseHeader(header)
		local str = read_header(header) or ""
		local included = {}
	
		local out = parse_headers(str)
		out = remove_definitions(out)
		out = remove_comments(out)
		out = remove_whitespace(out)
		
		return out
	end
	
	function sfml.DefineHeaders()
		for file_name in lfs.dir("../"..sfml.headers_path) do
			if file_name:find(".h", nil, true) then
				local header = sfml.ParseHeader(file_name)
				file.Write(file_name, header)
				ffi.cdef(header)
			end
		end
	end
end

sfml.LoadLibraries()
sfml.DefineHeaders()