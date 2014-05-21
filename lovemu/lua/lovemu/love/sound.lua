local love = (...) or _G.lovemu.love

love.sound = {}

function love.sound.newSoundData(file_name)
	local self = lovemu.NewObject("SoundData")
	local ptr = newproxy()
	
	function self:getPointer()
		return ptr
	end
	
	function self:getSize()
		return size
	end
	
	function self:getString()
	
	end
	
	function self:getBitDepth()
		
	end
	
	function self:getBits()
	
	end
	
	function self:getChannels()
	
	end
	
	function self:getDuration()
	
	end
	
	function self:getSample()
	
	end
	function self:getSampleCount()
	
	end
	function self:getSampleRate()
	
	end
	function self:setSample()
	
	end
	
	return self
end