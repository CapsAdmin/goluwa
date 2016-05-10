local gui = ... or _G.gui

local META = prototype.CreateTemplate("panel", "base")

include("lua/libraries/templates/parenting.lua", META)

prototype.GetSet(META, "MousePosition", Vec2(0, 0))
prototype.IsSet(META, "Visible", true)
prototype.GetSet(META, "Clipping", false)
prototype.GetSet(META, "Color", Color(1,1,1,1))
prototype.GetSet(META, "Cursor", "arrow")
prototype.GetSet(META, "TrapChildren", false)
prototype.GetSet(META, "Texture", render.GetWhiteTexture())
prototype.GetSet(META, "RedirectFocus", NULL)
prototype.GetSet(META, "ObeyMargin", true)
prototype.GetSet(META, "BringToFrontOnClick", false)
prototype.GetSet(META, "LayoutParentOnLayout", false)
prototype.GetSet(META, "LayoutWhenInvisible", true)
prototype.GetSet(META, "VisibilityPanel", NULL)
prototype.GetSet(META, "NoDraw", false)
prototype.GetSet(META, "GreyedOut", false)
prototype.GetSet(META, "UpdateRate", 1/33)

function META:CreatePanel(name, store_in_self)
	return gui.CreatePanel(name, self, store_in_self)
end

function META:__tostring2()
	return ("[%s %s %s %s][%s]"):format(self.Position.x, self.Position.y, self.Size.x, self.Size.y, self.layout_count)
end

function META:IsWorld()
	return self.is_world
end

function META:GetSizeOfChildren()

	if self.last_children_size then
		return self.last_children_size
	end

	for _, child in ipairs(self:GetChildren()) do
		child:Layout(true)
	end
	self:Layout(true)

	local total_size = Vec2()

	for _, v in ipairs(self:GetChildren()) do
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

	self.last_children_size = total_size

	return total_size
end

function META:SizeToChildrenHeight()
	self:SetHeight(math.huge)
	self:SetHeight(self:GetSizeOfChildren().y + self.Margin:GetHeight())
	if not math.isvalid(self.Size.y) then self.Size.y = 100 end -- FIX ME
	self.LayoutSize = self.Size:Copy()
end

function META:SizeToChildrenWidth()
	self:SetWidth(math.huge)
	self:SetWidth(self:GetSizeOfChildren().x + self.Margin:GetWidth())
	if not math.isvalid(self.Size.x) then self.Size.x = 100 end -- FIX ME
	self.LayoutSize = self.Size:Copy()
end

function META:SizeToChildren()
	self:SetSize(Vec2() + math.huge)
	self:SetSize(self:GetSizeOfChildren() + self.Margin:GetSize())
	if not self.Size:IsValid() then self.Size:Set(100, 100) end -- FIX ME
	self.LayoutSize = self.Size:Copy()
end

function META:GetVisibleChildren()
	local tbl = {}

	for _, v in ipairs(self:GetChildren()) do
		if v.Visible then
			table.insert(tbl, v)
		end
	end

	return tbl
end

function META:IsInsideParent()
	local override = self.Parent

	if not override:IsValid() then return true end

	override = override.Parent

	if not override:IsValid() then return true end

	if override.VisibilityPanel:IsValid() then
	--	override = override.VisibilityPanel
	end

	if
		self.Position.x - override.Scroll.x < override.Size.x and
		self.Position.y - override.Scroll.y < override.Size.y and
		self.Position.x + self.Size.x - override.Scroll.x > 0 and
		self.Position.y + self.Size.y - override.Scroll.y > 0
	then
		return true
	end

	return false
end

do -- focus
	function META:BringToFront()
		if self.RedirectFocus:IsValid() then
			return self.RedirectFocus:BringToFront()
		end

		local parent = self:GetParent()

		if parent:IsValid() then
			self:UnParent()
			parent:AddChild(self)
		end
	end

	function META:SendToBack()
		local parent = self:GetParent()

		if parent:IsValid() then
			self:UnParent()
			parent:AddChild(self, 1)
		end
	end

	function META:RequestFocus()
		if self.RedirectFocus:IsValid() then
			self = self.RedirectFocus
		end

		if gui.focus_panel:IsValid() and gui.focus_panel ~= self then
			gui.focus_panel:OnUnfocus()
		end

		self:OnFocus()

		gui.focus_panel = self
	end

	function META:Unfocus()
		if self.RedirectFocus:IsValid() then
			self = self.RedirectFocus
		end

		if gui.focus_panel:IsValid() and gui.focus_panel == self then
			self:OnUnfocus()
			gui.focus_panel = NULL
		end
	end

	function META:IsFocused()
		return gui.focus_panel == self
	end
end

do -- call on hide
	function META:IsVisible()
		if self.visible == nil then return true end -- ?????
		return self.Visible
	end

	function META:SetVisible(bool)
		self.call_on_hide = self.call_on_hide or {}

		self.Visible = bool
		if bool then
			self:OnShow()
		else
			self:OnHide()
			for _, v in pairs(self.call_on_hide) do
				if v() == false then
					break
				end
			end
		end

		self:Layout(true)
	end

	function META:CallOnHide(callback, id)
		self.call_on_hide = self.call_on_hide or {}

		id = id or callback

		self.call_on_hide[id] = callback
	end
end

