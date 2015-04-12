local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Panel")

function META:__index(key)
	
	if key == "x" then
		return self.__obj:GetPosition().x
	elseif key == "y" then
		return self.__obj:GetPosition().y
	elseif key == "w" then
		return self.__obj:GetSize().w
	elseif key == "h" then
		return self.__obj:GetSize().h
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

META.__eq = nil -- no need

function META:SetParent(panel)
	self.__obj:SetParent(panel and panel.__obj or NULL)
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

function META:IsVisible()
	return self.__obj:IsVisible()
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

function META:DockPadding(left, top, right, bottom)
	self.__obj:SetPadding(Rect(left, top, right, bottom))
end

function META:DockMargin(left, top, right, bottom)
	self.__obj:SetMargin(Rect(left, top, right, bottom))
end

function META:SetMouseInputEnabled(b)
	self.__obj:SetIgnoreMouse(not b)
end

function META:MouseCapture(b)
	self:SetMouseInputEnabled(b)
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

function META:LocalToScreen(x, y)
	return self.__obj:LocalToWorld(Vec2(x, y)):Unpack()
end

do
	function META:SetFontInternal(font)
		self.__obj.font_internal = font
	end

	function META:SetText(text)
		self.__obj.text_internal = text
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
	
	return NULL
end

function META:InvalidateLayout(b)
	self.__obj:Layout(b)
end

function META:SizeToContents()
	local panel = self.__obj
	
	if panel.vgui_type == "label" then
		local w, h = surface.GetFont(panel.font_internal):GetTextSize(panel.text_internal)
		
		panel:Layout(true)
		
		local size = panel.text_offset + Vec2(w, h)
		panel:SetSize(size)
		
		panel.LayoutSize = panel:GetSize():Copy()
	end
end

function META:SetTextInset(x, y)
	self.__obj.Margin.x = x
	self.__obj.Margin.y = y
end

function META:SizeToChildren()
	self.__obj:SetSize(self.__obj:GetSizeOfChildren())
end

function META:SetVisible(b)
	self.__obj:SetVisible(b)
end

function META:Dock(enum)
	if enum == gmod.env.FILL then
		self.__obj:SetupLayout("center_simple", "fill")
	elseif enum == gmod.env.LEFT then
		self.__obj:SetupLayout("left", "fill_y")
	elseif enum == gmod.env.RIGHT then
		self.__obj:SetupLayout("right", "fill_y")
	elseif enum == gmod.env.TOP then
		self.__obj:SetupLayout("top", "fill_x")
	elseif enum == gmod.env.BOTTOM then
		self.__obj:SetupLayout("bottom", "fill_x")
	elseif enum == gmod.env.NODOCK then
		self.__obj:SetupLayout()
	end	
end

function META:SetCursor(typ)
	self.__obj:SetCursor(typ)
end

function META:SetContentAlignment(num) 
	self.__obj.content_alignment = num 
end
function META:SetExpensiveShadow() end
function META:Prepare() end
function META:SetPaintBorderEnabled() 

end
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
		self.__obj:BringToFront()
	end

	function META:MoveToFront()

	end
	
	function META:SetFocusTopLevel()
	
	end
end

function META:ParentToHUD()
	
end

function META:DrawTextEntryText(text_color, highlight_color, cursor_color)
	
end

function META:SetWrap(b)
	-- text wrap
end

function META:SetWorldClicker()
end

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

function META:HasFocus()
	return self.__obj:IsFocused()
end

function META:HasHierarchicalFocus()
	for _, pnl in pairs(self.__obj:GetChildrenList()) do
		if pnl:IsFocused() then
			return true
		end
	end
	return false
end

function META:GetContentSize() return self.__obj:GetSizeOfChildren():Unpack() end
function META:ChildrenSize() return self.__obj:GetSizeOfChildren():Unpack() end