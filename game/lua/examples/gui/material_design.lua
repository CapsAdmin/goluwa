local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(window.GetSize())
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(ColorBytes(238, 238, 238))
base:SetMargin(Rect()+16)
base:SetName("base")

local btn = base:CreatePanel("image")
--btn:SetResizable(true)
btn:SetDraggable(true)
--btn:SetPath("http://www.pngmart.com/files/5/Marketplace-Transparent-PNG.png")

btn:SetSize(Vec2()+160)
btn:CenterSimple()
btn:SetColor(ColorBytes(255, 255, 255))

base:SetStack(true)

for i = 0, 0 do
	local btn = base:CreatePanel("image")
	--btn:SetResizable(true)
	btn:SetDraggable(true)
	btn:SetBringToFrontOnClick(true)

	btn:SetSize(Vec2()+128)
	btn:SetPadding(Rect()+32)
	btn:SetColor(ColorHSV(math.random(),0.75,1))
	btn:SetZ((i/15) * 45)
	--btn:CenterSimple()
	--btn:SetPosition(Vec2(i*170,0))
end

local shadow_size = Vec2() + 1024
local shadow_texture = render.CreateTexture("2d_multisample")
shadow_texture:SetSize(shadow_size)
shadow_texture:SetMultisample(8)
shadow_texture:SetInternalFormat("rgba8")
shadow_texture:SetupStorage()

local shadow_framebuffer = render.CreateFrameBuffer()
shadow_framebuffer:SetTexture(1, shadow_texture)
shadow_texture.fb = shadow_framebuffer

local resolve_tex = render.CreateBlankTexture(shadow_size)

function base:DrawChild(child)
	child.lol = child.lol or math.random()*100
	child.Z = 45*(math.sin(5*system.GetElapsedTime()+child.lol)*0.5+0.5)
--	for _, child in ipairs(self:GetChildren()) do
	--	if child:IsVisible() then
			child:InvalidateMatrix()
			child:RebuildMatrix(true)

			local m = child:GetSize():GetLength() * 0.0025

			render2d.SetWorldMatrix(child.Matrix)

			shadow_framebuffer:Begin()
			shadow_framebuffer:ClearColor(0,0,0,0)

			-- trail and error math
			render2d.PushMatrix()
			render2d.Translatef(0,child.Z*m / window.GetSize().y * shadow_size.y / 2.5)
			render2d.Scale(1/self.Size.x * shadow_size.x,1/self.Size.y * shadow_size.y)
			render2d.Translatef(-child.Position.x * (self.Size.x / shadow_size.x) + child.Position.x, -child.Position.y * (self.Size.y / shadow_size.y) + child.Position.y)
				child:OnPreDraw()
				child:OnDraw()
				child:OnPostDraw()
			render2d.PopMatrix()

			shadow_framebuffer:End()

			resolve_tex:Clear()
			resolve_tex:Shade([[
				vec4 color = vec4(0);

				for (int i = 0; i < samples; i++)
				{
					color += texelFetch(msaa_tex, ivec2(uv * textureSize(msaa_tex)), i);
				}

				return color / samples;
			]], {samples = shadow_texture:GetMultisample(), msaa_tex = shadow_texture})


			local iterations = 2
			local size = child.Z * m ^ 2.75

			for i = 1, iterations do
				for _, dir in ipairs({Vec2(1, 0), Vec2(0, 1)}) do
					resolve_tex:Shade([[
						vec4 sum = vec4(0.0);

						vec2 blur = radius/resolution;

						sum += texture(self, vec2(uv.x - 4.0*blur.x*dir.x, uv.y - 4.0*blur.y*dir.y)) * 0.0162162162;
						sum += texture(self, vec2(uv.x - 3.0*blur.x*dir.x, uv.y - 3.0*blur.y*dir.y)) * 0.0540540541;
						sum += texture(self, vec2(uv.x - 2.0*blur.x*dir.x, uv.y - 2.0*blur.y*dir.y)) * 0.1216216216;
						sum += texture(self, vec2(uv.x - 1.0*blur.x*dir.x, uv.y - 1.0*blur.y*dir.y)) * 0.1945945946;

						sum += texture(self, vec2(uv.x, uv.y)) * 0.2270270270;

						sum += texture(self, vec2(uv.x + 1.0*blur.x*dir.x, uv.y + 1.0*blur.y*dir.y)) * 0.1945945946;
						sum += texture(self, vec2(uv.x + 2.0*blur.x*dir.x, uv.y + 2.0*blur.y*dir.y)) * 0.1216216216;
						sum += texture(self, vec2(uv.x + 3.0*blur.x*dir.x, uv.y + 3.0*blur.y*dir.y)) * 0.0540540541;
						sum += texture(self, vec2(uv.x + 4.0*blur.x*dir.x, uv.y + 4.0*blur.y*dir.y)) * 0.0162162162;

						sum.rgb = vec3(0);

						return sum;
					]], {
						radius = size/i,
						resolution = window.GetSize(),
						dir = dir,
					}, "none")

				end
			end

			render.SetPresetBlendMode("alpha")

			self:InvalidateMatrix()
			self:RebuildMatrix()
			render2d.SetWorldMatrix(self.Matrix)
			gfx.DrawRect(0, 0, self.Size.x, self.Size.y, resolve_tex, 1,1,1,0.75)
			render.SetPresetBlendMode("alpha")
		--end
	--end
end
