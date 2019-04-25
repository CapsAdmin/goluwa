if not SOUND then return end

local love = ... or _G.love
local ENV = love._line_env

local ffi = require("ffi")

love.sound = love.sound or {}

local SoundData = line.TypeTemplate("SoundData")

function SoundData:getPointer()
	return self.samples
end

function SoundData:getSize()
	return self.buffer:GetSize()
end

function SoundData:getString()
	return ffi.string(self.buffer:GetData())
end

function SoundData:getBitDepth()
	return self.buffer:GetBits()
end

function SoundData:getBits()
	return self.buffer:GetBits()
end

function SoundData:getChannels()
	return self.buffer:GetChannels()
end

function SoundData:getDuration()
	return self.buffer:GetDuration()
end

function SoundData:getSample(i)
	return self.samples and self.samples[i] or 0
end

function SoundData:getSampleCount()
	return self.buffer:GetLength()
end

function SoundData:getSampleRate()
	return self.buffer:GetSampleRate()
end
function SoundData:setSample(i, sample)
	if not self.samples then return end
	self.samples[i] = sample*127
	self.buffer:SetData(self.buffer:GetData()) -- slow!!!
end

local al = desire("al")

local function get_format(channels, bits)
	if al then
		if channels == 1 and bits == 8 then
			return al.e.FORMAT_MONO8
		elseif channels == 1 and bits == 16 then
			return al.e.FORMAT_MONO16
		elseif channels == 2 and bits == 8 then
			return al.e.FORMAT_STEREO8
		elseif channels == 2 and bits == 16 then
			return al.e.FORMAT_STEREO16
		end
	end

	return 0
end

function love.sound.newSoundData(samples, rate, bits, channels)
	local self = line.CreateObject("SoundData")
	local buffer = audio.CreateBuffer()
	self.buffer = buffer

	if type(samples) == "string" then
		resource.Download(samples):Then(function(path)
			local file = vfs.Open(path)
			local data, length, info = audio.Decode(file)
			file:Close()

			if data then
				local buffer = audio.CreateBuffer()
				if al then buffer:SetFormat(info.channels == 1 and al.e.FORMAT_MONO16 or al.e.FORMAT_STEREO16) end
				buffer:SetSampleRate(info.samplerate)
				buffer:SetData(data, length)

				self.buffer = buffer

			end
		end)

		return self
	end


	buffer:SetFormat(get_format(channels, bits))
	buffer:SetData(ffi.new("int8_t[?]", samples * channels), samples * channels)

	self.samples = buffer:GetData()

	return self
end

line.RegisterType(SoundData)


local Decoder = line.TypeTemplate("Decoder")

function Decoder:getDepth() return 8 end
function Decoder:getBits() return 8 end
function Decoder:getChannels() return self.info.channels end
function Decoder:getDuration() return self.length end
function Decoder:getSampleRate() return self.info.samplerate end

function love.sound.newDecoder(file, buffer_size)
	local self = line.CreateObject("Decoder")

	local file

	if line.Type(file) == "File" then
		file = file.file
	elseif line.Type(file) == "string" then
		error("vfs.OPENMEMORY HERE")
	end

	local decoded_data, length, info = audio.Decode(file)

	self.decoded_data = decoded_data
	self.length = length
	self.info = info

	return self
end

line.RegisterType(Decoder)
