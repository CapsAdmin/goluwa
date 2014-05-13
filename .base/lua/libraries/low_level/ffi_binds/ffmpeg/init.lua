local header = include("header.lua")
local enums = include("enums.lua")
for k,v in pairs(enums) do
	e[k] = v
end

ffi.cdef(header)  

header = header:gsub("%s+", " ")
header = header:gsub(";", "%1\n")

local ffmpeg = {
	libs = {
		avcodec = ffi.load("avcodec-55"),
		avformat = ffi.load("avformat-55"),
		avdevice = ffi.load("avdevice-55"),
		avutil = ffi.load("avutil-52"),
		swresample = ffi.load("swresample-0"),
		swscale = ffi.load("swscale-2"),
	}
}

for line in header:gmatch("(.-)\n") do
	if not line:find("typedef") then
		local name = line:match("(av.-)%s-%(") or line:match("(sw[rs]_.-)%s-%(")
		if name then
			for k,v in pairs(ffmpeg.libs) do
				local ok , err = pcall(function()
					ffmpeg[name] = v[name]
				end)
			end
			
			local func = ffmpeg[name]
			ffmpeg[name] = function(...)
				if ffmpeg.logcalls then
					setlogfile("ffmpeg_calls")
					logf("%s(%s)", name, table.concat(tostring_args(...), ",\t"))
				end
				
				local val = func(...)
				
				if ffmpeg.logcalls then
					logf(">> %s\n", luadata.ToString(val))
					setlogfile()
				end
				
				return val
			end
		end
	end
end

function ffmpeg.lua_initialize()
	ffi.cdef[[int sprintf(char *str, const char *format, ...);]]

	ffmpeg.av_log_set_callback(function(huh, level, fmt, va_list)
		if not ffmpeg.debug then return end
		local buffer = ffi.new("char[256]")
		ffi.C.sprintf(buffer, fmt, va_list)
		log("[ffmpeg] ", ffi.string(buffer))
	end)

	ffmpeg.av_register_all() 
end

function ffmpeg.lua_table_to_dictionary(tbl)	
	local dict = ffi.new("AVDictionary *[1]")
	
	if not tbl then return dict[0] end
	
	for key, val in pairs(tbl) do
		ffmpeg.av_dict_set(dict, tostring(key), tostring(val), 0)
	end
	
	return dict[0]
end

function ffmpeg.lua_dictionary_to_table(dict)	
	local tbl = {}
	
	if dict == nil then return tbl end
	
	local entry = ffi.new("AVDictionaryEntry *")
	while true do 
		entry = ffmpeg.av_dict_get(dict, "", entry, AV_DICT_IGNORE_SUFFIX)
		if entry == nil then break end
		tbl[ffi.string(entry.key)] = ffi.string(entry.value)
	end
	
	return tbl
end

function ffmpeg.lua_get_last_error()
	local buff = ffi.new("char[512]")
	ffmpeg.av_strerror(ffi.errno(), buff, 512) 
	return ffi.string(buff) 
end

ffmpeg.lua_initialize()

return ffmpeg