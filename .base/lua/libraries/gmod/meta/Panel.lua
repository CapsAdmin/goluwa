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
	self.__obj:SetPadding(left, top, right, bottom)
end

function META:SetMouseInputEnabled(b)
	self.__obj:SetIgnoreMouse(not b)
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
	return self.__obj:SetSize(Vec2(w,h))
end

function META:SetFontInternal(font)
	self.__obj.font_internal = font
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

function META:Dock(enum)
	if enum == gmod.env.DOCK_FILL then
		self.__obj:SetupLayout("fill")
	elseif enum == gmod.env.DOCK_LEFT then
		self.__obj:SetupLayout("left")
	elseif enum == gmod.env.DOCK_RIGHT then
		self.__obj:SetupLayout("right")
	elseif enum == gmod.env.DOCK_TOP then
		self.__obj:SetupLayout("top")
	elseif enum == gmod.env.DOCK_BOTTOM then
		self.__obj:SetupLayout("bottom")
	elseif enum == gmod.env.DOCK_NODOCK then
		self.__obj:SetupLayout()
	end	
end

function META:Prepare() end
function META:SetPaintBorderEnabled() end
function META:SetPaintBackgroundEnabled() end