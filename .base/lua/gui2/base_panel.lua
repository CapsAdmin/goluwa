local gui2 = ... or _G.gui2

local PANEL = prototype.CreateTemplate("panel2", "base")

prototype.AddParentingTemplate(PANEL)

prototype.GetSet(PANEL, "MousePosition", Vec2(0, 0))
prototype.IsSet(PANEL, "Visible", true)
prototype.GetSet(PANEL, "Clipping", false)
prototype.GetSet(PANEL, "Color", Color(1,1,1,1))
prototype.GetSet(PANEL, "Cursor", "arrow")
prototype.GetSet(PANEL, "TrapChildren", false)
prototype.GetSet(PANEL, "Texture", render.GetWhiteTexture())
prototype.GetSet(PANEL, "RedirectFocus", NULL)
prototype.GetSet(PANEL, "Padding", Rect(0, 0, 0, 0))
prototype.GetSet(PANEL, "Margin", Rect(1, 1, 1, 1))
prototype.GetSet(PANEL, "ObeyMargin", true)
prototype.GetSet(PANEL, "BringToFrontOnClick", false)
prototype.GetSet(PANEL, "LayoutParentOnLayout", false)
prototype.GetSet(PANEL, "VisibilityPanel", NULL)
prototype.GetSet(PANEL, "NoDraw", false)

function PANEL:CreatePanel(name, store_in_self)
	return gui2.CreatePanel(name, self, store_in_self)
end

function PANEL:__tostring2()
	return ("[%s %s %s %s][%s]"):format(self.Position.x, self.Position.y, self.Size.w, self.Size.h, self.layout_count)
end

function PANEL:IsWorld()
	return self == gui2.world
end

function PANEL:BringToFront()	
	if self.RedirectFocus:IsValid() then
		return self.RedirectFocus:BringToFront()
	end

	local parent = self:GetParent()

	if parent:IsValid() then
		self:SetParent()
		parent:AddChild(self)
	end
end

function PANEL:RequestFocus()
	if self.RedirectFocus:IsValid() then
		self = self.RedirectFocus
	end

	if gui2.focus_panel:IsValid() and gui2.focus_panel ~= self then
		gui2.focus_panel:OnUnfocus()
	end
	
	self:OnFocus()
	
	gui2.focus_panel = self
end

function PANEL:Unfocus()
	if self.RedirectFocus:IsValid() then
		self = self.RedirectFocus
	end

	if gui2.focus_panel:IsValid() and gui2.focus_panel == self then
		self:OnUnfocus()
		gui2.focus_panel = NULL
	end
end

function PANEL:OnUnParent()
	gui2.unrolled_draw = nil
end

function PANEL:OnChildAdd()
	gui2.unrolled_draw = nil
end

do -- call on hide
	PANEL.call_on_hide = {}
	
	function PANEL:IsVisible()
		if self.visible == nil then return true end -- ?????
		return self.Visible
	end
	
	function PANEL:SetVisible(bool)
		self.Visible = bool
		if bool then
			self:OnShow()
		else
			self:OnHide()
			for k, v in pairs(self.call_on_hide) do
				if v() == false then
					return
				end
			end
		end
		if self:HasParent() then
			self.Parent:Layout()
		end
	end
	
	function PANEL:CallOnHide(callback, id)
		id = id or callback
		
		self.call_on_hide[id] = callback		
	end
end
	
function PANEL:OnRemove(a)
	gui2.panels[self] = nil
	
	a = (a or 0) + 1
	
	for k,v in pairs(self:GetChildrenList()) do
		v:Remove(a)
	end
		
	-- this is important!!
	self:UnParent()
end

function PANEL:GetSizeOfChildren()
	self:Layout(true)
	
	local total_size = Vec2()

	for k, v in ipairs(self:GetChildren()) do
		if v:IsVisible() then
			local pos = v:GetPosition() + v:GetSize() + v.Padding:GetPosition()
			
			if pos.x > total_size.x then
				total_size.x = pos.x
			end

			if pos.y > total_size.y then
				total_size.y = pos.y
			end
		end
	end

	return total_size
end

function PANEL:IsInsideParent()	
	local override = self.Parent
	
	if not override:IsValid() then return true end
	
	if self.VisibilityPanel:IsValid() then
		override = self.VisibilityPanel
	end
		
	if 
		self.Position.x - override.Scroll.x < override.Size.w and
		self.Position.y - override.Scroll.y < override.Size.h and
		self.Position.x + self.Size.w - override.Scroll.x > 0 and
		self.Position.y + self.Size.h - override.Scroll.y > 0
	then
		return true
	end
		
	return false
end

function PANEL:PreDraw(from_cache)
	if self.ThreeDee then surface.Start3D(self.ThreeDeePosition, self.ThreeDeeAngles, self.ThreeDeeScale) end
	
	local no_draw = self:HasParent() and self.Parent.draw_no_draw

	surface.PushMatrix()
	surface.Translate(self.Position.x, self.Position.y, 0)

	local w = (self.Size.w)/2
	local h = (self.Size.h)/2

	render.Translate(w, h, 0)
	render.Rotate(self.Angle, 0, 0, 1)
	render.Translate(-w, -h, 0)

	if not from_cache then
		self:CalcMouse()
	
		self:CalcDragging()
		self:CalcScrolling()
	end

	self:CalcAnimations()
	
	if self.layout_me then 
		self:Layout(true) 
	end
	
	if self.CachedRendering then
		self:DrawCache()
		no_draw = true
	end

	self:OnUpdate()
		
	if from_cache or not no_draw then
		if self:IsDragging() or self:IsWorld() or self:IsInsideParent() then
			self:OnPreDraw()
			self:OnDraw()
			self:OnPostDraw()
			self.visible = true
			no_draw = false
		else
			self.visible = false
			no_draw = true
		end
	end
	
	if --[[true or]] not no_draw and self.Clipping then
		--surface.PushClipFunction(self.DrawClippingStencil, self)
		surface.EnableClipRect(0,0,self.Size.w + self.DrawSizeOffset.w, self.Size.h + self.DrawSizeOffset.h)
	end
	
	surface.Translate(-self.Scroll.x, -self.Scroll.y, 0)
	
	if from_cache then
		self.draw_no_draw = false
	else
		self.draw_no_draw = no_draw
	end
end

function PANEL:DrawClippingStencil()
	--if not self.Clipping then return end
	local tex = surface.GetTexture()
	surface.SetWhiteTexture()
	--surface.SetTexture(self.Texture)
	local r,g,b,a = surface.SetColor(1,1,1,0.1)
	self:DrawRect()
	surface.SetColor(r,g,b,a)
	surface.SetTexture(tex)
end

function PANEL:Draw(from_cache)
	if not self.Visible then return end
	self:PreDraw(from_cache)
		for k,v in ipairs(self:GetChildren()) do
			v:Draw(from_cache)
		end
	self:PostDraw(from_cache)
end

local gl = require("lj-opengl")
			
