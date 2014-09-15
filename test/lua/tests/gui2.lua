window.SetSize(Vec2(1680, 1050))

-- drag drop doesn't work properly with camera changes
-- multiple animations of the same type
-- support rotation in TrapChildren and drag drop
-- clipping isn't "recursive"

local gui2 = {}

_G.gui2 = gui2
 
gui2.hovering_panel = NULL
gui2.focus_panel = NULL
gui2.panels = {}

do -- base panel
	local PANEL = metatable.CreateTemplate("panel2")

	metatable.AddParentingTemplate(PANEL)

	metatable.GetSet(PANEL, "MousePosition", Vec2(0, 0))
	metatable.IsSet(PANEL, "Visible", true)
	metatable.GetSet(PANEL, "Clipping", false)
	metatable.GetSet(PANEL, "Color", Color(1,1,1,1))
	metatable.GetSet(PANEL, "Cursor", "hand")
	metatable.GetSet(PANEL, "TrapChildren", false)
	metatable.GetSet(PANEL, "Texture", render.GetWhiteTexture())

	metatable.GetSet(PANEL, "Padding", Rect(10, 10, 10, 10))
	metatable.GetSet(PANEL, "Margin", Rect(10, 10, 10, 10))

	function PANEL:__tostring()
		return ("panel[%p] %s %s %s %s"):format(self, self.Position.x, self.Position.y, self.Size.w, self.Size.h)
	end
	
	function PANEL:IsWorld()
		return self == gui2.world
	end
	
	function PANEL:BringToFront()
		local parent = self:GetParent()

		if parent:IsValid() then
			self:SetParent()
			parent:AddChild(self)
		end
	end

	function PANEL:RequestFocus()
		gui2.focus_panel = self
	end

	function PANEL:GetSizeOfChildren()
		local total_size = Vec2()

		for k, v in ipairs(self:GetChildren()) do
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

	function PANEL:PreDraw()
		local no_clip = self:HasParent() and self.Parent.draw_no_clip
		local no_draw = self:HasParent() and self.Parent.draw_no_draw
	
		surface.PushMatrix()
			render.Translate(self.Position.x, self.Position.y, 0)

			local w = (self.Size.w)/2
			local h = (self.Size.h)/2

			render.Translate(w, h, 0)
			render.Rotate(self.Angle, 0, 0, 1)
			render.Translate(-w, -h, 0)

			self:CalcMouse()
			self:CalcDragging()
			self:CalcScrolling()

			self:CalcAnimations()

			if self.CachedRendering then
				self:DrawCache()
				no_draw = true
			end

			local sigh = false
			if not no_draw and not no_clip and self.Clipping then
				surface.StartClipping2(0, 0, self.Size.w + self.DrawSizeOffset.w, self.Size.h + self.DrawSizeOffset.h)
				no_clip = true
				sigh = true
			end

				self:OnUpdate()

				if not no_draw then
					if	
						self:IsDragging() or
						self:IsWorld() or
						(
							self.Position.x - self.Parent.Scroll.x < self.Parent.Size.w and
							self.Position.y - self.Parent.Scroll.y < self.Parent.Size.h and
							self.Position.x + self.Size.w - self.Parent.Scroll.x > -self.Parent.Size.w and
							self.Position.y + self.Size.h - self.Parent.Scroll.y > -self.Parent.Size.h
						)
					then
						self:OnDraw()
						self:SetVisible(true)
					else
						self:SetVisible(false)
					end
				end

				render.Translate(-self.Scroll.x, -self.Scroll.y, 0)

				--for k,v in ipairs(self:GetChildren()) do
				--	v:Draw(no_clip, no_draw)
				--end
				
				self.draw_no_clip = no_clip
				self.draw_no_draw = no_draw
				self.draw_sigh = sigh
	end
	
	function PANEL:Draw()
		self:PreDraw()
			for k,v in ipairs(self:GetChildren()) do
				v:Draw()
			end
		self:PostDraw()
	end
				
	function PANEL:PostDraw()
				self:CalcResizing()

			if self.draw_sigh or not self.draw_no_draw and not self.draw_no_clip and self.Clipping then
				surface.EndClipping2()
			end
		surface.PopMatrix()
	end

	do -- orientation
		metatable.GetSet(PANEL, "Position", Vec2(0, 0))
		metatable.GetSet(PANEL, "Size", Vec2(50, 50))
		metatable.GetSet(PANEL, "MinimumSize", Vec2(4, 4))
		metatable.GetSet(PANEL, "Angle", 0)
		metatable.GetSet(PANEL, "Order", 0)
		
		function PANEL:SetPosition(pos)
			if self:HasParent() and self.Parent.TrapChildren then
				pos:Clamp(Vec2(0, 0), self.Parent.Size - self.Size)
			end

			self.Position = pos
		end

		function PANEL:SetSize(size)
			size.x = math.max(size.x, self.MinimumSize.w)
			size.y = math.max(size.y, self.MinimumSize.h)

			self.Size = size
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
			end
			return lpos
		end

		function PANEL:LocalToWorld(lpos)
			local wpos = lpos
			for k, v in npairs(self:GetParentList()) do
				wpos = wpos + v:GetPosition()
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
			end
		end

		function PANEL:SetWidth(w)
			self.Size.w = w
		end
		function PANEL:GetWidth()
			return self.Size.w
		end

		function PANEL:SetHeight(h)
			self.Size.h = h
		end
		function PANEL:GetHeight()
			return self.Size.h
		end
	end

	do -- cached rendering
		metatable.GetSet(PANEL, "CachedRendering", false)

		function PANEL:SetCachedRendering(b)
			self.CachedRendering = b

			self:MarkDirty()
		end

		function PANEL:MarkDirty()
			if self.CachedRendering then
				self.cache_dirty = true

				if not self.cache_fb then
					self.cache_fb = render.CreateFrameBuffer(self.Size.w, self.Size.h, {
						{
							name = "color",
							attach = "color1",

							texture_format = {
								internal_format = "RGB32F",
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
					if v.CachedRendering then
						v:MarkDirty()
					end
				end
			end
		end

		function PANEL:IsDirty()
			return self.cache_dirty
		end

		function PANEL:DrawCache()
			if self:IsDirty() then
				self.cache_fb:Begin()
				self.cache_fb:Clear()

				surface.PushMatrix()
					-- this matrix needs to be reset so it will draw
					-- from the origin of the framebuffer
					-- the framebuffer itself is drawn at the correct position
					surface.LoadIdentity()

					self:OnDraw()

					surface.Translate(-self.Scroll.x, -self.Scroll.y)

					for k,v in ipairs(self:GetChildren()) do
						v:Draw()
					end

					self.cache_dirty = false
				surface.PopMatrix()
				self.cache_fb:End()
			end

			surface.SetColor(1, 1, 1, 1)
			surface.SetTexture(self.cache_texture)
			surface.DrawRect(0, 0, self.Size.w, self.Size.h)
		end
	end
		
	do -- scrolling		
		metatable.GetSet(PANEL, "Scroll", Vec2(0, 0))
		metatable.GetSet(PANEL, "ScrollFraction", Vec2(0, 0))
	
		function PANEL:SetScroll(vec)
			local size = self:GetSizeOfChildren()

			self.Scroll = Vec2(math.clamp(vec.x, 0, size.x - self.Size.w), math.clamp(vec.y, 0, size.y - self.Size.h))
			
			self.ScrollFraction = self.Scroll / (size + self.Scroll - self.Size) * 2
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
				self:MarkDirty()
			else
				self:StopScrolling()
			end
		end
	end
	
	do -- drag drop
		metatable.GetSet(PANEL, "DragDrop", false)

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
			self:AddChild(child)
			child:SetPosition(pos)
			--child:Dock("fill_" .. self:GetDockLocation())
		end
	end
	
	do -- magnet snap
		metatable.GetSet(PANEL, "SnapWhileDragging", false)

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
		metatable.GetSet(PANEL, "DrawSizeOffset", Vec2(0, 0))
		metatable.GetSet(PANEL, "DrawPositionOffset", Vec2(0, 0))
		metatable.GetSet(PANEL, "DrawAngleOffset", 0)
		
		PANEL.animations = {}

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

		function PANEL:CalcAnimations()
			render.Translate(self.DrawPositionOffset.x, self.DrawPositionOffset.y, 0)

			local w = (self.Size.w + self.DrawSizeOffset.w)/2
			local h = (self.Size.h + self.DrawSizeOffset.h)/2

			render.Translate(w, h, 0)
			render.Rotate(self.DrawAngleOffset, 0, 0, 1)
			render.Translate(-w, -h, 0)
				
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

					if alpha >= 1 then
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

		function PANEL:Animate(var, to, time, operator, pow)

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

	do -- docking
		do -- center
			function PANEL:CenterX()
				self:SetPosition(Vec2((self.Parent:GetSize().x * 0.5) - (self:GetSize().x * 0.5), self:GetPosition().y))
			end

			function PANEL:CenterY()
				self:SetPosition(Vec2(self:GetPosition().x, (self.Parent:GetSize().y * 0.5) - (self:GetSize().y * 0.5)))
			end

			function PANEL:Center()
				self:CenterY()
				self:CenterX()
			end
		end

		function PANEL:Align(vec, off, parent)
			off = off or Vec2()
			parent = parent or self:GetParent()

			local padding = parent:GetPadding() or Rect()
			local size = self:GetSize() + padding:GetPosSize()
			local centerparent = parent:GetSize() * vec
			local centerself = size * vec
			local pos = centerparent - centerself

			if vec.x == -1 and vec.y == -1 then
				return
			elseif vec.x == -1 then
				self.Position.y = pos.y + off.y + padding.y
			elseif vec.y == -1 then
				self.Position.x = pos.x + off.x + padding.x
			else
				self:SetPosition(pos + off + padding:GetPos())
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

			self.Parent:DockLayout()
		end

		function PANEL:DockLayout()
			local margin = self.Margin

			local x = margin.x
			local y = margin.y
			local w = self:GetWidth() - x - margin.w
			local h = self:GetHeight() - y - margin.h

			local area = Rect(x, y, w, h)

			local left, right, top, bottom, center
			local pad

			-- grab one of each dock type
			for _, pnl in ipairs(self:GetChildren()) do
				if pnl.dock_location then
					if pnl.dock_location == "fill" then
						pnl:SetPosition(area:GetPos() + pnl:GetPos())
						pnl:SetSize(area:GetSize() - pnl:GetPosSize())

						if pnl.SizeToContens then
							pnl:SizeToContents()
						end
					else
						if pnl.dock_location == "center" then
							pnl:Center()
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
				pnl:DockLayout()
			end

			if top then
				pad = top:GetPadding()

				top:SetPosition(area:GetPos() + pad:GetPos())
				top:SetWidth(area.w - pad:GetXW())

				area.y = area.y + top:GetHeight() + pad:GetYH()
				area.h = area.h - top:GetHeight() - pad:GetYH()
			end

			if bottom then
				pad = bottom:GetPadding()

				bottom:SetPosition(area:GetPos() + Vec2(pad.x, area.h - bottom:GetHeight() - pad.h))
				bottom:SetWidth(w - pad:GetXW())
				area.h = area.h - bottom:GetHeight() - pad:GetYH()
			end

			if left then
				pad = left:GetPadding()

				left:SetPosition(area:GetPos() + pad:GetPos())
				left:SetHeight(area.h - pad:GetYH())
				area.x = area.x + left:GetWidth() + pad:GetXW()
				area.w = area.w - left:GetWidth() - pad:GetXW()
			end

			if right then
				pad = right:GetPadding()

				right:SetPosition(area:GetPos() + Vec2(area.w - right:GetWidth() - pad.w, pad.y))
				right:SetHeight(area.h - pad:GetYH())
				area.w = area.w - right:GetWidth() - pad:GetXW()
			end
		end

		function PANEL:GetDockLocation(pos, offset) -- rename this function
			pos = pos or self:GetMousePosition()
			offset = offset or self:GetSize() / 4

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
		function PANEL:GetResizeLocation(pos)
			pos = pos or self:GetMousePosition()
			local loc = self:GetDockLocation(pos, Vec2(8, 8))

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

		function PANEL:CalcResizing()
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

				if self:HasParent() then
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
		metatable.GetSet(PANEL, "SendMouseInputToParent", false)
	
		function PANEL:IsMouseOver()
			return self:IsDragging() or self:IsResizing() or self.mouse_over and gui2.hovering_panel == self
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
		
		function PANEL:MouseInput(button, press)
			
			if self.SendMouseInputToParent then
				self.Parent:MouseInput(button, press)
			end
		
			self:BringToFront()

			if press then
				if button == "button_2" then
					self:SetClipping(not self:GetClipping())
				end

				if button == "button_1" then
					if not self:StartResizing(nil, button) then
						if not self.lol then
							self:StartDragging(button)
						end
					end
				end
				
				if button == "button_3" then
					self:StartScrolling(button)
				end
				
				if button == "mwheel_down" then
					self:SetScroll(self:GetScroll() + Vec2(0, 20))
				elseif button == "mwheel_up" then
					self:SetScroll(self:GetScroll() + Vec2(0, -20))
				end
			end
			
			self:RequestFocus()

			-- temp
			if button == "button_1" and press then
				self:OnClick()
			end
			
			self:OnMouseInput(button, press)
		end
		
		function PANEL:KeyInput(button, press)
			self:OnKeyInput(button, press)
		end	
		
		function PANEL:CharInput(char)
			self:OnCharInput(char)
		end
	end
	
	do -- events
		function PANEL:OnUpdate()

		end

		function PANEL:OnDraw()	
			surface.SetColor(self.Color:Unpack())
			surface.SetTexture(self.Texture)

			surface.DrawRect(0, 0, self.Size.w + self.DrawSizeOffset.w, self.Size.h + self.DrawSizeOffset.h)

			if gui2.debug then
				surface.SetWhiteTexture()
				surface.SetColor(1,0,0,1)
				surface.DrawRect(self:GetMousePosition().x, self:GetMousePosition().y, 2, 2)
			end
		end

		function PANEL:OnMouseEnter(x, y) self:SetColor(Color(1,1,1,1)) end
		function PANEL:OnMouseExit(x, y) self:SetColor(self.original_color) end
		function PANEL:OnMouseMove(x, y) self:MarkDirty() end
		function PANEL:OnMouseInput(button, press) end
		
		function PANEL:OnKeyInput(button, press) end
		function PANEL:OnCharInput(char) end

		function PANEL:OnCharTyped(char) end
		function PANEL:OnKeyPressed(key, pressed) end
		function PANEL:OnClick(key, pressed) end
	end

	function gui2.CreatePanel(parent)
		local self = PANEL:New()

		self:SetParent(parent or gui2.world)

		table.insert(gui2.panels, self)
		self.i = #gui2.panels

		return self
	end
end

function gui2.GetHoveringPanel(panel, filter)
	panel = panel or gui2.world
	local children = panel:GetChildren()

	for i = #children, 1, -1 do
		local panel = children[i]
		if panel.mouse_over and (not filter or panel ~= filter) then
			if panel:HasChildren() then
				return gui2.GetHoveringPanel(panel, filter)
			end
			return panel
		end
	end

	return panel.mouse_over and panel or gui2.world
end

function gui2.MouseInput(button, press)
	local panel = gui2.hovering_panel

	if panel:IsValid() and panel:IsMouseOver() then
		panel:MouseInput(button, press)
	end
end

function gui2.KeyInput(button, press)
	local panel = gui2.focus_panel

	if panel:IsValid() then
		panel:KeyInput(button, press)
	end
end

function gui2.CharInput(char)
	local panel = gui2.focus_panel

	if panel:IsValid() then
		panel:CharInput(char)
	end
end

function gui2.Draw2D()
	render.SetCullMode("none")
	if gui2.threedee then 
		--surface.Start3D(Vec3(1, -5, 10), Ang3(-90, 180, 0), Vec3(8, 8, 10))
		surface.Start3D(Vec3(0, 0, 0), Ang3(0, 0, 0), Vec3(20, 20, 20))
	end

	gui2.hovering_panel = gui2.GetHoveringPanel()

	if gui2.hovering_panel:IsValid() then
		local cursor = gui2.hovering_panel:GetCursor()

		if gui2.active_cursor ~= cursor then
			system.SetCursor(cursor)
			gui2.active_cursor = cursor
		end
	end
	
		gui2.mouse_pos.x, gui2.mouse_pos.y = surface.GetMousePos()

		gui2.world:Draw()
	if gui2.threedee then 
		surface.End3D()
	end
		do return end
		
		if not gui2.unrolled_draw then
			local str = {"local panels = gui2.panels"}
			
			local function add_children_to_list(parent, str, level)
				table.insert(str, ("%spanels[%i]:PreDraw()"):format((" "):rep(level), parent.i))
				for i, child in ipairs(parent:GetChildren()) do
					level = level + 1
					add_children_to_list(child, str, level) 
					level = level - 1
				end
				table.insert(str, ("%spanels[%i]:PostDraw()"):format((" "):rep(level), parent.i))
			end
		
			add_children_to_list(gui2.world, str, 0)
			str = table.concat(str, "\n")
			print(str)			
			gui2.unrolled_draw = loadstring(str, "gui2_unrolled_draw")
		end
		
		for i = 1, 40 do
			gui2.world:Draw()
		end
				


end

function gui2.Initialize()
	local world = gui2.CreatePanel()

	world:SetPosition(Vec2(0, 0))
	world:SetSize(Vec2(window.GetSize()))
	world:SetCursor("arrow")
	world:SetTrapChildren(true)
	world:SetColor(Color(1,1,1,0))
	world:SetPadding(Rect(10, 10, 10, 10))

	gui2.world = world

	gui2.mouse_pos = Vec2()

	event.AddListener("Draw2D", "gui2", gui2.Draw2D)
	event.AddListener("MouseInput", "gui2", gui2.MouseInput)
	event.AddListener("KeyInputRepeat", "gui2", gui2.KeyInput)
	event.AddListener("CharInput", "gui2", gui2.CharInput)
end

function gui2.Test()
	local parent = gui2.CreatePanel()
	parent:SetPosition(Vec2(400,140))
	parent:SetSize(Vec2(300,300))
	local c = HSVToColor(0, 0, 0.25)
	parent:SetColor(c)
	parent.original_color = c
	parent:SetSnapWhileDragging(true)

	for i = 1, 5 do
		local panel = gui2.CreatePanel(parent)
		panel:SetPosition(Vec2(50,50))
		panel:SetColor(HSVToColor(math.random(), 1, 1))
		panel.original_color = panel:GetColor()
		panel:SetSize(Vec2(50,50))
		panel:SetSnapWhileDragging(true)
	end
	
	do -- markup
		local panel = gui2.CreatePanel()
		panel:SetPosition(Vec2(800,300))
		panel:SetSize(Vec2(300,300))
		panel:SetClipping(true)
		panel:SetColor(Color(0.1,0.1,0.1,1))
		panel.original_color = panel.Color:Copy()
		panel.lol = true
		
		function panel:OnMouseInput(button, press)
			if button == "button_2" then
				if not self:StartResizing(nil, button) then
					self:StartDragging(button)
				end
			end
		end
			
		do
			local panel = gui2.CreatePanel(panel) 
			panel:SetColor(Color(0.1,0.1,0.1,0))
			panel.original_color = panel.Color:Copy()
			panel:SetSendMouseInputToParent(true)
			
			panel.lol = true
			local markup = surface.CreateMarkup()
			markup:Test()
			
			function panel:OnDraw()
				markup:SetMousePosition(self:GetMousePosition():Copy())

				markup.cull_x = self.Parent.Scroll.x
				markup.cull_y = self.Parent.Scroll.y
				markup.cull_w = self.Parent.Size.w
				markup.cull_h = self.Parent.Size.h
				
				--getmetatable(self).OnDraw(self)
				markup:Draw()
				
				self.Size.w = markup.width
				self.Size.h = markup.height
			end
			
			function panel:OnMouseInput(button, press)
				markup:OnMouseInput(button, press)
			end
			
			function panel:OnKeyInput(key, press)
				if key == "left_shift" or key == "right_shift" then  markup:SetShiftDown(press) return end
				if key == "left_control" or key == "right_control" then  markup:SetControlDown(press) return end
			
				if press then
					markup:OnKeyInput(key, press)
				end
			end
			
			function panel:OnCharInput(char)
				markup:OnCharInput(char)
			end
			
			panel.OnMouseEnter = function() end
			panel.OnMouseExit = function() end	
		end
	end
	

	local frame = gui2.CreatePanel()
	frame:SetSize(Vec2(200,200))
	frame:SetPosition(Vec2(57,50))

	local c = Color(1,1,1,1) * 0.25
	frame:SetColor(c)
	frame.original_color = c

	frame:SetClipping(true)
	--frame:SetCachedRendering(true)
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
		pnl.OnMouseMove = function(self) self:MarkDirty() end
		pnl.lol = true

		--pnl.OnMouseInput = pnl.RequestFocus

		table.insert(lol, pnl)
	end
	end

	event.AddListener("Update", "lol", function()
		for i, v in ipairs(lol) do
			v:SetAngle(os.clock()*v.rand)
		end
	end)

	function frame:OnMouseMove(x, y)
		self:MarkDirty()
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
		pnl.OnMouseMove = function(s) s:MarkDirty() end

		if math.random() > 0.5 then
			if math.random() > 0.5 then
				if math.random() > 0.5 then
					pnl.OnClick = function(self)
						self:Animate("Color", {Color(0,0,0,0), "from", Color(1,1,0,1), "from"}, 0.5)
					end
				else
					pnl.OnClick = function(self)
						self:Animate("Color", {Color(1,0,0,1), Color(0,1,0,1),  Color(0,0,1,1), "from"}, 2)
					end
				end
			else
				pnl.OnClick = function(self)
					local duration = 0.2

					self:Animate("DrawSizeOffset", {Vec2(10, 10), function() return input.IsMouseDown("button_1") end, Vec2(0, 0)}, duration, "-")
					self:Animate("DrawPositionOffset", {Vec2(10, 10) * 0.5, function() return input.IsMouseDown("button_1") end, Vec2(0, 0)}, duration, "+")

					--self:Animate("DrawPositionOffset", Vec2(150, 150), 0.5, function(self) self:SetSize(Vec2(50,50)) end)
				end
			end
		else
			if math.random() > 0.5 then
				pnl.OnClick = function(self)
					local duration = 0.6
					self:Animate("Color", {Color(0,0,0,0), "from"}, duration)
					self:Animate("DrawAngleOffset", math.random() > 0.5 and 360 or -360, duration)
				end
			else
				if math.random() > 0.5 then
					pnl.OnClick = function(self)
						local pow = 1
						local duration = 0.5

						self:Animate("DrawSizeOffset", {Vec2(1, -self.Size.h*2), function() return input.IsMouseDown("button_1") end, "from"}, duration, "+", pow)
						self:Animate("DrawPositionOffset", {Vec2(0, self.Size.h), function() return input.IsMouseDown("button_1") end, "from"}, duration, "+", pow)
						self:Animate("Color", {Color(0,0,0,0), function() return input.IsMouseDown("button_1") end, "from"}, duration, "", pow)
					end
				else
					pnl.OnClick = function(self)
						self:Animate("DrawAngleOffset", {math.randomf(-360, 360), "from"}, math.random())
					end
				end
			end
		end
	end
	end
end

gui2.Initialize()
gui2.Test()

--for k,v in pairs(event.GetTable()) do for k2,v2 in pairs(v) do if type(v2.id)=='string' and v2.id:lower():find"aahh" or v2.id == "gui" then event.RemoveListener(k,v2.id) end end end