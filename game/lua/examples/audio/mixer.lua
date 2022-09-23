local ffi = require("ffi")
local source = audio.CreateSource()
local frame_size = 0.25
local queue_length = 100
local max_volume = 0xFF
local sample_rate = 44100
local output_channels = 2
local buffer_size = math.ceil(frame_size * sample_rate * 2)

for i = 0, 4 do
	local int, frac = math.modf((buffer_size + i) / 4)

	if frac == 0 then
		buffer_size = buffer_size + i

		break
	end
end

local sounds = {}

do
	local META = prototype.CreateTemplate("sound")
	META:GetSet("Volume", 1)
	META:GetSet("Pitch", 1)

	function META:Debug()
		local len = sample_rate * output_channels * 5
		local buf = ffi.new("int16_t[?]", len)
		local t = 0

		for i = 0, len - 1, 2 do
			buf[i] = math.sin(((i / len) ^ 3) * sample_rate + (i / sample_rate * 1500)) * 0xFF
			local i = -i + len
			buf[i + 1] = math.sin(((i / len) ^ 0.5) * sample_rate + (i / sample_rate * 1500)) * 0xFF
		end

		self.Buffer = buf
		self.Channels = 2
		self.SampleLength = len / self.Channels
	--[[
        local b = audio.CreateBuffer()
        b:SetFormat(require("al").e.FORMAT_STEREO16)
        b:SetData(buf, len)
        LOL = audio.CreateSource(b)
        LOL.b = b
        LOL:Play()
        --]] end

	function META:LoadPath(path)
		local len = sample_rate * 2
		local buf = ffi.new("int16_t[?]", len)

		for i = 0, len - 1, 2 do
			buf[i + 0] = math.sin((i / sample_rate) * 440 + len) * 0xFFF
			local i = -i + len
			buf[i + 1] = math.sin((i / sample_rate) * 440 + len) * 0xFFF
		end

		self.Buffer = buf
		self.BufferSize = len
		self.SampleLength = len

		do
			return
		end

		resource.Download(path):Then(function(path)
			local file = vfs.Open(path)
			local data, length, info = audio.Decode(file, path)
			self.Buffer = data
			self.BufferSize = length
			self.SampleLength = info.frames
		end)
	end

	function META:Initialize()
		self.SamplePosition = 0
	end

	META:Register()

	local function Sound(path)
		local self = META:CreateObject()
		self:Initialize()
		--self:LoadPath(path)
		self:Debug()
		return self
	end

	list.insert(
		sounds,
		Sound(
			"https://raw.githubusercontent.com/PAC3-Server/chatsounds-valve-games/master/hl2/robert_guillaume/-now%20lets%20see%20the%20last%20time%20i%20s-206290379.ogg"
		)
	)
end

local function render(buf, len, i)
	for _, sound in ipairs(sounds) do
		if sound.Buffer then
			for index = 0, len - 1, output_channels do
				for channel = 0, output_channels - 1 do
					local buffer_channel = channel % sound.Channels
					local sample = buf[index + channel]
					--sample = math.random(0xFF)
					sample = sample + sound.Buffer[math.floor(sound.SamplePosition) * (buffer_channel + 1)]
					buf[index + channel] = sample
				end

				sound.SamplePosition = sound.SamplePosition + 1

				if sound.SamplePosition >= sound.SampleLength then
					sound.SamplePosition = 0
					list.remove_value(sounds, sound)
				end
			end
		end
	end
end

local function process(b, i)
	local buf, len = b:GetData()
	len = len or buffer_size
	buf = buf or ffi.new("int16_t[?]", len)

	for i = 0, len - 1 do
		buf[i] = 0
	end

	render(buf, len, i)
	b:SetData(buf, len)
	b:SetSampleRate(sample_rate)
	source:PushBuffer(b)
end

for i = 1, queue_length do
	local b = audio.CreateBuffer()
	b:SetFormat(require("al").e.FORMAT_STEREO16)
	process(b, i - 1)
end

source:Play()

do
	return
end

timer.Repeat(
	"chatsounds_mixer",
	frame_size / 2,
	0,
	function()
		local processed = source:GetBuffersProcessed()

		while processed > 0 do
			process(source:PopBuffer())
			processed = processed - 1
		end

		if not source:IsPlaying() then source:Play() end
	end
)

source:Play()