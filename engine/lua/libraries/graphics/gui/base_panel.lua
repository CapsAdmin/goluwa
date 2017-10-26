local gui = ... or _G.gui

local META = prototype.CreateTemplate("panel", "base")

runfile("lua/libraries/prototype/parenting_template.lua", META)

META:GetSet("MousePosition", Vec2(0, 0))
META:IsSet("Visible", true)
META:GetSet("Clipping", false)
META:GetSet("Color", Color(1,1,1,1))
META:GetSet("Cursor", "arrow")
META:GetSet("TrapChildren", false)
META:GetSet("Texture", render.GetWhiteTexture())
META:GetSet("RedirectFocus", NULL)
META:GetSet("ObeyMargin", true)
META:GetSet("BringToFrontOnClick", false)
META:GetSet("LayoutParentOnLayout", false)
META:GetSet("LayoutWhenInvisible", true)
META:GetSet("VisibilityPanel", NULL)
META:GetSet("NoDraw", false)
META:GetSet("GreyedOut", false)
META:GetSet("UpdateRate", 1/33)
META:GetSet("MouseZPos", nil)

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

	if #self.Children == 0 then return self:GetSize() end

	if self.last_children_size then
		return self.last_children_size:Copy()
	end

	self:DoLayout()

	local total_size = Vec2()
	for _, v in ipairs(self:GetChildren()) do
		if v.Visible == true then
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
	if #self.Children == 0 then return end
	self.layout_me = false
	self.last_children_size = nil
	self.real_size = self.Size:Copy()
	self.Size.y = math.huge
	self.Size.y = self:GetSizeOfChildren().y

	local min_pos = self.Size.y
	local max_pos = 0

	for i,v in ipairs(self:GetChildren()) do
		min_pos = math.min(min_pos, v.Position.y - v.Padding.y - self.Margin.y)
	end

	for i,v in ipairs(self:GetChildren()) do
		v.Position.y = v.Position.y - min_pos

		max_pos = math.max(max_pos, v.Position.y + v.Size.y + v.Padding.h)
	end

	self.Size.y = max_pos + self.Margin:GetSize().y
	self.LayoutSize = self.Size:Copy()
	self.laid_out_y = true
	self.real_size = nil
end

function META:SizeToChildrenWidth()
	if #self.Children == 0 then return end
	self.layout_me = false
	self.last_children_size = nil
	self.real_size = self.Size:Copy()
	self.Size.x = math.huge
	self.Size.x = self:GetSizeOfChildren().x

	local min_pos = self.Size.x
	local max_pos = 0

	for i,v in ipairs(self:GetChildren()) do
		min_pos = math.min(min_pos, v.Position.x - v.Padding.x - self.Margin.x)
	end

	for i,v in ipairs(self:GetChildren()) do
		v.Position.x = v.Position.x - min_pos

		max_pos = math.max(max_pos, v.Position.x + v.Size.x + v.Padding.w)
	end

	self.Size.x = max_pos + self.Margin:GetSize().x
	self.LayoutSize = self.Size:Copy()
	self.laid_out_x = true
	self.real_size = nil
end

function META:SizeToChildren()
	if #self.Children == 0 then return end
	self.layout_me = false
	self.last_children_size = nil
	self.real_size = self.Size:Copy()
	self.Size = Vec2() + math.huge
	self.Size = self:GetSizeOfChildren()

	local min_pos = self.Size:Copy()
	local max_pos = Vec2()

	for i,v in ipairs(self:GetChildren()) do
		min_pos.x = math.min(min_pos.x, v.Position.x - v.Padding.x - self.Margin.x)
		min_pos.y = math.min(min_pos.y, v.Position.y - v.Padding.y - self.Margin.y)
	end

	for i,v in ipairs(self:GetChildren()) do
		v.Position.x = v.Position.x - min_pos.x
		v.Position.y = v.Position.y - min_pos.y

		max_pos.x = math.max(max_pos.x, v.Position.x + v.Size.x + v.Padding.w)
		max_pos.y = math.max(max_pos.y, v.Position.y + v.Size.y + v.Padding.h)
	end

	self.Size = max_pos + self.Margin:GetSize()
	self.LayoutSize = self.Size:Copy()
	self.laid_out_x = true
	self.laid_out_y = true
	self.real_size = nil
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
		self.Position.x - override.RealScroll.x < override.Size.x and
		self.Position.y - override.RealScroll.y < override.Size.y and
		self.Position.x + self.Size.x - override.RealScroll.x > 0 and
		self.Position.y + self.Size.y - override.RealScroll.y > 0
	then
		return true
	end

	return false