function PANEL:PostDraw(from_cache)
	self:CalcResizing()

	if --[[true or]] not self.draw_no_draw and self.Clipping then
		--surface.PopClipFunction()
		surface.DisableClipRect()
		--render.PopViewport()
	end
	
	if self.layout_me == "init" then 
		self.layout_me = false 
	end
	
	if gui2.debug then
		if self.Clipping then	
			gl.Disable(gl.e.GL_STENCIL_TEST)
			render.SetBlendMode("additive")
			surface.SetColor(1, 0, 1, 0.25)
			surface.SetWhiteTexture()
			surface.DrawRect(0, 0, self.Size.w, self.Size.h)
			render.SetBlendMode("alpha")
			gl.Enable(gl.e.GL_STENCIL_TEST)
		end
		if self.updated_layout then
			render.SetBlendMode("additive")
			surface.SetColor(1, 0, 0, 0.1)
			surface.SetWhiteTexture(self.cache_texture)
			surface.DrawRect(0, 0, self.Size.w, self.Size.h)
			self.updated_layout = false
			render.SetBlendMode("alpha")
		else
			if self.updated_cache then
				surface.SetColor(0, 1, 0, 0.1)
				surface.SetWhiteTexture(self.cache_texture)
				surface.DrawRect(0, 0, self.Size.w, self.Size.h)
				self.updated_cache = false
			end
		end
	end
	
	surface.PopMatrix()
	
	if self.ThreeDee then surface.End3D() end
end

do -- orientation
	prototype.GetSet(PANEL, "Position", Vec2(0, 0))
	prototype.GetSet(PANEL, "Size", Vec2(50, 50))
	prototype.GetSet(PANEL, "MinimumSize", Vec2(4, 4))
	prototype.GetSet(PANEL, "Angle", 0)
	prototype.GetSet(PANEL, "Order", 0)
	
	prototype.GetSet(PANEL, "ThreeDee", false)
	prototype.GetSet(PANEL, "ThreeDeePosition", Vec3(0,0,0))
	prototype.GetSet(PANEL, "ThreeDeeAngles", Ang3(0,0,0))
	prototype.GetSet(PANEL, "ThreeDeeScale", Vec3(1,1,1))
	
	function PANEL:SetPosition(pos)
		if self:HasParent() and self.Parent.TrapChildren and not self.ThreeDee then
			pos:Clamp(Vec2(0, 0), self.Parent.Size - self.Size)
		end
		
		self:OnPositionChanged(pos)

		self.Position = pos
	end

	function PANEL:SetSize(size)
		if self.StyleSize:IsZero() then
			size.x = math.max(size.x, self.MinimumSize.w)
			size.y = math.max(size.y, self.MinimumSize.h)

			self.Size = size
			
			self:Layout()
		end
	end

	function PANEL:GetWorldPosition()
		return self:LocalToWorld(self:GetPosition())
	end

	function PANEL:SetWorldPosition(wpos)
		self:SetPosition(self:WorldToLocal(wpos))
	end

	function PANEL:WorldToLocal(wpos)
		local lpos = wpos
		for k, v in ipairs(self:GetParentList()) do
			lpos = lpos - v:GetPosition()
			if v:HasParent() then
				wpos = wpos + v.Parent:GetScroll()
			end
		end
		return lpos
	end

	function PANEL:LocalToWorld(lpos)
		local wpos = lpos
		for k, v in npairs(self:GetParentList()) do
			wpos = wpos + v:GetPosition()
			if v:HasParent() then
				wpos = wpos - v.Parent:GetScroll()
			end
		end
		return wpos
	end

	local sorter = function(a,b)
		return a.Order > b.Order
	end

	function PANEL:SetOrder(pos)
		self.Order = pos

		local parent = self:GetParent()

		if parent:IsValid() then
			table.sort(parent:GetChildren(), sorter)
			gui2.unrolled_draw = nil
		end
	end
	
	function PANEL:SetX(x)
		self.Position.x = x
	end
	function PANEL:GetX()
		return self.Position.x
	end
	
	function PANEL:SetY(y)
		self.Position.y = y
	end
	function PANEL:GetY()
		return self.Position.y
	end

	function PANEL:SetWidth(w)
		self.Size.w = w
		self:Layout()
	end
	function PANEL:GetWidth()
		return self.Size.w
	end

	function PANEL:SetHeight(h)
		self.Size.h = h
		self:Layout()
	end
	function PANEL:GetHeight()
		return self.Size.h
	end
	
	PANEL.SetW = PANEL.SetWidth
	PANEL.GetW = PANEL.GetWidth
	
	PANEL.SetH = PANEL.SetHeight
	PANEL.GetH = PANEL.GetHeight
	
	function PANEL:SetRect(rect)
		self:SetPosition(Vec2(rect.x, rect.y))
		self:SetSize(Vec2(rect.w, rect.h))
	end
	
	function PANEL:GetRect()
		return Rect(self.Position.x, self.Position.y, self.Size.w, self.Size.h)
	end
	
	function PANEL:GetWorldRect(pad)
		local rect = self:GetRect()
		
		-- convert to world
		rect.w = rect.x + rect.w
		rect.h = rect.y + rect.h
		
		-- add padding
		if pad then
			rect.left = rect.left - self.Padding.left
			rect.top = rect.top - self.Padding.top
			rect.right = rect.right + self.Padding.right
			rect.bottom = rect.bottom + self.Padding.bottom
		end
		
		return rect
	end
end

do -- cached rendering
	prototype.GetSet(PANEL, "CachedRendering", false)

	function PANEL:SetCachedRendering(b)
		self.CachedRendering = b

		self:MarkCacheDirty()
	end

	function PANEL:MarkCacheDirty()
		if self.CachedRendering then
			self.cache_dirty = true

			if not self.cache_fb or self.cache_texture:GetSize() ~= self.Size then
				self.cache_fb = render.CreateFrameBuffer(self.Size.w, self.Size.h, {
					{
						name = "color",
						attach = "color1",

						texture_format = {
							internal_format = "RGBA8",
						},
					},
					{
						name = "stencil",
						attach = "stencil",
					}
				})
				self.cache_texture = self.cache_fb:GetTexture("color")
			end
		else
			for k,v in ipairs(self:GetParentList()) do
				if v:IsValid() and v.CachedRendering then
					v:MarkCacheDirty()
				end
			end
		end
	end

	function PANEL:IsCacheDirty()
		return self.cache_dirty
	end

	function PANEL:DrawCache()
		if self:IsCacheDirty() then
			self.cache_fb:Begin()
			self.cache_fb:Clear()

			surface.PushMatrix()
				-- this matrix needs to be reset so it will draw
				-- from the origin of the framebuffer
				-- the framebuffer itself is drawn at the correct position
				surface.LoadIdentity()

				if self:IsDragging() or self:IsInsideParent() then
					self:OnPreDraw()
					self:OnDraw()
					self:OnPostDraw()
				end

				surface.Translate(-self.Scroll.x, -self.Scroll.y)

				for k,v in ipairs(self:GetChildren()) do
					if v.Visible then
						v:Draw(true)
					end
				end

				self.cache_dirty = false
			surface.PopMatrix()
			self.cache_fb:End()
			
			self.updated_cache = true
		end
		
		surface.SetColor(1, 1, 1, 1)
		surface.SetTexture(self.cache_texture)
		surface.DrawRect(0, 0, self.Size.w, self.Size.h)
	end
end
	
