local gmod = ... or gmod

local META = gmod.env.FindMetaTable("Panel")

function META:__index(key)
	if META[key] then 
		return META[key] 
	end
	
	local base = rawget(self, "BaseClass")
	
	if base and base[key] then
		return base[key]
	end
end

function META:GetChildren()
	local children = {}
	
	for k,v in pairs(self.__obj:GetChildren()) do
		table.insert(children, gmod.WrapObject(v, "Panel"))
	end
	
	return children
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
	self.__obj:SetPosition(Vec2(x,y))
end

function META:HasChildren()
	return self.__obj:HasChildren()
end

function META:Remove()
	self.__obj:Remove()
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
	self.__obj:SetSize(self.__obj:GetSizeOfChildren())
end

function META:Dock(enum)
	if enum == gmod.env.FILL then
		self.__obj:SetupLayout("fill")
	elseif enum == gmod.env.LEFT then
		self.__obj:SetupLayout("left")
	elseif enum == gmod.env.RIGHT then
		self.__obj:SetupLayout("right")
	elseif enum == gmod.env.TOP then
		self.__obj:SetupLayout("top")
	elseif enum == gmod.env.BOTTOM then
		self.__obj:SetupLayout("bottom")
	elseif enum == gmod.env.NODOCK then
		self.__obj:SetupLayout()
	end	
end

function META:SetCursor(typ)
	self.__obj:SetCursor(typ)
end

function META:SetContentAlignment(num) end
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