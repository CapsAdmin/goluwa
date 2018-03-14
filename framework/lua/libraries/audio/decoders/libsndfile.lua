local ffi =  require("ffi")
local audio = ... or _G.audio
local soundfile = system.GetFFIBuildLibrary("libsndfile") -- sound decoder

if not soundfile then return end

local aaa = WINDOWS and "" or "struct "

audio.AddDecoder("libsndfile", function(vfs_file, path_hint)
	local info = ffi.new(aaa .. "SF_INFO[1]")

	local file = soundfile.OpenVFS(vfs_file, soundfile.e.READ, info)
	local err = ffi.string(soundfile.Strerror(file))

	if err ~= "No Error." then
		return false, err
	end

	local typename
	local extension
	local subname

	do
		local data = ffi.new(aaa .. "SF_FORMAT_INFO[1]")
		data[0].format = info[0].format
		soundfile.Command(nil, soundfile.e.GET_FORMAT_INFO, data, ffi.sizeof(aaa .. "SF_FORMAT_INFO"))

		typename = ffi.string(data[0].name)
		extension = ffi.string(data[0].extension)

		data[0].format = bit.band(info[0].format , soundfile.e.FORMAT_SUBMASK)
		soundfile.Command(nil, soundfile.e.GET_FORMAT_INFO, data, ffi.sizeof(aaa .. "SF_FORMAT_INFO"))
		subname = ffi.string(data[0].name)
	end

	local info = {
		frames = tonumber(info[0].frames),
		channels = info[0].channels,
		format = format,
		sections = info[0].sections,
		seekable = info[0].seekable ~= 0,
		subname = subname,
		extension = extension,
		typename = typename,
		samplerate = info[0].samplerate,
		buffer_length = info[0].frames * info[0].channels * ffi.sizeof("short"),
	}

	local buffer = ffi.new("short[?]", info.buffer_length)
	-- just read everything
	-- maybe have a callback later using coroutines
	soundfile.ReadShort(file, buffer, info.buffer_length)

	soundfile.Close(file)

	return buffer, info.buffer_length, info
end)