local mpg123 = system.GetFFIBuildLibrary("mpg123")
local ffi = require("ffi")

local INPUT_BUFFER_SIZE = 16384
local OUTPUT_BUFFER_SIZE = 32768

if not mpg123 then return end

local audio = ... or _G.audio

local out = ffi.new("uint8_t[?]", OUTPUT_BUFFER_SIZE)

steam.MountSourceGame("tf2")
local input_file = assert(vfs.Open("sound/vo/spy_cartgoingforwardoffense05.mp3"))
local input_byte_count = 0
local output_byte_count = 0

local ret = ffi.new("int[1]")
local size = ffi.new("size_t[1]")

mpg123.Init()
local feed = mpg123.New(nil, ret)

if feed == nil then
	return false, "Unable to create mpg123 handle: " .. ffi.string(mpg123.PlainStrerror(ret[0]))
end


local tbl = {}
local format_info = {}

while true do
	local buf = input_file:ReadBytes(INPUT_BUFFER_SIZE)
	if not buf then
		break
	end

	input_byte_count = input_byte_count + #buf

	ret = mpg123.Decode(feed, buf, #buf, out, OUTPUT_BUFFER_SIZE, size)

	if ret == mpg123.e.NEW_FORMAT then
		local rate = ffi.new("long[1]")
		local channels = ffi.new("int[1]")
		local enc = ffi.new("int[1]")
		mpg123.Getformat(feed, rate, channels, enc)
		print(enc[0])
		format_info.samplerate = rate[0]
		format_info.channels = channels[0]
	end

	table.insert(tbl, ffi.string(out, size[0]))
	output_byte_count = output_byte_count + size[0]

	while ret ~= mpg123.e.ERR and ret ~= mpg123.e.NEED_MORE do
		ret = mpg123.Decode(feed, nil, 0, out, OUTPUT_BUFFER_SIZE, size)
		table.insert(tbl, ffi.string(out, size[0]))
		output_byte_count = output_byte_count + size[0]
	end

	if ret == mpg123.e.ERR then
		logn("error: ", mpg123.Strerror(feed))
		break
	end
end

logf("%i bytes in, %i bytes out\n", tonumber(input_byte_count), tonumber(output_byte_count))

mpg123.Delete(feed)
mpg123.Exit()

local str = table.concat(tbl)
local buf = ffi.new("uint8_t[?]", #str)
ffi.copy(buf, str)

local buffer = audio.CreateBuffer()
if format_info.channels == 1 then
	buffer:SetFormat(require("al").e.FORMAT_MONO16)
else
	buffer:SetFormat(require("al").e.FORMAT_STEREO16)
end
buffer:SetSampleRate(format_info.samplerate)
buffer:SetData(buf, #str)

local snd = audio.CreateSource()
snd:SetBuffer(buffer)
snd:Play()

table.print(format_info)