end

do -- focus
	do -- child order
		META:GetSet("ChildOrder", 0)

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

		function META:SetChildOrder(pos)
			self.ChildOrder = pos

			if self:HasParent() then
				table.sort(self.Parent.Children, function(a, b) return a.ChildOrder > b.ChildOrder end)
			end
		end
	end

	do -- focus
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
end

do -- call on hide
	function META:IsVisible()
		if not self.Visible then
			return false
		end
		if self.visible == false then
			return false
		end
		return self.Visible
	end

	function META:SetVisible(bool)
		self.call_on_hide = self.call_on_hide or {}

		self.Visible = not not bool -- nil would make self.Visible be the default which is true
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
		if self.GreyedOut then render2d.PushHSV(1,0,0.5) end
		render2d.PushAlphaMultiplier(self.DrawAlpha)

		if self.ThreeDee then render2d.Start3D2D() end

		local no_draw = self:HasParent() and self.Parent.draw_no_draw

		self:InvalidateMatrix()
		self:RebuildMatrix()

		render2d.SetWorldMatrix(self.Matrix)

		if not from_cache then
			self:CalcMouse()
			self:CalcDragging()
			self:CalcScrolling()
		end

		self:CalcAnimations()
		self:CalcResizing()
		self:CalcLayout()

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

				self:DrawDebug()

				if gui.keyboard_selected_panel == self then
					render.SetPresetBlendMode("additive")
					render2d.SetColor(1, 1, 1, 0.5)
					render2d.SetTexture()
					render2d.DrawRect(0, 0, self.Size.x + self.DrawSizeOffset.x, self.Size.y + self.DrawSizeOffset.y)
					render.SetPresetBlendMode("alpha")
				end

				self.visible = true
				no_draw = false
			else
				self.visible = false
				no_draw = true
			end
		end

		if --[[true or]] not no_draw and self.Clipping then
			--render2d.PushClipFunction(self.DrawClippingStencil, self)
			render2d.EnableClipRect(0,0,self.Size.x + self.DrawSizeOffset.x, self.Size.y + self.DrawSizeOffset.y)
		end

		if from_cache then
			self.draw_no_draw = false
		else
			self.draw_no_draw = no_draw
		end
	end

	function META:DrawClippingStencil()
		--if not self.Clipping then return end
		local tex = render2d.GetTexture()
		render2d.SetTexture()
		--render2d.SetTexture(self.Texture)
		render2d.PushColor(1,1,1,0.1)
		self:DrawRect()
		render2d.PopColor()
		render2d.SetTexture(tex)
	end

	function META:Draw(from_cache)
		if not self.Visible then return end
		if self.SetupShadows then self:SetupShadows() end
		self:PreDraw(from_cache)
		if self.DrawShadows then self:DrawShadows() end
			for _, v in ipairs(self:GetChildren()) do
				if self.DrawChild then self:DrawChild(v) end
				v:Draw(from_cache)
			end
		self:PostDraw(from_cache)
	end

	function META:PostDraw(from_cache)
		if --[[true or]] not self.draw_no_draw and self.Clipping then
			--render2d.PopClipFunction()
			render2d.DisableClipRect()
			--render.PopViewport()
		end

		if self.ThreeDee then render2d.End3D2D() end

		if self.GreyedOut then render2d.PopHSV() end
		render2d.PopAlphaMultiplier()
	end

	function META:DrawDebug()
		if self.debug_flash and self.debug_flash > system.GetElapsedTime() then
			render2d.SetTexture()
			render2d.SetColor(1,0,0,(system.GetElapsedTime()*4)%1 > 0.5 and 0.5 or 0)
			render2d.DrawRect(0, 0, self.Size.x, self.Size.y)
		end

		if gui.debug then

			if self.debug_layout then
				gfx.SetFont()
				render2d.SetColor(1, 1, 1, 1)
				gfx.DrawText("layout count " .. self.layout_count, 0, 0)
				--render2d.SetTexture()
				--render2d.SetColor(1,0,0,1)
				--render2d.DrawRect(self:GetMousePosition().x, self:GetMousePosition().y, 2, 2)
			end

			if self.updated_layout then
				render2d.SetAlphaMultiplier(1)
				render.SetPresetBlendMode("additive")
				render2d.SetColor(1, 0, 0, 0.1)
				render2d.SetTexture()
				render2d.DrawRect(0,0, self.Size.x, self.Size.y)
				self.updated_layout = false
				render.SetPresetBlendMode("alpha")
			else
				if self.updated_cache then
					render2d.SetAlphaMultiplier(1)
					render2d.SetColor(0, 1, 0, 0.1)
					render2d.SetTexture()
					render2d.DrawRect(0, 0, self.Size.x, self.Size.y)
					self.updated_cache = false
				end
			end
		end
	end

	function META:DrawRect(x, y, w, h)
		if self.NinePatch then
			gfx.DrawNinePatch(
				x or 0, y or 0,
				w or (self.Size.x + self.DrawSizeOffset.x), h or (self.Size.y + self.DrawSizeOffset.y),
				self.NinePatchRect.w, self.NinePatchRect.h,
				self.NinePatchCornerSize,
				self.NinePatchRect.x, self.NinePatchRect.y,
				self:GetSkin().pixel_scale
			)
		else
			if not self.NinePatchRect:IsZero() then
				render2d.SetRectUV(self.NinePatchRect.x, self.NinePatchRect.y, self.NinePatchRect.w, self.NinePatchRect.h, self.Texture.Size.x, self.Texture.Size.y)
			end
			render2d.DrawRect(x or 0, y or 0, w or (self.Size.x + self.DrawSizeOffset.x), h or (self.Size.y + self.DrawSizeOffset.y))
			if not self.NinePatchRect:IsZero() then
				render2d.SetRectUV()
			end
		end
	end

	function META:DebugFlash()
		self.debug_flash = system.GetElapsedTime() + 3
	end
