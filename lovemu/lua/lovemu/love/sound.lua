local love = (...) or _G.lovemu.love

love.sound = {}

local SoundData = {}

SoundData.Type = "SoundData"

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
	return self.samples[i]
end

function SoundData:getSampleCount()
	return self.buffer:GetLength()
end

function SoundData:getSampleRate()
	return self.buffer:GetSampleRate()
end
function SoundData:setSample(i, sample)
	self.samples[i] = sample*127
	self.buffer:SetData(self.buffer:GetData()) -- slow!!!
end

local al = require("lj-openal.al")

local function get_format(channels, bits)
	if channels == 1 and bits == 8 then
		return al.e.AL_FORMAT_MONO8
	elseif channels == 1 and bits == 16 then
		return al.e.AL_FORMAT_MONO16
	elseif channels == 2 and bits == 8 then
		return al.e.AL_FORMAT_STEREO8
	elseif channels == 2 and bits == 16 then
		return al.e.AL_FORMAT_STEREO16
	end
	
	return 0
end

function love.sound.newSoundData(samples, rate, bits, channels)
	if type(samples) == "string" then
		
	end
	
	local self = lovemu.CreateObject(SoundData)
	local buffer = audio.CreateBuffer()
	self.buffer = buffer
	
	buffer:SetFormat(get_format(channels, bits))
	buffer:SetData(ffi.new("int8_t[?]", samples * channels), samples * channels)
	
	self.samples = buffer:GetData()
	
	return self
end