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
		local func = line:match("(av.-)%s-%(") or line:match("(sw[rs]_.-)%s-%(")
		if func then
			for k,v in pairs(ffmpeg.libs) do
				local ok , err = pcall(function()
					ffmpeg[func] = v[func]
				end)
			end
		end
	end
end

function ffmpeg.get_last_error()
	local buff = ffi.new("char[512]")
	ffmpeg.av_strerror(ffi.errno(), buff, 512) 
	return ffi.string(buff) 
end

return ffmpeg