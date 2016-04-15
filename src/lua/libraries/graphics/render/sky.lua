local render = ... or _G.render

local directions = {
	QuatDeg3(0,-90,-90), -- back
	QuatDeg3(0,90,90), -- front

	QuatDeg3(0,0,0), -- up
	QuatDeg3(180,0,0), -- down

	QuatDeg3(90,0,0), -- left
	QuatDeg3(-90,180,0), -- right
}

local fb
local tex
local shader

function render.InitializeSky()
	tex = render.CreateTexture("cube_map")
	tex:SetInternalFormat("rgb16f")

	--tex:SetMipMapLevels(16)
	tex:SetSize(Vec2() + 512)
	tex:SetupStorage()

	shader = render.CreateShader({
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
					out_color = gbuffer_compute_sky(get_camera_dir(uv), 1);
				}
			]]
		}
	})

	fb = render.CreateFrameBuffer()
	fb:SetTexture(1, tex, "write", nil, 1)
	fb:CheckCompletness()
	fb:WriteThese(1)
end

function render.UpdateSky()
	if not fb then return end
	if not tex then render.InitializeSky() end

	render.SetDepth(false)
	render.SetBlendMode()

	for k,v in pairs(render.gbuffer_values) do
		shader[k] = v
	end

	render.SetShaderOverride(shader)
	local old_view = render.camera_3d:GetView()
	local old_projection = render.camera_3d:GetProjection()

	local projection = Matrix44()
	projection:Perspective(math.rad(90), render.camera_3d.FarZ, render.camera_3d.NearZ, tex:GetSize().x / tex:GetSize().y)

	fb:Begin()
		for i, rot in ipairs(directions) do
			fb:SetTexture(1, tex, nil, nil, i)
			--fb:Clear()

			local view = Matrix44()
			view:SetRotation(rot)
			render.camera_3d:SetView(view)
			render.camera_3d:SetProjection(projection)

			surface.DrawRect(0,0,surface.GetSize())
		end
	fb:End()

	render.camera_3d:SetView(old_view)
	render.camera_3d:SetProjection(old_projection)

	tex:GenerateMipMap()


	render.SetShaderOverride()
end

function render.GetSkyTexture()
	if not tex then render.InitializeSky() end
	return tex
end

function render.GetShaderSunDirection()
	local sun = entities.world and entities.world.sun

	if sun and sun:IsValid() then
		local dir = sun:GetTRPosition():GetNormalized()

		return Vec3(dir.y, dir.z, -dir.x)
	end

	return Vec3()
end

if RELOAD then
	RELOAD = nil
	render.InitializeGBuffer()
end