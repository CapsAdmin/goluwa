local render = ... or _G.render

local SHADER = {
	name = "shadow_map",
	force = true,
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{normal = "vec3"},
		},
		source = "gl_Position = g_projection_view_world * vec4(pos, 1); out_pos.z = (gl_Position.z) * 0.5 + 0.5;"
	},
	fragment = {
		mesh_layout = {
			{pos = "vec3"},
			{uv = "vec2"},
			{normal = "vec3"},
		},
		source = [[
			out float depth;

			// https://www.shadertoy.com/view/MslGR8
			bool dither(vec2 uv, float alpha)
			{
				if (lua[AlphaTest = false])
				{
					return alpha*alpha < 0.25;
				}

				const vec3 magic = vec3( 0.06711056, 0.00583715, 52.9829189 );
				float lol = fract( magic.z * fract( dot( gl_FragCoord.xy, magic.xy ) ) );

				return (alpha + lol) < 1;
			}

			void main()
			{
				if (!lua[AlbedoAlphaMetallic = false])
				{
					float alpha = texture(lua[AlbedoTexture = "sampler2D"], uv).a * lua[Color = Color(1,1,1,1)].a;

					if
					(
						(lua[Translucent = false] && dither(uv, alpha)) ||
						(lua[AlphaTest = false] && alpha < 0.5)
					)
					{
						discard;
					}
				}

				depth = pos.z;
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
	tex:SetBaseLevel(0)
	tex:SetMaxLevel(0)
	--[[tex:SetWrapS("clamp_to_border")
	tex:SetWrapT("clamp_to_border")
	tex:SetWrapR("clamp_to_border")
	tex:SetBorderColor(Color(1,1,1,1))
	]]
	tex:SetMinFilter("linear")
	tex:SetupStorage()

	local fb = render.CreateFrameBuffer()
	fb:SetSize(Vec2() + self.ShadowSize)
	fb:SetTexture("depth", {
		size = Vec2() + self.ShadowSize,
		internal_format = "depth_component32f",
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
	render.SetCullMode("none", true)
	render.SetDepth(true)
	render.SetBlendMode()
	render.SetShaderOverride(render.shadow_map_shader)
	self.fb:Begin()
end

function META:End()
	render.SetCullMode("front", false)
	render.SetDepth(false)
	self.fb:End()
end

function META:GetTexture()
	return self.tex
end

function META:Clear()
	self.fb:Clear("all", 1,0,0,0, 1)
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

function render.CreateShadowMap(cubemap)
	local self = prototype.CreateObject(META)

	if not render.shadow_map_shader then
		render.shadow_map_shader = render.CreateShader(SHADER)
	end

	self.cubemap = cubemap

	setup(self)

	return self
end

if RELOAD then
	render.shadow_map_shader = render.CreateShader(SHADER)
end