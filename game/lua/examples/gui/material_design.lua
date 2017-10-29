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
btn:SetPath("https://www.besttvchoice.net/wp-content/uploads/2017/05/abstract-background.png")
btn:SetSizeToImage(true)
--btn:SetSize(Vec2()+160)
btn:CenterSimple()
btn:SetColor(ColorBytes(255, 255, 255))
btn:SetZ(0)

function btn:OnMouseEnter()
	self:Animate("Z", {50, function() return self:IsMouseOver() end, "from"})
end

--base:SetStack(true)

for i = 0, 2 do
	local btn = base:CreatePanel("base")
	--btn:SetResizable(true)
	btn:SetDraggable(true)
	btn:SetBringToFrontOnClick(true)

	btn:SetSize(Vec2(200,60))
	btn:SetPadding(Rect()+32)
	btn:SetColor(ColorHSV(math.random(),0.75,1))
	btn:SetZ(6)
	btn:SetResizable(true)
	btn:SetPosition(Vec2(0, i*(60+10))+400)

	local life = system.GetElapsedTime()

	btn.Roundness = 4
	function btn:SetRoundness(v) self.Roundness = v end

btn.DrawScaleCenter = true
	btn:Animate("DrawScaleOffset", {Vec2(1/btn:GetSize().x/btn:GetSize().y,btn:GetSize().y/btn:GetSize().x), "from"}, 0.5, "=", 3, true)
	btn:Animate("Roundness", {64, "from"}, 0.5, "=", 3, true)

	btn.OnDraw = function(self, shadows)

		render2d.SetColor(
			self.Color.r + self.DrawColor.r,
			self.Color.g + self.DrawColor.g,
			self.Color.b + self.DrawColor.b,
			self.Color.a + self.DrawColor.a
		)

		gfx.DrawRoundedRect(0, 0, self.Size.x, self.Size.y, self.Roundness)

		if self.circle_animation and not shadows then
			render.SetStencil(true)
			render.GetFrameBuffer():ClearStencil(0) -- out = 0

			render.StencilOperation("keep", "replace", "replace")
			render.StencilFunction("always", 33)
				render2d.PushColor(0, 0, 0, 0)
				render2d.SetTexture()
				render2d.DrawRect(0, 0, self.Size.x, self.Size.y)
				render2d.PopColor()

			render.StencilFunction("equal", 33)

			local t = self.circle_time - system.GetElapsedTime()
			if t > 0 then
				render2d.PushColor(0.5, 0.5, 0.5, (t ^ 4) * 0.5)
				t = -t + 1
				t = t ^ 0.75

				gfx.DrawFilledCircle(self.circle_animation.x, self.circle_animation.y, 4 + t * self.Size.x * 2, 4 + t * self.Size.x * 2)

				render2d.PopColor()
			else
				self.circle_animation = nil
			end

			render.SetStencil(false)
		end

	end

	function btn:OnMouseInput(key, press)
		if key == "button_1" and press then
			self:Animate("Z", {"from", 35, function() return self:IsMouseOver() end, "from"}, 0.75, "+")
			self:Animate("DrawColor", {Color(1,1,1,1)*0.3, function() return self:IsMouseOver() end, "from"}, nil, "-", 0.25)

			self.circle_animation = self:GetMousePosition():Copy()
			self.circle_time = system.GetElapsedTime() + 1
		end
	end

	--btn:CenterSimple()
	--btn:SetPosition(Vec2(i*170,0))
end

local shadow_size = Vec2() + 512
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
	if child.Z == 0 then return end
			child:InvalidateMatrix()
			child:RebuildMatrix(true)

			local m = 0.4

			render2d.SetWorldMatrix(child.Matrix)

			shadow_framebuffer:Begin()
			shadow_framebuffer:ClearColor(0,0,0,0)

			-- trail and error math
			render2d.PushMatrix()
				render2d.Translatef(0,child.Z / window.GetSize().y * shadow_size.y / 2.5)
				render2d.Scale(1/self.Size.x * shadow_size.x,1/self.Size.y * shadow_size.y)
				render2d.Translatef(-child.Position.x * (self.Size.x / shadow_size.x) + child.Position.x, -child.Position.y * (self.Size.y / shadow_size.y) + child.Position.y)
				child:OnPreDraw()
				child:OnDraw(true)
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
			local size = child.Z * 2 * m ^ 2.75

			for i = 1, iterations do
				for _, dir in ipairs({Vec2(1, 0), Vec2(0, 1)}) do
					resolve_tex:Shade([[
						float sum = 0;

						vec2 blur = radius/resolution;

						sum += texture(self, vec2(uv.x - 4.0*blur.x*dir.x, uv.y - 4.0*blur.y*dir.y)).a * 0.0162162162;
						sum += texture(self, vec2(uv.x - 3.0*blur.x*dir.x, uv.y - 3.0*blur.y*dir.y)).a * 0.0540540541;
						sum += texture(self, vec2(uv.x - 2.0*blur.x*dir.x, uv.y - 2.0*blur.y*dir.y)).a * 0.1216216216;
						sum += texture(self, vec2(uv.x - 1.0*blur.x*dir.x, uv.y - 1.0*blur.y*dir.y)).a * 0.1945945946;

						sum += texture(self, vec2(uv.x, uv.y)).a * 0.2270270270;

						sum += texture(self, vec2(uv.x + 1.0*blur.x*dir.x, uv.y + 1.0*blur.y*dir.y)).a * 0.1945945946;
						sum += texture(self, vec2(uv.x + 2.0*blur.x*dir.x, uv.y + 2.0*blur.y*dir.y)).a * 0.1216216216;
						sum += texture(self, vec2(uv.x + 3.0*blur.x*dir.x, uv.y + 3.0*blur.y*dir.y)).a * 0.0540540541;
						sum += texture(self, vec2(uv.x + 4.0*blur.x*dir.x, uv.y + 4.0*blur.y*dir.y)).a * 0.0162162162;

						return vec4(0,0,0,sum);
					]], {
						radius = size/i / 1.75,
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