do -- scrolling		
	prototype.GetSet(PANEL, "Scrollable", false)
	prototype.GetSet(PANEL, "Scroll", Vec2(0, 0))
	prototype.GetSet(PANEL, "ScrollFraction", Vec2(0, 0))

	function PANEL:SetScroll(vec)
		local size = self:GetSizeOfChildren()
		
		self.Scroll = vec:GetClamped(Vec2(0), size - self.Size)
		self.ScrollFraction = self.Scroll / (size + self.Scroll - self.Size) * 2
		
		self:OnScroll(self.ScrollFraction)
		
		self:MarkCacheDirty()
	end
	
	function PANEL:SetScrollFraction(frac)
		local size = self:GetSizeOfChildren()

		self.Scroll = frac * size
		self.Scroll:Clamp(Vec2(0, 0), size - self.Size)
		self.ScrollFraction = frac
		
		self:OnScroll(self.ScrollFraction)
		
		self:MarkCacheDirty()
	end
	
	function PANEL:StartScrolling(button)
		self.scroll_button = button
		self.scroll_drag_pos = self:GetScroll() + self:GetMousePosition()
	end
	
	function PANEL:StopScrolling()
		self.scroll_button = nil
		self.scroll_drag_pos = nil
	end
	
	function PANEL:IsScrolling()
		return self.scroll_button ~= nil
	end
	
	function PANEL:CalcScrolling()
		if not self:IsScrolling() then return end
		
		if input.IsMouseDown(self.scroll_button) then
			self:SetScroll(self.scroll_drag_pos - self:GetMousePosition())
			self:OnScroll(self.ScrollFraction)
		else
			self:StopScrolling()
		end
	end
end

do -- drag drop
	prototype.GetSet(PANEL, "Draggable", false)
	prototype.GetSet(PANEL, "DragDrop", false)

	function PANEL:StartDragging(button)
		self.drag_world_pos = gui2.mouse_pos:Copy()
		self.drag_stop_button = button
	end

	function PANEL:StopDragging()
		self.drag_world_pos = nil
		self.drag_panel_start_pos = nil
		self.drag_last_hover = nil
	end

	function PANEL:IsDragging()
		return self.drag_world_pos ~= nil
	end

	function PANEL:CalcDragging()
		if self.drag_world_pos then
			if not self.drag_panel_start_pos then
				self.drag_panel_start_pos = self:GetPosition()
			end

			local drag_pos = Vec2(surface.WorldToLocal(self.drag_world_pos:Unpack()))

			self:SetPosition(self.drag_panel_start_pos + self:GetMousePosition() - drag_pos)

			local panel = gui2.GetHoveringPanel(nil, self)

			local drop_pos = panel:GetMousePosition() - self:GetMousePosition() + panel.Scroll

			if self.drag_last_hover ~= panel then

				if self.drag_last_hover then
					self.drag_last_hover:OnDraggedChildExit(self, drop_pos)
				end

				panel:OnDraggedChildEnter(self, drop_pos)

				self.drag_last_hover = panel
			end

			if self.SnapWhileDragging then
				self:SnapToClosestPanel()
			end

			panel:OnPanelHover(self, drop_pos)

			if not input.IsMouseDown(self.drag_stop_button) then

				self:OnParentLand(panel)
				panel:OnChildDrop(self, drop_pos)

				self:StopDragging()
			end
		end
	end

	function PANEL:OnDraggedChildEnter(child, drop_pos)
		--print("enter", self, drop_pos, child)
	end

	function PANEL:OnDraggedChildExit(child, drop_pos)
		--print("left", self, drop_pos, child)
	end

	function PANEL:OnParentLand(parent)

	end
	
	function PANEL:OnPanelHover(panel, drop_pos)

	end

	function PANEL:OnChildDrop(child, pos)
	
	end
end

do -- magnet snap
	prototype.GetSet(PANEL, "SnapWhileDragging", false)

	local snapped = false

	local function check1(pos, size, parent, pos2, axis1, axis2)
		if
			pos[axis1] < pos2[axis1] + (parent.Padding[axis1] * 1.5) and
			pos[axis1] > pos2[axis1] + (parent.Padding[axis1] / 4)
		then
			pos[axis1] = pos2[axis1] + parent.Padding[axis1]
			snapped = true
		elseif
			pos[axis1] < pos2[axis1] + parent.Padding[axis1] and
			pos[axis1] > pos2[axis1] + -parent.Padding[axis1]
		then
			pos[axis1] = pos2[axis1]
			snapped = true
		elseif pos[axis1] + size[axis2] < pos2[axis1] then
			if
				pos[axis1] + size[axis2] < pos2[axis1] + parent.Margin[axis1] and
				pos[axis1] + size[axis2] > pos2[axis1] + -parent.Margin[axis1]
			then
				pos[axis1] = pos2[axis1] + -size[axis2]
				snapped = true
			elseif
				pos[axis1] + size[axis2] > pos2[axis1] + (-parent.Margin[axis1] * 1.5) and
				pos[axis1] + size[axis2] < pos2[axis1] + (parent.Margin[axis1] / 4)
			then
				pos[axis1] = pos2[axis1] + -size[axis2] - parent.Margin[axis1]
				snapped = true
			end
		end
	end

	local function check2(pos, size, parent, pos2, axis1, axis2)
		if
			pos[axis1] + size[axis2] > pos2[axis1] + parent.Size[axis2] - (parent.Padding[axis1] * 1.5) and
			pos[axis1] + size[axis2] < pos2[axis1] + parent.Size[axis2] - (parent.Padding[axis1] / 4)
		then
			pos[axis1] = pos2[axis1] + parent.Size[axis2] - parent.Padding[axis1] - size[axis2]
			snapped = true
		elseif
			pos[axis1] + size[axis2] > pos2[axis1] + parent.Size[axis2] - parent.Padding[axis1] and
			pos[axis1] + size[axis2] < pos2[axis1] + parent.Size[axis2] + parent.Padding[axis1]
		then
			pos[axis1] = pos2[axis1] + parent.Size[axis2] - size[axis2]
			snapped = true
		elseif pos[axis1] > pos2[axis1] + parent.Size[axis2] then
			if
				pos[axis1] < pos2[axis1] + parent.Size[axis2] + parent.Margin[axis1] and
				pos[axis1] > pos2[axis1] + parent.Size[axis2] - parent.Margin[axis1]
			then
				pos[axis1] = pos2[axis1] + parent.Size[axis2]
				snapped = true
			elseif
				pos[axis1] < pos2[axis1] + parent.Size[axis2] + (parent.Margin[axis1] * 1.5) and
				pos[axis1] > pos2[axis1] + parent.Size[axis2] + (parent.Margin[axis1] / 4)
			then
				pos[axis1] = pos2[axis1] + parent.Size[axis2] + parent.Margin[axis1]
				snapped = true
			end
		end
	end

	function PANEL:SnapPosition(panel)
		panel = panel or self:GetParent()

		local pos = self:GetWorldPosition():Copy()
		local pos2 = panel:GetWorldPosition()
		local size = self:GetSize()

		snapped = false

		check1(pos, size, panel, pos2, "x", "w")
		check1(pos, size, panel, pos2, "y", "h")

		check2(pos, size, panel, pos2, "x", "w")
		check2(pos, size, panel, pos2, "y", "h")

		if snapped then
			pos = self:WorldToLocal(pos)
			self:SetPosition(pos)
		end

		return snapped
	end

	function PANEL:SnapToClosestPanel()
		local tbl = {}

		for k,v in pairs(self:GetParent():GetChildren()) do tbl[k] = v end

		local wpos = self:GetWorldPosition()

		table.sort(tbl, function(a, b) return a:GetWorldPosition():Distance(wpos) < b:GetWorldPosition():Distance(wpos) end)

		for i, v in ipairs(tbl) do
			if v:IsVisible() and v ~= self then
				self:SnapPosition(v)
			end
		end
		self:SnapPosition(self:GetParent())
	end