end

do -- orientation
	META:GetSet("Position", Vec2(0, 0))
	META:GetSet("Z", 0)
	META:GetSet("Size", Vec2(4, 4))
	META:GetSet("MinimumSize", Vec2(4, 4))
	META:GetSet("Padding", Rect(0, 0, 0, 0))
	META:GetSet("Margin", Rect(0, 0, 0, 0))
	META:GetSet("Angle", 0)
	META:GetSet("Order", 0)

	META:GetSet("ThreeDee", false)
	META:GetSet("ThreeDeePosition", Vec3(0,0,0))
	META:GetSet("ThreeDeeAngles", Ang3(0,0,0))
	META:GetSet("ThreeDeeScale", Vec3(1,1,1))

	do
		META:GetSet("Matrix", Matrix44())

		function META:InvalidateMatrix()
			if not self.rebuild_matrix then
				for _, v in ipairs(self:GetChildrenList()) do
					v.rebuild_matrix = true
				end
			end
			self.rebuild_matrix = true
		end

		function META:RebuildMatrix(lol)
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
						local w,h = render2d.GetSize()
						local scale2d = (w/h) / 100
						self.Matrix:Scale(scale.x * scale2d, scale.y * scale2d, scale.z)
					end
				end

if not lol then
				self.temp_matrix = self.temp_matrix or Matrix44()
				self.Parent.Matrix:Multiply(self.Matrix, self.temp_matrix)
				self.Matrix, self.temp_matrix = self.temp_matrix, self.Matrix
end
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

				self.Matrix:Translate(math.ceil(-self.Parent.RealScroll.x), math.ceil(-self.Parent.RealScroll.y), 0)

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
				wpos = wpos + v.Parent.RealScroll
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
	META:GetSet("CachedRendering", false)

	function META:SetCachedRendering(b)
		self.CachedRendering = b

		if not render.IsExtensionSupported("GL_ARB_framebuffer_object") then
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
		render2d.SetColor(1, 1, 1, 1)
		render2d.SetTexture(self.cache_texture)
		render2d.DrawRect(0, 0, self.Size.x, self.Size.y)
		self:OnPostDraw()
	end

	function META:BuildCache()
		if self:IsCacheDirty() then
			self.cache_fb:Begin()
			--self.cache_fb:Clear()

			local x,y = self.Matrix:GetTranslation()
			self.Matrix:Translate(-x, -y, 0)
			render2d.PushMatrix(nil, true)

			if self:IsDragging() or self:IsInsideParent() then
				self:OnDraw()
			end

			--render2d.Translate(-self.Scroll.x, -self.Scroll.y)

			for _, v in ipairs(self:GetChildren()) do
				if v.Visible then
					v:Draw(true)
				end
			end

			render2d.PopMatrix()

			self.Matrix:Translate(x, y, 0)
			self.cache_fb:End()

			self.cache_dirty = false
			self.updated_cache = true
		end
	end
end

