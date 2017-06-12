local render3d = ... or _G.render3d

function render3d.InitializeSky()
	do
		local tex = render.CreateTexture("cube_map")
		tex:SetInternalFormat("r11f_g11f_b10f")
		--tex:SetInternalFormat("r11f_g11f_b10f")

		--tex:SetMipMapLevels(1)
		tex:SetSize(Vec2() + 512)
		tex:SetupStorage()

		local fb = render.CreateFrameBuffer()
		fb:SetTexture(1, tex, "write", nil, 1)
		fb:WriteThese(1)

		render3d.sky_fb = fb
		render3d.sky_texture = tex
	end

	do
		local views = {
			Matrix44():SetRotation(QuatDeg3(0,-90,-90)), -- back
			Matrix44():SetRotation(QuatDeg3(0,90,90)), -- front

			Matrix44():SetRotation(QuatDeg3(0,0,0)), -- up
			Matrix44():SetRotation(QuatDeg3(180,0,0)), -- down

			Matrix44():SetRotation(QuatDeg3(90,0,0)), -- left
			Matrix44():SetRotation(QuatDeg3(-90,180,0)), -- right
		}

		local sky_projection = Matrix44():Perspective(
			math.rad(90),
			camera.camera_3d.FarZ,
			camera.camera_3d.NearZ,
			render3d.sky_texture:GetSize().x / render3d.sky_texture:GetSize().y
		)

		for i, view in pairs(views) do
			local cam = camera.CreateCamera()
			cam:SetView(view)
			cam:SetProjection(sky_projection)
			views[i] = cam
		end

		render3d.sky_cameras = views
	end


	render3d.sky_shader_source = {
		name = "sky",
		fragment = {
			mesh_layout = {
				{pos = "vec3"},
				{uv = "vec2"},
			},
			source = [[
				out vec3 out_color;

				void main()
				{
					out_color = gbuffer_compute_sky(-get_camera_dir(uv).xzy*vec3(1,-1,1), 1);
				}
			]]
		}
	}
end

function render3d.GetSkyTexture()
	return render3d.sky_texture
end

function render3d.GetShaderSunDirection()
	local sun = entities.world:IsValid() and entities.world.sun

	if sun and sun:IsValid() then
		local dir = sun:GetTRPosition():GetNormalized()
		local x,y,z = dir:Unpack()
		dir.x = y
		dir.y = z
		dir.z = -x
		return dir
	end

	return Vec3(0, 0, 0)
end

function render3d.UpdateSky()
	render.PushDepth(false)
	render.SetPresetBlendMode("none")

	local old = camera.camera_3d

	render3d.sky_fb:Begin()
	for i, view in ipairs(render3d.sky_cameras) do
		render3d.sky_fb:SetTextureLayer(1, render3d.sky_texture, i)

		camera.camera_3d = view

		render2d.PushMatrix(0, 0, render2d.GetSize())
			render3d.sky_shader:Bind()
			render2d.rectangle:Draw()
		render2d.PopMatrix()
	end
	render3d.sky_fb:End()
--	render3d.sky_texture:GenerateMipMap()

	camera.camera_3d = old

	render.PopDepth()
end

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end