end

do -- animations
	-- these are useful for animations
	prototype.GetSet(PANEL, "DrawSizeOffset", Vec2(0, 0))
	prototype.GetSet(PANEL, "DrawScaleOffset", Vec2(1, 1))
	prototype.GetSet(PANEL, "DrawPositionOffset", Vec2(0, 0))
	prototype.GetSet(PANEL, "DrawAngleOffset", Ang3(0,0,0))
	prototype.GetSet(PANEL, "DrawColor", Color(0,0,0,0))
	
	PANEL.animations = {}

	local function lerp_values(values, alpha)
		local tbl = {}

		for i = 1, #values - 1 do
			if type(values[i] ) == "number" then
				tbl[i] = math.lerp(alpha, values[i], values[i + 1])
			else
				tbl[i] = values[i]:GetLerped(alpha, values[i + 1])
			end
		end

		if #tbl > 1 then
			return lerp_values(tbl, alpha)
		else
			return tbl[1]
		end
	end

	function PANEL:CalcAnimations()
		if not self.DrawPositionOffset:IsZero() then
			render.Translate(self.DrawPositionOffset.x, self.DrawPositionOffset.y, 0)
		end
		
		if not self.DrawScaleOffset:IsZero() then
			render.Scale(self.DrawScaleOffset.x, self.DrawScaleOffset.y, 1)
		end
		
		if not self.DrawSizeOffset:IsZero() or not self.DrawAngleOffset:IsZero() then
			local w = (self.Size.w + self.DrawSizeOffset.w)/2
			local h = (self.Size.h + self.DrawSizeOffset.h)/2

			render.Translate(w, h, 0)
			render.Rotate(self.DrawAngleOffset.p, 0, 0, 1)
			render.Rotate(self.DrawAngleOffset.y, 0, 1, 0)
			render.Rotate(self.DrawAngleOffset.r, 1, 0, 0)
			render.Translate(-w, -h, 0)
		end
				
		for key, animation in pairs(self.animations) do

			local pause = false

			for i, v in ipairs(animation.pausers) do
				if animation.alpha >= v.alpha then
					if v.check() then
						pause = true
					else
						table.remove(animation.pausers, i)
						break
					end
				end
			end

			if not pause then

				animation.alpha = animation.alpha + system.GetFrameTime() / animation.time
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
				
				if alpha >= 1 then
					if animation.callback then
						if animation.callback(self) ~= false then
							animation.func(self, from)
						end
					else
						animation.func(self, from)
					end

					self.animations[key] = nil
				else
					if self:HasParent() then self.Parent:CalcLayoutChain() end
					self:MarkCacheDirty()
				end
			end
		end
	end

	function PANEL:StopAnimations()
		for key, animation in pairs(self.animations) do
			if animation.callback then
				if animation.callback(self) ~= false then
					animation.func(self, animation.from)
				end
			else
				animation.func(self, animation.from)
			end

			self.animations[key] = nil
		end
		self:UpdateAnimations()
	end

	function PANEL:Animate(var, to, time, operator, pow, set, callback)
		if self.animations[var] then
			self.animations[var].alpha = 0
			return
		end

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
		
		if not set then
			table.insert(to, 1, from)
		end

		self.animations[var] = {
			operator = operator,
			from = from,
			to = to,
			time = time or 0.25,
			var = var,
			func = self["Set" .. var],
			start_time = system.GetTime(),
			pow = pow,
			callback = callback,
			pausers =  pausers,
			alpha = 0,
		}
	end
end

