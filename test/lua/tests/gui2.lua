
local gui2 = {}

gui2.hovering_panel = NULL
gui2.panels = {}

do -- base panel
	local PANEL = metatable.CreateTemplate("panel2")

	metatable.AddParentingTemplate(PANEL)

	metatable.GetSet(PANEL, "Position", Vec3(0, 0, 0))
	metatable.GetSet(PANEL, "Scroll", Vec2(0, 0))
	metatable.GetSet(PANEL, "Size", Vec2(50, 50))
	metatable.GetSet(PANEL, "Angle", 0)
	metatable.GetSet(PANEL, "MousePosition", Vec2(0, 0))
	metatable.GetSet(PANEL, "Clipping", false)
	metatable.GetSet(PANEL, "Color", Color(1,1,1,1))
	metatable.IsSet (PANEL, "Valid", true)
	metatable.GetSet(PANEL, "Cursor", "hand")
	metatable.GetSet(PANEL, "CachedRendering", false)
	metatable.GetSet(PANEL, "Texture", render.GetWhiteTexture())

	function PANEL:__tostring()
		return ("panel[%p] %s %s %s %s"):format(self, self.Position.x, self.Position.y, self.Size.w, self.Size.h)
	end

	do -- cached rendering
		function PANEL:SetCachedRendering(b)
			self.CachedRendering = b

			if b then
				self:UpdateFrameBuffer()
			end

			self:MarkDirty()
		end

		function PANEL:UpdateFrameBuffer()
			self.framebuffer = render.CreateFrameBuffer(self.Size.w, self.Size.h, {
				attach = "color1",

				texture_format = {
					internal_format = "RGB32F",
				}
			})
			self.cache_texture = self.framebuffer:GetTexture()
		end

		function PANEL:MarkDirty()
			for i, v in ipairs(self:GetParentList()) do
				v:MarkDirty()
			end
			self.dirty = true
		end

		function PANEL:DrawCache()
			if self.dirty then
				self.framebuffer:Begin()
				self.framebuffer:Clear()

				surface.PushMatrix(nil,nil, nil,nil, nil, true)
					self:OnDraw()

					surface.Translate(self.Scroll.x, self.Scroll.y)
					
					for k,v in pairs(self:GetChildren()) do
						v:Draw()
					end

					self.dirty = false
				surface.PopMatrix()
				self.framebuffer:End()
			end

			surface.SetColor(1, 1, 1, 1)
			surface.SetTexture(self.cache_texture)
			surface.DrawRect(0, 0, self.Size.w, self.Size.h)
		end
	end

	local sorter = function(a,b)
		return a.Position.z > b.Position.z
	end

	function PANEL:SetPosition(pos)
		if typex(pos) == "vec2" then
			self.Position.x = pos.x
			self.Position.y = pos.y
		else
			self.Position = pos
		end

		local parent = self:GetParent()

		if parent:IsValid() then
			table.sort(parent:GetChildren(), sorter)
		end
	end

	function PANEL:BringToFront()
		local parent = self:GetParent()

		if parent:IsValid() then
			parent:UnparentChild(self)
			parent:AddChild(self)
		end
	end

	function PANEL:RequestFocus()
		gui2.focus_panel = self
	end

	function PANEL:IsWorld()
		return self == gui2.world
	end

	function PANEL:Draw()
		surface.PushMatrix()
			surface.Translate(self.Position.x, self.Position.y)
			surface.Rotate(self.Angle)

			if self.CachedRendering then
				self:DrawCache()
			else
				if self.Clipping then
					surface.StartClipping(0, 0, self.Size.w, self.Size.h)
				end

					self:OnDraw()

					surface.Translate(self.Scroll.x, self.Scroll.y)
					
					for k,v in ipairs(self:GetChildren()) do
						v:Draw()
					end

				if self.Clipping then
					surface.EndClipping()
				end
			end
		surface.PopMatrix()
	end

	function PANEL:Update()
		surface.PushMatrix()
			surface.Translate(self.Position.x, self.Position.y)
			surface.Rotate(self.Angle)

			self:CalcMouse()

			self:OnUpdate()
			
			surface.Translate(self.Scroll.x, self.Scroll.y)

			for k,v in ipairs(self:GetChildren()) do
				v:Update()
			end
		surface.PopMatrix()
	end

	do -- mouse
		function PANEL:IsMouseOver()
			return self.mouse_over and gui2.hovering_panel == self
		end

		function PANEL:CalcMouse()
			local x, y = surface.WorldToLocal(gui2.mouse_pos.x, gui2.mouse_pos.y)

			self.MousePosition.x = x
			self.MousePosition.y = y
			
			local alpha = 1

			if self.Texture ~= render.GetWhiteTexture() and not self.Texture:IsLoading() then

				-- WHYYYYYYY
				-- WHYYYYYYY
				-- WHYYYYYYY
				if not self.Texture.buffer_cache then
					local buffer, length = self.Texture:Download()

					local tbl = {}

					for i = 0, length - 1 do
						tbl[i] = buffer[i]
					end

					self.Texture.buffer_cache = tbl
				end
				-- WHYYYYYYY
				-- WHYYYYYYY
				-- WHYYYYYYY

				local x = (x / self.Size.w)
				local y = -(y / self.Size.h)  +  1

				alpha = self.Texture:GetPixelColor(x * self.Texture.w, y * self.Texture.h, self.Texture.buffer_cache).a
			end

			if x > 0 and x < self.Size.w and y > 0 and y < self.Size.h and alpha > 0 then
				if self:HasParent() and (self:GetParent():IsWorld() or self:GetParent().mouse_over) then
					self.mouse_over = true
				else
					self.mouse_over = false
				end
			else
				self.mouse_over = false
			end

			if self:IsMouseOver() then
				if not self.mouse_just_entered then
					self:OnMouseEnter(x, y)
					self.mouse_just_entered = true
				end
				self:OnMouseMove(x, y)
			else
				if self.mouse_just_entered then
					self:OnMouseExit(x, y)
					self.mouse_just_entered = false
				end
			end
		end
	end

	function PANEL:OnUpdate()

	end

	function PANEL:OnDraw()
		surface.SetColor(self.Color:Unpack())
		surface.SetTexture(self.Texture)

		surface.DrawRect(0, 0, self.Size.w, self.Size.h)
	end

	function PANEL:OnMouseEnter(x, y) self:SetColor(Color(1,1,1,1)) end
	function PANEL:OnMouseExit(x, y) self:SetColor(self.original_color) end
	function PANEL:OnMouseMove(x, y) self:MarkDirty() end
	function PANEL:OnMouseInput(button, press) self:RequestFocus() self:BringToFront() self:SetClipping(not self:GetClipping()) end

	function PANEL:OnCharTyped(char) end
	function PANEL:OnKeyPressed(key, pressed) end

	function gui2.CreatePanel(parent)
		local self = PANEL:New()

		self:SetParent(parent or gui2.world)

		table.insert(gui2.panels, self)

		return self
	end