do -- drawing

	function META:PreDraw(from_cache)
		if self.GreyedOut then surface.PushHSV(1,0,0.5) end

		if self.ThreeDee then surface.Start3D2D() end

		local no_draw = self:HasParent() and self.Parent.draw_no_draw

		self:InvalidateMatrix()
		self:RebuildMatrix()

		surface.SetWorldMatrix(self.Matrix)

		if not from_cache then
			self:CalcMouse()

			self:CalcDragging()
			self:CalcScrolling()
		end

		self:CalcAnimations()
		self:CalcLayout()
		self:CalcResizing()

		if self.CachedRendering and not gui.debug then
			self:BuildCache()
			self:DrawCache()
			no_draw = true
		end


		do
			local time = system.GetElapsedTime()
			self.next_update = self.next_update or time

			if self.next_update + self.UpdateRate < time then
				self:OnUpdate(time - self.next_update)
				self.next_update = time
			end
		end

		if from_cache or not no_draw then
			if self:IsDragging() or self:IsWorld() or self:IsInsideParent() then
				self:OnPreDraw()
				self:OnDraw()
				self:OnPostDraw()

				if gui.keyboard_selected_panel == self then
					render.SetBlendMode("additive")
					surface.SetColor(1, 1, 1, 0.5)
					surface.SetWhiteTexture()
					surface.DrawRect(0, 0, self.Size.x + self.DrawSizeOffset.x, self.Size.y + self.DrawSizeOffset.y)
					render.SetBlendMode("alpha")
				end

				self.visible = true
				no_draw = false
			else
				self.visible = false
				no_draw = true
			end
		end

		if --[[true or]] not no_draw and self.Clipping then
			--surface.PushClipFunction(self.DrawClippingStencil, self)
			surface.EnableClipRect(0,0,self.Size.x + self.DrawSizeOffset.x, self.Size.y + self.DrawSizeOffset.y)
		end

		if from_cache then
			self.draw_no_draw = false
		else
			self.draw_no_draw = no_draw
		end
	end

	function META:DrawClippingStencil()
		--if not self.Clipping then return end
		local tex = surface.GetTexture()
		surface.SetWhiteTexture()
		--surface.SetTexture(self.Texture)
		surface.PushColor(1,1,1,0.1)
		self:DrawRect()
		surface.PopColor()
		surface.SetTexture(tex)
	end

	function META:Draw(from_cache)
		if not self.Visible then return end
		self:PreDraw(from_cache)
			for _, v in ipairs(self:GetChildren()) do
				v:Draw(from_cache)
			end
		self:PostDraw(from_cache)
	end

	function META:PostDraw(from_cache)
		if --[[true or]] not self.draw_no_draw and self.Clipping then
			--surface.PopClipFunction()
			surface.DisableClipRect()
			--render.PopViewport()
		end

		if self.debug_flash and self.debug_flash > system.GetElapsedTime() then
			surface.SetColor(1,0,0,(system.GetElapsedTime()*4)%1 > 0.5 and 0.5 or 0)
			surface.DrawRect(0, 0, self.Size.x, self.Size.y)
		end

		if gui.debug then
			if self.updated_layout then
				render.SetBlendMode("additive")
				surface.SetColor(1, 0, 0, 0.1)
				surface.SetWhiteTexture(self.cache_texture)
				surface.DrawRect(self.Scroll.x, self.Scroll.y, self.Size.x, self.Size.y)
				self.updated_layout = false
				render.SetBlendMode("alpha")
			else
				if self.updated_cache then
					surface.SetColor(0, 1, 0, 0.1)
					surface.SetWhiteTexture(self.cache_texture)
					surface.DrawRect(0, 0, self.Size.x, self.Size.y)
					self.updated_cache = false
				end
			end
		end

		if self.ThreeDee then surface.End3D2D() end

		if self.GreyedOut then surface.PopHSV() end
	end

	function META:DrawRect(x, y, w, h)
		if self.NinePatch then
			surface.DrawNinePatch(
				x or 0, y or 0,
				w or (self.Size.x + self.DrawSizeOffset.x), h or (self.Size.y + self.DrawSizeOffset.y),
				self.NinePatchRect.w, self.NinePatchRect.h,
				self.NinePatchCornerSize,
				self.NinePatchRect.x, self.NinePatchRect.y,
				self:GetSkin().pixel_scale
			)
		else
			if not self.NinePatchRect:IsZero() then
				surface.SetRectUV(self.NinePatchRect.x, self.NinePatchRect.y, self.NinePatchRect.w, self.NinePatchRect.h, self.Texture.Size.x, self.Texture.Size.y)
			end
			surface.DrawRect(x or 0, y or 0, w or (self.Size.x + self.DrawSizeOffset.x), h or (self.Size.y + self.DrawSizeOffset.y))
			if not self.NinePatchRect:IsZero() then
				surface.SetRectUV()
			end
		end
	end

	function META:DebugFlash()
		self.debug_flash = system.GetElapsedTime() + 3
	end
end

do -- orientation
	prototype.GetSet(META, "Position", Vec2(0, 0))
	prototype.GetSet(META, "Size", Vec2(4, 4))
	prototype.GetSet(META, "MinimumSize", Vec2(4, 4))
	prototype.GetSet(META, "Padding", Rect(0, 0, 0, 0))
	prototype.GetSet(META, "Margin", Rect(0, 0, 0, 0))
	prototype.GetSet(META, "Angle", 0)
	prototype.GetSet(META, "Order", 0)

	prototype.GetSet(META, "ThreeDee", false)
	prototype.GetSet(META, "ThreeDeePosition", Vec3(0,0,0))
	prototype.GetSet(META, "ThreeDeeAngles", Ang3(0,0,0))
	prototype.GetSet(META, "ThreeDeeScale", Vec3(1,1,1))

	do
		prototype.GetSet(META, "Matrix", Matrix44())

		function META:InvalidateMatrix()
			if not self.rebuild_matrix then
				for _, v in ipairs(self:GetChildrenList()) do
					v.rebuild_matrix = true
				end
			end
			self.rebuild_matrix = true
		end

		function META:RebuildMatrix()
			if self:IsWorld() then return end
			if self.rebuild_matrix then
				self.rebuild_matrix = false

				self.Matrix:Identity()

				self:OnPreMatrixBuild()

				if self.ThreeDee then
					local pos, ang, scale = self.ThreeDeePosition, self.ThreeDeeAngles, self.ThreeDeeScale
					if pos then
						self.Matrix:Translate(-pos.y, -pos.x, -pos.z) -- Vec3(left/right, back/forth, down/up)
					end

					if ang then
						self.Matrix:Rotate(-ang.y, 0, 0, 1)
						self.Matrix:Rotate(-ang.z, 0, 1, 0)
						self.Matrix:Rotate(-ang.x, 1, 0, 0)
					end

					if scale then
						local w,h = surface.GetSize()
						local scale2d = (w/h) / 100
						self.Matrix:Scale(scale.x * scale2d, scale.y * scale2d, scale.z)
					end
				end

				self.temp_matrix = self.temp_matrix or Matrix44()
				self.Matrix:Multiply(self.Parent.Matrix, self.temp_matrix)
				self.Matrix, self.temp_matrix = self.temp_matrix, self.Matrix

				self.Matrix:Translate(math.ceil(self.Position.x), math.ceil(self.Position.y), 0)

				if self.Angle ~= 0 then
					local w = (self.Size.x)/2
					local h = (self.Size.y)/2

					self.Matrix:Translate(w, h, 0)
						self.Matrix:SetRotation(Quat():SetAngles(Ang3(0,self.Angle,0)))
					self.Matrix:Translate(-w, -h, 0)
				end

				if not self.DrawPositionOffset:IsZero() then
					self.Matrix:Translate(self.DrawPositionOffset.x, self.DrawPositionOffset.y, 0)
				end

				if self.DrawScaleOffset.x ~= 1 or self.DrawScaleOffset.y ~= 1 then
					self.Matrix:Scale(self.DrawScaleOffset.x, self.DrawScaleOffset.y, 1)
				end

				if not self.DrawSizeOffset:IsZero() or not self.DrawAngleOffset:IsZero() then
					local w = (self.Size.x + self.DrawSizeOffset.x)/2
					local h = (self.Size.y + self.DrawSizeOffset.y)/2

					self.Matrix:Translate(w, h, 0)

					self.Matrix:Rotate(self.DrawAngleOffset.x, 0, 0, 1)
					self.Matrix:Rotate(self.DrawAngleOffset.y, 0, 1, 0)
					self.Matrix:Rotate(self.DrawAngleOffset.z, 1, 0, 0)

					self.Matrix:Translate(-w, -h, 0)
				end

				self.Matrix:Translate(math.ceil(-self.Parent.Scroll.x), math.ceil(-self.Parent.Scroll.y), 0)

				self:OnPostMatrixBuild()

				self.rebuild_matrix = false
			end
		end

		function META:GetMatrix()
			return self.Matrix
		end
	end

	function META:SetPosition(pos)
		if self:HasParent() and self.Parent.TrapChildren and not self.ThreeDee then
			pos:Clamp(Vec2(0, 0), self.Parent.Size - self.Size)
		end

		self:OnPositionChanged(pos)

		self.Position = pos
	end

	function META:SetSize(size)
		if self.StyleSize:IsZero() then
			size.x = math.max(size.x, self.MinimumSize.x)
			size.y = math.max(size.y, self.MinimumSize.y)

			self.Size = size

			self:Layout()
		end
	end

	function META:SetPadding(rect)
		self.Padding = rect
		self:Layout()
	end

	function META:SetMargin(rect)
		self.Margin = rect
		self:Layout()
	end

	function META:WorldToLocal(wpos)
		local lpos = wpos
		for _, v in ipairs(self:GetParentList()) do
			lpos = lpos - v:GetPosition()
			if v:HasParent() then
				wpos = wpos + v.Parent:GetScroll()
			end
		end
		return lpos
	end

	function META:GetWorldPosition()
		local x, y = self.Matrix:GetTranslation()
		return Vec2(x, y)
	end

	function META:SetWorldPosition(wpos)
		self.Matrix:SetTranslation(wpos.x, wpos.y, 0)
	end

	function META:LocalToWorld(lpos)
		local x, y = self.Matrix:GetTranslation()

		return Vec2(x + lpos.x, y + lpos.y)
	end

	local sorter = function(a,b)
		return a.Order > b.Order
	end

	function META:SetOrder(pos)
		self.Order = pos

		local parent = self:GetParent()

		if parent:IsValid() then
			table.sort(parent:GetChildren(), sorter)
			--gui.unrolled_draw = nil
		end
	end

	function META:SetX(x)
		self.Position.x = x
	end
	function META:GetX()
		return self.Position.x
	end

	function META:SetY(y)
		self.Position.y = y
	end
	function META:GetY()
		return self.Position.y
	end

	function META:SetWidth(w)
		self.Size.x = w
		self:Layout()
	end
	function META:GetWidth()
		return self.Size.x
	end

	function META:SetHeight(h)
		self.Size.y = h
		self:Layout()
	end
	function META:GetHeight()
		return self.Size.y
	end

	META.SetW = META.SetWidth
	META.GetW = META.GetWidth

	META.SetH = META.SetHeight
	META.GetH = META.GetHeight

	function META:SetRect(rect)
		self:SetPosition(Vec2(rect.x, rect.y))
		self:SetSize(Vec2(rect.w, rect.h))
	end

	function META:GetRect()
		return Rect(self.Position.x, self.Position.y, self.Size.x, self.Size.y)
	end

	function META:SetRectFast(x,y,w,h)
		self.Position.x = x
		self.Position.y = y
		self.Size.x = w
		self.Size.y = h
	end

	function META:GetRectFast()
		return self.Position.x, self.Position.y, self.Size.x, self.Size.y
	end

	function META:GetWorldRect()
		local rect = Rect(self.Position.x, self.Position.y, self.Size.x, self.Size.y)

		-- convert to world
		rect.w = rect.x + rect.w
		rect.h = rect.y + rect.h

		return rect
	end

	function META:GetWorldRectFast()
		return self.Position.x, self.Position.y, self.Position.x + self.Size.x, self.Position.y + self.Size.y
	end

	function META:CenterX()
		self:SetX((self.Parent:GetWidth() * 0.5) - (self:GetWidth() * 0.5))
	end

	function META:CenterY()
		self:SetY((self.Parent:GetHeight() * 0.5) - (self:GetHeight() * 0.5))
	end

	function META:Center()
		self:CenterY()
		self:CenterX()
	end