do -- scrolling
	META:GetSet("Scrollable", false)
	META:GetSet("Scroll", Vec2(0, 0))
	META:GetSet("ScrollFraction", Vec2(0, 0))


	META:GetSet("SmoothScroll", 0.25)
	META.RealScroll = Vec2(0, 0)

	local function start_scroll(self, add)
		if self.SmoothScroll ~= 0 and not self:IsScrolling() then
			if self.scroll_start and self.scroll_stop and add then
				self.scroll_vel = self.scroll_start - self.scroll_stop
				local dir = add - self.scroll_stop

				if math.abs(dir.y) > math.abs(self.scroll_vel.y) then
					self.scroll_vel.y = -self.scroll_vel.y
				end
			end
			self.scroll_start = self:GetScroll():Copy()
			self.scroll_time = system.GetElapsedTime() + self.SmoothScroll
		end
	end

	local function stop_scroll(self, size, add)
		if self.SmoothScroll ~= 0 and not self:IsScrolling() then
			if add then
				self.scroll_stop = (-(self.scroll_vel or Vec2())*0.9) + self.Scroll:Copy()
				self.scroll_vel = nil
			else
				self.scroll_stop = self.Scroll:Copy()
			end
			self.scroll_start:Clamp(Vec2(0), size - self.Size)
			self.scroll_stop:Clamp(Vec2(0), size - self.Size)
		else
			self.RealScroll = self.Scroll:Copy()
		end
	end

	function META:SetScroll(vec)
		start_scroll(self, vec)

		local size = self:GetSizeOfChildren()

		self.Scroll = vec:GetClamped(Vec2(0), size - self.Size)

		if size.x < self.Size.x then self.Scroll.x = 0 end
		if size.y < self.Size.y then self.Scroll.y = 0 end

		self.ScrollFraction = self.Scroll / (size - self.Size)
		self:OnScroll(self.ScrollFraction)

		self:MarkCacheDirty()

		stop_scroll(self, size, vec)
	end

	function META:SetScrollFraction(frac)
		local size = self:GetSizeOfChildren()

		start_scroll(self, size)

		self.Scroll = frac * size
		self.Scroll:Clamp(Vec2(0, 0), size - self.Size)
		self.ScrollFraction = frac

		self:OnScroll(self.ScrollFraction)

		self:MarkCacheDirty()

		stop_scroll(self, size)
	end

	function META:GetScroll()
		return self.RealScroll
	end

	function META:StartScrolling(button)
		self.scroll_button = button
		self.scroll_drag_pos = self:GetScroll() + self:GetMousePosition()
	end

	function META:StopScrolling()
		self.scroll_button = nil
		self.scroll_drag_pos = nil

		self.scroll_time = nil
		self.scroll_stop = nil
		self.scroll_start = nil
		self.scroll_vel = nil
	end

	function META:IsScrolling()
		return self.scroll_button ~= nil
	end

	function META:CalcScrolling()
		if self:IsScrolling() then
			local size = self:GetSizeOfChildren()

			if size.x < self.Size.x and size.y < self.Size.y then self:StopScrolling() return end

			if input.IsMouseDown(self.scroll_button) then
				self:SetScroll(self.scroll_drag_pos - self:GetMousePosition())
				self:OnScroll(self.ScrollFraction)
			else
				self:StopScrolling()
			end
		elseif self.scroll_time and self.scroll_stop then
			local f = (self.scroll_time - system.GetElapsedTime()) / self.SmoothScroll
			if f >= 0 then
				f = f ^ 5
				self.RealScroll = self.scroll_stop:GetLerped(f, self.scroll_start)
			else
				self.scroll_time = nil
				self.scroll_stop = nil
				self.scroll_start = nil
			end
		end
	end
end

do -- drag drop
	META:GetSet("Draggable", false)
	META:GetSet("DragDrop", false)
	META:GetSet("DragMinDistance", 0)

	function META:StartDragging(button)
		self.drag_original_pos = self:GetPosition()
		self.drag_world_pos = gui.mouse_pos:Copy()
		self.drag_local_pos = self:GetMousePosition():Copy()
		self.drag_stop_button = button
	end

	function META:StopDragging()
		self.drag_original_pos = nil
		self.drag_drop_pos = nil
		self.drag_panel = nil

		self.drag_stop_button = nil
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

		local drag_pos = Vec2(render2d.ScreenToWorld(self.drag_world_pos:Unpack()))
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

		self.drag_drop_pos = drop_pos
		self.drag_panel = panel

		self:MarkCacheDirty()
	end

	function META:OnDraggedChildEnter(child, drop_pos)

	end

	function META:OnDraggedChildExit(child, drop_pos)

	end

	function META:OnParentLand(parent)

	end

	function META:OnPanelHover(panel, drop_pos)

	end

	function META:OnChildDrop(child, pos)

	end
end

