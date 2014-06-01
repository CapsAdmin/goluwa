local love = (...) or _G.lovemu.love

love.sound = {}

local SoundData = {}

SoundData.Type = "SoundData"

function SoundData:getPointer()
	return self.ptr
end

function SoundData:getSize()
	return self.size
end

function SoundData:getString()

end

function SoundData:getBitDepth()
	
end

function SoundData:getBits()

end

function SoundData:getChannels()

end

function SoundData:getDuration()

end

function SoundData:getSample()

end
function SoundData:getSampleCount()

end
function SoundData:getSampleRate()

end
function SoundData:setSample()

end


function love.sound.newSoundData(file_name)
	local self = lovemu.CreateObject(SoundData)
	local ptr = newproxy()
	
	self.ptr = ptr
	
	return self
end