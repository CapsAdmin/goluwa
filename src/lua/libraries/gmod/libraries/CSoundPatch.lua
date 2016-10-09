local gmod = ... or gmod

function gmod.env.CreateSound(ent, path, filter)
	local self = audio.CreateSource("sound/" .. path)

	return gmod.WrapObject(self, "CSoundPatch")
end

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