end

do -- cached rendering
	prototype.GetSet(META, "CachedRendering", false)

	function META:SetCachedRendering(b)
		self.CachedRendering = b

		if not system.IsOpenGLExtensionSupported("GL_ARB_framebuffer_object") then
			self.CachedRendering = false
		end

		self:MarkCacheDirty()
	end

	function META:MarkCacheDirty()
		if self.CachedRendering then
			self.cache_dirty = true

			if
				(not self.cache_fb or self.cache_texture:GetSize() ~= self.Size) and

				self.Size.x > 1 and
				self.Size.y > 1 and
				self.Size.x < 4096 and
				self.Size.y < 4096
			then
				local fb = render.CreateFrameBuffer()
				fb:SetTexture(1, render.CreateBlankTexture(self.Size))
				fb:SetTexture("depth_stencil", {internal_format = "depth_stencil", size = self.Size})
				fb:CheckCompletness()

				self.cache_fb = fb
				self.cache_texture = fb:GetTexture(1)
			end
		else
			for _, v in ipairs(self:GetParentList()) do
				if v:IsValid() and v.CachedRendering then
					v.cache_dirty = true
				end
			end
		end
		self:InvalidateMatrix()
	end

	function META:IsCacheDirty()
		return self.cache_dirty
	end

	function META:DrawCache()
		self:OnPreDraw()
		surface.SetColor(1, 1, 1, 1)
		surface.SetTexture(self.cache_texture)
		surface.DrawRect(0, 0, self.Size.x, self.Size.y)
		self:OnPostDraw()
	end

	function META:BuildCache()
		if self:IsCacheDirty() then
			self.cache_fb:Begin()
			--self.cache_fb:Clear()

			local x,y = self.Matrix:GetTranslation()
			self.Matrix:Translate(-x, -y, 0)
			surface.PushMatrix(nil, true)

			if self:IsDragging() or self:IsInsideParent() then
				self:OnDraw()
			end

			--surface.Translate(-self.Scroll.x, -self.Scroll.y)

			for _, v in ipairs(self:GetChildren()) do
				if v.Visible then
					v:Draw(true)
				end
			end

			surface.PopMatrix()

			self.Matrix:Translate(x, y, 0)
			self.cache_fb:End()

			self.cache_dirty = false
			self.updated_cache = true
		end
	end
end

do -- scrolling
	prototype.GetSet(META, "Scrollable", false)
	prototype.GetSet(META, "Scroll", Vec2(0, 0))
	prototype.GetSet(META, "ScrollFraction", Vec2(0, 0))

	function META:SetScroll(vec)
		local size = self:GetSizeOfChildren()

		self.Scroll = vec:GetClamped(Vec2(0), size - self.Size)

		if size.x < self.Size.x then self.Scroll.x = 0 end
		if size.y < self.Size.y then self.Scroll.y = 0 end

		self.ScrollFraction = self.Scroll / (size - self.Size)
		self:OnScroll(self.ScrollFraction)

		self:MarkCacheDirty()
	end

	function META:SetScrollFraction(frac)
		local size = self:GetSizeOfChildren()

		self.Scroll = frac * size
		self.Scroll:Clamp(Vec2(0, 0), size - self.Size)
		self.ScrollFraction = frac

		self:OnScroll(self.ScrollFraction)

		self:MarkCacheDirty()
	end

	function META:StartScrolling(button)
		self.scroll_button = button
		self.scroll_drag_pos = self:GetScroll() + self:GetMousePosition()
	end

	function META:StopScrolling()
		self.scroll_button = nil
		self.scroll_drag_pos = nil
	end

	function META:IsScrolling()
		return self.scroll_button ~= nil
	end

	function META:CalcScrolling()
		if not self:IsScrolling() then return end

		local size = self:GetSizeOfChildren()

		if size.x < self.Size.x and size.y < self.Size.y then self:StopScrolling() return end

		if input.IsMouseDown(self.scroll_button) then
			self:SetScroll(self.scroll_drag_pos - self:GetMousePosition())
			self:OnScroll(self.ScrollFraction)
		else
			self:StopScrolling()
		end
	end
end

