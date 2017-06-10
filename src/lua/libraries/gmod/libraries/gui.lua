do -- chatbox
	local chat = gine.env.chat
	local lib = _G.chat

	function chat.AddText(...)
		local tbl = {...}
		for i, v in ipairs(tbl) do
			if gine.env.IsColor(v) then
				tbl[i] = ColorBytes(v.r, v.g, v.b, v.a)
			elseif type(v) == "table" and v.__obj then
				tbl[i] = v.__obj
			end
		end
		chathud.AddText(unpack(tbl))
	end

	function chat.Close()
		lib.Close()
	end

	function chat.Open()
		lib.Open()
	end

	function chat.GetChatBoxPos()
		if lib.panel:IsValid() then
			return lib.panel:GetPosition():Unpack()
		end

		return 0, 0
	end

	function chat.GetChatBoxSize()
		if lib.panel:IsValid() then
			return lib.panel:GetSize():Unpack()
		end

		return 0, 0
	end
end

do
	local vgui = gine.env.vgui

	function vgui.GetHoveredPanel()
		local pnl = gui.GetHoveringPanel()
		if pnl:IsValid() then
			return gine.WrapObject(gui.GetHoveringPanel(), "Panel")
		end
	end

	function vgui.FocusedHasParent(parent)
		if gui.focus_panel:IsValid() and parent then
			return parent.__obj:HasChild(gui.focus_panel)
		end
	end

	function vgui.GetKeyboardFocus()
		return true
	end

	function vgui.CursorVisible()
		return window.IsCursorVisible()
	end
end

do
	local gui = gine.env.gui

	function gui.MousePos()
		return window.GetMousePosition():Unpack()
	end

	function gui.MouseX()
		return window.GetMousePosition().x
	end

	function gui.MouseY()
		return window.GetMousePosition().y
	end

	function gui.ScreenToVector(x, y)
		return gine.env.Vector(math3d.ScreenToWorldDirection(Vec2(x, y)):Unpack())
	end

	function gui.IsGameUIVisible()
		return menu.IsVisible()
	end
end

