local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Panel")

function META:ActionSignal() end
function META:AnimationThink() end
function META:ApplySchemeSettings() end
function META:FinishedURL() end
function META:Init() end
function META:OnChildAdded() end
function META:OnChildRemoved() end
function META:OnCursorEntered() end
function META:OnCursorExited() end
function META:OnCursorMoved() end
function META:OnFocusChanged() end
function META:OnKeyCodePressed() end
function META:OnMousePressed() end
function META:OnMouseReleased() end
function META:OnMouseWheeled() end
function META:OnRemove() end
function META:OpeningURL() end
function META:PageTitleChanged() end
function META:Paint() end
function META:PaintOver() end
function META:PerformLayout() end
function META:ResourceLoaded() end
function META:StatusChanged() end
function META:Think() end

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
		self.__obj:SetParent(gmod.gui_world)
	end
end

function META:GetChildren()
	local children = {}
	
	for k,v in pairs(self.__obj:GetChildren()) do
		table.insert(children, gmod.WrapObject(v, "Panel"))
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

function META:HasParent()
	return self.__obj:HasParent()
end

function META:DockPadding(left, top, right, bottom)
	self.__obj:SetMargin(Rect(left, bottom, right, top))
end

function META:DockMargin(left, top, right, bottom)
	self.__obj:SetPadding(Rect(left, bottom, right, top))
end

local in_drawing

function META:PaintAt(x,y,w,h)
if in_drawing then return end
in_drawing = true
	surface.PushMatrix(x,y,w,h)
	self.__obj:OnDraw()
	surface.PopMatrix()
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
	self.__obj:SetSize(Vec2(w,h))
end

function META:GetSize()
	return self.__obj:GetSize():Unpack()
end

function META:ChildrenSize() 
	return self.__obj:GetSizeOfChildren():Unpack() 
end

function META:LocalToScreen(x, y)
	return self.__obj:LocalToWorld(Vec2(x, y)):Unpack()
end

function META:ScreenToLocal(x, y)
	return self.__obj:WorldToLocal(Vec2(x,y)):Unpack()
end

do
	function META:SetFontInternal(font)
		self.__obj.font_internal = font
	end

	function META:SetText(text)
		self.__obj.text_internal = gmod.translation2[text] or text
	end
end

function META:SetAlpha(a)
	self.__obj.DrawAlpha = a/255
end

function META:GetParent()
	local parent = self.__obj:GetParent()
	
	if parent:IsValid() then
		return gmod.WrapObject(parent, "Panel")
	end
	
	return nil
end

function META:InvalidateLayout(b)
	self.__obj:Layout(b)
end

function META:GetContentSize() 
	local panel = self.__obj

	if panel.vgui_type == "label" then
		return self:GetTextSize()
	end
	
	return 0, 0
end

function META:GetTextSize()
	local panel = self.__obj

	return surface.GetFont(panel.font_internal):GetTextSize(panel.text_internal) 
end

function META:SizeToContents()
	local panel = self.__obj

	local w, h = self:GetContentSize()
	
	if panel.vgui_type == "label" then		
		panel:Layout(true)
		panel:SetSize(Vec2(panel.text_inset.x + panel.Margin.x + w, panel.text_inset.y + panel.Margin.y + h))		
		panel.LayoutSize = panel:GetSize():Copy()
	end
end

function META:GetValue()
	return self:GetText()
end

function META:GetText()
	if self.__obj.vgui_type == "label" then
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
	print(self, size_w, size_h)
	if size_w then
		self.__obj:SizeToChildrenWidth()
	end
	if size_h then
		self.__obj:SizeToChildrenHeight()
	end
end

function META:SetVisible(b)
	self.__obj:SetVisible(b)
end

function META:Dock(enum)
	if enum == gmod.env.FILL then
		self.__obj:SetupLayout("center_simple", "fill")
	elseif enum == gmod.env.LEFT then
		self.__obj:SetupLayout("center_simple", "left", "fill_y")
	elseif enum == gmod.env.RIGHT then
		self.__obj:SetupLayout("center_simple", "right", "fill_y")
	elseif enum == gmod.env.TOP then
		self.__obj:SetupLayout("center_simple", "top", "fill_x")
	elseif enum == gmod.env.BOTTOM then
		self.__obj:SetupLayout("center_simple", "bottom", "fill_x")
	elseif enum == gmod.env.NODOCK then
		self.__obj:SetupLayout()
	end	
	self.__obj.vgui_dock = enum
end

function META:GetDock()
	return self.__obj.vgui_dock or gmod.env.NODOCK
end

function META:SetCursor(typ)
	self.__obj:SetCursor(typ)
end

function META:SetContentAlignment(num) 
	self.__obj.content_alignment = num 
end
function META:SetExpensiveShadow() end
function META:Prepare() self:__setup_events() end
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
		--self.__obj:BringToFront()
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
	surface.DrawRect(0,0,self:GetSize())
end

function META:DrawOutlinedRect()
	surface.DrawRect(0,0,self:GetSize())
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

function META:HasHierarchicalFocus()
	for _, pnl in ipairs(self.__obj:GetChildrenList()) do
		if pnl.IsFocused and pnl:IsFocused() then
			return true
		end
	end
	return false
end
