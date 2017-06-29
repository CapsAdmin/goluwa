do
	function gine.env.ParticleEmitter()
		return gine.WrapObject(gfx.CreateParticleEmitter(), "CLuaEmitter")
	end

	local META = gine.GetMetaTable("CLuaEmitter")

	gine.GetSet(META, "NoDraw", false)

	function META:Add()

	end
end

do
	local META = gine.GetMetaTable("CLuaParticle")

end