do -- docking
	do -- center
		function PANEL:CenterX()
			self:SetX((self.Parent:GetWidth() * 0.5) - (self:GetWidth() * 0.5))
		end

		function PANEL:CenterY()
			self:SetY((self.Parent:GetHeight() * 0.5) - (self:GetHeight() * 0.5))
		end

		function PANEL:Center()
			self:CenterY()
			self:CenterX()
		end
	end

	function PANEL:Align(vec, off, parent)
		off = off or Vec2()
		parent = parent or self:GetParent()

		local margin = parent:GetMargin()
		local padding = self:GetPadding()
		
		if not self.ObeyMargin then
			margin = Rect()
		end
		
		local size = self:GetSize() + margin:GetPosSize() + padding:GetPosSize()
		local centerparent = parent:GetSize() * vec
		local centerself = size * vec
		local pos = centerparent - centerself

		if vec.x == -1 and vec.y == -1 then
			return
		elseif vec.x == -1 then
			self.Position.y = pos.y + off.y + margin.y + padding.y
		elseif vec.y == -1 then
			self.Position.x = pos.x + off.x + margin.x + padding.x
		else
			self:SetPosition(pos + off + margin:GetPosition() + padding:GetPosition())
		end

	end

	function PANEL:Undock()
		self:Dock()
	end

	function PANEL:Dock(location)
		if not location then
			self.dock_location = nil
		else
			self.dock_location = location
		end

		self.Parent:Layout()
	end

	function PANEL:DockLayout()	
		local left, right, top, bottom, center

		-- grab one of each dock type
		for _, pnl in ipairs(self:GetChildren()) do
			if pnl.dock_location then
				if pnl.dock_location == "fill" then
					local margin = self:GetMargin()
				
					if not pnl.ObeyMargin then margin = Rect() end
					
					local x = margin.x
					local y = margin.y
					local w = self:GetWidth() - x - margin.w
					local h = self:GetHeight() - y - margin.h

					local area = Rect(x, y, w, h)	
					
					pnl:SetPosition(area:GetPosition())
					pnl:SetSize(area:GetSize())

					if pnl.SizeToContens then
						pnl:SizeToContents()
					end
				else
					if pnl.dock_location == "center" then
						pnl:Center()
					elseif pnl.dock_location == "center_x" then
						pnl:CenterX()
					elseif pnl.dock_location == "center_y" then
						pnl:CenterY()
					elseif pnl.dock_location == "top" then
						pnl:Align(Vec2(0.5, 0))
					elseif pnl.dock_location == "bottom" then
						pnl:Align(Vec2(0.5, 1))
					elseif pnl.dock_location == "left" then
						pnl:Align(Vec2(0, 0.5))
					elseif pnl.dock_location == "right" then
						pnl:Align(Vec2(1, 0.5))
					elseif pnl.dock_location == "top_left" then
						pnl:Align(Vec2(0, 0))
					elseif pnl.dock_location == "top_right" then
						pnl:Align(Vec2(1, 0))
					elseif pnl.dock_location == "bottom_left" then
						pnl:Align(Vec2(0, 1))
					elseif pnl.dock_location == "bottom_right" then
						pnl:Align(Vec2(1, 1))
					else
						if not left and pnl.dock_location == "fill_left" then
							left = pnl
						end
						if not right and pnl.dock_location == "fill_right" then
							right = pnl
						end
						if not top and pnl.dock_location == "fill_top" then
							top = pnl
						end
						if not bottom and pnl.dock_location == "fill_bottom" then
							bottom = pnl
						end
					end
				end
			end
		end
				
		if top then				
			local margin = self:GetMargin()
			
			if not top.ObeyMargin then margin = Rect() end
			
			local x = margin.x
			local y = margin.y
			local w = self:GetWidth() - x - margin.w
			local h = self:GetHeight() - y - margin.h

			local area = Rect(x, y, w, h)	
			local pad = top:GetPadding()

			top:SetPosition(area:GetPosition() + pad:GetPosition())
			top:SetWidth(area.w - pad:GetXW())
			area.y = area.y + top:GetHeight() + pad:GetYH()
			area.h = area.h - top:GetHeight() - pad:GetYH()
		end

		if bottom then
			local margin = self:GetMargin()
			
			if not bottom.ObeyMargin then margin = Rect() end
			
			local x = margin.x
			local y = margin.y
			local w = self:GetWidth() - x - margin.w
			local h = self:GetHeight() - y - margin.h

			local area = Rect(x, y, w, h)	
			local pad = bottom:GetMargin()

			bottom:SetPosition(area:GetPosition() + Vec2(pad.x, area.h - bottom:GetHeight() - pad.h))
			bottom:SetWidth(w - pad:GetXW())
			area.h = area.h - bottom:GetHeight() - pad:GetYH()
		end

		if left then
			local margin = self:GetMargin()
			
			if not left.ObeyMargin then margin = Rect() end
			
			local x = margin.x
			local y = margin.y
			local w = self:GetWidth() - x - margin.w
			local h = self:GetHeight() - y - margin.h

			local area = Rect(x, y, w, h)	
			local pad = left:GetMargin()

			left:SetPosition(area:GetPosition() + pad:GetPosition())
			left:SetHeight(area.h - pad:GetYH())
			area.x = area.x + left:GetWidth() + pad:GetXW()
			area.w = area.w - left:GetWidth() - pad:GetXW()
		end

		if right then
			local margin = self:GetMargin()
			
			if not right.ObeyMargin then margin = Rect() end
			
			local x = margin.x
			local y = margin.y
			local w = self:GetWidth() - x - margin.w
			local h = self:GetHeight() - y - margin.h

			local area = Rect(x, y, w, h)	
			local pad = right:GetMargin()

			right:SetPosition(area:GetPosition() + Vec2(area.w - right:GetWidth() - pad.w, pad.y))
			right:SetHeight(area.h - pad:GetYH())
			area.w = area.w - right:GetWidth() - pad:GetXW()
		end			
	end
	
	prototype.GetSet(PANEL, "ResizePadding", Rect(4,4,4,4))

	function PANEL:GetDockLocation(pos) -- rename this function
		pos = pos or self:GetMousePosition()
		local offset = self.ResizePadding

		local siz = self:GetSize()

		if
			(pos.y > 0 and pos.y < offset.h) and -- top
			(pos.x > 0 and pos.x < offset.w) -- left
		then
			return "top_left"
		end

		if
			(pos.y > 0 and pos.y < offset.h) and -- top
			(pos.x > siz.w - offset.w and pos.x < siz.w) -- right
		then
			return "top_right"
		end


		if
			(pos.y > siz.h - offset.h and pos.y < siz.h) and -- bottom
			(pos.x > 0 and pos.x < offset.w) -- left
		then
			return "bottom_left"
		end

		if
			(pos.y > siz.h - offset.h and pos.y < siz.h) and -- bottom
			(pos.x > siz.w - offset.w and pos.x < siz.w) --right
		then
			return "bottom_right"
		end

		--

		if pos.x > 0 and pos.x < offset.w then
			return "left"
		end

		if pos.x > siz.w - offset.w and pos.x < siz.w then
			return "right"
		end

		if pos.y > siz.h - offset.h and pos.y < siz.h then
			return "bottom"
		end

		if pos.y > 0 and pos.y < offset.h then
			return "top"
		end

		return "center"
	end
end

do -- resizing
	prototype.GetSet(PANEL, "Resizable", false)

	function PANEL:GetResizeLocation(pos)
		pos = pos or self:GetMousePosition()
		local loc = self:GetDockLocation(pos)

		if loc ~= "center" then
			return loc
		end
	end

	function PANEL:StartResizing(pos, button)
		local loc = self:GetResizeLocation(pos)
		if loc then
			self.resize_start_pos = self:GetMousePosition():Copy()
			self.resize_location = loc
			self.resize_prev_mouse_pos = gui2.mouse_pos:Copy()
			self.resize_prev_pos = self:GetPosition():Copy()
			self.resize_prev_size = self:GetSize():Copy()
			self.resize_button = button
			return true
		end
	end

	function PANEL:StopResizing()
		self.resize_start_pos = nil
	end

	function PANEL:IsResizing()
		return self.resize_start_pos ~= nil
	end
	
	local location2cursor = {
		right = "sizewe",
		left = "sizewe",
		top = "sizens",
		bottom = "sizens",
		top_right = "sizenesw",
		bottom_left = "sizenesw",
		top_left = "sizenwse",
		bottom_right = "sizenwse",
	}

	function PANEL:CalcResizing()
		if self.Resizable then
			local loc = self:GetResizeLocation(self:GetMousePosition())
			if location2cursor[loc] then
				system.SetCursor(location2cursor[loc])
			else
				gui2.active_cursor = nil
			end
		end
	
		if self.resize_start_pos then

			if self.resize_button ~= nil and not input.IsMouseDown(self.resize_button) then
				self:StopResizing()
				return
			end

			local diff = self:GetMousePosition() - self.resize_start_pos
			local diff_world = gui2.mouse_pos - self.resize_prev_mouse_pos
			local loc = self.resize_location
			local prev_size = self.resize_prev_size:Copy()
			local prev_pos = self.resize_prev_pos:Copy()

			if loc == "right" or loc == "top_right" then
				prev_size.w = prev_size.w + diff.x
			elseif loc == "bottom" or loc == "bottom_left" then
				prev_size.h = prev_size.h + diff.y
			elseif loc == "bottom_right" then
				prev_size = prev_size + diff
			end

			if loc == "top" or loc == "top_right" then
				prev_pos.y = prev_pos.y + math.min(diff_world.y, prev_size.h - self.MinimumSize.h)
				prev_size.h = prev_size.h - diff_world.y
			elseif loc == "left" or loc == "bottom_left" then
				prev_pos.x = prev_pos.x + math.min(diff_world.x, prev_size.w - self.MinimumSize.w)
				prev_size.w = prev_size.w - diff_world.x
			elseif loc == "top_left" then
				prev_pos = prev_pos + diff_world
				prev_size = prev_size - diff_world
			end

			if self:HasParent() and not self.ThreeDee then
				prev_pos.x = math.max(prev_pos.x, 0)
				prev_pos.y = math.max(prev_pos.y, 0)

				prev_size.w = math.min(prev_size.w, self.Parent.Size.w - prev_pos.x)
				prev_size.h = math.min(prev_size.h, self.Parent.Size.h - prev_pos.y)
			end

			self:SetPosition(prev_pos)
			self:SetSize(prev_size)
		end
	end