do -- magnet snap
	META:GetSet("SnapWhileDragging", false)

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
	META:GetSet("DrawSizeOffset", Vec2(0, 0))
	META:GetSet("DrawScaleOffset", Vec2(1, 1))
	META:GetSet("DrawPositionOffset", Vec2(0, 0))
	META:GetSet("DrawAngleOffset", Ang3(0,0,0))
	META:GetSet("DrawColor", Color(0,0,0,0))
	META:GetSet("DrawAlpha", 1)

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
	META:GetSet("ResizeBorder", Rect(8,8,8,8))
	META:GetSet("Resizable", false)

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
	META:GetSet("IgnoreMouse", false)
	META:GetSet("FocusOnClick", false)
	META:GetSet("AlwaysCalcMouse", false)
	META:GetSet("AlwaysReceiveMouseInput", false)
	META:GetSet("SendMouseInputToPanel", NULL)
	META:GetSet("AllowKeyboardInput", true)

	META:GetSet("MouseHoverTime", 0)
	META:GetSet("MouseHoverTimeTrigger", 1)

	do
		gui.active_tooltip = NULL

		META:GetSet("Tooltip", "")

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
			not self.AlwaysCalcMouse and
			not self.mouse_capture and
			not self.mouse_hover_triggered and
			not self.mouse_just_entered
		then
			self.mouse_over = false
			return
		end

		local x, y = render2d.ScreenToWorld(gui.mouse_pos.x, gui.mouse_pos.y)

		self.MousePosition.x = x
		self.MousePosition.y = y

		local alpha = 1

		if not self.NinePatch and self.NinePatchRect:IsZero() and self.Texture:IsValid() and self.Texture ~= render.GetWhiteTexture() and not self.Texture:IsLoading() then
			local x = (x / self.Size.x)
			local y = (y / self.Size.y)

			x = x * self.Texture:GetSize().x
			y = y * self.Texture:GetSize().y

			x = math.clamp(math.floor(x), 1, self.Texture:GetSize().x-1)
			y = math.clamp(math.floor(y), 1, self.Texture:GetSize().y-1)

			alpha = select(4, self.Texture:GetRawPixelColor(x, y)) / 255
		end

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
						return
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
						return
					end
				end
				self:OnMouseExit(x, y)
				self.mouse_just_entered = false
			end

			if self.mouse_hover_triggered and not (gui.active_tooltip:IsValid() or not self:ContainsParent(gui.active_tooltip)) then
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
			return
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

		if button == self.drag_stop_button and not press then
			if self.drag_panel and self.drag_drop_pos then
				self:OnParentLand(self.drag_panel, self.drag_drop_pos, self.drag_original_pos)
				self.drag_panel:OnChildDrop(self, self.drag_drop_pos, self.drag_original_pos)
			end
			self:StopDragging()
		end

		self:OnGlobalMouseInput(button, press)
	end

	function META:KeyInput(button, press)
		if self.GreyedOut or not self.AllowKeyboardInput then return end

		local b

		if self:OnPreKeyInput(button, press) ~= false then
			b = self:OnKeyInput(button, press)
			self:OnPostKeyInput(button, press)
		end

		self:MarkCacheDirty()

		return b
	end

	function META:CharInput(char)
		if not self.AllowKeyboardInput then return end
		self:MarkCacheDirty()
		return self:OnCharInput(char)
	end
end

