local render = ... or _G.render

local directions = {
	Matrix44():SetRotation(QuatDeg3(0,-90,-90)), -- back
	Matrix44():SetRotation(QuatDeg3(0,90,90)), -- front

	Matrix44():SetRotation(QuatDeg3(0,0,0)), -- up
	Matrix44():SetRotation(QuatDeg3(180,0,0)), -- down

	Matrix44():SetRotation(QuatDeg3(90,0,0)), -- left
	Matrix44():SetRotation(QuatDeg3(-90,180,0)), -- right
}

local fb
local tex
local shader
local sky_projection

function render.InitializeSky()
	tex = render.CreateTexture("cube_map")
	tex:SetInternalFormat("r11f_g11f_b10f")

	--tex:SetMipMapLevels(16)
	tex:SetSize(Vec2() + 256)
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

	sky_projection = Matrix44():Perspective(math.rad(90), render.camera_3d.FarZ, render.camera_3d.NearZ, tex:GetSize().x / tex:GetSize().y)
end

function render.UpdateSky()
	render.SetDepth(false)
	render.SetBlendMode()

	render.SetShaderOverride(shader)
	local old_view = render.camera_3d:GetView()
	local old_projection = render.camera_3d:GetProjection()

	fb:Begin()
		for i, view in ipairs(directions) do
			--fb:SetTexture(1, tex, nil, nil, i)
			fb:SetTextureLayer(1, tex, i)
			--fb:Clear()
			render.camera_3d:SetView(view)
			render.camera_3d:SetProjection(sky_projection)

			surface.DrawRect(0,0,surface.GetSize())
		end
	fb:End()

	render.camera_3d:SetView(old_view)
	render.camera_3d:SetProjection(old_projection)

	tex:GenerateMipMap()
	render.SetShaderOverride()
end

function render.GetSkyTexture()
	return tex
end

function render.GetShaderSunDirection()
	local sun = entities.world and entities.world.sun

	if sun and sun:IsValid() then
		local dir = sun:GetTRPosition():GetNormalized()
		local x,y,z = dir:Unpack()
		dir.x = y
		dir.y = z
		dir.z = -x
		return dir
	end

	return Vec3()
end

if RELOAD then
	RELOAD = nil
	render.InitializeGBuffer()
end