end

do -- mouse
	prototype.GetSet(PANEL, "IgnoreMouse", false)
	prototype.GetSet(PANEL, "FocusOnClick", false)
	prototype.GetSet(PANEL, "AlwaysCalcMouse", false)
	prototype.GetSet(PANEL, "AlwaysReceiveMouseInput", false)
	prototype.GetSet(PANEL, "SendMouseInputToPanel", NULL)
	
	prototype.GetSet(PANEL, "MouseHoverTime", 0)
	prototype.GetSet(PANEL, "MouseHoverTimeTrigger", 1)

	function PANEL:IsMouseOver()
		return self:IsDragging() or self:IsResizing() or self.mouse_over and gui2.hovering_panel == self
	end

	function PANEL:CalcMouse()
		if 
			self:HasParent() and 
			not self.Parent:IsWorld() and 
			not self.Parent.mouse_over and 
			not self:IsDragging() and 
			not self.AlwaysCalcMouse and 
			not self.IgnoreMouse 
		then 
	
			if self.mouse_just_entered then
				self:OnMouseExit()
				self.mouse_just_entered = false
			end
	
			return 
		end
		
		local x, y = surface.WorldToLocal(gui2.mouse_pos.x, gui2.mouse_pos.y)

		self.MousePosition.x = x
		self.MousePosition.y = y

		local alpha = 1

		if not self.NinePatch and self.NinePatchRect:IsZero() and self.Texture:IsValid() and self.Texture ~= render.GetWhiteTexture() and not self.Texture:IsLoading() then
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
			
			x = x * self.Texture.w
			y = y * self.Texture.h
			
			x = math.clamp(math.floor(x), 1, self.Texture.w-1)		
			y = math.clamp(math.floor(y), 1, self.Texture.h-1)		
			
			local i = (y * self.Texture.w + x) * self.Texture.format.stride
			
			alpha = self.Texture.buffer_cache[i + 3] / 255

			--alpha = self.Texture:GetPixelColor(, self.Texture.buffer_cache).a
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
				if self.SendMouseInputToPanel:IsValid() then
					if not self.SendMouseInputToPanel.mouse_just_entered then
						self.SendMouseInputToPanel:OnMouseEnter(x, y)
						self.SendMouseInputToPanel.mouse_just_entered = true
					end
				end
				self:OnMouseEnter(x, y)
				self.mouse_just_entered = true
				self.mouse_hover_triggered = false
				self.MouseHoverTime = os.clock()
			end

			if self.MouseHoverTime + self.MouseHoverTimeTrigger < os.clock() then
				if not self.mouse_hover_triggered then
					self:OnMouseHoverTrigger(true, x, y)
					self.mouse_hover_triggered = true
				end
			end
			
			self:OnMouseMove(x, y)
		else
			if self.mouse_just_entered then
				if self.SendMouseInputToPanel:IsValid() then					
					if self.SendMouseInputToPanel.mouse_just_entered then
						self.SendMouseInputToPanel:OnMouseExit(x, y)
						self.SendMouseInputToPanel.mouse_just_entered = false
					end
				end
				self:OnMouseExit(x, y)
				self.mouse_just_entered = false
			end
			
			if self.mouse_hover_triggered then
				self:OnMouseHoverTrigger(false, x, y)
				self.mouse_hover_triggered = false
			end
		end
	end
	
	function PANEL:MouseInput(button, press)		
		if self.SendMouseInputToPanel:IsValid() then
			self.SendMouseInputToPanel:MouseInput(button, press)
		end
		
		event.Call("PanelMouseInput", self, button, press)
		
		if press then
			
			if self.FocusOnClick then
				self:RequestFocus()
			end
			
			if self.BringToFrontOnClick then 
				self:BringToFront()
			end

			if button == "button_1" then
				if not self.Resizable or not self:StartResizing(nil, button) then
					if self.Draggable then
						self:StartDragging(button)
					end
				end
			end
			
			if button == "button_2" then
				self:OnRightClick()
			end
			
			if self.Scrollable then
				if button == "button_3" then
					self:StartScrolling(button)
				end
				
				if button == "mwheel_down" then
					self:SetScroll(self:GetScroll() + Vec2(0, 20))
				elseif button == "mwheel_up" then
					self:SetScroll(self:GetScroll() + Vec2(0, -20))
				end
			end
		end

		self:OnMouseInput(button, press)
		
		self:MarkCacheDirty()
	end
	
	function PANEL:KeyInput(button, press)
		local b
		
		if self:OnPreKeyInput(button, press) ~= false then
			b = self:OnKeyInput(button, press)
			self:OnPostKeyInput(button, press)
		end
		
		self:MarkCacheDirty()
		
		return b
	end	
	
	function PANEL:CharInput(char)			
		self:MarkCacheDirty()
		return self:OnCharInput(char)
	end
end

do -- layout
	PANEL.layout_count = 0
	
	prototype.GetSet(PANEL, "StretchToPanelWidth", NULL)
	prototype.GetSet(PANEL, "StretchToPanelHeight", NULL)
	
	function PANEL:Layout(now)
		if now then			
			if self.in_layout then return end
			self.in_layout = true
				
				for i, v in ipairs(self:GetChildren()) do
					v:Layout()
				end
				
				self.layout_count = (self.layout_count or 0) + 1
				
				self:DockLayout()			
	
				if self.StretchToPanelWidth:IsValid() then
					self:SetWidth(self.StretchToPanelWidth:GetWidth())
				end
				
				if self.StretchToPanelHeight:IsValid() then
					self:SetHeight(self.StretchToPanelHeight:GetHeight())
				end
				
				self:OnLayout(self:GetPosition(), self:GetSize())
				self:CalcLayoutChain()
									
				if self.LayoutParentOnLayout and self:HasParent() then
					self.Parent:Layout(now)
				end
				
				self:StackChildren()
				
				if self.layout_me ~= "init" then
					self.layout_me = false
				end
				
				self:MarkCacheDirty()
				
				self.updated_layout = true
				
			self.in_layout = false
		else
			self.layout_me = true
		end
	end
end

