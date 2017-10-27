-- scale translation somehow


local base = gui.CreatePanel("base", nil, "lol")
base:SetSize(window.GetSize())
base:CenterSimple()
base:SetResizable(true)
base:SetDraggable(true)
base:SetColor(ColorBytes(238, 238, 238))
base:SetMargin(Rect()+16)
base:SetName("base")
--[[
local btn = base:CreatePanel("image")
--btn:SetResizable(true)
btn:SetDraggable(true)
btn:SetPath("https://openclipart.org/image/2400px/svg_to_png/252869/Prismatic-Abstract-Star-Motif-2.png")

btn:SetSize(Vec2()+160)
btn:CenterSimple()
btn:SetColor(ColorBytes(255, 255, 255))
]]

base:SetStack(true)

for i = 0, 0 do
	local btn = base:CreatePanel("image")
	--btn:SetResizable(true)
	btn:SetDraggable(true)
	btn:SetBringToFrontOnClick(true)

	btn:SetSize(Vec2()+128)
	btn:SetPadding(Rect()+32)
	btn:SetColor(ColorHSV(math.random(),0.75,1))
	--btn:CenterSimple()
	--btn:SetPosition(Vec2(i*170,0))


	btn.OnPostDraw = function()  end

end

local shadow_size = window.GetSize()/2
local shadow_texture = render.CreateTexture("2d_multisample")
shadow_texture:SetSize(shadow_size)
shadow_texture:SetMultisample(4)
shadow_texture:SetInternalFormat("rgba8")
shadow_texture:SetMipMapLevels(1)
shadow_texture:SetupStorage()

local shadow_framebuffer = render.CreateFrameBuffer()
shadow_framebuffer:SetTexture(1, shadow_texture)
shadow_texture.fb = shadow_framebuffer

function base:DrawChild(child)
	child.lol = child.lol or math.random()*100
	child.Z = 0--45*(math.sin(5*system.GetElapsedTime()+child.lol)*0.5+0.5)
--	for _, child in ipairs(self:GetChildren()) do
	--	if child:IsVisible() then
			child:InvalidateMatrix()
			child:RebuildMatrix(true)

			local m = child:GetSize():GetLength() * 0.002

			render2d.SetWorldMatrix(child.Matrix)

			shadow_framebuffer:Begin()
			shadow_framebuffer:ClearColor(0,0,0,0)


			render2d.PushMatrix()
				render2d.Translatef(math.sin(os.clock()) * 40,math.cos(os.clock()) * 40)
				render2d.Scale(50,50)
				render2d.BindShader()
				render2d.rectangle:Draw()
			render2d.PopMatrix()

			-- trail and error math
			render2d.PushMatrix()
			render2d.Translatef(0,child.Z*m/3 + 10 + math.sin(os.clock()*10)*5)
			render2d.Scale(1/self.Size.x * shadow_size.x,1/self.Size.y * shadow_size.y)
			render2d.Translatef(-child.Position.x * (self.Size.x / shadow_size.x) + child.Position.x, -child.Position.y * (self.Size.y / shadow_size.y) + child.Position.y)
				child:OnPreDraw()
				child:OnDraw()
				child:OnPostDraw()
			render2d.PopMatrix()

			shadow_framebuffer:End()

			local iterations = 2
			local size = child.Z * m ^ 2.75

			for i = 1, iterations do
				for _, dir in ipairs({Vec2(1, 0), Vec2(0, 1)}) do
					shadow_texture:Shade([[
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
						resolution = shadow_size,
						dir = dir,
					}, "none")

				end
			end

			render.SetPresetBlendMode("alpha")

			self:InvalidateMatrix()
			self:RebuildMatrix()
			render2d.SetWorldMatrix(self.Matrix)
			gfx.DrawRect(0, 0, self.Size.x, self.Size.y, shadow_texture, 1,1,1,0.75)
			render.SetPresetBlendMode("alpha")
		--end
	--end
end
