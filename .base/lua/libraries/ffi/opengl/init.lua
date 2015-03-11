local header = include("header.lua") 
local enums = include("enums.lua")

ffi.cdef(header)

local lib = assert(ffi.load(WINDOWS and "opengl32" or "libgl"))

local gl = {
	lib = lib,
	header = header,
	e = enums,
}

local suppress = false
local reverse_enums = {}

function gl.GetReverseEnums()
	 return reverse_enums
end

function gl.FindInEnum(num, find)
	if gl.GetReverseEnums()[num] then
		for k, v in pairs(gl.GetReverseEnums()[num]) do
			if k:compare(find) then
				return true
			end
		end
	end
end

local function add_gl_func(friendly, func)
	gl[friendly] = func
end

for line in header:gmatch("(.-)\n") do
	local func_name = line:match(" (gl%u.-) %(")
	if func_name then
		add_gl_func(func_name:sub(3), lib[func_name])
	end 
end

if WINDOWS then
	ffi.cdef"void *wglGetProcAddress(const char *);"
	gl.GetProcAddress = lib.wglGetProcAddress
else
	ffi.cdef"void *glXGetProcAddress(const char *);"
	gl.GetProcAddress = lib.glXGetProcAddress
end

-- mini glew
-- to check if extensions exist, just check if the function exists.
-- if gl.GenBuffers then

function gl.InitMiniGlew()

	if gl.debug then
		logn("parsing gl extensions..")
	end
	local invalid = 0
	
	if DEBUG then
		setlogfile("unexpected_extensions")
	end
	
	for line in header:gmatch("(.-)\n") do
		local func_name = line:match(" (gl%u.-) %(")
		if func_name then
			add_gl_func(func_name:sub(3), lib[func_name])
		end 
	end
	
	local cache = serializer.ReadFile("msgpack", "gl_extensions_cache")
	
	if cache then
		for i, info in ipairs(cache) do
			if info.enum then
				enums[info[1]] = info[2]
			else
				if info[4] then ffi.cdef(info[4]) end
				add_gl_func(info[1], ffi.cast(info[3], gl.GetProcAddress(info[2])))
			end
		end
	else
		cache = {}
		
		local time = system.GetTime()
		for path in vfs.Iterate("lua/libraries/ffi/opengl/extensions/", nil, true) do
			local str, err = vfs.Read(path)
			for line in str:gmatch("\t(.-)\n") do
				local key, val = line:match("([1-9a-Z_]+) (.+)")
				
				if key and val then
					enums[key] = tonumber(val)
					table.insert(cache, {key, enums[key], enum = true})
				elseif line:find("typedef") then
					--print(line)
				else
					local ret, nam, args = line:match("(.-) (gl.-) (%(.+%))")
					
					if not nam or nam:trim() == "" then
						ret, nam, args = line:match("(.-) (wgl.-) (%(.+%))")
					end
					
					if nam then
						nam = nam:trim()
						local func = gl.GetProcAddress(nam)
						if func ~= nil then
							local cdef_str
							local cast_str = ret .. "(*)" ..  args
							
							local ok, var = pcall(ffi.cast, cast_str, func) 
							
							if not ok and var:find("specifier expected near") then
								local type = var:match("near.-'(.-)'")
								cdef_str = ("typedef struct %s {} %s;"):format(type, type)
								ffi.cdef(cdef_str)
								ok, var = pcall(ffi.cast, cast_str, func)
								if not ok and DEBUG then
									logn(line)
									invalid = invalid + 1
								end
							end
							
							if ok then
								local friendly = nam:match(".-gl(%u.+)")
								
								table.insert(cache, {friendly, nam, cast_str, cdef_str})
								
								add_gl_func(friendly, var)
							end
						elseif DEBUG then
							logn(line)
							invalid = invalid + 1
					end
				end
			end
		end
		end
		
		serializer.WriteFile("msgpack", "gl_extensions_cache", cache)
	end
	
	-- adds gl.GenBuffer which creates and returns a single id from gl.GenBuffers 
	for name, func in pairs(gl) do
		if name:find("Gen%a-s$") then
			gl[name:sub(0,-2)] = function()
				local id = ffi.new("GLint [1]") 
				gl[name](1, id) 
				return id[0]
			end
		end
	end
	
	for k, v in pairs(enums) do
		if k ~= "GL_INVALID_ENUM" then
			reverse_enums[v] = reverse_enums[v] or {}
			reverse_enums[v][k] = k
		end
		enums[k] = v
	end
		
	if DEBUG then
		setlogfile()
	end
	
	if gl.debug then
		logf("glew extensions took %f ms to parse\n", (system.GetTime() - time) * 100)
		--logf("%i extensions could not be parsed. see the unexpected_extensions log for more info\n", invalid)
	end
end

return gl