do -- layout chain
	prototype.GetSet(PANEL, "LayoutSize", nil)

	local function ray_cast(self, where, panel, collide, asdf)
		local pos = where:GetPosition()
		local dir = (where:GetPosition() - panel:GetPosition()):Normalize()
		local found
		
		if collide then
			found = {}
			local panel_rect = panel:GetWorldRect()
			
			for i, child in ipairs(self:GetChildren()) do
				if child ~= panel and child.laid_out and child.Visible then
					local child_rect = child:GetWorldRect()
					
					if 
						child_rect.left <= panel_rect.left and 
						child_rect.right >= panel_rect.right
						or
						child_rect.left >= panel_rect.left and 
						child_rect.right <= panel_rect.right
						or 
						child_rect.right > panel_rect.right and
						child_rect.left < panel_rect.right
						or 
						child_rect.right > panel_rect.left and
						child_rect.left < panel_rect.left
					then					
						if dir.y == 1 and child_rect.top > panel_rect.top then
							table.insert(found, {child = child, point = child_rect.top})
						elseif dir.y == -1 and child_rect.bottom < panel_rect.bottom then
							table.insert(found, {child = child, point = child_rect.bottom})
						end
					end	
					
					if
						child_rect.top <= panel_rect.top and 
						child_rect.bottom >= panel_rect.bottom 
						or
						child_rect.top >= panel_rect.top and 
						child_rect.bottom <= panel_rect.bottom
						or 
						child_rect.bottom > panel_rect.bottom and
						child_rect.top < panel_rect.bottom
						or 
						child_rect.bottom > panel_rect.top and
						child_rect.top < panel_rect.top
					then					
						if dir.x == 1 and child_rect.right > panel_rect.right then
							table.insert(found, {child = child, point = child_rect.left})
						elseif dir.x == -1 and child_rect.left < panel_rect.left then
							table.insert(found, {child = child, point = child_rect.right})
						end
					end
				end
			end
			
			local origin
			
			if dir.y == 1 then
				origin = panel_rect.bottom
			elseif dir.y == -1 then
				origin = panel_rect.top
			elseif dir.x == 1 then
				origin = panel_rect.right
			elseif dir.x == -1 then
				origin = panel_rect.left
			end
			
			table.sort(found, function(a, b) 
				return math.abs(a.point-origin) < math.abs(b.point-origin)
			end)		
		end
			
		if found and found[1] then		
			local child = found[1].child
			
			pos = child:GetPosition():Copy()
				
			if dir.x == -1 then
				pos.y = panel:GetY()
				pos.x = pos.x + child:GetWidth() + child.Padding.right			
			elseif dir.x == 1 then
				pos.y = panel:GetY()
				pos.x = pos.x - panel:GetWidth() - child.Padding.left			
			elseif dir.y == -1 then
				pos.x = panel:GetX()
				pos.y = pos.y + child:GetHeight() + child.Padding.bottom
			elseif dir.y == 1 then
				pos.x = panel:GetX()
				pos.y = pos.y - panel:GetHeight() - child.Padding.top			
			end
		else
			if dir.x == -1 then
				pos.x = pos.x + self.Margin.right + panel.Padding.right		
			elseif dir.x == 1 then                  
				pos.x = pos.x - self.Margin.left - panel.Padding.left	
			elseif dir.y == -1 then                  	
				pos.y = pos.y + self.Margin.bottom + panel.Padding.bottom
			elseif dir.y == 1 then            
				pos.y = pos.y - self.Margin.top - panel.Padding.top
			end                                     
		end
				
		return pos
	end

	local function process_commands(self, child, commands)
		local collide = true
		local args
			
		for i, cmd in ipairs(commands) do
			if type(cmd) == "table" then
				args = cmd
				cmd = cmd[1]
			end
			
			if cmd == "collide" then
				collide = true
			elseif cmd == "no_collide" then
				collide = false
			elseif typex(cmd) == "vec2" then
				child:SetSize(cmd:Copy())
			elseif cmd == "layout_children" then
				child:Layout(true)
			elseif cmd == "size_to_width" then
				local old = child:GetRect()
				child:SetHeight(self:GetHeight())									
				child:SetWidth(1)
				child:SetX(self:GetWidth() - 1)
				child:SetY(1)
				
				local left = ray_cast(child, child:GetRect():SetX(child:GetWidth()), child, collide)
				
				child:SetRect(old)
				
				child:SetWidth(left.x + 1)
			elseif cmd == "fill_x" then
				child:SetWidth(0)
				
				local left = ray_cast(self, child:GetRect():SetX(0), child, collide)
				local right = ray_cast(self, child:GetRect():SetX(self:GetWidth()), child, collide)
				right.x = right.x - left.x
				
				local x = left.x
				local w = right.x
				
				local min_width = child.MinimumSize.w
				
				if args and args[2] then
					x = math.max(math.lerp(args[2], left.x, right.x + child:GetWidth()), min_width/2) - min_width/2 + left.x
					w = w-x*2 + left.x*2
					if w < min_width then
						x = -left.x
						w = right.x
					end
				end
				
				child:SetX(math.max(x, left.x)) -- HACK???
				child:SetWidth(math.max(w, min_width))
			elseif cmd == "fill_y" then
				child:SetHeight(0)
				
				local top = ray_cast(self, child:GetRect():SetY(0), child, collide)
				child:SetPosition(top)
				
				local bottom = ray_cast(self, child:GetRect():SetY(self:GetHeight()), child, collide)
				bottom.h = bottom.h - top.y
				if bottom.h <= child.MinimumSize.h then
					--self:StopDragging()
				end
				child:SetHeight(bottom.h)
			elseif cmd == "center" then
				child:SetPosition(self:GetPosition() - (child:GetSize() / 2))
			elseif cmd == "center_x" then				
				local left = ray_cast(self, child:GetRect():SetX(0), child, collide)
				local right = ray_cast(self, Rect(left, child:GetSize()):SetX(self:GetWidth()), child, collide)

				child:SetX(math.lerp(0.5, left.x, right.x))
			elseif cmd == "center_x_simple" then				
				child:SetX(self:GetWidth() / 2 - child:GetWidth() / 2)
			elseif cmd == "center_x_frame" then
				local left = ray_cast(self, child:GetRect():SetX(0), child, collide)
				local right = ray_cast(self, Rect(left, child:GetSize()):SetX(self:GetWidth()), child, collide)
				
				if 
					child:GetX()+child:GetWidth()+child.Padding.right < right.x+child:GetWidth()-child.Padding.right and
					child:GetX()-child.Padding.x > left.x
				then
					child:SetX(self:GetWidth() / 2 - child:GetWidth() / 2)
					break
				end
			elseif cmd == "center_y" then
				local top = ray_cast(self, child:GetRect():SetY(0), child, collide)
				local bottom = ray_cast(self, Rect(top, child:GetSize()):SetY(self:GetHeight()), child, collide)					
				child:SetY(top.y + (bottom.y/2 - child:GetHeight()/2) - child.Padding.top + child.Padding.bottom)
			elseif cmd == "top" then
				child:SetY(math.max(child:GetY(), 1))
				child:SetY(ray_cast(self, child:GetRect():SetY(0), child, collide).y)
			elseif cmd == "left" then
				child:SetX(math.max(child:GetX(), 1))
				child:SetX(ray_cast(self, child:GetRect():SetX(0), child, collide).x)
			elseif cmd == "bottom" then
				child:SetY(ray_cast(self, child:GetRect():SetY(self:GetHeight() - child:GetHeight()), child, collide).y)
			elseif cmd == "right" then
				child:SetX(math.max(child:GetX(), 1))
				child:SetX(ray_cast(self, child:GetRect():SetX(self:GetWidth() - child:GetWidth()), child, collide).x)
			end
		end
	end

	function PANEL:CalcLayoutChain()
		for i, child in ipairs(self:GetChildren()) do
			if child.layout_chain then
				if child.LayoutSize then 
					child:SetSize(child.LayoutSize:Copy())
				end
				child:SetPosition((self:GetSize() / 2) - (child:GetSize() / 2))
				child.laid_out = false
			end
		end
		
		for i, child in ipairs(self:GetChildren()) do
			if child.layout_chain then
				child.laid_out = true
				process_commands(self, child, child.layout_chain)
			end
		end		
	end
	
	function PANEL:SetupLayoutChain(...)
		self.layout_chain = {...}
		self.LayoutSize = self:GetSize():Copy()
		if self:HasParent() then self.Parent:Layout() end
	end