end

function gui2.Initialize()
	local world = gui2.CreatePanel()
	world:SetPosition(Vec3(0, 0))
	world:SetSize(Vec2(window.GetSize()))
	world:SetColor(Color(1,1,1,0))
	world:SetCursor'arrow'
	gui2.world = world

	local function check_mouse(panel)
		local children = panel:GetChildren()

		for i = #children, 1, -1 do
			local panel = children[i]
			if panel.mouse_over then
				if panel:HasChildren() then
					return check_mouse(panel)
				end
				return panel
			end
		end

		return panel.mouse_over and panel
	end

	gui2.mouse_pos = Vec2()

	event.AddListener("Draw2D", "gui2", function()

		gui2.mouse_pos.x, gui2.mouse_pos.y = surface.GetMousePos()

		world:Draw()
		world:Update()

		surface.SetWhiteTexture()
		surface.SetColor(1,1,1,1)
		local x, y = surface.WorldToLocal(gui2.mouse_pos.x, gui2.mouse_pos.y)
		surface.DrawRect(x, y, 1, 1)

		gui2.hovering_panel = check_mouse(world) or gui2.world

		if gui2.hovering_panel:IsValid() then
			local cursor = gui2.hovering_panel:GetCursor()

			if gui2.active_cursor ~= cursor then
				system.SetCursor(cursor)
				gui2.active_cursor = cursor
			end
		end
	end)

	event.AddListener("MouseInput", "gui2", function(button, press)
		local panel = gui2.hovering_panel

		if panel:IsValid() and panel:IsMouseOver() then
			panel:MarkDirty()
			panel:OnMouseInput(button, press)
			panel:BringToFront()
		end
	end)
end

function gui2.Test()
	local parent = gui2.CreatePanel()
	parent:SetPosition(Vec2(500,140))
	parent:SetSize(Vec2(300,100))

	local c = HSVToColor(0, 0.65, 1)
	parent:SetColor(c)
	parent.original_color = c

	for i = 1, 12 do

		local pnl = gui2.CreatePanel(parent)

		local c = HSVToColor(math.sin(i/10 * math.pi), 0.65, 1)
		pnl:SetColor(c)
		pnl.original_color = c


		pnl:SetPosition(Vec2(0, 20))

		pnl:SetSize(Vec2(30,80))
		pnl:SetAngle(15)
		pnl:SetCursor("no")
		parent = pnl
	end

	local frame = gui2.CreatePanel()
	frame:SetSize(Vec2(200,200))
	frame:SetPosition(Vec2(50,50))

	frame:SetColor(Color(1,1,1,1))
	frame.original_color = c
	frame:SetTexture(Texture("textures/aahh/soil.png"))
	
	frame:SetCachedRendering(true)
	--frame.OnMouseExit = function() end
	--frame.OnMouseEnter = function() end

	for x = 1, 5 do
	for y = 1, 5 do
		math.randomseed(x*y)

		local pnl = gui2.CreatePanel(frame)

		local c = HSVToColor(math.sin(x+y), 0.65, 1)
		pnl:SetColor(c)
		pnl.original_color = c

		pnl:SetPosition(Vec2(45 * x, 45 * y))
		pnl:SetSize(Vec2(80,80))
		pnl:SetAngle(math.random(360))
		pnl:SetCursor("icon")
		pnl:SetTexture(Texture("textures/aahh/flower.png"))

		pnl.OnMouseInput = pnl.RequestFocus
	end
	end
	
	function frame:OnMouseMove(x, y)
		if input.IsMouseDown("button_3") and not self.drag_pos then
			self.drag_pos = self:GetScroll() + Vec2(x, y)
		end
	end
	
	function frame:OnUpdate()
		if self.drag_pos and input.IsMouseDown("button_3") then
			self:SetScroll(self.drag_pos - self:GetMousePosition())
			self:MarkDirty()
		else
			self.drag_pos = nil
		end
	end
end

gui2.Initialize()
gui2.Test()

for k,v in pairs(event.GetTable()) do for k2,v2 in pairs(v) do if type(v2.id)=='string' and v2.id:lower():find"aahh" or v2.id == "gui" then event.RemoveListener(k,v2.id) end end end