do -- layout
	META.layout_count = 0

	META:GetSet("LayoutSize", nil)
	META:GetSet("IgnoreLayout", false)
	META:GetSet("CollisionGroup", "none")

	local origin

	local function sort(a, b)
		return math.abs(a.point-origin) < math.abs(b.point-origin)
	end

	function META:RayCast(start_pos, stop_pos)
		local parent = self:GetParent()

		local dir = stop_pos - start_pos

		local found = {}
		local i = 1

		local a_lft, a_top, a_rgt, a_btm = self:GetWorldRectFast()

		for _, b in ipairs(parent:GetChildren()) do
			if
				b ~= self and
				not b.nocollide and
				((b.laid_out_x == nil or b.laid_out_x == true) or (b.laid_out_y == nil or b.laid_out_y == true)) and
				b.Visible and
				not b.ThreeDee and
				not b.IgnoreLayout and
				(self.CollisionGroup == "none" or self.CollisionGroup == b.CollisionGroup)
			then
				local b_lft, b_top, b_rgt, b_btm = b:GetWorldRectFast()

				if
					(b_lft <= a_lft and b_rgt >= a_rgt) or
					(b_lft >= a_lft and b_rgt <= a_rgt) or
					(b_rgt > a_rgt and b_lft < a_rgt) or
					(b_rgt > a_lft and b_lft < a_lft)
				then
					if dir.y > 0 and b_top > a_top and not b.nocollide_up then
						found[i] = {child = b, point = b_top}
						i = i + 1
					elseif dir.y < 0 and b_btm < a_btm and not b.nocollide_down then
						found[i] = {child = b, point = b_btm}
						i = i + 1
					end
				end

				if
					(b_top <= a_top and b_btm >= a_btm) or
					(b_top >= a_top and b_btm <= a_btm) or
					(b_btm > a_btm and b_top < a_btm) or
					(b_btm > a_top and b_top < a_top)

				then
					if dir.x > 0 and b_rgt > a_rgt and not b.nocollide_left then
						found[i] = {child = b, point = b_lft}
						i = i + 1
					elseif dir.x < 0 and b_lft < a_lft and not b.nocollide_right then
						found[i] = {child = b, point = b_rgt}
						i = i + 1
					end
				end
			end
		end

		if dir.y > 0 then
			origin = a_btm
		elseif dir.y < 0 then
			origin = a_top
		elseif dir.x > 0 then
			origin = a_rgt
		elseif dir.x < 0 then
			origin = a_lft
		end

		table.sort(found, sort)

		local hit_pos = stop_pos

		if found and found[1] then
			local child = found[1].child

			hit_pos = child:GetPosition():Copy()

			if dir.x < 0 then
				hit_pos.y = self:GetY()
				hit_pos.x = hit_pos.x + child:GetWidth() + self.Padding:GetRight()
			elseif dir.x > 0 then
				hit_pos.y = self:GetY()
				hit_pos.x = hit_pos.x - self:GetWidth() - self.Padding:GetLeft()
			elseif dir.y < 0 then
				hit_pos.x = self:GetX()
				hit_pos.y = hit_pos.y + child:GetHeight() + self.Padding:GetBottom()
			elseif dir.y > 0 then
				hit_pos.x = self:GetX()
				hit_pos.y = hit_pos.y - self:GetHeight() - self.Padding:GetTop()
			end
		else
			if dir.x < 0 then
				hit_pos.x = hit_pos.x + self.Padding:GetRight()
				hit_pos.x = hit_pos.x + parent.Margin:GetRight()
			elseif dir.x > 0 then
				hit_pos.x = hit_pos.x - self.Padding:GetLeft()
				hit_pos.x = hit_pos.x - parent.Margin:GetLeft()
			elseif dir.y < 0 then
				hit_pos.y = hit_pos.y + self.Padding:GetBottom()
				hit_pos.y = hit_pos.y + parent.Margin:GetBottom()
			elseif dir.y > 0 then
				hit_pos.y = hit_pos.y - self.Padding:GetTop()
				hit_pos.y = hit_pos.y - parent.Margin:GetTop()
			end

			hit_pos.x = math.max(hit_pos.x, 0)
			hit_pos.y = math.max(hit_pos.y, 0)
		end

		return hit_pos, found and found[1] and found[1].child
	end

	function META:ExecuteLayoutCommands()
	--	if self:HasParent() then self = self.Parent end

		if not self.layout_us then return end

		for _, child in ipairs(self:GetChildren()) do
			if child.layout_commands then
				if child.LayoutSize then
					child:SetSize(child.LayoutSize:Copy())
				end
				child.laid_out_x = false
				child.laid_out_y = false
				child:Confine()
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
						child:Collide()
					elseif cmd == "size_to_children_width" then
						child:SizeToChildrenWidth()
					elseif cmd == "size_to_children_height" then
						child:SizeToChildrenHeight()
					elseif cmd == "size_to_children" then
						child:SizeToChildren()
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
					elseif cmd == "gmod_left" then
						child:CenterYSimple()
						child:MoveLeft()
						child:FillY()
						child:NoCollide("left")
					elseif cmd == "gmod_right" then
						child:CenterYSimple()
						child:MoveRight()
						child:FillY()
						child:NoCollide("right")
					elseif cmd == "gmod_top" then
						child:CenterXSimple()
						child:MoveUp()
						child:FillX()
						child:NoCollide("up")
					elseif cmd == "gmod_bottom" then
						child:CenterXSimple()
						child:MoveDown()
						--child:FillX()
						child:NoCollide("down")
					elseif typex(cmd) == "vec2" then
						child:SetSize(cmd:Copy())
					end
				end
			end
		end

		for _, child in ipairs(self:GetChildren()) do
			if child.layout_commands then
				for _, cmd in ipairs(child.layout_commands) do
					if cmd == "gmod_fill" then
						child.LayoutSize = Vec2(1,1)
						child:CenterSimple()
						child:FillX()
						child:FillY()
						child:NoCollide()
					end
				end
			end
		end
	end

	function META:DoLayout()
		self.in_layout = true
		self:OnLayout(self:GetLayoutScale(), self:GetSkin())
		self.in_layout = false

		self:ExecuteLayoutCommands()

		if self.Stack then
			local size = self:StackChildren()
			if self.StackSizeToChildren then
				self:SetSize(size)
			end
		end
	end

	function META:Layout(now)
		if self.in_layout then return end
		if now and (self.LayoutWhenInvisible or not self.draw_no_draw) then

			self:DoLayout()

			for _, v in ipairs(self:GetChildren()) do
				v.layout_me = true
			end

			self.updated_layout = true
			self.layout_count = (self.layout_count or 0) + 1

			self.last_children_size = nil

			self:MarkCacheDirty()

			self.in_layout = true
			self:OnPostLayout()
			self.in_layout = false

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

		--event.Delay(0, function() self:Layout() end, nil, self) -- FIX ME
	end

	function META:OnParent(parent)
		if parent ~= self.Parent then
			if self.layout_commands then
				self:SetupLayout(unpack(self.layout_commands))
			end
		end
	end

	do -- layout commands

		function META:ResetLayout()
			self.laid_out_x = false
			self.laid_out_y = false

			for _, child in ipairs(self:GetChildren()) do
				if child.LayoutSize then
					child:SetSize(child.LayoutSize:Copy())
				end
				child.laid_out_x = false
				child.laid_out_y = false
			end
		end

		function META:Collide()
			self.nocollide = false
			self.nocollide_up = false
			self.nocollide_down = false
			self.nocollide_left = false
			self.nocollide_right = false
		end

		function META:NoCollide(dir)
			if dir then
				self["nocollide_" .. dir] = true
			else
				self.nocollide = true
			end
		end

		function META:FillX(percent)
			local parent = self:GetParent()
			local parent_width = parent.real_size and parent.real_size.x or parent:GetWidth()

			self:SetWidth(1)

			local left = self:RayCast(self:GetPosition(), Vec2(0, self.Position.y))
			local right = self:RayCast(self:GetPosition(), Vec2(parent_width, self.Position.y))
			right.x = right.x - left.x

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

			self.laid_out_x = true
		end

		function META:FillY(percent)
			local parent = self:GetParent()
			local parent_height = parent.real_size and parent.real_size.y or parent:GetHeight()

			self:SetHeight(1)

			local top = self:RayCast(self:GetPosition(), Vec2(self.Position.x, 0))
			local bottom = self:RayCast(self:GetPosition(), Vec2(self.Position.x, parent_height))
			bottom.y = bottom.y - top.y

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

			self.laid_out_y = true
		end

		function META:Center()
			self:CenterX()
			self:CenterY()
		end

		function META:CenterX()
			local parent = self:GetParent()
			local width = parent.real_size and parent.real_size.x or parent:GetWidth()

			local left = self:RayCast(self:GetPosition(), Vec2(0, self.Position.y))
			local right = self:RayCast(self:GetPosition(), Vec2(width, left.y))

			self:SetX(math.lerp(0.5, left.x, right.x))

			self.laid_out_x = true
		end

		function META:CenterY()
			local parent = self:GetParent()
			local height = parent.real_size and parent.real_size.y or parent:GetHeight()

			local top = self:RayCast(self:GetPosition(), Vec2(self.Position.x, 0))
			local bottom = self:RayCast(self:GetPosition(), Vec2(top.x, height))
			self:SetY(top.y + (bottom.y/2 - self:GetHeight()/2) - self.Padding:GetTop() + self.Padding:GetBottom())

			self.laid_out_y = true
		end


		function META:CenterXSimple()
			local parent = self:GetParent()
			local width = parent.real_size and parent.real_size.x or parent:GetWidth()

			self:SetX(width / 2 - self:GetWidth() / 2)

			self.laid_out_x = true
		end

		function META:CenterYSimple()
			local parent = self:GetParent()
			local height = parent.real_size and parent.real_size.y or parent:GetHeight()

			self:SetY(height / 2 - self:GetHeight() / 2)

			self.laid_out_y = true
		end

		function META:CenterSimple()
			self:CenterXSimple()
			self:CenterYSimple()
		end

		function META:CenterXFrame()
			local parent = self:GetParent()

			local left = self:RayCast(self:GetPosition(), Vec2(0, self.Position.y))
			local right = self:RayCast(self:GetPosition(), Vec2(parent:GetWidth(), left.y))

			if
				self:GetX()+self:GetWidth()+self.Padding:GetRight() < right.x+self:GetWidth()-self.Padding:GetRight() and
				self:GetX()-self.Padding.x > left.x
			then
				self:SetX(parent:GetWidth() / 2 - self:GetWidth() / 2)
			end

			self.laid_out_x = true
		end

		function META:MoveUp()
			local parent = self:GetParent()

			if not self.laid_out_y then
				self:SetY(parent:GetHeight() == math.huge and 999999999999 or parent:GetHeight()) -- :(
			end

			self:SetY(math.max(self:GetY(), 1))
			self:SetY(self:RayCast(self:GetPosition(), Vec2(self:GetX(), 0)).y)

			self.laid_out_y = true
		end

		function META:MoveLeft()
			local parent = self:GetParent()

			if not self.laid_out_x then
				self:SetX(parent:GetWidth() == math.huge and 999999999999 or parent:GetWidth()) -- :(
			end

			self:SetX(math.max(self:GetX(), 1))
			self:SetX(self:RayCast(self:GetPosition(), Vec2(0, self.Position.y)).x)

			self.laid_out_x = true
		end

		function META:Confine()
			local m = self:GetParent():GetMargin()
			local p = self:GetPadding()

			self.Position.x = math.clamp(self.Position.x, m:GetLeft() + p:GetLeft(), self.Parent.Size.x - self.Size.x - m:GetRight() + p:GetRight())
			self.Position.y = math.clamp(self.Position.y, m:GetTop() + p:GetTop(), self.Parent.Size.y - self.Size.y - m:GetBottom() + p:GetBottom())
		end


		function META:MoveDown()
			local parent = self:GetParent()

			if not self.laid_out_y then
				self:SetY(0 - self:GetHeight())
			end

			self:SetY(math.max(self:GetY(), 1))
			self:SetY(self:RayCast(self:GetPosition(), Vec2(self:GetX(), parent:GetHeight() - self:GetHeight())).y)

			self.laid_out_y = true
		end

		function META:MoveRight()
			local parent = self:GetParent()

			if not self.laid_out_x then
				self:SetX(0 - self:GetWidth())
			end

			self:SetX(math.max(self:GetX(), 1))
			self:SetX(self:RayCast(self:GetPosition(), Vec2(parent:GetWidth() - self:GetWidth(), self.Position.y)).x)

			self.laid_out_x = true
		end

		function META:MoveRightOf(panel)
			self:SetY(panel:GetY())
			self:SetX(panel:GetX() + panel:GetWidth())

			self.laid_out_x = true
			self.laid_out_y = true
		end

		function META:MoveDownOf(panel)
			self:SetX(panel:GetX())
			self:SetY(panel:GetY() + panel:GetHeight())

			self.laid_out_x = true
			self.laid_out_y = true
		end

		function META:MoveLeftOf(panel)
			self:SetY(panel:GetY())
			self:SetX(panel:GetX() - self:GetWidth())

			self.laid_out_x = true
			self.laid_out_y = true
		end

		function META:MoveUpOf(panel)
			self:SetX(panel:GetX())
			self:SetY(panel:GetY() - self:GetHeight())

			self.laid_out_x = true
			self.laid_out_y = true
		end
	end
end

do -- stacking
	META:GetSet("ForcedStackSize", Vec2(0, 0))

	META:GetSet("StackRight", true)
	META:GetSet("StackDown", true)

	META:GetSet("SizeStackToWidth", false)
	META:GetSet("SizeStackToHeight", false)
	META:IsSet("Stackable", true)
	META:IsSet("Stack", false)
	META:IsSet("StackSizeToChildren", false)

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
	META:GetSet("Style")
	META:GetSet("Skin")
	META:GetSet("LayoutScale")

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

	META:GetSet("NinePatch", false)
	META:GetSet("NinePatchRect", Rect(0, 0, 0, 0))
	META:GetSet("NinePatchCornerSize", 4)
	META:GetSet("StyleSize", Vec2(0, 0))

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

		render2d.SetColor(
			self.Color.r + self.DrawColor.r,
			self.Color.g + self.DrawColor.g,
			self.Color.b + self.DrawColor.b,
			self.Color.a + self.DrawColor.a
		)

		render2d.SetTexture(self.Texture)

		self:DrawRect()
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

	META:GetSet("RemoveOnParentRemove", true)

	function META:OnRemove()
		self:MarkCacheDirty()

		gui.panels[self] = nil

		for _, v in pairs(self:GetChildrenList()) do
			if v.RemoveOnParentRemove then
				v:Remove()
			end
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
	function META:OnPostLayout() end
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
