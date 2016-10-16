if not SOUND then return end

local love = ... or _G.love
local ENV = love._line_env

love.audio = love.audio or {}

function love.audio.getNumSources()
	return #line.GetCreatedObjects("Source")
end

love.audio.getSourceCount = love.audio.getNumSources

function love.audio.getOrientation()
	return audio.GetListenerOrientation()
end

function love.audio.getPosition()
	return audio.GetListenerPosition()
end

function love.audio.getVelocity()
	return audio.GetListenerVelocity()
end

function love.audio.getVolume()
	return audio.GetListenerGain()
end

function love.audio.pause()
	for k,v in pairs(line.GetCreatedObjects("Source")) do
		v:pause()
	end
end

function love.audio.play()
	for k,v in pairs(line.GetCreatedObjects("Source")) do
		v:play()
	end
end

function love.audio.resume()
	for k,v in pairs(line.GetCreatedObjects("Source")) do
		v:resume()
	end
end

function love.audio.rewind()
	for k,v in pairs(line.GetCreatedObjects("Source")) do
		v:rewind()
	end
end

function love.audio.setDistanceModel(name)
	audio.SetDistanceModel(name)
end

function love.audio.getDistanceModel()
	return audio.GetDistanceModel()
end

function love.audio.setOrientation(x,y,z,x2,y2,z2)
	audio.SetListenerOrientation(x,y,z,x2,y2,z2)
end

function love.audio.setPosition(x,y,z)
	audio.SetListenerPosition(x,y,z)
end

function love.audio.setVelocity(x,y,z)
	audio.SetListenerVelocity(x,y,z)
end

function love.audio.setVolume(vol)
	audio.SetListenerGain(vol or 1)
end

function love.audio.newEffect(...) --line only
	return audio.CreateEffect(...)
end

function love.audio.newFilter(...) --line only
	return audio.CreateFilter(...)
end

function love.audio.stop()
	for k,v in pairs(line.GetCreatedObjects("Source")) do
		v:stop()
	end
end

do -- Source

	local Source = line.TypeTemplate("Source")

	function Source:getChannels()
		return 2 --stereo
	end

	function Source:getDirection()
		if self.source then
			return self.source:GetDirection()
		end

		return 0,0,0
	end

	function Source:getDistance()
		if self.source then
			return self.source:GetReferenceDistance(), self.source:GetMaxDistance()
		end

		return 0,0
	end

	function Source:getPitch()
		if self.source then
			return self.source:GetPitch()
		end

		return 1
	end

	function Source:getPosition()
		if self.source then
			return self.source:GetPosition()
		end

		return 0,0,0
	end

	function Source:getRolloff()
		if self.source then
			return self.source:GetRolloffFactor()
		end

		return 1
	end

	function Source:getVelocity()
		if self.source then
			return self.source:GetVelocity()
		end

		return 0,0,0
	end

	function Source:getVolume()
		if self.source then
			return self.source:GetGain()
		end

		return 1
	end

	function Source:getVolumeLimits()
		return 0,1
	end

	function Source:isLooping()
		if self.source then
			return self.source:GetLooping()
		end

		return false
	end

	function Source:isPaused()
		if self.source then
			return not self.playing
		end

		return false
	end

	function Source:isStatic()
		return false
	end

	function Source:isStopped()
		if self.source then
			return not self.playing
		end

		return false
	end

	function Source:isPlaying()
		return not self:isStopped()
	end

	function Source:pause()
		if self.source then
			self.source:Pause()
		end
	end

	function Source:play()
		if self.source then
			self.source:Play()
			self.playing = true
		end
	end

	function Source:resume()
		if self.source then
			self.source:Play()
		end
	end

	function Source:rewind()
		if self.source then
			self.source:Rewind()
		end
	end

	function Source:seek(offset, type)
		if self.source then
			self.source:Seek(offset, type)
		end
	end

	function Source:stop()
		if self.source then
			self.source:Stop()
			self.playing=false
		end
	end

	function Source:setDirection(x, y, z)
		if self.source then
			self.source:SetDirection(x, y, z)
		end
	end

	function Source:setDistance(ref, max)
		if self.source then
			self.source:SetReferenceDistance(ref)
			self.source:SetMaxDistance(max)
		end
	end

	function Source:setAttenuationDistances(ref, max)
		if self.source then
			self.source:SetReferenceDistance(ref)
			self.source:SetMaxDistance(max)
		end
	end

	function Source:setLooping(bool)
		if self.source then
			self.source:SetLooping(not not bool)
		end
	end

	function Source:setPitch(pitch)
		if self.source then
			self.source:SetPitch(pitch)
		end
	end

	function Source:setPosition(x, y, z)
		if self.source then
			self.source:SetPosition(x,y,z)
		end
	end

	function Source:setRolloff(x)
		if self.source then
			self.source:SetRolloffFactor(x)
		end
	end

	function Source:setVelocity(x,y,z)
		if self.source then
			self.source:SetVelocity(x,y,z)
		end
	end

	function Source:setVolume(vol)
		if self.source then
			self.source:SetGain(vol)
		end
	end

	function Source:setVolumeLimits()

	end

	function Source:tell(type)
		if self.source then
			return self.source:Tell(self, type)
		end

		return 1
	end

	function Source:addEffect(...) --line only
		if self.source then
			return self.source:AddEffect(...)
		end
	end

	function Source:setFilter(...) --line only
		if self.source then
			return self.source:SetFilter(...)
		end
	end

	function Source:clone()
		return love.audio.newSource(self.path)
	end

	function love.audio.newSource(var, type)
		local self = line.CreateObject("Source")

		if line.Type(var) == "string" then

			self.path = var

			if vfs.Exists(var) then
				local ext = var:match(".+%.(.+)")

				if ext == "flac" or ext == "wav" or ext == "ogg" then
					self.source = audio.CreateSource(var)
					self.source:SetChannel(1)
				end

			end
		elseif line.Type(var) == "File" then
			line.ErrorNotSupported("Decoder is not supported yet")
		elseif line.Type(var) == "Decoder" then
			line.ErrorNotSupported("Decoder is not supported yet")
		elseif line.Type(var) == "SoundData" then
			self.source = audio.CreateSource(var)
			self.source:SetBuffer(var.buffer)
		else
			wlog("tried to create unknown source type: %s %s", line.Type(var), type, 2)
		end

		return self
	end

	line.RegisterType(Source)
end
