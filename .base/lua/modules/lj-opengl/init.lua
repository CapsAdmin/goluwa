local header = require("lj-opengl.header")
local enums = require("lj-opengl.enums")

ffi.cdef(header)

local translate = {
	OSX = "OpenGL.framework/OpenGL",
	Windows = "OPENGL32.DLL",
	Linux = "libGL.so",
	BSD = "libGL.so",
	POSIX = "libGL.so",
	Other = "libGL.so",
}

local lib = assert(ffi.load(translate[ffi.os]))

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

gl.call_count = 0

local errors = {
	[0] = "no error",
	[1280] = "invalid enum",
	[1281] = "invalid value",
	[1282] = "invalid operation",
	[1283] = "stack overflow",
	[1284] = "stack underflow",	
	[1285] = "out of memory",
	[1286] = "invalid framebuffer operation",
}

local function add_gl_func(name, func)
	
	-- lets remove the ARB field from extensions officially approved 
	-- by the OpenGL Architecture Review Board
	--name = name:gsub("ARB", "")
	-- or not
	
	gl[name] = func
	
	--[==[
	
	gl[name] = function(...) 
		if gl.mute then return end
		
		local val = func(...)
		
		gl.call_count = gl.call_count + 1
		
		if name ~= "GetError" then			
			if gl.debug then	
				local val = gl.GetError()
				if val ~= 0 then
					val = errors[val] or val
					local info = debug.getinfo(2)
				
					logf("[gl] %q in function %s at %s:%i\n", val, info.name, info.source, info.currentline)
				end
			end
			
			if gl.logcalls then
				setlogfile("gl_calls")
				
					local args = {}
					for i =  1, select("#", ...) do
						local val = select(i, ...)
						if false and type(val) == "number" and reverse_enums[val] and val > 10 then
							args[#args+1] = select(2, next(reverse_enums[val])):gsub("_EXT", ""):gsub("_ARB", ""):gsub("_ATI", "")
						else
							args[#args+1] = serializer.GetLibrary("luadata").ToString(val)
						end
					end
					
					if not val then
						logf("gl%s(%s)\n", name, table.concat(args, ", "))
					else
						local val = val
						if false and reverse_enums[val] then
							val = select(2, next(reverse_enums[val])):gsub("_EXT", ""):gsub("_ARB", ""):gsub("_ATI", "")
						end
						
						logf("%s = gl%s(%s)\n", val, name, table.concat(args, ", "))
					end
				setlogfile()
			end
		end
		
		return val
	end
	
	]==]
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
end

if LINUX then
	ffi.cdef"void *glXGetProcAddress(const char *);"
	gl.GetProcAddress = lib.glXGetProcAddress
end

-- mini glew..
-- to check if extensions exist, just check if the function exists.
-- if gl.GenBuffers then
function gl.InitMiniGlew()

	if gl.debug then
		logn("parsing gl extensions..")
	end
	local invalid = 0
	
	setlogfile("unexpected_extensions")
	
	for line in header:gmatch("(.-)\n") do
		local func_name = line:match(" (gl%u.-) %(")
		if func_name then
			add_gl_func(func_name:sub(3), lib[func_name])
		end 
	end
	
	local time = system.GetTime()
	for path in vfs.Iterate("lua/modules/lj-opengl/extensions/", nil, true) do
		local str, err = vfs.Read(path)
		for line in str:gmatch("\t(.-)\n") do
			local key, val = line:match("([1-9a-Z_]+) (.+)")
			
			if key and val then
				enums[key] = tonumber(val)
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
						local ok, var = pcall(ffi.cast, ret .. "(*)" ..  args, func) 
						if not ok and var:find("specifier expected near") then
							local type = var:match("near.-'(.-)'")
							ffi.cdef(("typedef struct %s {} %s;"):format(type, type))
							ok, var = pcall(ffi.cast, ret .. "(*)" ..  args, func)
							if not ok then 
								logn(line)
								invalid = invalid + 1
							else
								add_gl_func(nam:match(".-gl(%u.+)"), var)
							end
						else
							add_gl_func(nam:match(".-gl(%u.+)"), var)
						end
					else
						logn(line)
						invalid = invalid + 1
					end
				end
			end
		end
	end 
	
	-- adds gl.GenBuffer which creates and returns a single id from gl.GenBuffers 
	-- no support for ARB stuff yet lol
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
		
	setlogfile()
	
	if gl.debug then
		logf("glew extensions took %f ms to parse\n", (system.GetTime() - time) * 100)
		--logf("%i extensions could not be parsed. see the unexpected_extensions log for more info\n", invalid)
	end
end

-- the download functions work but the idea wasn't thought out properly
-- the data from registry/specs/ is very inconsistent so parsing it
-- would be a pain...

function gl.DownloadExtensionList(callback)
	if not sockets then return end
	
	local ext_folder = e.BASE_FOLDER .. "lua/libraries/low_level/ffi_binds/gl/extensions/"
	
	local domain = "http://www.opengl.org/"
	local base = "registry/"
	
	local pattern = "\"(specs/.-%.txt)"
	
	sockets.Get(domain .. base, function(data) 
		local list = {}

		for url in data.content:gmatch(pattern) do 
			local vendor, file_name = url:match("specs/(.-)/(.+)")
			file_name = vendor .. "_" .. file_name
			
			local name = file_name:lower():match("(.+)%.txt")
						
			table.insert(list, {url = domain .. base .. url, path = ext_folder .. file_name:lower(), name = name})
		end
		
		logf("found %i extensions from %q!\n", #list, domain .. base)
		logf("checking extensions in %q..\n", ext_folder)
		for i, data in pairs(list) do
			local str = vfs.Read(data.path)
			
			if not str then
				logf("extension %q was not found!\n", data.name)
				data.not_found = true
			end
		end

		if callback then
			callback(list)
		end
	end)
end

function gl.DownloadExtensions()
	if not sockets then return end
		
	gl.DownloadExtensionList(function(list)	
		print(table.count(list))
		local function download()
			local i, extension = next(list)
			list[i] = nil
			
			if extension then
				logf("downloading %q (%i left)\n", extension.name, table.count(list))
				sockets.Get(extension.url, function(data)
					vfs.Write(extension.path, data.content, nil, false)
					logf("saved %q (%i bytes)\n", extension.name, #data.content)
					
					download()
				end, 3)
			else
				logn("finished downloading extensions")
			end
		end
		
		for i = 1, 50 do
			download()
		end	
	end)
end

return gl
