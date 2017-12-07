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
		return vgui.GetHoveredPanel()
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

	function gui.EnableScreenClicker(b)
		window.SetMouseTrapped(b)
	end
end

do
	gine.AddEvent("GUIPanelMouseInput", function(panel, button, press)
		if press then
			gine.env.hook.Run("VGUIMousePressed", gine.WrapObject(panel, "Panel"), gine.GetMouseCode(button))
		end
	end)

	gine.gui_world = gine.gui_world or NULL

	local function hook(obj, func_name, callback)
		--print(obj, func_name, callback)
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
			gine.gui_world:SetIgnoreLayout(true)

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
			obj:SetMultiline(false)
			obj:SetEditable(false)
			obj.label.markup:SetPreserveTabsOnEnter(false)
			--local draw_func = obj.label.OnPostDraw
			obj.label.DrawTextEntryText = function() end
			--obj.label.OnPostDraw = function() end
		else
			obj = gui.CreatePanel("base")
		end

		local self = gine.WrapObject(obj, "Panel")

		obj:SetName("gmod_" .. name)

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
		obj:ResetLayout()
--		obj:SetAllowKeyboardInput(false)
		obj:SetFocusOnClick(false)
		obj:SetBringToFrontOnClick(false)
		obj:SetClipping(true)

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
		function self:OnGetFocus() end
		function self:OnLoseFocus() end

		obj.OnDraw = function()
			if obj.draw_manual and not obj.in_paint_manual then return end

			local w, h = obj:GetWidth(), obj:GetHeight()

			local paint_bg = self:Paint(w, h)

			if obj.paint_bg and paint_bg ~= nil then
				render2d.SetTexture()
				render2d.SetColor(obj.bg_color:Unpack())
				render2d.DrawRect(0,0,obj.Size.x,obj.Size.y)
			end

			if class == "label" then
				if obj.text_internal and obj.text_internal ~= "" then
					local text = obj.text_internal
					local font = gine.render2d_fonts[obj.font_internal:lower()]

					if obj.gmod_wrap then
						text = gfx.WrapString(text, w, font)
					else
						text = gfx.DotLimitText(text, w, font)
					end

					if obj.expensive_shadow_dir then
						render2d.SetColor(obj.expensive_shadow_color:Unpack())
						font:DrawString(text, obj.text_offset.x + obj.expensive_shadow_dir, obj.text_offset.y + obj.expensive_shadow_dir)
					end

					render2d.SetColor(obj.fg_color:Unpack())
					font:DrawString(text, obj.text_offset.x, obj.text_offset.y)
				end
			end

			self:PaintOver(obj:GetWidth(), obj:GetHeight())

			if self.gine_layout then
				self:InvalidateLayout(true)
				self.gine_layout = nil
			end
		end

		obj:CallOnRemove(function() obj.marked_for_deletion = true self:OnDeletion() end)

		if class == "textentry" then
			hook(obj, "OnCharInput", function(_, char)
				if self.AllowInput then
					return self:AllowInput(char)
				end
			end)
			hook(obj, "OnTextChanged", function()
				local text = self:GetText():gsub("\t", "")
				if text ~= "" then
					for _, char in ipairs(text:utotable()) do
						self.override_text = char
						self:OnTextChanged()
						self.override_text = nil
					end
				end
			end)
		end

		hook(obj, "OnFocus", function() self:OnGetFocus() end)
		hook(obj, "OnUnfocus", function() self:OnLoseFocus() end)

		hook(obj, "OnUpdate", function() self:Think() self:AnimationThink() end)
		hook(obj, "OnMouseMove", function(_, x, y) self:OnCursorMoved(x, y) end)
		hook(obj, "OnMouseEnter", function() gine.env.ChangeTooltip(self) self:OnCursorEntered() end)
		hook(obj, "OnMouseExit", function() gine.env.EndTooltip(self) self:OnCursorExited() end)

		hook(obj, "OnPostLayout", function()
			local panel = obj

			if panel.vgui_type == "label" then
				local w, h = panel.gine_pnl:GetTextSize()

				if panel.content_alignment == 5 then
					panel.text_offset = (panel:GetSize() / 2) - (Vec2(w, h) / 2)
				elseif panel.content_alignment == 4 then
					panel.text_offset.x = 0
					panel.text_offset.y = (panel:GetHeight() / 2) - (h / 2)
				elseif panel.content_alignment == 6 then
					panel.text_offset.x = panel:GetWidth() - w
					panel.text_offset.y = (panel:GetHeight() / 2) - (h / 2)
				elseif panel.content_alignment == 2 then
					panel.text_offset.x = (panel:GetWidth() / 2) - (w / 2)
					panel.text_offset.y = panel:GetHeight() - h
				elseif panel.content_alignment == 8 then
					panel.text_offset.x = (panel:GetWidth() / 2) - (w / 2)
					panel.text_offset.y = 0
				elseif panel.content_alignment == 7 then
					panel.text_offset.x = 0
					panel.text_offset.y = 0
				elseif panel.content_alignment == 9 then
					panel.text_offset.x = panel:GetWidth() - w
					panel.text_offset.y = 0
				elseif panel.content_alignment == 1 then
					panel.text_offset.x = 0
					panel.text_offset.y = panel:GetHeight() - h
				elseif panel.content_alignment == 3 then
					panel.text_offset.x = panel:GetWidth() - w
					panel.text_offset.y = panel:GetHeight() - h
				end

				if w > panel:GetWidth() then
					panel.text_offset.x = 0
				end

				panel.text_offset = panel.text_offset + panel.text_inset
				--panel.text_offset.x = panel.text_offset.x + panel:GetPadding():GetLeft()
				--panel.text_offset.y = panel.text_offset.y + panel:GetPadding():GetTop()
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
			if self.popup then
				return true
			end

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

		obj.name_prepare = name

		return self
	end

	if gine.env.vgui.CreateX then
		gine.env.vgui.CreateX = vgui_Create
	else
		gine.env.vgui.Create = vgui_Create
	end

	local META = gine.GetMetaTable("Panel")

	function META:Prepare()
		if self.__obj.name_prepare ~= self.ClassName then return end
		if self.__obj.gine_prepared then return end

		self.__obj.gine_prepared = true

		if self.__obj.gine_prepare_layout then
			self:InvalidateLayout()
		end

		hook(self.__obj, "OnChildAdd", function(_, child)
			self:OnChildAdded(gine.WrapObject(child, "Panel"))
		end)

		hook(self.__obj, "OnChildRemove", function(_, child)
			self:OnChildRemoved(gine.WrapObject(child, "Panel"))
		end)
	end

	function META:IsMarkedForDeletion()
		return self.__obj.marked_for_deletion
	end

	function META:__tostring()
		return ("Panel: [name:Panel][class:%s][%s,%s,%s,%s]"):format(self.__class, self.x, self.y, self.w, self.h)
	end

	function META:__index(key)

		if key == "x" or key == "X" then
			return self.__obj:GetPosition().x
		elseif key == "y" or key == "Y" then
			return self.__obj:GetPosition().y
		elseif key == "w" or key == "W" then
			return self.__obj:GetSize().x
		elseif key == "h" or key == "H" then
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
		if k == "x" or k == "X" then
			self.__obj:SetX(v)
		elseif k == "y" or k == "Y" then
			self.__obj:SetY(v)
		else
			rawset(self, k, v)
		end
	end

	META.__eq = nil -- no need

	function META:SetParent(panel)
		if panel and panel:IsValid() and panel.__obj and panel.__obj:IsValid() then
			self.__obj:SetParent(panel.__obj)
		else
			self.__obj:SetParent(gine.gui_world)
		end
	end

	function META:SetAutoDelete(b)
		self.__obj:SetRemoveOnParentRemove(b)
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

	function META:SetName(name)
		self.__obj.name = name
	end

	function META:GetName(name)
		return self.__obj.name
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
		self.__obj:SetMargin(Rect(right, bottom, left, top))
	end

	function META:DockMargin(left, top, right, bottom)
		self.__obj:SetPadding(Rect(left, top, right, bottom))
	end

	function META:SetMouseInputEnabled(b)
		self.__obj:SetIgnoreMouse(not b)
	end

	function META:MouseCapture(b)
		self.__obj:GlobalMouseCapture(b)
	end

	function META:SetKeyboardInputEnabled(b)
		--self.__obj:SetAllowKeyboardInput(b)
	end

	function META:IsKeyboardInputEnabled()
		return self.__obj:GetAllowKeyboardInput()
	end

	function META:GetWide()
		return self.__obj:GetWidth()
	end

	function META:GetTall()
		return self.__obj:GetHeight()
	end

	function META:SetSize(w,h)
		w = tonumber(w)
		h = tonumber(h) or w

		self.__obj:SetSize(Vec2(w, h))

		if self.__obj.vgui_dock then
			if self.__obj.Size ~= self.__obj.gine_last_Size then
				self.__obj.in_layout = true
				self:Dock(self.__obj.vgui_dock)
				self.__obj.in_layout = false
				self.__obj:Layout()
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

		function META:GetFont()
			return self.__obj.font_internal or "default"
		end

		function META:SetText(text)
			if self.__obj.vgui_type == "textentry" then
				self.__obj.in_layout = true
				text = tostring(text):gsub("\t", "")
				self.__obj:SetText(text)
				self.__obj.in_layout = false
			else
				self.__obj.text_internal = gine.translation2[text] or text
			--	self.__obj.label_settext = system.GetFrameNumber()
			end
		end
	end

	function META:SetAlpha(a)
		self.__obj.DrawAlpha = (a/255) ^ 2
		self.__obj.gmod_draw_alpha = a
	end

	function META:GetAlpha()
		return self.__obj.gmod_draw_alpha or 255
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
			self.in_layout = false
		else
			self.gine_layout = true
		end
	end

	function META:GetContentSize()
		local panel = self.__obj

		if panel.vgui_type == "label" then
			self.get_content_size = true
			local w,h = self:GetTextSize()
			self.get_content_size = false
			return w,h
		end


		return panel:GetSizeOfChildren():Unpack()
	end

	function META:GetTextSize()
		local panel = self.__obj

		-- in gmod the text size isn't correct until next frame
		--[[if panel.label_settext then
			if panel.label_settext == system.GetFrameNumber() then
				return 0, 0
			end
			panel.label_settext = nil
		end]]

		local font = gine.render2d_fonts[panel.font_internal:lower()]
		local text = tostring(panel.text_internal or "")

		if not self.get_content_size then
			if panel.gmod_wrap then
				text = gfx.WrapString(text, panel.Parent:IsValid() and panel.Parent:GetWidth() or self:GetWide(), font)
			elseif not text:find("\n", nil, true) then
				text = gfx.DotLimitText(text, self:GetWide(), font)
			end
		end

		local w, h = font:GetTextSize(text)

		if panel.gmod_wrap and panel.Parent:IsValid() then
			w = panel.Parent:GetWidth()
		end

		return w + panel.text_inset.x, h + panel.text_inset.y
	end

	function META:SizeToContents()
		local panel = self.__obj

		if panel.vgui_type == "label" or self.__obj.vgui_type == "textentry" then
			local w, h = self:GetContentSize()

			--panel:Layout(true)
			panel:SetSize(Vec2(panel.text_inset.x + w, panel.text_inset.y + h))
			panel.LayoutSize = panel:GetSize():Copy()
		end
	end

	function META:GetValue()
		if self.override_text then
			return self.override_text
		end
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
		self.__obj.in_layout = true -- hack
		self.__obj:SetVisible(b)
		self.__obj.in_layout = false
	end

	function META:Dock(enum)
		if enum == gine.env.FILL then
			self.__obj:SetupLayout("gmod_fill")
		elseif enum == gine.env.LEFT then
			self.__obj:SetupLayout("gmod_left")
		elseif enum == gine.env.RIGHT then
			self.__obj:SetupLayout("gmod_right")
		elseif enum == gine.env.TOP then
			self.__obj:SetupLayout("gmod_top")
		elseif enum == gine.env.BOTTOM then
			self.__obj:SetupLayout("gmod_bottom")
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
	function META:SetExpensiveShadow(dir, color)
		self.__obj.expensive_shadow_dir = dir
		self.__obj.expensive_shadow_color = ColorBytes(color.r, color.g, color.b, color.a)
	end
	function META:SetPaintBorderEnabled() end
	function META:SetPaintBackgroundEnabled(b)
		self.__obj.paint_bg = b
	end

	function META:SetDrawOnTop(b)
		self.__obj.draw_ontop = b
		self.__obj:SetChildOrder(math.huge)
	end

	do -- z pos stuff
		function META:SetZPos(pos)
			self.__obj:SetChildOrder(-pos)
		end

		function META:MoveToBack()
			--self.__obj:Unfocus()
		end

		function META:MoveToFront()
			--self.__obj:BringToFront()
		end

		--function META:SetFocusTopLevel() end

		function META:MakePopup()
			self.__obj:BringToFront()
			self.__obj:RequestFocus()
			self.__obj:SetIgnoreMouse(false)
			self.__obj:MakePopup()

			if self.__obj.vgui_type == "textentry" then
				self.__obj:SetEditable(true)
				self.__obj:SetAllowKeyboardInput(true)
				self.__obj:SetFocusOnClick(true)
			else
				for _, child in ipairs(self.__obj:GetChildrenList()) do
					if child.vgui_type == "textentry" then
						child:SetEditable(true)
						child:SetAllowKeyboardInput(true)
						child:SetFocusOnClick(true)
					end
				end
			end
		end
	end

	function META:NoClipping(b)

	end

	function META:ParentToHUD()

	end

	function META:DrawFilledRect()
		gine.env.surface.DrawRect(0,0,self:GetSize())
	end

	function META:DrawOutlinedRect()
		gine.env.surface.DrawOutlinedRect(0,0, self:GetSize())
	end

	function META:SetWrap(b)
		self.__obj.gmod_wrap = b
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

		function META:SetHTML()

		end
	end

	-- edit
	do
		function META:GetCaretPos()
			return self.__obj:GetCaretSubPosition()
		end

		function META:SetCaretPos(pos)
			self.__obj:SetCaretSubPosition(pos)
		end

		function META:GotoTextEnd()
			self.__obj:SetCaretSubPosition(math.huge)
		end

		function META:SetVerticalScrollbarEnabled(b)

		end

		function META:AppendText(str)
			self:SetText(self:GetText() .. str)
		end

		function META:InsertColorChange(r,g,b)
			self:SetText(self:GetText() .. ("<color=%s,%s,%s>"):format(r/255, g/255, b/255))
		end

		function META:DrawTextEntryText(text_color, highlight_color, cursor_color)
			self.__obj.label:DrawTextEntryText()
		end

		function META:SelectAllText()
			self.__obj:SelectAll()
		end
	end

	function META:HasFocus()
		return self.__obj:IsFocused()
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

	function META:SetPaintedManually(b)
		self.__obj.draw_manual = b
	end

	do
		local in_drawing

		function META:PaintAt(x,y,w,h)
			if in_drawing then return end
			self.__obj.in_paint_manual = true
			in_drawing = true
			render2d.PushMatrix(x,y,w,h)
			self.__obj:OnDraw()
			render2d.PopMatrix()
			in_drawing = false
			self.__obj.in_paint_manual = false
		end

		function META:PaintManual()
			if in_drawing then return end
			self.__obj.in_paint_manual = true
			in_drawing = true
			self.__obj:OnDraw()
			in_drawing = false
			self.__obj.in_paint_manual = false
		end
	end

	function META:SetPlayer(ply)
		local steamid = ply:SteamID()

	end

	function META:RequestFocus()
		if self.__obj.vgui_type == "textentry" then
			self:SetKeyboardInputEnabled(true)
		end
		self.__obj:RequestFocus()
	end

	function META:SetMultiline(b)
		self.__obj:SetMultiline(b)
	end

	function META:IsMultiline()
		return self.__obj:GetMultiline()
	end

	function META:SetFocusTopLevel()

	end

	function META:SetDrawLanguageIDAtLeft()

	end


	function META:DoModal()
		self.__obj:RequestFocus()
	end

	function META:SetWorldClicker()

	end

	function META:FocusNext()

	end
end
