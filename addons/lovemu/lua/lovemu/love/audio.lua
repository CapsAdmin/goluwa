local love=love
local lovemu=lovemu
love.audio={}


local function getChannels(self)
	return 2 --stereo
end

local function getDirection(self)
	return 0,0,0
end

local function getDistance(self)
	return 0,0
end

local function getPitch(self)
	return 1
end

local function getPosition(self)
	return 0,0,0
end

local function getRolloff(self)
	return 0
end

local function getVelocity(self)
	return 0,0,0
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
end

local function play(self)
	if self.legit==true then
		self:Play()
		self.playing=true
	end
end

local function resume(self)
end

local function rewind(self)
end

local function seek(self)
end

local function stop(self)
	if self.legit==true then
		self.playing=false
		self:Stop()
	end
end

local function setDirection(self)
end

local function setDistance(self)
end

local function setAttenuationDistances(self)
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

local function setPosition(self)
end

local function setRolloff(self)
end

local function setVelocity(self)
end

local function setVolume(self,vol)
	if self.legit==true then
		self:SetGain(vol)
	end
end

local function setVolumeLimits(self)
end

local function tell(self)
	return 1
end

local id=1
function love.audio.newSource(path) --partial
	local legit=false
	local source={}
	if vfs.Exists(R(path))==true then
		local ext=string.explode(path,".")
		ext=ext[#ext]
		if ext=="flac" or ext=="wav" or ext=="ogg" then
			source = utilities.RemoveOldObject(Sound(path),id)
			id=id+1
			legit=true
			source:SetChannel(1)
			print("loaded: "..path)
		else
			print("CANT LOAD AUDIO FILE: "..path)
		end
	else
		print("CANT LOAD AUDIO FILE: "..path)
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
	return source
end


function love.audio.getDistanceModel() --partial
end

function love.audio.getNumSources() --partial
end

function love.audio.getOrientation() --partial
end

function love.audio.getPosition() --partial
end

function love.audio.getVelocity() --partial
end

function love.audio.getVolume() --partial
end

function love.audio.pause() --partial
end

function love.audio.play() --partial
end

function love.audio.resume() --partial
end

function love.audio.rewind() --partial
end

function love.audio.setDistanceModel() --partial
end

function love.audio.setOrientation() --partial
end

function love.audio.setPosition() --partial
end

function love.audio.setVelocity() --partial
end

function love.audio.setVolume() --partial
end

function love.audio.stop() --partial
end