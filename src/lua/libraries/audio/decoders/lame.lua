local lib = desire("liblame")

if not lib then return end

local audio = ... or _G.audio

audio.AddDecoder("lame", function(data, path_hint)
	local file = assert(vfs.Open(path_hint))

	if data:sub(0,3) ~= "ID3" then return false, "unknown format" end

	local lame = lib.lame_init()
	local hip = lib.hip_decode_init()

	local header = ffi.new("mp3data_struct[1]")

	local left = {}
	local right = {}

	local enc_delay = ffi.new("int[1]")
	local enc_padding = ffi.new("int[1]")

	local buffer_left = ffi.new("short[?]", 4096)
	local buffer_right = ffi.new("short[?]", 4096)
	--local total_size = 0ULL

	while true do
		local chunk = file:ReadBytes(4096*8)

		local size = lib.hip_decode1_headersB(hip, ffi.cast("unsigned char *", chunk), 4096*8, buffer_left, buffer_right, header, enc_delay, enc_padding)

		if size < 0 or not chunk then break end

		--[[logn("header_parsed", " = ", header[0].header_parsed)
		logn("stereo", " = ", header[0].stereo)
		logn("samplerate", " = ", header[0].samplerate)
		logn("bitrate", " = ", header[0].bitrate)
		logn("mode", " = ", header[0].mode)
		logn("mode_ext", " = ", header[0].mode_ext)
		logn("framesize", " = ", header[0].framesize)
		logn("nsamp", " = ", header[0].nsamp)
		logn("totalframes", " = ", header[0].totalframes)
		logn("framenum", " = ", header[0].framenum)]]

		table.insert(left, ffi.string(buffer_left, size))
		table.insert(right, ffi.string(buffer_right, size))

		--[[local buffer = ffi.new("short[?]", size)
		ffi.copy(buffer, buffer_left, size)
		table.insert(left, {buffer = buffer, size = size})

		local buffer = ffi.new("short[?]", size)
		ffi.copy(buffer, buffer_right, size)
		table.insert(right, {buffer = buffer, size = size})

		total_size = total_size + size]]
	end

	--logn("delay", " = ", enc_delay[0])
	--logn("padding", " = ", enc_padding[0])

	lib.hip_decode_exit(hip)
	lib.lame_close(lame)

	--[[local buffer = ffi.new("short[?]", total_size)
	local offset = 0
	for _, v in ipairs(left) do
		for i = 0, v.size - 1 do
			buffer[i + offset] = v.buffer[i]
		end
		offset = offset + v.size
	end]]

	local left = table.concat(left)
	local buffer = ffi.cast("short *", left)

	return buffer, #left
end)