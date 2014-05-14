audio.AddDecoder("libsoundfile", function(data, path_hint)
	if type(length) == "number" and type(data) == "cdata" then
		data = ffi.string(data, length)
	end

	-- use a dummy file so we can read from memory...
	local  name = os.tmpname()
	local file = assert(io.open(name, "wb"))
	file:write(data)
	file:close()

	local info = ffi.new("SF_INFO[1]")
	local file = soundfile.Open(name, e.SFM_READ, info)
	info = info[0]

	local err = ffi.string(soundfile.StringError(file))

	if err ~= "No Error." then
		return false, err
	end

	local typename
	local extension
	local subname

	do
		local data = ffi.new("SF_FORMAT_INFO[1]")
		data[0].format = info.format
		soundfile.Command(nil, e.SFC_GET_FORMAT_INFO, data, ffi.sizeof("SF_FORMAT_INFO"))

		typename = ffi.string(data[0].name)
		extension = ffi.string(data[0].extension)

		data[0].format = bit.band(info.format , e.SF_FORMAT_SUBMASK)
		soundfile.Command(nil, e.SFC_GET_FORMAT_INFO, data, ffi.sizeof("SF_FORMAT_INFO"))
		subname = ffi.string(data[0].name)
	end

	local info = {
		frames = tonumber(info.frames),
		channels = info.channels,
		format = format,
		sections = info.sections,
		seekable = info.seekable ~= 0,
		subname = subname,
		extension = extension,
		typename = typename,
		samplerate = info.samplerate,
		buffer_length = info.frames * info.channels * ffi.sizeof("ALshort"),
	}

	local buffer = ffi.new("ALshort[?]", info.buffer_length)
	-- just read everything
	-- maybe have a callback later using coroutines
	soundfile.ReadShort(file, buffer, info.buffer_length)

	soundfile.Close(file)

	os.remove(name)
	
	return buffer, info.buffer_length, info
end)