do
	gine.gui_world = gine.gui_world or NULL

	local function hook(obj, func_name, callback)
		local old = obj[func_name]
		if not old then
			obj[func_name] = callback
		else
			obj[func_name] = function(...)
				local a,b,c,d = callback(...)
				if a ~= nil then
					return a,b,c,d
				end
				return old(...)
			end
		end
	end

	local function vgui_Create(class, parent, name)

		if not gine.gui_world:IsValid() then
			gine.gui_world = gui.CreatePanel("base")
			gine.gui_world:SetNoDraw(true)
			--gine.gui_world:SetIgnoreMouse(true)
			gine.gui_world.__class = "CGModBase"
			function gine.gui_world:OnLayout()
				self:SetPosition(Vec2(0, 0))
				self:SetSize(window.GetSize())
			end
		end

		class = class:lower()

		local obj

		if class == "textentry" then
			obj = gui.CreatePanel("text_edit")
		else
			obj = gui.CreatePanel("base")
		end

		local self = gine.WrapObject(obj, "Panel")

		obj.gine_pnl = self
		self.__class = class

		obj.fg_color = Color(1,1,1,1)
		obj.bg_color = Color(1,1,1,1)
		obj.text_inset = Vec2()
		obj.text_offset = Vec2()
		obj.vgui_type = class
		--self:SetPaintBackgroundEnabled(true)
		obj:SetSize(Vec2(64, 24))
		obj:SetPadding(Rect())
		obj:SetMargin(Rect())
		self:SetContentAlignment(4)

		self:SetFontInternal("default")

		self:MouseCapture(false)

		self:SetParent(parent)

		function self:ActionSignal() end
		function self:AnimationThink() end
		function self:ApplySchemeSettings() end
		function self:FinishedURL() end
		function self:Init() end
		function self:OnChildAdded() end
		function self:OnChildRemoved() end
		function self:OnCursorEntered() end
		function self:OnCursorExited() end
		function self:OnCursorMoved() end
		function self:OnFocusChanged() end
		function self:OnKeyCodePressed() end
		function self:OnKeyCodeReleased() end
		function self:OnKeyCodeTyped() end
		function self:OnMousePressed() end
		function self:OnMouseReleased() end
		function self:OnMouseWheeled() end
		function self:OnDeletion() end
		function self:OpeningURL() end
		function self:PageTitleChanged() end
		function self:Paint() end
		function self:PaintOver() end
		function self:PerformLayout() end
		function self:ResourceLoaded() end
		function self:StatusChanged() end
		function self:Think() end

		hook(obj, "OnChildAdd", function(_, child)
			if obj.gine_prepared then
				child = gine.WrapObject(child, "Panel")
				if child.__obj.gine_prepared then
					self:OnChildAdded(child)
				end
			end
		end)

		hook(obj, "OnChildRemove", function(_, child)
			if obj.gine_prepared then
				child = gine.WrapObject(child, "Panel")
				if child.__obj.gine_prepared then
					self:OnChildRemoved(child)
				end
			end
		end)

		obj.OnDraw = function()
			if self.gine_layout then
				self:InvalidateLayout(true)
				self.gine_layout = nil
			end

			local paint_bg = self:Paint(obj:GetWidth(), obj:GetHeight())

			if not obj.draw_manual then
				if obj.paint_bg and paint_bg ~= nil then
					render2d.SetTexture()
					render2d.SetColor(obj.bg_color:Unpack())
					render2d.DrawRect(0,0,obj.Size.x,obj.Size.y)
				end

				if class == "label" then
					if obj.text_internal and obj.text_internal ~= "" then
						render2d.SetColor(obj.fg_color:Unpack())
						gine.render2d_fonts[obj.font_internal:lower()]:DrawString(obj.text_internal, obj.text_offset.x, obj.text_offset.y)
					end
				end
			end

			self:PaintOver(obj:GetWidth(), obj:GetHeight())
		end

		obj:CallOnRemove(function() self:OnDeletion() end)

		hook(obj, "OnUpdate", function() self:Think() self:AnimationThink() end)
		hook(obj, "OnMouseMove", function(_, x, y) self:OnCursorMoved(x, y) end)
		hook(obj, "OnMouseEnter", function() self:OnCursorEntered() end)
		hook(obj, "OnMouseExit", function() self:OnCursorExited() end)

		-- OnChildAdd and such doesn't seem to be called in Init

		hook(obj, "OnPostLayout", function()
			local panel = obj

			if panel.vgui_type == "label" then
				local w, h = gine.render2d_fonts[panel.font_internal:lower()]:GetTextSize(panel.text_internal)
				local m = panel:GetMargin()

				if panel.content_alignment == 5 then
					panel.text_offset = (panel:GetSize() / 2) - (Vec2(w, h) / 2)
				elseif panel.content_alignment == 4 then
					panel.text_offset.x = m:GetLeft()
					panel.text_offset.y = (panel:GetHeight() / 2) - (h / 2)
				elseif panel.content_alignment == 6 then
					panel.text_offset.x = panel:GetWidth() - w - m:GetRight()
					panel.text_offset.y = (panel:GetHeight() / 2) - (h / 2)
				elseif panel.content_alignment == 2 then
					panel.text_offset.x = (panel:GetWidth() / 2) - (w / 2)
					panel.text_offset.y = panel:GetHeight() - h - m:GetBottom()
				elseif panel.content_alignment == 8 then
					panel.text_offset.x = (panel:GetWidth() / 2) - (w / 2)
					panel.text_offset.y = m:GetTop()
				elseif panel.content_alignment == 7 then
					panel.text_offset.x = m:GetLeft()
					panel.text_offset.y = m:GetTop()
				elseif panel.content_alignment == 9 then
					panel.text_offset.x = panel:GetWidth() - w - m:GetRight()
					panel.text_offset.y = m:GetTop()
				elseif panel.content_alignment == 1 then
					panel.text_offset.x = m:GetLeft()
					panel.text_offset.y = panel:GetHeight() - h - m:GetBottom()
				elseif panel.content_alignment == 3 then
					panel.text_offset.x = panel:GetWidth() - w - m:GetRight()
					panel.text_offset.y = panel:GetHeight() - h - m:GetBottom()
				end

				panel.text_offset = panel.text_offset + panel.text_inset
			end

			if not obj.gine_prepared then
				obj.gine_prepare_layout = true
			else
				self:InvalidateLayout(true)
			end
		end)

		hook(obj, "OnMouseInput", function(_, button, press)
			if button == "mwheel_down" then
				self:OnMouseWheeled(1)
			elseif button == "mwheel_up" then
				self:OnMouseWheeled(-1)
			else
				if press then
					self:OnMousePressed(gine.GetMouseCode(button))
				else
					self:OnMouseReleased(gine.GetMouseCode(button))
				end
			end
		end)

		hook(obj, "OnKeyInput", function(_, key, press)
			if press then
				self:OnKeyCodeTyped(gine.GetKeyCode(key))
				self:OnKeyCodePressed(gine.GetKeyCode(key))
			else
				self:OnKeyCodeReleased(gine.GetKeyCode(key))
			end
		end)

		function obj:IsInsideParent()
			if
				self.Position.x < self.Parent.Size.x and
				self.Position.y < self.Parent.Size.y and
				self.Position.x + self.Size.x > 0 and
				self.Position.y + self.Size.y > 0
			then
				return true
			end

			return false
		end
	---debug.trace()
		return self
	end

	if gine.env.vgui.CreateX then
		gine.env.vgui.CreateX = vgui_Create
	else
		gine.env.vgui.Create = vgui_Create
	end

	local META = gine.GetMetaTable("Panel")

	function META:__tostring()
		return ("Panel: [name:Panel][class:%s][%s,%s,%s,%s]"):format(self.__class, self.x, self.y, self.w, self.h)
	end

	function META:__index(key)

		if key == "x" then
			return self.__obj:GetPosition().x
		elseif key == "y" then
			return self.__obj:GetPosition().y
		elseif key == "w" then
			return self.__obj:GetSize().x
		elseif key == "h" then
			return self.__obj:GetSize().y
		elseif key == "Hovered" then
			return self.__obj:IsMouseOver()
		end

		local val = rawget(META, key)
		if val then
			return val
		end

		local base = rawget(self, "BaseClass")

		if base then
			return rawget(base, key)
		end
	end

	function META:__newindex(k, v)
		if k == "x" then
			self.__obj:SetX(v)
		elseif k == "y" then
			self.__obj:SetY(v)
		else
			rawset(self, k, v)
		end
	end

	META.__eq = nil -- no need

	function META:SetParent(panel)
		if panel and panel.__obj and panel.__obj:IsValid() then
			self.__obj:SetParent(panel.__obj)
		else
			self.__obj:SetParent(gine.gui_world)
		end
	end

	function META:GetChildren()
		local children = {}

		for k,v in pairs(self.__obj:GetChildren()) do
			table.insert(children, gine.WrapObject(v, "Panel"))
		end

		return children
	end

	function META:GetChild(idx)
		return self:GetChildren()[idx - 1]
	end

	function META:SetFGColor(r,g,b,a)
		self.__obj.fg_color.r = r/255
		self.__obj.fg_color.g = g/255
		self.__obj.fg_color.b = b/255
		self.__obj.fg_color.a = (a or 0)/255
	end

	function META:SetBGColor(r,g,b,a)
		self.__obj.bg_color.r = r/255
		self.__obj.bg_color.g = g/255
		self.__obj.bg_color.b = b/255
		self.__obj.bg_color.a = (a or 0)/255
	end

	function META:CursorPos()
		return self.__obj:GetMousePosition():Unpack()
	end

	function META:GetPos()
		return self.__obj:GetPosition():Unpack()
	end

	function META:GetBounds()
		local x,y = self:GetPos()
		local w,h = self:GetSize()

		return x,y,w,h
	end

	function META:IsVisible()
		return self.__obj.Visible
	end

	function META:GetTable()
		return self
	end

	function META:SetPos(x, y)
		self.__obj:SetPosition(Vec2(x or 0, y or 0))
	end

	function META:HasChildren()
		return self.__obj:HasChildren()
	end

	function META:HasParent(panel)
		return panel.__obj:HasChild(self.__obj)
	end

	function META:DockPadding(left, top, right, bottom)
		self.__obj:SetMargin(Rect(left, bottom, right, top))
	end

	function META:DockMargin(left, top, right, bottom)
		self.__obj:SetPadding(Rect(right, bottom, left, top))
	end

	local in_drawing

	function META:PaintAt(x,y,w,h)
	if in_drawing then return end
	in_drawing = true
		render2d.PushMatrix(x,y,w,h)
		self.__obj:OnDraw()
		render2d.PopMatrix()
	in_drawing = false
	end

	function META:SetMouseInputEnabled(b)
		self.__obj:SetIgnoreMouse(not b)
	end

	function META:MouseCapture(b)
		self.__obj:GlobalMouseCapture(b)
	end

	function META:SetKeyboardInputEnabled(b)
		--self.__obj:SetIgnoreMouse(not b)
	end

	function META:GetWide()
		return self.__obj:GetWidth()
	end

	function META:GetTall()
		return self.__obj:GetHeight()
	end

	function META:SetSize(w,h)
		self.__obj:SetSize(Vec2(tonumber(w),tonumber(h)))
		if self.__obj.vgui_dock then
			if self.__obj.Size ~= self.__obj.gine_last_Size then
				self:Dock(self.__obj.vgui_dock)
				self.__obj.gine_last_Size = self.__obj.Size
			end
		end
	end

	function META:GetSize()
		return self.__obj:GetSize():Unpack()
	end

	function META:ChildrenSize()
		return self.__obj:GetSizeOfChildren():Unpack()
	end

	function META:LocalToScreen(x, y)
		return self.__obj:LocalToWorld(Vec2(x or 0, y or 0)):Unpack()
	end

	function META:ScreenToLocal(x, y)
		return self.__obj:WorldToLocal(Vec2(x,y)):Unpack()
	end

	do
		function META:SetFontInternal(font)
			self.__obj.font_internal = font or "default"
			if not gine.render2d_fonts[self.__obj.font_internal:lower()] then
				--llog("font ", self.__obj.font_internal, " does not exist")
				self.__obj.font_internal = "default"
			end
		end

		function META:SetText(text)
			if self.__obj.vgui_type == "textentry" then
				self.__obj:SetText(text)
			else
				self.__obj.text_internal = gine.translation2[text] or text
			end
		end
	end

	function META:SetAlpha(a)
		self.__obj.DrawAlpha = a/255
	end

	function META:GetAlpha()
		return self.__obj.DrawAlpha * 255
	end

	function META:GetParent()
		local parent = self.__obj:GetParent()

		if parent:IsValid() then
			return gine.WrapObject(parent, "Panel")
		end

		return nil
	end

	function META:InvalidateLayout(now)
		if self.in_layout then return end
		if now then
			self.in_layout = true
			self:ApplySchemeSettings()
			self:PerformLayout(self.__obj:GetWidth(), self.__obj:GetHeight())
			self.in_layout = nil
		else
			self.gine_layout = true
		end
	end

	function META:GetContentSize()
		local panel = self.__obj

		if panel.vgui_type == "label" then
			return self:GetTextSize()
		end

		return (panel:GetSizeOfChildren() + panel.text_inset):Unpack()
	end

	function META:GetTextSize()
		local panel = self.__obj

		local w, h = fonts.FindFont(panel.font_internal):GetTextSize(panel.text_internal)
		return w + panel.text_inset.x, h + panel.text_inset.y
	end

	function META:SizeToContents()
		local panel = self.__obj

		local w, h = self:GetContentSize()

		if panel.vgui_type == "label" or self.__obj.vgui_type == "textentry" then
			panel:Layout(true)
			panel:SetSize(Vec2(panel.text_inset.x + panel.Margin.x + w, panel.text_inset.y + panel.Margin.y + h))
			panel.LayoutSize = panel:GetSize():Copy()
		end
	end

	function META:GetValue()
		return self:GetText()
	end

	function META:GetText()
		if self.__obj.vgui_type == "textentry" then
			return self.__obj:GetText()
		elseif self.__obj.vgui_type == "label" then
			return self.__obj.text_internal
		end
		return ""
	end

	function META:SetTextInset(x, y)
		self.__obj.text_inset.x = x
		self.__obj.text_inset.y = y
	end

	function META:SizeToChildren(size_w, size_h)
		if size_w == nil then size_w = true end
		if size_h == nil then size_h = true end

		if size_w and size_h then
			self.__obj:SizeToChildren()
		elseif size_w then
			self.__obj:SizeToChildrenWidth()
		elseif size_h then
			self.__obj:SizeToChildrenHeight()
		end
	end

	function META:SetVisible(b)
		self.__obj:SetVisible(b)
	end

	function META:Dock(enum)
		if enum == gine.env.FILL then
			self.__obj:SetupLayout("center_simple", "fill")
		elseif enum == gine.env.LEFT then
			self.__obj:SetupLayout("center_y_simple", "left", "fill_y")
		elseif enum == gine.env.RIGHT then
			self.__obj:SetupLayout("center_y_simple", "right", "fill_y")
		elseif enum == gine.env.TOP then
			self.__obj:SetupLayout("center_x_simple", "top", "fill_x")
		elseif enum == gine.env.BOTTOM then
			self.__obj:SetupLayout("center_x_simple", "bottom", "fill_x")
		elseif enum == gine.env.NODOCK then
			self.__obj:SetupLayout()
		end
		self.__obj.vgui_dock = enum
	end

	function META:GetDock()
		return self.__obj.vgui_dock or gine.env.NODOCK
	end

	function META:SetCursor(typ)
		self.__obj:SetCursor(typ)
	end

	function META:SetContentAlignment(num)
		self.__obj.content_alignment = num
		self.__obj:Layout()
	end
	function META:SetExpensiveShadow() end
	function META:Prepare()
		self.__obj.gine_prepared = true
		if self.__obj.gine_prepare_layout then
			self:InvalidateLayout()
		end
	end
	function META:SetPaintBorderEnabled() end
	function META:SetPaintBackgroundEnabled(b)
		self.__obj.paint_bg = b
	end

	function META:PaintManual(b)
		self.__obj.draw_manual = b
	end

	function META:SetDrawOnTop(b)
		self.__obj.draw_ontop = b
	end

	do -- z pos stuff
		function META:SetZPos(pos)
			self.__obj:SetChildOrder(pos)
		end

		function META:MoveToBack()
			--self.__obj:Unfocus()
		end

		function META:MoveToFront()
			--self.__obj:BringToFront()
		end

		--function META:SetFocusTopLevel() end

		function META:MakePopup()
		--	self.__obj:BringToFront()
		end
	end

	function META:NoClipping(b)

	end

	function META:ParentToHUD()

	end

	function META:DrawTextEntryText(text_color, highlight_color, cursor_color)

	end

	function META:DrawFilledRect()
		render2d.DrawRect(0,0,self:GetSize())
	end

	function META:DrawOutlinedRect()
		render2d.DrawRect(0,0,self:GetSize())
	end

	function META:SetWrap(b)
		-- text wrap
	end

	--function META:SetWorldClicker() end

	function META:SetAllowNonAsciiCharacters() end


	do -- html
		function META:IsLoading()
			return true
		end

		function META:NewObject(obj)

		end

		function META:NewObjectCallback(obj, func)

		end

		function META:OpenURL()

		end
	end

	-- edit
	do
		function META:GetCaretPos()
			return 0
		end

		function META:SetCaretPos(pos)

		end
	end

	function META:HasFocus()
		return self.__obj:IsFocused()
	end

	function META:SetHTML()

	end

	function META:IsEnabled()
		return true
	end

	function META:HasHierarchicalFocus()
		for _, pnl in ipairs(self.__obj:GetChildrenList()) do
			if pnl.IsFocused and pnl:IsFocused() then
				return true
			end
		end
		return false
	end

	function META:SetPaintedManually()

	end

	function META:AppendText(str)
		self:SetText(self:GetText() .. str)
	end
	function META:InsertColorChange(r,g,b)
		self:SetText(self:GetText() .. ("<color=%s,%s,%s>"):format(r/255, g/255, b/255))
	end

	function META:SetPlayer(ply)
		local steamid = ply:SteamID()

	end

	function META:RequestFocus()
		self.__obj:RequestFocus()
	end

	function META:SetMultiline(b)
		self.__obj.multiline = b
	end

	function META:IsMultiline(b)
		return self.__obj.multiline
	end

	function META:SetFocusTopLevel()

	end

	function META:SetDrawLanguageIDAtLeft()

	end

	function META:GotoTextEnd()

	end

	function META:SetWorldClicker()

	end

	function META:FocusNext()

	end
end
