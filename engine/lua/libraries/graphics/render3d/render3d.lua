local render3d = _G.render3d or {}

-- debug variables
render3d.noculling = false
render3d.nomat = false
render3d.nomodel = false


render3d.camera = camera.CreateCamera()

event.AddListener("Draw3D", "render3d", function()
	if render3d.IsGBufferReady() then
		render3d.DrawGBuffer()
	end
end)

event.AddListener("PreDrawGUI", "render3d", function()
	if render3d.IsGBufferReady() then
		render.GetScreenFrameBuffer():ClearAll()

		if menu and menu.IsVisible() then
			render2d.PushHSV(1,0,1)
		end

		render2d.SetTexture(render3d.GetFinalGBufferTexture())
		render2d.DrawRect(0, 0, render2d.GetSize())

		if menu and menu.IsVisible() then
			render2d.PopHSV()
		end

		if render3d.debug then
			render3d.DrawGBufferDebugOverlay()
		end
	end
end)

runfile("camera.lua", render3d)
runfile("model_loader.lua", render3d)
runfile("gbuffer.lua", render3d)
runfile("environment_probe.lua", render3d)
runfile("framebuffer_cubemap.lua", render3d)
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

	render3d.LoadModel("models/low-poly-sphere.obj", function(meshes)
		render3d.simple_mesh = meshes[1]
	end)
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