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

function META:Prepare() end
function META:SetPaintBorderEnabled() end
function META:SetPaintBackgroundEnabled() end