do -- drag drop
	prototype.GetSet(META, "Draggable", false)
	prototype.GetSet(META, "DragDrop", false)
	prototype.GetSet(META, "DragMinDistance", 20)

	function META:StartDragging(button)
		self.drag_world_pos = gui.mouse_pos:Copy()
		self.drag_local_pos = self:GetMousePosition():Copy()
		self.drag_stop_button = button
	end

	function META:StopDragging()
		self.drag_world_pos = nil
		self.drag_local_pos = nil
		self.drag_panel_start_pos = nil
		self.drag_last_hover = nil
		self.dragged_out_of_min_distance = nil
	end

	function META:IsDragging()
		return self.drag_world_pos ~= nil
	end

	function META:CalcDragging()
		if not self.drag_world_pos then return end

		if not self.drag_panel_start_pos then
			self.drag_panel_start_pos = self:GetPosition()
		end

		local drag_pos = Vec2(surface.ScreenToWorld(self.drag_world_pos:Unpack()))
		local pos = self.drag_panel_start_pos + self:GetMousePosition() - drag_pos

		if not self.dragged_out_of_min_distance and pos:Distance(self.drag_panel_start_pos) < self.DragMinDistance then
			return
		else
			self.dragged_out_of_min_distance = true
		end

		self:SetPosition(pos)

		local panel = gui.GetHoveringPanel(nil, self)

		local drop_pos = panel:GetMousePosition()

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

			--self:SetPosition(drop_pos - self.drag_local_pos)
			self:OnParentLand(panel)
			panel:OnChildDrop(self, drop_pos)

			self:StopDragging()
		end

		self:MarkCacheDirty()
	end

	function META:OnDraggedChildEnter(child, drop_pos)
		--print("enter", self, drop_pos, child)
	end

	function META:OnDraggedChildExit(child, drop_pos)
		--print("left", self, drop_pos, child)
	end

	function META:OnParentLand(parent)

	end

	function META:OnPanelHover(panel, drop_pos)

	end

	function META:OnChildDrop(child, pos)

	end
end

do -- magnet snap
	prototype.GetSet(META, "SnapWhileDragging", false)

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

	function META:SnapPosition(panel)
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

	function META:SnapToClosestPanel()
		local tbl = {}

		for k,v in pairs(self:GetParent():GetChildren()) do tbl[k] = v end

		local wpos = self:GetWorldPosition()

		table.sort(tbl, function(a, b) return a:GetWorldPosition():Distance(wpos) < b:GetWorldPosition():Distance(wpos) end)

		for _, v in ipairs(tbl) do
			if v:IsVisible() and v ~= self then
				self:SnapPosition(v)
			end
		end
		self:SnapPosition(self:GetParent())
	end
end

do -- animations
	-- these are useful for animations
	prototype.GetSet(META, "DrawSizeOffset", Vec2(0, 0))
	prototype.GetSet(META, "DrawScaleOffset", Vec2(1, 1))
	prototype.GetSet(META, "DrawPositionOffset", Vec2(0, 0))
	prototype.GetSet(META, "DrawAngleOffset", Ang3(0,0,0))
	prototype.GetSet(META, "DrawColor", Color(0,0,0,0))
	prototype.GetSet(META, "DrawAlpha", 1)

	local parent_layout = {
		DrawSizeOffset = true,
		DrawScaleOffset = true,
		DrawAngleOffset = true,
		DrawPositionOffset = true,
		Size = true,
		Position = true,
		Angle = true,
	}

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

	function META:CalcAnimations()
		for i, animation in ipairs(self.animations) do
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

				if parent_layout[animation.var] and self:HasParent() and not self.Parent:IsWorld() then
					self.Parent:Layout(true)
				else
					self:Layout(true)
				end

				if alpha >= 1 then
					if animation.callback then
						if animation.callback(self) ~= false then
							animation.func(self, from)
						end
					else
						animation.func(self, from)
					end

					table.remove(self.animations, i)
					break
				else
					self:MarkCacheDirty()
				end
			end
		end
	end

	function META:StopAnimations()
		for _, animation in ipairs(self.animations) do
			if animation.callback then
				if animation.callback(self) ~= false then
					animation.func(self, animation.from)
				end
			else
				animation.func(self, animation.from)
			end
		end

		table.clear(self.animations)

		self:UpdateAnimations()
	end

	function META:IsAnimating()
		return #self.animations ~= 0
	end

	function META:Animate(var, to, time, operator, pow, set, callback)
		for _, v in ipairs(self.animations) do
			if v.var == var then
				v.alpha = 0
				return
			end
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

		table.insert(self.animations, {
			operator = operator,
			from = from,
			to = to,
			time = time or 0.25,
			var = var,
			func = self["Set" .. var],
			start_time = system.GetElapsedTime(),
			pow = pow,
			callback = callback,
			pausers =  pausers,
			alpha = 0,
		})
	end
end

do -- resizing
	prototype.GetSet(META, "ResizeBorder", Rect(8,8,8,8))
	prototype.GetSet(META, "Resizable", false)

	function META:GetResizeLocation(pos)
		pos = pos or self:GetMousePosition()
		local loc = self:GetMouseLocation(pos)

		if loc ~= "center" then
			return loc
		end
	end

	function META:StartResizing(pos, button)
		local loc = self:GetResizeLocation(pos)
		if loc then
			self.resize_start_pos = self:GetMousePosition():Copy()
			self.resize_location = loc
			self.resize_prev_mouse_pos = gui.mouse_pos:Copy()
			self.resize_prev_pos = self:GetPosition():Copy()
			self.resize_prev_size = self:GetSize():Copy()
			self.resize_button = button
			return true
		end
	end

	function META:StopResizing()
		self.resize_start_pos = nil
	end

	function META:IsResizing()
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

	function META:CalcResizing()
		if self.Resizable then
			local loc = self:GetResizeLocation(self:GetMousePosition())
			if location2cursor[loc] then
				self:SetCursor(location2cursor[loc])
			else
				self:SetCursor()
			end
		end

		if self.resize_start_pos then

			if self.resize_button ~= nil and not input.IsMouseDown(self.resize_button) then
				self:StopResizing()
				return
			end

			local diff = self:GetMousePosition() - self.resize_start_pos
			local diff_world = gui.mouse_pos - self.resize_prev_mouse_pos
			local loc = self.resize_location
			local prev_size = self.resize_prev_size:Copy()
			local prev_pos = self.resize_prev_pos:Copy()

			if loc == "right" or loc == "top_right" then
				prev_size.x = prev_size.x + diff.x
			elseif loc == "bottom" or loc == "bottom_left" then
				prev_size.y = prev_size.y + diff.y
			elseif loc == "bottom_right" then
				prev_size = prev_size + diff
			end

			if loc == "top" or loc == "top_right" then
				prev_pos.y = prev_pos.y + math.min(diff_world.y, prev_size.y - self.MinimumSize.y)
				prev_size.y = prev_size.y - diff_world.y
			elseif loc == "left" or loc == "bottom_left" then
				prev_pos.x = prev_pos.x + math.min(diff_world.x, prev_size.x - self.MinimumSize.x)
				prev_size.x = prev_size.x - diff_world.x
			elseif loc == "top_left" then
				prev_pos = prev_pos + diff_world
				prev_size = prev_size - diff_world
			end

			if self:HasParent() and not self.ThreeDee then
				prev_pos.x = math.max(prev_pos.x, 0)
				prev_pos.y = math.max(prev_pos.y, 0)

				prev_size.x = math.min(prev_size.x, self.Parent.Size.x - prev_pos.x)
				prev_size.y = math.min(prev_size.y, self.Parent.Size.y - prev_pos.y)
			end

			self:SetPosition(prev_pos)
			self:SetSize(prev_size)
			if self.LayoutSize then
				self:SetLayoutSize(prev_size:Copy())
			end
		end
	end