end

do -- stacking
	prototype.GetSet(PANEL, "ForcedStackSize", Vec2(0, 0))
	
	prototype.GetSet(PANEL, "StackRight", true)
	prototype.GetSet(PANEL, "StackDown", true)

	prototype.GetSet(PANEL, "SizeStackToWidth", false)
	prototype.GetSet(PANEL, "SizeStackToHeight", false)
	prototype.IsSet(PANEL, "Stackable", true)
	prototype.IsSet(PANEL, "Stack", false)
	 
	function PANEL:StackChildren()
		if not self.Stack then return end
		
		local w = 0
		local h
		local pad = self:GetPadding()
			
		for _, pnl in ipairs(self:GetChildren()) do
			if not pnl:IsStackable() then goto NEXT end
			local siz = pnl:GetSize()
			
			if self.ForcedStackSize.w ~= 0 then
				siz.w = self.ForcedStackSize.w
			end
			
			if self.ForcedStackSize.h ~= 0 then
				siz.h = self.ForcedStackSize.h
			end
			
			siz = siz + self.Padding:GetSize()

			if self.StackRight then
				h = h or siz.h
				w = w + siz.w

				if self.StackDown and w > self:GetWidth() then
					h = h + siz.h
					w = siz.w
				end
				
				pnl:SetPosition(Vec2(w + pad.w, h + pad.h) - siz)
			else
				h = h or 0
				h = h + siz.h
				w = siz.w > w and siz.w or w
				
				pnl:SetPosition(Vec2(pad.x, h + pad.y - siz.h))
			end
			
			if not self.ForcedStackSize:IsZero() then
				local siz = self.ForcedStackSize
				
				if self.SizeStackToWidth then
					siz.w = self:GetWidth()
				end
				
				if self.SizeStackToHeight then
					siz.w = self:GetHeight()
				end

				pnl:SetSize(Vec2(siz.w - pad.h * 2, siz.h))
			else
				if self.SizeStackToWidth then
					pnl:SetWidth(self:GetWidth() - pad.w * 2)
				end
				
				if self.SizeStackToHeight then
					pnl:SetHeight(self:GetHeight() - pad.h * 2)
				end
			end
			
			::NEXT::
		end
		
		if self.SizeStackToWidth then
			w = self:GetWidth() - pad.w * 2
		end
		
		h = h or 0

		return Vec2(w, h) + pad:GetSize()
	end
end

do -- skin
	prototype.GetSet(PANEL, "Style")
		
	function PANEL:SetStyle(name)
		self.Style = name
		
		if name == "none" then
			self:SetNinePatch(false)
			self:SetNinePatchRect(Rect(0, 0, 0, 0))
			self:SetNinePatchCornerSize(4)
			self:SetStyleSize(Vec2(0, 0))
			self:SetTexture(render.GetWhiteTexture())
			return
		end
		
		name = self.style_translation[name] or name
		
		if gui2.skin[name] then
			self:SetupStyle(gui2.skin[name])
		end
	end
	
	PANEL.style_translation = {}
	
	function PANEL:SetStyleTranslation(from, to)
		self.style_translation[from] = to
	end
	
	prototype.GetSet(PANEL, "NinePatch", false)
	prototype.GetSet(PANEL, "NinePatchRect", Rect(0, 0, 0, 0))
	prototype.GetSet(PANEL, "NinePatchCornerSize", 4)
	prototype.GetSet(PANEL, "StyleSize", Vec2(0, 0))
	
	function PANEL:SetStyleSize(vec)
		if not vec:IsZero() then
			self:SetSize(vec)
		end
		self.StyleSize = vec
	end
	
	function PANEL:SetupStyle(tbl)
		tbl.texture_rect = tbl.texture_rect or self.NinePatchRect
		tbl.corner_size = tbl.corner_size or self.NinePatchCornerSize
		tbl.color = tbl.color or self.Color
		tbl.size = tbl.size or self.StyleSize
		
		self:SetNinePatch(tbl.ninepatch)
		self:SetColor(tbl.color)
		self:SetTexture(tbl.texture)
		self:SetNinePatchRect(tbl.texture_rect)
		self:SetNinePatchCornerSize(tbl.corner_size)
		self:SetStyleSize(tbl.size)
	end
end

function PANEL:DrawRect(x, y, w, h)
	if self.NinePatch then			
		surface.DrawNinePatch(
			x or 0, y or 0, 
			w or (self.Size.w + self.DrawSizeOffset.w), h or (self.Size.h + self.DrawSizeOffset.h),
			self.NinePatchRect.w, self.NinePatchRect.h, 
			self.NinePatchCornerSize, 
			self.NinePatchRect.x, self.NinePatchRect.y
		)
	else
		if not self.NinePatchRect:IsZero() then
			surface.SetRectUV(self.NinePatchRect.x, self.NinePatchRect.y, self.NinePatchRect.w, self.NinePatchRect.h, self.Texture.w, self.Texture.h)
		end
		surface.DrawRect(x or 0, y or 0, w or (self.Size.w + self.DrawSizeOffset.w), h or (self.Size.h + self.DrawSizeOffset.h))
		if not self.NinePatchRect:IsZero() then
			surface.SetRectUV()
		end
	end
end

do -- events
	function PANEL:OnDraw()
		if self.NoDraw then return end
		
		local r,g,b,a = self.Color:Unpack()
		local mr,mg,mb,ma = self.DrawColor:Unpack()
				
		surface.SetColor(r+mr,g+mg,b+mb,a+ma)
		surface.SetTexture(self.Texture)
		
		self:DrawRect()

		if gui2.debug_layout then
			surface.SetFont("default")
			surface.DrawText("layout count " .. self.layout_count)
			--surface.SetWhiteTexture()
			--surface.SetColor(1,0,0,1)
			--surface.DrawRect(self:GetMousePosition().x, self:GetMousePosition().y, 2, 2)
		end
	end
	
	function PANEL:OnPreDraw() end
	function PANEL:OnPostDraw() end
	
	function PANEL:OnFocus() end
	function PANEL:OnUnfocus() end

	function PANEL:OnMouseEnter(x, y) end
	function PANEL:OnMouseExit(x, y) end
	function PANEL:OnMouseMove(x, y) end
	function PANEL:OnMouseInput(button, press) end
	
	function PANEL:OnPreKeyInput(button, press) end
	function PANEL:OnKeyInput(button, press) end
	function PANEL:OnPostKeyInput(button, press) end
	function PANEL:OnCharInput(char) end
	function PANEL:OnRightClick() end
	function PANEL:OnGlobalMouseInput(button, press) end

	function PANEL:OnCharTyped(char) end
	function PANEL:OnKeyPressed(key, pressed) end
	function PANEL:OnUpdate() end

	function PANEL:OnPositionChanged(pos) end
	function PANEL:OnScroll(fraction) end
	function PANEL:OnLayout() end
	function PANEL:OnShow() end
	function PANEL:OnHide() end
	function PANEL:OnMouseHoverTrigger(x, y) end
	function PANEL:Initialize() end
end

gui2.RegisterPanel(PANEL)

for k,v in pairs(gui2.panels) do
	v:Layout()
end