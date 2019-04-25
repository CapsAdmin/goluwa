local render3d = ... or _G.render3d

local SHADER = {
	name = "shadow_map",
	force = true,
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{normal = "vec3"},
		},
		source = "gl_Position = g_projection_view_world * vec4(pos, 1.0);"
	},
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		source = [[
			out float depth;

			void main()
			{
				if (!lua[AlbedoAlphaMetallic = false])
				{
					float alpha = texture(lua[AlbedoTexture = "sampler2D"], uv).a * lua[Color = Color(1,1,1,1)].a;

					if (alpha_discard(uv, alpha))
					{
						discard;
					}
				}

				depth = gl_FragCoord.z;
			}
		]],
	},
}

local function setup(self)
	local tex = render.CreateTexture("2d")

	if self.cubemap then
		tex = render.CreateTexture("cube_map")
	else
		tex = render.CreateTexture("2d")
	end

	tex:SetSize(Vec2() + self.ShadowSize)
	tex:SetInternalFormat("r32f")

	tex:SetupStorage()

	local fb = render.CreateFrameBuffer()
	fb:SetSize(Vec2() + self.ShadowSize)
	fb:SetTexture("depth", {
		size = Vec2() + self.ShadowSize,
		internal_format = "depth_component16",
	})
	fb:SetTexture(1, tex)
	fb:WriteThese(1)

	self.fb = fb
	self.tex = tex
end

local directions = {
	QuatDeg3(0,-90,-90), -- back
	QuatDeg3(0,90,90), -- front

	QuatDeg3(0,0,0), -- up
	QuatDeg3(180,0,0), -- down

	QuatDeg3(90,0,0), -- left
	QuatDeg3(-90,180,0), -- right
}

local META = prototype.CreateTemplate("shadow_map")

META:GetSet("ShadowSize", 256)

function META:SetShadowSize(size)
	self.ShadowSize = size
	setup(self)
end

function META:Begin()
	render.SetForcedCullMode("none")
	render.PushDepth(true)
	render.SetPresetBlendMode("none")
	render3d.shadow_map_shader:Bind()
	self.fb:Begin()
end

function META:End()
	render.SetForcedCullMode()
	render.PopDepth()
	self.fb:End()
end

function META:GetTexture()
	return self.tex
end

function META:Clear()
	self.fb:ClearDepth(1)
end

function META:GetDirections()
	return directions
end

function META:SetupCube(i)
	if self.cubemap then
		self.fb:SetTexture(1, self.tex, nil, nil, i)
	end
end

META:Register()

function render3d.CreateShadowMap(cubemap)
	local self = META:CreateObject()

	if not render3d.shadow_map_shader then
		render3d.shadow_map_shader = render.CreateShader(SHADER)
	end

	self.cubemap = cubemap

	setup(self)

	return self
end

if RELOAD then
	render3d.shadow_map_shader = render.CreateShader(SHADER)
end