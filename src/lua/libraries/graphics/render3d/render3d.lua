local render3d = _G.render3d or {}

runfile("model_loader.lua", render3d)
runfile("gbuffer.lua", render3d)
runfile("environment_probe.lua", render3d)
runfile("shadow_map.lua", render3d)
runfile("sky.lua", render3d)
runfile("vmt.lua", render3d)
runfile("debug.lua", render3d)

function render3d.Initialize()
	render3d.InitializeSky()
	render3d.InitializeGBuffer()
	render3d.sky_shader = render.CreateShader(render3d.sky_shader_source) -- uahsduyHUASH
	render3d.GenerateTextures()
	runfile("lua/libraries/graphics/render3d/scene.lua", render3d)
end

function render3d.GenerateTextures()
	if not render3d.environment_probe_texture then
		local tex = render.CreateTexture("cube_map")
		tex:SetMipMapLevels(1)

		render3d.environment_probe_texture = tex
	end

	local mat = render.CreateMaterial("model")
	mat:SetAlbedoTexture(render.GetWhiteTexture())
	mat:SetRoughnessTexture(render.GetWhiteTexture())
	mat:SetMetallicTexture(render.GetWhiteTexture())
	mat:SetRoughnessMultiplier(0)
	mat:SetMetallicMultiplier(1)
	render3d.default_material = mat
end

function render3d.GetEnvironmentProbeTexture()
	return render3d.environment_probe_texture
end

return render3d