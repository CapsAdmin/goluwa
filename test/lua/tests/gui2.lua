
local gui2 = {}

gui2.hovering_panel = NULL
gui2.panels = {}
local world
do -- base panel
	local PANEL = metatable.CreateTemplate("panel2")

	metatable.AddParentingTemplate(PANEL)

	metatable.GetSet(PANEL, "Position", Vec3(0, 0, 0))
	metatable.GetSet(PANEL, "Size", Vec2(50, 50))
	metatable.GetSet(PANEL, "Angle", 0)
	metatable.GetSet(PANEL, "Clipping", false)
	metatable.GetSet(PANEL, "Color", Color(1,1,1,1))
	metatable.IsSet (PANEL, "Valid", true)
	metatable.GetSet(PANEL, "Cursor", "hand")
	metatable.GetSet(PANEL, "CacheRender", false) -- WIP
	
	function PANEL:SetCacheRender(b)
		self.CacheRender = b
		
		if b then
			self:UpdateFrameBuffer()
		else
			--self.framebuffer:Remove()
		end
	end	
	
	function PANEL:UpdateFrameBuffer()
		self.framebuffer = render.CreateFrameBuffer(self.Size.w, self.Size.h, {
			attach = "color1",
			texture_format = {
				internal_format = "RGB32F",
			}
		})
	end
	
	function PANEL:MarkDirty()
		self.dirty = true
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
			table.sort( parent:GetChildren(), sorter )
		end
	end
	
	function PANEL:BringToFront()
		local parent = self:GetParent()
		if parent:IsValid() then
			parent:UnparentChild(self)
			parent:AddChild(self)
		end
	end
	
	function PANEL:Render()						
		
		if self.CacheRender then
			surface.SetColor(1,1,0,1)
			surface.SetTexture(self.framebuffer:GetTexture())
			surface.DrawRect(0, 0, self.Size.w, self.Size.h)
		
			if not self.dirty then return end
			
			self.framebuffer:Begin()
			self.framebuffer:Clear()
		end
	
		surface.PushMatrix()
			
			if not self.CacheRender then surface.Translate(self.Position.x, self.Position.y) end
			surface.Rotate(self.Angle)
			
			self:CalcMouse()
			
			if not self.CacheRender and self.Clipping then surface.StartClipping(0, 0, self.Size.w, self.Size.h) end
				
				self:Draw()

				for k,v in pairs(self:GetChildren()) do
					v:Render()
				end				
				
			if not self.CacheRender and self.Clipping then surface.EndClipping() end
			
		surface.PopMatrix()
		
			
		if self.CacheRender then
			self.dirty = false
			
			self.framebuffer:End()
		end
	end

	function PANEL:Draw()
		surface.SetColor(self.Color:Unpack())
		surface.SetWhiteTexture()
		
		local select = 0
		
		if self == gui2.active_focus then
			select = 8
		end
		
		surface.DrawRect(0 - select, 0 - select, self.Size.w + select*2, self.Size.h + select*2)
	end

	do -- mouse

		function PANEL:IsMouseInside()
			return self.hovering and gui2.hovering_panel == self
			--[[if gui2.hovering_panel == self then
					
				for i,v in ipairs(self:GetParentList()) do
					if v ~= gui2.world and not v.hovering then
						return false
					end
				end
				
				return self.hovering
			end]]
		end
		function PANEL:WorldToLocal( ... )--utility
			return surface.WorldToLocal( ... )
		end
		function PANEL:CalcMouse()
			local x, y = surface.WorldToLocal( surface.GetMousePos() )
			
			
			
			if x > 0 and x < self.Size.w and y > 0 and y < self.Size.h then
				self.hovered = true
			else
				self.hovered = false
			end
			local parent = self:GetParent()
			self.hovering = self.hovered and (parent == world or (parent:IsValid() and parent.hovering))

			if self:IsMouseInside() then
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

		function PANEL:OnMouseEnter(x, y)
			self:SetColor(Color(1,1,1,1))
		end

		function PANEL:OnMouseExit(x, y)
			self:SetColor(self.original_color)
		end
		
		function PANEL:OnMouseMove(x, y) end
		function PANEL:OnMouseInput(button, press) self:RequestFocus() self:BringToFront() end
		
		function PANEL:OnCharTyped( c ) end
		function PANEL:OnKeyPressed( key, pressed ) end
		
		function PANEL:RequestFocus()
			gui2.active_focus = self
		end
	end
	
	function gui2.CreatePanel()
		local self = PANEL:New()
		
		table.insert(gui2.panels, self)
				
		return self
	end
end

world = gui2.CreatePanel()
world:SetPosition(Vec3(0, 0))
world:SetSize(Vec2(window.GetSize()))
world:SetColor(Color(1,1,1,0))
world:SetCursor'arrow'
gui2.world = world

event.AddListener("Draw2D", "gui2", function()
	world:Render()
	
	local count = #gui2.panels
	
	for i = count, 1, -1 do
		local panel = gui2.panels[i]
		
		if panel.hovering then
			gui2.hovering_panel = panel
			break
		end
	end
	
	local hover = gui2.hovering_panel
	
	if hover and hover:IsValid() then
		if not hover.hovering and gui2.hovering_panel == hover then
			gui2.hovering_panel = world
		end
		
		local cursor = hover:GetCursor()
		if gui2.active_cursor ~= cursor then
			system.SetCursor(cursor)			
			gui2.active_cursor = cursor
		end
	end
end)

event.AddListener("MouseInput", "gui2", function(button, press)
	local panel = gui2.hovering_panel
	
	if panel:IsValid() and panel:IsMouseInside() then
		panel:OnMouseInput(button, press)
		panel:BringToFront()
	end
end)

local parent = gui2.CreatePanel()
parent:SetPosition(Vec2(500,140))
parent:SetSize(Vec2(300,100))
local c = HSVToColor(0, 0.65, 1)
parent:SetColor(c)
parent.original_color = c
world:AddChild(parent)

for i = 1, 12 do

	local pnl = gui2.CreatePanel()
	
	local c = HSVToColor(math.sin(i/10 * math.pi), 0.65, 1)
	pnl:SetColor(c)
	pnl.original_color = c
	
	pnl:SetPosition(Vec2(0, 20))
	pnl:SetSize(Vec2(30,80))
	pnl:SetAngle(15)
	pnl:SetCursor("no")
	parent:AddChild(pnl)
	parent = pnl
end

local frame = gui2.CreatePanel()
frame:SetSize(Vec2(200,200))
frame:SetPosition(Vec2(50,50))
frame:SetColor(Color(0.65/2,0.65/2,0.65/2,1))
frame:SetClipping(true)
frame:SetCacheRender(false)
frame.OnMouseExit = function() end
frame.OnMouseEnter = function() end
world:AddChild(frame)

for x = 1, 5 do
for y = 1, 5 do

	local pnl = gui2.CreatePanel()
	
	local c = HSVToColor(math.sin(x+y), 0.65, 1)
	pnl:SetColor(c)
	pnl.original_color = c
	
	pnl:SetPosition(Vec2(45 * x, 45 * y) - Vec2(25,50 + 25))
	pnl:SetSize(Vec2(50,50))
	pnl:SetAngle(45)
	pnl:SetCursor'sizeall'
	
	pnl.OnMouseInput = pnl.RequestFocus
	
	frame:AddChild(pnl)
end
end
for k,v in pairs(event.GetTable()) do for k2,v2 in pairs(v) do if type(v2.id)=='string' and v2.id:lower():find"aahh" or v2.id == "gui" then event.RemoveListener(k,v2.id) end end end