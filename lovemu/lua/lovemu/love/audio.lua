local love=love
local lovemu=lovemu
love.audio={}

local sources = {}


local function getChannels(self)
	return 2 --stereo
end

local function getDirection(self)
	if self.legit==true then
		return	self:GetDirection()
	else
		return 0,0,0
	end
end

local function getDistance(self)
	if self.legit==true then
		return self:GetReferenceDistance(),self:GetMaxDistance()
	else
		return 0,0
	end
end

local function getPitch(self)
	if self.legit==true then
		return self:GetPitch()
	else
		return 1
	end
end

local function getPosition(self)
	if self.legit==true then
		return self:GetPosition()
	else
		return 0,0,0
	end
end

local function getRolloff(self)
	if self.legit==true then
		return self:GetRolloffFactor()
	else
		return 1
	end
end

local function getVelocity(self)
	if self.legit==true then
		return self:GetVelocity()
	else
		return 0,0,0
	end
end

local function getVolume(self)
	if self.legit==true then
		return self:GetGain()
	else
		return 1
	end
end

local function getVolumeLimits(self)
	return 0,1
end

local function isLooping(self)
	if self.legit==true then
		return self:GetLooping()
	else
		return false
	end
end

local function isPaused(self)
	if self.legit==true then
		return not self.isplaying
	else
		return false
	end
end

local function isStatic(self)
	return false
end

local function isStopped(self)
	if self.legit==true then
		return not self.isplaying
	else
		return false
	end
end

local function pause(self)
	if self.legit==true then
		self:Pause()
	end
end

local function play(self)
	if self.legit==true then
		self:Play()
		self.playing=true
	end
end

local function resume(self)
	if self.legit==true then
		self:Resume()
	end
end

local function rewind(self)
	if self.legit==true then
		self:Rewind()
	end
end

local function seek(self,offset,type)
	if self.legit==true then
		if type~="samples" then
			offset = offset * self:GetBuffer():GetSampleRate()
		end
		
		self:SetSampleOffset(offset)
	end
end

local function stop(self)
	if self.legit==true then
		self:Stop()
		self.playing=false
	end
end

local function setDirection(self,x,y,z)
	if self.legit==true then
		self:SetDirection(x,y,z)
	end
end

local function setDistance(self,ref,max)
	if self.legit==true then
		self:SetReferenceDistance(ref)
		self:SetMaxDistance(max)
	end
end

local function setAttenuationDistances(self,ref,max)
	if self.legit==true then
		self:SetReferenceDistance(ref)
		self:SetMaxDistance(max)
	end
end

local function setLooping(self,bool)
	if self.legit==true then
		self:SetLooping(bool)
	end
end

local function setPitch(self,pitch)
	if self.legit==true then
		self:SetPitch(pitch)
	end
end

local function setPosition(self,x,y,z)
	if self.legit==true then
		self:SetPosition(x,y,z)
	end
end

local function setRolloff(self,x)
	if self.legit==true then
		self:SetRolloffFactor(x)
	end
end

local function setVelocity(self,x,y,z)
	if self.legit==true then
		self:SetVelocity(x,y,z)
	end
end

local function setVolume(self,vol)
	if self.legit==true then
		self:SetGain(vol)
	end
end

local function setVolumeLimits(self)
end

local function tell(self,type)
	if self.legit==true then
		if type=="samples" then
			return self:GetSampleOffset()
		else
			return self:GetSampleOffset() / self:GetBuffer():GetSampleRate()
		end
	else
		return 1
	end
end

local id=0
function love.audio.newSource(path) --partial
	local legit=false
	local source=lovemu.NewObject("source")
	
	if vfs.Exists(path) then
		local ext = path:match(".+%.(.+)")
		if ext == "flac" or ext == "wav" or ext == "ogg" then
			source = utilities.RemoveOldObject(Sound(path),id)
			id=id+1
			legit=true
			source:SetChannel(1)
			if lovemu.debug then print("loaded: "..path) end
		else
			if lovemu.debug then print("CANT LOAD AUDIO FILE: "..path) end
		end
	else
		if lovemu.debug then print("CANT LOAD AUDIO FILE: "..path) end
	end
	source.playing=false
	
	source.getChannels=getChannels
	source.getDirection=getDirection
	source.getDistance=getDistance
	source.getPitch=getPitch
	source.getPosition=getPosition
	source.getRolloff=getRolloff
	source.getVelocity=getVelocity
	source.getVolume=getVolume
	source.getVolumeLimits=getVolumeLimits
	source.isLooping=isLooping
	source.isPaused=isPaused
	source.isStopped=isStopped
	source.pause=pause
	source.play=play
	source.resume=resume
	source.rewind=rewind
	source.seek=seek
	source.stop=stop
	source.setDirection=setDirection
	source.setDistance=setDistance
	source.setAttenuationDistances=setAttenuationDistances
	source.setLooping=setLooping
	source.setPitch=setPitch
	source.setPosition=setPosition
	source.setRolloff=setRolloff
	source.setVelocity=setVelocity
	source.setVolume=setVolume
	source.setVolumeLimits=setVolumeLimits
	source.tell=tell
	source.legit=legit
	
	sources[id] = source
	
	return source
end

local DistanceModel="none"
function love.audio.getDistanceModel()
	return DistanceModel
end

function love.audio.getNumSources()
	return table.count(sources)
end

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
	for k,v in pairs(sources) do v:Pause() end
end

function love.audio.play()
	for k,v in pairs(sources) do v:Play() end
end

function love.audio.resume()
	for k,v in pairs(sources) do v:Resume() end
end

function love.audio.rewind()
	for k,v in pairs(sources) do v:Rewind() end
end

function love.audio.setDistanceModel(name)
	name = name or "none"
	if name=="none" then
		audio.SetDistanceModel(e.AL_NONE)
	elseif name=="inverse" then
		audio.SetDistanceModel(e.AL_INVERSE_DISTANCE)
	elseif name=="inverse clamped" then
		audio.SetDistanceModel(e.AL_INVERSE_DISTANCE_CLAMPED)
	elseif name=="linear" then
		audio.SetDistanceModel(e.AL_LINEAR_DISTANCE)
	elseif name=="linear clamped" then
		audio.SetDistanceModel(e.AL_LINEAR_DISTANCE_CLAMPED)
	elseif name=="exponent" then
		audio.SetDistanceModel(e.AL_EXPONENT_DISTANCE)
	else
		audio.SetDistanceModel(e.AL_EXPONENT_DISTANCE_CLAMPED)
	end
	
	DistanceModel=name
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
	audio.SetListenerGain(vol)
end

function love.audio.stop()
	for k,v in pairs(sources) do v:Stop() end
end