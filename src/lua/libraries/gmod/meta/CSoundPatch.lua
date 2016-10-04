local gmod = ... or gmod

local META = gmod.env.FindMetaTable("CSoundPatch")

function META:SetSoundLevel()

end

function META:Stop()
	self.__obj:Stop()
end

function META:Play()
	self.__obj:Play()
end

function META:IsPlaying()
	return self.__obj:IsPlaying()
end