do
	function gmod.env.ParticleEmitter()
		return gmod.WrapObject(ParticleEmitter(), "CLuaEmitter")
	end

	local META = gmod.GetMetaTable("CLuaEmitter")

	function META:Add()

	end
end

do
	local META = gmod.GetMetaTable("CLuaParticle")

end
