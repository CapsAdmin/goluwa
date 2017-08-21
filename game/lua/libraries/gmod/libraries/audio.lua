do
	function gine.env.CreateSound(ent, path, filter)
		local self = audio.CreateSource("sound/" .. path)

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

	function META:IsPlaying()
		return self.__obj:IsPlaying()
	end
end

if CLIENT then
	function gine.env.surface.PlaySound(path)
		audio.CreateSource("sound/" .. path):Play()
	end
end

function gine.env.sound.GetTable()
	return {}
end