local ffi = require("ffi")
local audio = ... or _G.audio
local soundfile = desire("libsndfile") -- sound decoder
if RELOAD then
	local info = ffi.new("struct SF_FORMAT_INFO")
	local sfinfo = ffi.new("struct SF_INFO")
	local major_count = ffi.new("int[1]")
	soundfile.Command(
		nil,
		soundfile.clib.SFC_GET_FORMAT_MAJOR_COUNT,
		major_count,
		ffi.sizeof(major_count)
	)
	major_count = major_count[0]
	local minor_count = ffi.new("int[1]")
	soundfile.Command(
		nil,
		soundfile.clib.SFC_GET_FORMAT_SUBTYPE_COUNT,
		minor_count,
		ffi.sizeof(minor_count)
	)
	minor_count = minor_count[0]

	for m = 0, major_count - 1 do
		info.format = m
		soundfile.Command(nil, soundfile.clib.SFC_GET_FORMAT_MAJOR, info, ffi.sizeof(info))
		logf("%s  (extension \"%s\")\n", ffi.string(info.name), ffi.string(info.extension))
		format = info.format

		for s = 0, minor_count - 1 do
			info.format = s
			soundfile.Command(nil, soundfile.clib.SFC_GET_FORMAT_SUBTYPE, info, ffi.sizeof(info))
			--logf("\t%s  (extension \"%s\")\n", ffi.string(info.name), info.extension ~= nil and ffi.string(info.extension))
			format = bit.bor(bit.band(format, soundfile.clib.SF_FORMAT_TYPEMASK), info.format)
			sfinfo.format = format

			if soundfile.FormatCheck(sfinfo) ~= 0 then

			--	logf("   %s\n", ffi.string(info.name))
			end
		--	logn()'
		end
	--logn()
	end
end

if not soundfile then return end

audio.AddDecoder("libsndfile", function(vfs_file, path_hint)
	local info = ffi.new("struct SF_INFO[1]")
	local file = soundfile.OpenVFS(vfs_file, soundfile.e.READ, info)
	local err = ffi.string(soundfile.Strerror(file))


	if err ~= "No Error." then
		vfs_file:SetPosition(0)
		local header = vfs_file:ReadBytes(4)
		return false, err .. " (header: " .. header .. ")"
	end

	local typename
	local extension
	local subname

	do
		local data = ffi.new("struct SF_FORMAT_INFO[1]")
		data[0].format = info[0].format
		soundfile.Command(nil, soundfile.e.GET_FORMAT_INFO, data, ffi.sizeof("struct SF_FORMAT_INFO"))
		typename = ffi.string(data[0].name)
		extension = ffi.string(data[0].extension)
		data[0].format = bit.band(info[0].format, soundfile.e.FORMAT_SUBMASK)
		soundfile.Command(nil, soundfile.e.GET_FORMAT_INFO, data, ffi.sizeof("struct SF_FORMAT_INFO"))
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