do
	function gine.env.CreateSound(ent, path, filter)
		resource.skip_providers = true
		local self = audio.CreateSource("sound/" .. path)
		resource.skip_providers = false
		return gine.WrapObject(self, "CSoundPatch")
	end

	local META = gine.GetMetaTable("CSoundPatch")

	function META:SetSoundLevel(level)
		self.sound_level = level
	end

	function META:GetSoundLevel()
		return self.sound_level
	end

	function META:Stop()
		self.__obj:Stop()
	end

	function META:Play()
		self.__obj:Play()
	end

	function META:PlayEx(volume, pitch)
		self.__obj:Play()
		self.__obj:SetGain(volume)
		self.__obj:SetPitch(pitch/100)
	end

	function META:ChangeVolume(volume)
		self.__obj:SetGain(volume)
	end

	function META:ChangePitch(pitch)
		self.__obj:SetPitch(pitch/100)
	end

	function META:IsPlaying()
		return self.__obj:IsPlaying()
	end
end

if CLIENT then
	function gine.env.surface.PlaySound(path)
		resource.skip_providers = true
		audio.CreateSource("sound/" .. path):Play()
		resource.skip_providers = false
	end
end

function gine.env.sound.GetTable()
	return {}
end