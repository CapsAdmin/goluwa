
local gui2 = {}

gui2.hovering_panel = NULL
gui2.panels = {}

do -- base panel
	local PANEL = metatable.CreateTemplate("panel2")

	metatable.AddParentingTemplate(PANEL)

	metatable.GetSet(PANEL, "Position", Vec2(0, 0))
	metatable.GetSet(PANEL, "Order", 0)
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

					surface.Translate(-self.Scroll.x, -self.Scroll.y)
					
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
		return a.Order > b.Order
	end

	function PANEL:SetOrder(pos)
		self.Order = pos
		
		local parent = self:GetParent()

		if parent:IsValid() then
			table.sort(parent:GetChildren(), sorter)
		end
	end
	
	function PANEL:SetScroll(vec)
		local size = self:GetSizeOfChildren()
			
		self.Scroll = Vec2(math.clamp(vec.x, 0, size.x - self.Size.w), math.clamp(vec.y, 0, size.y - self.Size.h))
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
	
	function PANEL:GetSizeOfChildren()
		local total_size = Vec2()
		
		for k, v in pairs(self:GetChildren()) do
			local x, y = v:GetPosition():Unpack()
		 
			x = x + v.Size.x
			y = y + v.Size.y
			
			if x > total_size.x then 
				total_size.x = x
			end
			
			if y > total_size.y then
				total_size.y = y
			end
		end
		
		return total_size
	end
	
	do -- animations
		PANEL.animations = {}
		
		--[[2:11 AM - Morten: ]]
		local function lerp_values(values, alpha)
			local tbl = {}

			for i = 1, #values - 1 do
				if type(values[i] ) == "number" then
					tbl[i] = math.lerp(alpha, values[i], values[i + 1])
				else
					tbl[i] = values[i] :GetLerped(alpha, values[i + 1])
				end
			end

			if #tbl > 1 then 
				return lerp_values(tbl, alpha) 
			else 
				return tbl[1] 
			end
		end
		
		function PANEL:UpdateAnimations()
			for key, animation in pairs(self.animations) do
				
				local pause = false
				
				for i, v in ipairs(animation.pausers) do
					if animation.alpha >= v.alpha then
						if v.check()  then
							pause = true
						else
							table.remove(animation.pausers, i)
							break
						end
					end
				end
				
				if not pause then
				
					animation.alpha = animation.alpha + timer.GetFrameTime() / animation.time
					local alpha = animation.alpha
					
					local val
					local from = animation.from
					local to = animation.to
					
					if animation.pow then
						alpha = alpha ^ animation.pow
					end
								
					val = lerp_values(to, alpha)
					
					if val == false then return end
							
					animation.func(self, val)
								
					if alpha > 1 then
						if animation.callback then
							if animation.callback(self) ~= false then
								animation.func(self, from)
							end
						else
							animation.func(self, from)
						end
						
						self.animations[key] = nil
					end
				end
			end
		end
		
		function PANEL:Animate(var, to, time, operator, pow) 
		
			-- todo: multiple animations of the same type
			if self.animations[var] then 
				self.animations[var].alpha = 0
			return end
		
			
			local from = type(self[var]) == "number" and self[var] or self[var]:Copy()
			
			if type(to) ~= "table" then
				to = {to}
			end
			
			local pausers = {}
			
			for i, v in pairs(to) do
				if type(v) == "function" then
					to[i] = nil
					table.insert(pausers, {check = v, alpha = (i - 1) / (table.count(to) + #pausers)})
				end
			end
			
			table.fixindices(to)
			
			for i, v in ipairs(to) do 
				if v == "from" then 
					to[i] = from 
				else
					if operator then
						if operator == "+" then
							v = from + v
						elseif operator == "-" then
							v = from - v
						elseif operator == "^" then
							v = from ^ v
						elseif operator == "*" then
							v = from * v
						elseif operator == "/" then
							v = from / v
						end
					end
					
					to[i] = v
				end
			end
			
			table.insert(to, 1, from)
				
			self.animations[var] = {
				operator = operator,
				from = from,
				to = to,			
				time = time or 0.25, 
				var = var, 
				func = self["Set" .. var], 
				start_time = timer.GetSystemTime(),
				pow = pow,
				callback = callback,
				pausers =  pausers,
				alpha = 0,
			}
		end
	end
		
	function PANEL:Draw()
		surface.PushMatrix()
			render.Translate(self.Position.x, self.Position.y, 0)
			
			render.Translate(self.Size.w/2, self.Size.h/2, 0)
			render.Rotate(self.Angle, 0, 0, 1)
			render.Translate(-self.Size.w/2, -self.Size.h/2, 0)

			if self.CachedRendering then
				self:DrawCache()
			else
				if self.Clipping then
					surface.StartClipping(0, 0, self.Size.w, self.Size.h)
				end

					self:OnDraw()

					render.Translate(-self.Scroll.x, -self.Scroll.y, 0)
					
					for k,v in ipairs(self:GetChildren()) do
						if 	
							v.Position.x - self.Scroll.x < self.Size.w and 
							v.Position.y - self.Scroll.y < self.Size.h and
							v.Position.x - self.Scroll.x > -v.Size.w and 
							v.Position.y - self.Scroll.y > -v.Size.h
						then
							v:Draw()
						end
					end

				if self.Clipping then
					surface.EndClipping()
				end
			end
		surface.PopMatrix()
	end

	function PANEL:Update()
		
		self:UpdateAnimations()
	
		surface.PushMatrix()
			render.Translate(self.Position.x, self.Position.y, 0)
			
			render.Translate(self.Size.w/2, self.Size.h/2, 0)
			render.Rotate(self.Angle, 0, 0, 1)
			render.Translate(-self.Size.w/2, -self.Size.h/2, 0)

			self:CalcMouse()

			self:OnUpdate()
			
			render.Translate(-self.Scroll.x, -self.Scroll.y, 0)

			for k,v in ipairs(self:GetChildren()) do
				if 	
					v.Position.x - self.Scroll.x < self.Size.w and 
					v.Position.y - self.Scroll.y < self.Size.h and
					v.Position.x - self.Scroll.x > -v.Size.w and 
					v.Position.y - self.Scroll.y > -v.Size.h
				then
					v:Update()
				end
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
	world:SetPosition(Vec2(0, 0))
	world:SetSize(Vec2(window.GetSize()))
	world:SetColor(Color(1,1,1,0.1))
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

	local skin = Texture("textures/aahh/DefaultSkin.png")
	
	gui2.mouse_pos = Vec2()

	event.AddListener("Draw2D", "gui2", function()

		gui2.mouse_pos.x, gui2.mouse_pos.y = surface.GetMousePos()

		world:Draw()
		world:Update()
		

		surface.SetWhiteTexture()
		surface.SetColor(1,0,0,1)
		local x, y = surface.WorldToLocal(gui2.mouse_pos.x, gui2.mouse_pos.y)
		surface.DrawRect(x, y, 1, 1)

		--surface.SetTexture(skin) 
		--surface.DrawNinePatch(50, 50, 200, 200, 128, 32, 0, 0)  
		
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

	local c = Color(1,1,1,1) * 0.25
	frame:SetColor(c)
	frame.original_color = c
	
	frame:SetCachedRendering(true)
	--frame.OnMouseExit = function() end
	--frame.OnMouseEnter = function() end

	local lol = {}
	
	for x = 1, 5 do
	for y = 1, 5 do
		math.randomseed(x*y)

		local pnl = gui2.CreatePanel(frame)

		local c = HSVToColor(math.sin(x+y), 0.65, 1)
		pnl:SetColor(c)
		pnl.original_color = c

		pnl.rand = math.random() > 0.5 and math.randomf(20, 100) or -math.randomf(20, 100)
		
		pnl:SetPosition(Vec2(x * math.random(30, 80), y * math.random(30, 80)))
		pnl:SetSize(Vec2(80,80) * math.randomf(0.25, 2))
		--pnl:SetAngle(math.random(360))
		pnl:SetCursor("icon")
		pnl:SetTexture(Texture("textures/aahh/gear.png"))

		pnl.OnMouseInput = pnl.RequestFocus
		
		table.insert(lol, pnl)
	end
	end
	
	event.AddListener("Update", "lol", function()
		for i, v in ipairs(lol) do
			v:SetAngle(os.clock()*v.rand)
		end
	end)
	
	function frame:OnMouseMove(x, y)
		if input.IsMouseDown("button_3") and not self.drag_pos then
			self.drag_pos = self:GetScroll() + Vec2(x, y)
		end
		self:MarkDirty()
	end
	
	function frame:OnUpdate()
		if self.drag_pos and input.IsMouseDown("button_3") then
			self:SetScroll(self.drag_pos - self:GetMousePosition())
			self:MarkDirty()
		else
			self.drag_pos = nil
		end
	end
	
	
	for x = 1, 4 do
	for y = 1, 4 do
		math.randomseed(x*y)

		local pnl = gui2.CreatePanel()

		local c = HSVToColor(math.sin(x+y), 0.65, 1)
		pnl:SetColor(c)
		
		pnl:SetPosition(Vec2(-5, 260) + Vec2(x, y) * 55)
		pnl:SetSize(Vec2(50, 50))
		--pnl:SetTexture(Texture("textures/aahh/button.png"))
		
		pnl.OnMouseEnter = function() end
		pnl.OnMouseExit = function() end
		
		if math.random() > 0.5 then
			if math.random() > 0.5 then
				if math.random() > 0.5 then
					pnl.OnMouseInput = function(s, key, press) 
						if not press then return end
						s:Animate("Color", {Color(0,0,0,0), "from", Color(1,1,0,1), "from"}, 0.5) 
					end
				else
					pnl.OnMouseInput = function(s, key, press) 
						if not press then return end
						s:Animate("Color", {Color(1,0,0,1), Color(0,1,0,1),  Color(0,0,1,1), "from"}, 2) 
					end
				end
			else
				pnl.OnMouseInput = function(s, key, press) 
					if not press then return end
					
					local duration = 0.2
					s:Animate("Size", {Vec2(10, 10), function() return input.IsMouseDown(key) end, Vec2(0, 0)}, duration, "-") 
					s:Animate("Position", {Vec2(10, 10) * 0.5, function() return input.IsMouseDown(key) end, Vec2(0, 0)}, duration, "+")
										
					--s:Animate("Position", Vec2(150, 150), 0.5, function(s) s:SetSize(Vec2(50,50)) end) 
				end
			end
		else
			if math.random() > 0.5 then
				pnl.OnMouseInput = function(s, key, press) 
					if not press then return end
					
					local duration = 0.2
					s:Animate("Color", {Color(0,0,0,0), "from"}, duration) 
					s:Animate("Angle", math.random() > 0.5 and 90 or -90, duration) 
				end
			else
				if math.random() > 0.5 then
					pnl.OnMouseInput = function(s, key, press) 
						if not press then return end
						
						local pow = 1
						local duration = 0.5
						
						s:Animate("Size", {Vec2(1, -1), function() return input.IsMouseDown(key) end, "from"}, duration, "*", pow) 
						s:Animate("Position", {Vec2(0, s.Size.h), function() return input.IsMouseDown(key) end, "from"}, duration, "+", pow) 
						s:Animate("Color", {Color(0,0,0,0), function() return input.IsMouseDown(key) end, "from"}, duration, "", pow) 
					end
				else
					pnl.OnMouseInput = function(s, key, press) 
						if not press then return end
						s:Animate("Angle", {math.randomf(-360, 360), "from"}, math.random()) 
					end
				end
			end
		end
	end
	end
end

gui2.Initialize()
gui2.Test()

for k,v in pairs(event.GetTable()) do for k2,v2 in pairs(v) do if type(v2.id)=='string' and v2.id:lower():find"aahh" or v2.id == "gui" then event.RemoveListener(k,v2.id) end end end