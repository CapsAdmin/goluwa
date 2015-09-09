local render = ... or _G.render

local SHADER = {
	name = "shadow_map",
	force = true,
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
		},	
		source = "gl_Position = g_projection_view_world * vec4(pos, 1); out_pos.z = gl_Position.z;"
	},
	fragment = {
		mesh_layout = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
		},
		source = [[
			out float depth;
				
			void main()
			{			
				if ((lua[Translucent = false] || lua[AlphaTest = false]) && !lua[DiffuseAlphaMetallic = false] && texture(lua[DiffuseTexture = "sampler2D"], uv).r < 0.5)
				{
					discard;
				}
				else
				{
					depth = 0.5 * pos.z + 0.5;
				}
			}
		]],
	},
}

local function setup(self)
	local tex
	
	if self.cubemap then
		tex = render.CreateTexture("cube_map")
	else
		tex = render.CreateTexture("2d")
	end
	
	tex:SetSize(Vec2() + self.ShadowSize)
	tex:SetInternalFormat("r16f")
	tex:SetBaseLevel(0)
	tex:SetMaxLevel(0)
	tex:SetWrapS("clamp_to_border")
	tex:SetWrapT("clamp_to_border")
	tex:SetWrapR("clamp_to_border")
	tex:SetBorderColor(Color(1,1,1,1))
	tex:SetMinFilter("linear")
	tex:SetupStorage()
	
	local depth = render.CreateTexture("2d")
	depth:SetSize(Vec2() + self.ShadowSize)
	depth:SetInternalFormat("depth_component16")
	depth:SetMagFilter("nearest")
	depth:SetWrapS("clamp_to_edge")
	depth:SetWrapT("clamp_to_edge")
	depth:SetWrapR("clamp_to_edge")
	depth:SetupStorage()
	
	local fb = render.CreateFrameBuffer()
	fb:SetSize(Vec2() + self.ShadowSize)
	fb:SetTexture("depth", depth or {
		size = Vec2() + self.ShadowSize,
		internal_format = "depth_component16",
	})
	fb:SetTexture(1, tex)
	--fb:CheckCompletness()
	fb.fb:DrawBuffer("GL_COLOR_ATTACHMENT0")
	--fb.fb:ReadBuffer("GL_NONE")	
	
	self.fb = fb
	self.tex = tex
end

local directions = {
	QuatDeg3(0,0,0),
	QuatDeg3(180,0,0),
	QuatDeg3(0,90,0),
	QuatDeg3(0,-90,0),
	QuatDeg3(90,0,0),
	QuatDeg3(-90,0,0),
}

local META = prototype.CreateTemplate("shadow_map")

META:GetSet("ShadowSize", 256)

function META:SetShadowSize(size)
	self.ShadowSize = size
	setup(self)
end

function META:Begin()
	render.SetCullMode("none", true)
	render.EnableDepth(true)
	render.SetBlendMode()
	render.SetShaderOverride(render.shadow_map_shader)
	self.fb:Begin()
end

function META:End()
	render.SetCullMode("front", false)
	render.EnableDepth(false)
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
		self.fb:SetCubemapTexture(1, i, self.tex)
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