end

do -- mouse
	prototype.GetSet(META, "IgnoreMouse", false)
	prototype.GetSet(META, "FocusOnClick", false)
	prototype.GetSet(META, "AlwaysCalcMouse", false)
	prototype.GetSet(META, "AlwaysReceiveMouseInput", false)
	prototype.GetSet(META, "SendMouseInputToPanel", NULL)

	prototype.GetSet(META, "MouseHoverTime", 0)
	prototype.GetSet(META, "MouseHoverTimeTrigger", 1)
	prototype.GetSet(META, "AlphaMouseCheck", false)

	do
		gui.active_tooltip = NULL

		prototype.GetSet(META, "Tooltip", "")

		function META:ShowTooltip()
			local tooltip = gui.CreatePanel("text_button", nil, "gui_tooltip")
			tooltip:SetSkin(self:GetSkin())
			tooltip:SetPosition(self:GetWorldPosition())
			tooltip:SetMargin(Rect()+4)
			tooltip:SetText(self.Tooltip)
			tooltip:SizeToText()
			tooltip:SetIgnoreMouse(true)
			self:CallOnRemove(function()
				gui.RemovePanel(tooltip)
			end)
			gui.active_tooltip = tooltip
			self.my_tooltip = tooltip
		end

		function META:CloseTooltip()
			gui.RemovePanel(self.my_tooltip)
		end
	end


	function META:BringMouse()
		window.SetMousePosition(self:GetWorldPosition() + self:GetSize() / 2)
	end

	function META:IsMouseOver()
		return self:IsDragging() or self:IsResizing() or self.mouse_over and gui.hovering_panel == self
	end

	function META:GlobalMouseCapture(b)
		self.mouse_capture = b
	end

	function META:GetMouseLocation(pos) -- rename this function
		pos = pos or self:GetMousePosition()
		local offset = self.ResizeBorder

		local siz = self:GetSize()

		if
			(pos.y > 0 and pos.y < offset.h) and -- top
			(pos.x > 0 and pos.x < offset.w) -- left
		then
			return "top_left"
		end

		if
			(pos.y > 0 and pos.y < offset.h) and -- top
			(pos.x > siz.x - offset.w and pos.x < siz.x) -- right
		then
			return "top_right"
		end


		if
			(pos.y > siz.y - offset.h and pos.y < siz.y) and -- bottom
			(pos.x > 0 and pos.x < offset.w) -- left
		then
			return "bottom_left"
		end

		if
			(pos.y > siz.y - offset.h and pos.y < siz.y) and -- bottom
			(pos.x > siz.x - offset.w and pos.x < siz.x) --right
		then
			return "bottom_right"
		end

		--

		if pos.x > 0 and pos.x < offset.w then
			return "left"
		end

		if pos.x > siz.x - offset.w and pos.x < siz.x then
			return "right"
		end

		if pos.y > siz.y - offset.h and pos.y < siz.y then
			return "bottom"
		end

		if pos.y > 0 and pos.y < offset.h then
			return "top"
		end

		return "center"
	end

	function META:CalcMouse()
		if
			self:HasParent() and
			not self.Parent:IsWorld() and
			not self.Parent.mouse_over and
			not self:IsDragging() and
			not self:IsScrolling() and
			not self.AlwaysCalcMouse
		then

			if self.mouse_just_entered then
				self:OnMouseExit()
				self.mouse_just_entered = false
			end

			self.mouse_over = false

			return
		end

		local x, y = surface.ScreenToWorld(gui.mouse_pos.x, gui.mouse_pos.y)

		self.MousePosition.x = x
		self.MousePosition.y = y

		local alpha = 1

		--[[if self.AlphaMouseCheck and not self.NinePatch and self.NinePatchRect:IsZero() and self.Texture:IsValid() and self.Texture ~= render.GetWhiteTexture() and not self.Texture:IsLoading() then
			local x = (x / self.Size.x)
			local y = (y / self.Size.y)

			x = x * self.Texture:GetSize().x
			y = y * self.Texture:GetSize().y

			x = math.clamp(math.floor(x), 1, self.Texture:GetSize().x-1)
			y = math.clamp(math.floor(y), 1, self.Texture:GetSize().y-1)

			alpha = select(4, self.Texture:GetPixelColor(x, y)) / 255
		end]]

		if x > 0 and x < self.Size.x and y > 0 and y < self.Size.y and alpha > 0 then
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
				self.MouseHoverTime = system.GetElapsedTime()
			end

			if self.MouseHoverTime + self.MouseHoverTimeTrigger < system.GetElapsedTime() then
				if not self.mouse_hover_triggered then
					self:OnMouseHoverTrigger(true, x, y)
					self.mouse_hover_triggered = true
					if self.Tooltip ~= "" then
						self:ShowTooltip()
					end
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

			if self.mouse_hover_triggered and not self:HasParent(gui.active_tooltip) then
				self:OnMouseHoverTrigger(false, x, y)
				self.mouse_hover_triggered = false
				if self.Tooltip ~= "" then
					self:CloseTooltip()
				end
			end

			if self.mouse_capture then
				self:OnMouseMove(x, y)
			end
		end
	end

	function META:MouseInput(button, press)
		if self.GreyedOut then return end

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

		else
			if button == "button_2" then
				self:OnRightClick()
			end
			self:StopDragging()
		end

		self:OnMouseInput(button, press)

		self:MarkCacheDirty()
	end

	function META:GlobalMouseInput(button, press)
		if self.Scrollable and self.mouse_over then
			if button == "button_3" then
				self:StartScrolling(button)
			end

			if button == "mwheel_down" then
				self:SetScroll(self:GetScroll() + Vec2(0, 20))
			elseif button == "mwheel_up" then
				self:SetScroll(self:GetScroll() + Vec2(0, -20))
			end
		end

		self:OnGlobalMouseInput(button, press)
	end

	function META:KeyInput(button, press)
		if self.GreyedOut then return end

		local b

		if self:OnPreKeyInput(button, press) ~= false then
			b = self:OnKeyInput(button, press)
			self:OnPostKeyInput(button, press)
		end

		self:MarkCacheDirty()

		return b
	end

	function META:CharInput(char)
		self:MarkCacheDirty()
		return self:OnCharInput(char)
	end
end

