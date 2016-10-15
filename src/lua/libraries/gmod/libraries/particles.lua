do
	function gine.env.ParticleEmitter()
		return gine.WrapObject(ParticleEmitter(), "CLuaEmitter")
	end

	local META = gine.GetMetaTable("CLuaEmitter")

	function META:Add()

	end
end

do
	local META = gine.GetMetaTable("CLuaParticle")

end
