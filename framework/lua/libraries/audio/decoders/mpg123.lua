local ffi = require("ffi")
local audio = ... or _G.audio
local mpg123 = desire("mpg123")

if not mpg123 then return end

local INPUT_BUFFER_SIZE = 16384
local OUTPUT_BUFFER_SIZE = 32768
mpg123.Init()
local allowed = {
	"ID3",
	"\xFF\xFB\x92",
	"\xFF\xFB\x90",
}
local hex_allowed = {}

for i, v in ipairs(allowed) do
	hex_allowed[i] = "|" .. v:hexformat():trim():gsub("%s", ""):upper() .. "|"
end

audio.AddDecoder("mpg123", function(vfs_file, path_hint)
	local ok = false

	for i, v in ipairs(allowed) do
		if vfs_file:PeakBytes(#v) == v then
			ok = true

			break
		end
	end

	if not ok then
		return false,
		"not a valid file (file does not start with " .. table.concat(hex_allowed, " or ") .. ")"
	end

	local ret = ffi.new("int[1]")
	local feed = mpg123.New(nil, ret)

	if feed == nil then
		return nil,
		"unable to create mpg123 handle: " .. ffi.string(mpg123.PlainStrerror(ret[0]))
	end

	mpg123.OpenFeed(feed)
	local size = ffi.new("size_t[1]")
	local chunks = {}
	local format_info = {}
	local out = ffi.new("uint8_t[?]", OUTPUT_BUFFER_SIZE)

	while true do
		local buf = vfs_file:ReadBytes(INPUT_BUFFER_SIZE)

		if not buf then break end

		local ret = mpg123.Decode(feed, buf, #buf, out, OUTPUT_BUFFER_SIZE, size)

		if ret == mpg123.e.NEW_FORMAT then
			local rate = ffi.new("long[1]")
			local channels = ffi.new("int[1]")
			local enc = ffi.new("int[1]")
			mpg123.Getformat(feed, rate, channels, enc)
			format_info.samplerate = rate[0]
			format_info.channels = channels[0]
		end

		table.insert(chunks, ffi.string(out, size[0]))

		while ret ~= mpg123.e.NEED_MORE do
			ret = mpg123.Decode(feed, nil, 0, out, OUTPUT_BUFFER_SIZE, size)

			if ret == mpg123.e.ERR then
				return nil, ffi.string(mpg123.Strerror(feed))
			end

			table.insert(chunks, ffi.string(out, size[0]))
		end

		if ret == mpg123.e.ERR then
			return nil, ffi.string(mpg123.Strerror(feed))
		end
	end

	mpg123.Delete(feed)
	local str = table.concat(chunks)
	local buf = ffi.new("uint8_t[?]", #str)
	ffi.copy(buf, str, #str)
	return buf, #str, format_info
end)