do -- layout
	META.layout_count = 0

	prototype.GetSet(META, "LayoutSize", nil)
	prototype.GetSet(META, "IgnoreLayout", false)
	prototype.GetSet(META, "CollisionGroup", "none")

	local origin

	local function sort(a, b)
		return math.abs(a.point-origin) < math.abs(b.point-origin)
	end

	function META:RayCast(panel, x,y, collide, always)
		local dir_x = x - panel.Position.x
		local dir_y = y - panel.Position.y

		local found

		if collide then
			found = {}
			local i = 1

			local panel_left, panel_top, panel_right, panel_bottom = panel:GetWorldRectFast()

			for _, child in ipairs(self:GetChildren()) do
				if
					child ~= panel and
					(always or child.laid_out) and
					child.Visible and
					not child.ThreeDee and
					not child.IgnoreLayout and
					(panel.CollisionGroup == "none" or panel.CollisionGroup == child.CollisionGroup) and
					(panel.lol == nil or panel.lol ~= child.lol)
				then
					local child_left, child_top, child_right, child_bottom = child:GetWorldRectFast()

					if
						child_left <= panel_left and
						child_right >= panel_right
						or
						child_left >= panel_left and
						child_right <= panel_right
						or
						child_right > panel_right and
						child_left < panel_right
						or
						child_right > panel_left and
						child_left < panel_left
					then
						if dir_y > 0 and child_top > panel_top then
							found[i] = {child = child, point = child_top}
							i = i + 1
						elseif dir_y < 0 and child_bottom < panel_bottom then
							found[i] = {child = child, point = child_bottom}
							i = i + 1
						end
					end

					if
						child_top <= panel_top and
						child_bottom >= panel_bottom
						or
						child_top >= panel_top and
						child_bottom <= panel_bottom
						or
						child_bottom > panel_bottom and
						child_top < panel_bottom
						or
						child_bottom > panel_top and
						child_top < panel_top
					then
						if dir_x > 0 and child_right > panel_right then
							found[i] = {child = child, point = child_left}
							i = i + 1
						elseif dir_x < 0 and child_left < panel_left then
							found[i] = {child = child, point = child_right}
							i = i + 1
						end
					end
				end
			end

			if dir_y > 0 then
				origin = panel_bottom
			elseif dir_y < 0 then
				origin = panel_top
			elseif dir_x > 0 then
				origin = panel_right
			elseif dir_x < 0 then
				origin = panel_left
			end

			table.sort(found, sort)
		end

		if found and found[1] then
			local child = found[1].child

			x = child.Position.x
			y = child.Position.y

			if dir_x < 0 then
				y = panel:GetY()
				x = x + child:GetWidth() + panel.Padding:GetRight()
			elseif dir_x > 0 then
				y = panel:GetY()
				x = x - panel:GetWidth() - panel.Padding:GetLeft()
			elseif dir_y < 0 then
				x = panel:GetX()
				y = y + child:GetHeight() + panel.Padding:GetBottom()
			elseif dir_y > 0 then
				x = panel:GetX()
				y = y - panel:GetHeight() - panel.Padding:GetTop()
			end
		else
			if dir_x < 0 then
				x = x + panel.Padding:GetRight()
				x = x + self.Margin:GetRight()
			elseif dir_x > 0 then
				x = x - panel.Padding:GetLeft()
				x = x - self.Margin:GetLeft()
			elseif dir_y < 0 then
				y = y + panel.Padding:GetBottom()
				y = y + self.Margin:GetBottom()
			elseif dir_y > 0 then
				y = y - panel.Padding:GetTop()
				y = y - self.Margin:GetTop()
			end

			x = math.max(x, 0)
			y = math.max(y, 0)
		end

		return Vec2(x, y), found and found[1] and found[1].child
	end

	function META:ExecuteLayoutCommands()
	--	if self:HasParent() then self = self.Parent end

		if not self.layout_us then return end

		for _, child in ipairs(self:GetChildren()) do
			if child.layout_commands then
				if child.LayoutSize then
					child:SetSize(child.LayoutSize:Copy())
				end
				child.laid_out = false
			end
		end

		for _, child in ipairs(self:GetChildren()) do
			if child.layout_commands then
				for _, cmd in ipairs(child.layout_commands) do
					if cmd == "layout_children" then
						for _, child in ipairs(self:GetChildren()) do
							child:Layout(true)
						end
					elseif cmd == "collide" then
						child:Collide(true)
					elseif cmd == "no_collide" then
						child:Collide(false)
					elseif cmd == "size_to_width" then
						child:SizeToWidth()
					elseif cmd == "size_to_height" then
						child:SizeToHeight()
					elseif cmd == "fill" then
						child:MoveUp()
						child:MoveLeft()
						child:FillX()
						child:FillY()
					elseif cmd == "fill_x" then
						child:CenterXSimple()
						child:FillX()
					elseif cmd == "fill_y" then
						child:CenterYSimple()
						child:FillY()
					elseif cmd == "center" then
						child:Center()
					elseif cmd == "center_left" then
						child:MoveLeft()
						child:CenterYSimple()
					elseif cmd == "center_right" then
						child:MoveRight()
						child:CenterYSimple()
					elseif cmd == "center_simple" then
						child:CenterSimple()
					elseif cmd == "center_x" then
						child:CenterX()
					elseif cmd == "center_x_simple" then
						child:CenterXSimple()
					elseif cmd == "center_y_simple" then
						child:CenterYSimple()
					elseif cmd == "center_x_frame" then
						if child:CenterXFrame() then break end
					elseif cmd == "center_y" then
						child:CenterY()
					elseif cmd == "top" or cmd == "up" then
						child:MoveUp()
					elseif cmd == "left" then
						child:MoveLeft()
					elseif cmd == "bottom" or cmd == "down" then
						child:MoveDown()
					elseif cmd == "right" then
						child:MoveRight()
					elseif cmd == "gmod_fill" then
						child:CenterSimple()
						child:MoveUp()
						child:MoveLeft()
						child:FillX()
						child:FillY()
					elseif cmd == "gmod_left" then
						child:CenterSimple()
						child:MoveLeft()
						child:FillY()
					elseif cmd == "gmod_right" then
						child:CenterSimple()
						child:MoveRight()
						child:FillY()
					elseif cmd == "gmod_top" then
						child:CenterSimple()
						child:MoveUp()
						child:FillX()
					elseif cmd == "gmod_bottom" then
						child:CenterSimple()
						child:MoveDown()
						child:FillX()
					elseif typex(cmd) == "vec2" then
						child:SetSize(cmd:Copy())
					end
				end
			end
		end
	end

	function META:Layout(now)
		if now and (self.LayoutWhenInvisible or not self.draw_no_draw) then

			if not self.in_layout then
				self.in_layout = true
				self:OnLayout(self:GetLayoutScale(), self:GetSkin())
				self.in_layout = false
			end

			self:ExecuteLayoutCommands()
			if self.Stack then
				self:StackChildren()
			end

			for _, v in ipairs(self:GetChildren()) do
				v.layout_me = true
			end

			self.updated_layout = true
			self.layout_count = (self.layout_count or 0) + 1

			self.last_children_size = nil

			self:MarkCacheDirty()

			self.layout_me = false
		else
			self.layout_me = true
		end
	end

	function META:CalcLayout()
		if self.layout_me or gui.layout_stress then
			self:Layout(true)
		end
	end

	function META:SetupLayout(...)
		if self:HasParent() then self.Parent:Layout() end
		self:Layout(true)

		if ... then
			self.layout_commands = {...}
			self.LayoutSize = self:GetSize():Copy()
			self.Parent.layout_us = true
		else
			self.layout_commands = nil
			self.Parent.layout_us = nil
			self.LayoutSize = nil
		end

		event.Delay(0, function() self:Layout() end, nil, self) -- FIX ME
	end

	do -- layout commands

		function META:ResetLayout()
			self.laid_out = false

			for _, child in ipairs(self:GetChildren()) do
				if child.LayoutSize then
					child:SetSize(child.LayoutSize:Copy())
				end
				child.laid_out = false
			end
		end

		META.layout_collide = true

		function META:Collide()
			self.layout_collide = true
		end

		function META:NoCollide()
			self.layout_collide = false
		end

		function META:SizeToWidth()
			local parent = self:GetParent()

			local ox,oy,ow,oh = self:GetRectFast()
			self:SetHeight(parent:GetHeight())
			self:SetWidth(1)
			self:SetX(parent:GetWidth())
			self:SetY(0)

			local pos, pnl = self:RayCast(self, 1, self.Position.y, self.layout_collide)
			self:SetRectFast(ox,oy,ow,oh)

			self:SetWidth(pos.x + self.Margin:GetRight() + (pnl and pnl.Padding:GetRight() or 0))

			self.laid_out = true
		end

		function META:SizeToHeight()
			local parent = self:GetParent()

			local ox,oy,ow,oh = self:GetRectFast()

			--self:SetWidth(parent:GetWidth())
			self:SetHeight(1)
			self:SetY(parent:GetHeight())
			self:SetX(0)

			local pos, pnl = self:RayCast(self, self.Position.x, 1, self.layout_collide)

			self:SetRectFast(ox,oy,ow,oh)

			--self:SetHeight(left.y)
			self:SetHeight(pos.y + self.Margin.y + (pnl and pnl.Padding:GetBottom() or 0))

			self.laid_out = true
		end

		function META:FillX(percent)
			local parent = self:GetParent()

			self:SetWidth(1)

			local left = parent:RayCast(self, 0, self.Position.y, self.layout_collide)
			local right = parent:RayCast(self, parent:GetWidth(), self.Position.y, self.layout_collide)
			right.x = right.x - left.x + 1

			local x = left.x
			local w = right.x

			local min_width = self.MinimumSize.x

			if percent then
				x = math.max(math.lerp(percent*0.5, left.x, right.x + self:GetWidth()), min_width) - min_width + left.x
				w = w-x*2 + left.x*2
				if w < min_width then
					x = -left.x
					w = right.x
				end
			end

			self:SetX(math.max(x, left.x)) -- HACK???
			self:SetWidth(math.max(w, min_width))

			self.laid_out = true
		end

		function META:FillY(percent)
			local parent = self:GetParent()

			self:SetHeight(1)

			local top = parent:RayCast(self, self.Position.x, 0, self.layout_collide)
			local bottom = parent:RayCast(self, self.Position.x, parent:GetHeight(), self.layout_collide)
			bottom.y = bottom.y - top.y + 1

			local y = top.y
			local h = bottom.y

			local min_height = self.MinimumSize.y

			if percent then
				y = math.max(math.lerp(percent, top.y, bottom.y + self:GetHeight()), min_height/2) - min_height/2 + top.y
				h = h-y*2 + top.y*2
				if h < min_height then
					y = -top.y
					h = bottom.y
				end
			end

			self:SetY(math.max(y, top.y)) -- HACK???
			self:SetHeight(math.max(h, min_height))

			self.laid_out = true
		end

		function META:Center()
			self:CenterX()
			self:CenterY()
		end

		function META:CenterX()
			local parent = self:GetParent()

			local left = parent:RayCast(self, 0, self.Position.y, self.layout_collide)
			local right = parent:RayCast(self, parent.Size.x, left.y, self.layout_collide)

			self:SetX(math.lerp(0.5, left.x, right.x))

			self.laid_out = true
		end

		function META:CenterY()
			local parent = self:GetParent()

			local top = parent:RayCast(self, self.Position.x, 0, self.layout_collide)
			local bottom = parent:RayCast(self, top.x, parent:GetHeight(), self.layout_collide)
			self:SetY(top.y + (bottom.y/2 - self:GetHeight()/2) - self.Padding:GetTop() + self.Padding:GetBottom())

			self.laid_out = true
		end


		function META:CenterXSimple()
			local parent = self:GetParent()

			self:SetX(parent:GetWidth() / 2 - self:GetWidth() / 2)

			self.laid_out = true
		end

		function META:CenterYSimple()
			local parent = self:GetParent()

			self:SetY(parent:GetHeight() / 2 - self:GetHeight() / 2)

			self.laid_out = true
		end

		function META:CenterSimple()
			local parent = self:GetParent()

			local laid_out

			if parent:GetWidth() ~= math.huge then
				self:SetX(parent:GetWidth() / 2 - self:GetWidth() / 2)
				laid_out = true
			end

			if parent:GetHeight() ~= math.huge then
				self:SetY(parent:GetHeight() / 2 - self:GetHeight() / 2)
				laid_out = true
			end

			self.laid_out = laid_out
		end

		function META:CenterXFrame()
			local parent = self:GetParent()

			local left = parent:RayCast(self, 0, self.Position.y, self.layout_collide)
			local right = parent:RayCast(self, parent:GetWidth(), left.y, self.layout_collide)

			if
				self:GetX()+self:GetWidth()+self.Padding:GetRight() < right.x+self:GetWidth()-self.Padding:GetRight() and
				self:GetX()-self.Padding.x > left.x
			then
				self:SetX(parent:GetWidth() / 2 - self:GetWidth() / 2)
			end

			self.laid_out = true
		end

		function META:MoveUp()
			local parent = self:GetParent()

			if not self.laid_out then
				self:SetY(parent:GetHeight() == math.huge and 999999999999 or parent:GetHeight()) -- :(
			end

			self:SetY(math.max(self:GetY(), 1))
			self:SetY(parent:RayCast(self, self.Position.x, 0, self.layout_collide).y)

			self.laid_out = true
		end

		function META:MoveLeft()
			local parent = self:GetParent()

			if not self.laid_out then
				self:SetX(parent:GetWidth() == math.huge and 999999999999 or parent:GetWidth()) -- :(
			end

			self:SetX(math.max(self:GetX(), 1))
			self:SetX(parent:RayCast(self, 0, self.Position.y, self.layout_collide).x)

			self.laid_out = true
		end

		function META:MoveDown()
			local parent = self:GetParent()

			if not self.laid_out then
				self:SetY(0 - self:GetHeight())
			end

			self:SetY(math.max(self:GetY(), 1))
			self:SetY(parent:RayCast(self, self.Position.x, parent:GetHeight() - self:GetHeight(), self.layout_collide).y)

			self.laid_out = true
		end

		function META:MoveRight()
			local parent = self:GetParent()

			if not self.laid_out then
				self:SetX(0 - self:GetWidth())
			end

			self:SetX(math.max(self:GetX(), 1))
			self:SetX(parent:RayCast(self, parent:GetWidth() - self:GetWidth(), self.Position.y, self.layout_collide).x)

			self.laid_out = true
		end

		function META:MoveRightOf(panel)
			self:SetY(panel:GetY())
			self:SetX(panel:GetX() + panel:GetWidth())

			self.laid_out = true
		end

		function META:MoveDownOf(panel)
			self:SetX(panel:GetX())
			self:SetY(panel:GetY() + panel:GetHeight())

			self.laid_out = true
		end

		function META:MoveLeftOf(panel)
			self:SetY(panel:GetY())
			self:SetX(panel:GetX() - self:GetWidth())

			self.laid_out = true
		end

		function META:MoveUpOf(panel)
			self:SetX(panel:GetX())
			self:SetY(panel:GetY() - self:GetHeight())

			self.laid_out = true
		end
	end
end

do -- stacking
	prototype.GetSet(META, "ForcedStackSize", Vec2(0, 0))

	prototype.GetSet(META, "StackRight", true)
	prototype.GetSet(META, "StackDown", true)

	prototype.GetSet(META, "SizeStackToWidth", false)
	prototype.GetSet(META, "SizeStackToHeight", false)
	prototype.IsSet(META, "Stackable", true)
	prototype.IsSet(META, "Stack", false)

	function META:StackChildren()
		local w = 0
		local h
		local pad = self:GetMargin()

		for _, pnl in ipairs(self:GetChildren()) do
			if pnl:IsStackable() then
				local siz = pnl:GetSize():Copy()

				if self.ForcedStackSize.x ~= 0 then
					siz.x = self.ForcedStackSize.x
				end

				if self.ForcedStackSize.y ~= 0 then
					siz.y = self.ForcedStackSize.y
				end

				siz.x = siz.x + pnl.Padding.w
				siz.y = siz.y + pnl.Padding.h

				if self.StackRight then
					h = h or siz.y
					w = w + siz.x

					if self.StackDown and w > self:GetWidth() then
						h = h + siz.y
						w = siz.x
					end

					pnl.Position.x = w + pad.x - siz.x + pnl.Padding.x
					pnl.Position.y = h + pad.y - siz.y + pnl.Padding.y
				else
					h = h or 0
					h = h + siz.y

					w = siz.x > w and siz.x or w

					pnl.Position.x = pad.x + pnl.Padding.x
					pnl.Position.y = h + pad.y - siz.y + pnl.Padding.y
				end

				if not self.ForcedStackSize:IsZero() then
					local siz = self.ForcedStackSize

					if self.SizeStackToWidth then
						siz.x = self:GetWidth()
					end

					if self.SizeStackToHeight then
						siz.x = self:GetHeight()
					end

					pnl:SetSize(Vec2(siz.x - pad.y * 2, siz.y))
				else
					if self.SizeStackToWidth then
						pnl:SetWidth(self:GetWidth() - pad.x * 2)
					end

					if self.SizeStackToHeight then
						pnl:SetHeight(self:GetHeight() - pad.y * 2)
					end
				end
			end
		end

		if self.SizeStackToWidth then
			w = self:GetWidth() - pad.x * 2
		end

		h = h or 0

		return Vec2(w, h) + pad:GetSize()
	end
end

do -- skin
	prototype.GetSet(META, "Style")
	prototype.GetSet(META, "Skin")
	prototype.GetSet(META, "LayoutScale")

	function META:SetLayoutScale(scale)
		self.LayoutScale = scale
		for _, v in ipairs(self:GetChildrenList()) do
			v.LayoutScale = scale
		end
	end

	function META:GetLayoutScale()
		return self.LayoutScale or self:GetSkin():GetScale()
	end

	function META:HasSkin(name)
		return self.Skin and self:GetSkin().name == name
	end

	function META:SetSkin(skin)
		if type(skin) == "string" then
			skin = gui.GetRegisteredSkin(skin).skin
		end

		self.Skin = skin

		if skin then
			self.LayoutScale = skin:GetScale()
			self:ReloadStyle()
			self:OnStyleChanged(skin)

			for _, v in ipairs(self:GetChildrenList()) do
				v.LayoutScale = skin:GetScale()
				v.Skin = skin
				v:ReloadStyle()
				v:OnStyleChanged(skin)
			end
		end
	end

	function META:GetSkin()
		return self.Skin or gui.skin
	end

	function META:SetStyle(name)
		self.Style = name

		self.style_nodraw = false

		if name == "nodraw" then
			self.style_nodraw = true
		elseif name == "none" then
			self:SetNinePatch(false)
			self:SetNinePatchRect(Rect(0, 0, 0, 0))
			self:SetNinePatchCornerSize(4)
			self:SetStyleSize(Vec2(0, 0))
			self:SetTexture(render.GetWhiteTexture())
		else
			self.style_translation = self.style_translation or {}
			name = self.style_translation[name] or name

			local skin = self:GetSkin()

			if skin[name] then
				self:SetupStyle(skin[name])
			end
		end

		self:MarkCacheDirty()
	end

	function META:SetStyleTranslation(from, to)
		self.style_translation = self.style_translation or {}
		self.style_translation[from] = to
	end

	prototype.GetSet(META, "NinePatch", false)
	prototype.GetSet(META, "NinePatchRect", Rect(0, 0, 0, 0))
	prototype.GetSet(META, "NinePatchCornerSize", 4)
	prototype.GetSet(META, "StyleSize", Vec2(0, 0))

	function META:SetStyleSize(vec)
		if not vec:IsZero() then
			self:SetSize(vec)
		end
		self.StyleSize = vec
	end

	function META:SetupStyle(tbl)
		tbl = tbl or {}

		if tbl.ninepatch ~= nil then self:SetNinePatch(tbl.ninepatch) end
		if tbl.color then self:SetColor(tbl.color:Copy()) end
		if tbl.texture then self:SetTexture(tbl.texture) end
		if tbl.texture_rect then self:SetNinePatchRect(tbl.texture_rect:Copy()) end
		if tbl.corner_size then self:SetNinePatchCornerSize(tbl.corner_size) end

		local skin = self:GetSkin()

		local scale = tbl.size and tbl.size:Copy() or self.StyleSize

		if skin.pixel_scale then
			scale = scale * skin.pixel_scale
		end

		self:SetStyleSize(scale)
	end

	function META:ReloadStyle()

		local style = self:GetStyle()

		if style then
			self:SetStyle("none")
			self:SetStyle(style)

			if self.GetText then
				self:SetText(self:GetText())
			end
		end

		self:Layout()
	end
end

do -- events
	function META:OnDraw()
		if self.NoDraw or self.style_nodraw then return end

		surface.SetAlphaMultiplier(self.DrawAlpha)
		surface.SetColor(
			self.Color.r + self.DrawColor.r,
			self.Color.g + self.DrawColor.g,
			self.Color.b + self.DrawColor.b,
			self.Color.a + self.DrawColor.a
		)
		surface.SetTexture(self.Texture)

		self:DrawRect()

		if gui.debug_layout then
			surface.SetDefaultFont()
			surface.DrawText("layout count " .. self.layout_count)
			--surface.SetWhiteTexture()
			--surface.SetColor(1,0,0,1)
			--surface.DrawRect(self:GetMousePosition().x, self:GetMousePosition().y, 2, 2)
		end
	end
--[[
	function META:OnUnParent()
		gui.unrolled_draw = nil
	end

	function META:OnChildAdd(child)
		gui.unrolled_draw = nil
--		self:Layout()
		--child:Layout()
	end
	]]

	function META:OnRemove()
		gui.panels[self] = nil

		for _, v in pairs(self:GetChildrenList()) do
			v:Remove()
		end

		-- this is important!!
		self:UnParent()
		self:OnUnfocus()
	end

	function META:OnSystemFileDrop(path) end

	function META:OnPreDraw() end
	function META:OnPostDraw() end

	function META:OnPostMatrixBuild() end
	function META:OnPreMatrixBuild() end

	function META:OnFocus() end
	function META:OnUnfocus() end

	function META:OnMouseEnter(x, y) end
	function META:OnMouseExit(x, y) end
	function META:OnMouseMove(x, y) end
	function META:OnMouseInput(button, press) end

	function META:OnPreKeyInput(button, press) end
	function META:OnKeyInput(button, press) end
	function META:OnPostKeyInput(button, press) end
	function META:OnCharInput(char) end
	function META:OnRightClick() end
	function META:OnGlobalMouseInput(button, press) end

	function META:OnCharTyped(char) end
	function META:OnKeyPressed(key, pressed) end
	function META:OnUpdate() end
	function META:OnStyleChanged(skin) end

	function META:OnPositionChanged(pos) end
	function META:OnScroll(fraction) end
	function META:OnLayout() end
	function META:OnShow() end
	function META:OnHide() end
	function META:OnMouseHoverTrigger(x, y) end
	function META:Initialize() end
end

gui.RegisterPanel(META)

if RELOAD then
	for _,v in pairs(gui.panels) do
		v:Layout()
	end
end