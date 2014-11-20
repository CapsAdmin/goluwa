local structs = (...) or _G.structs

local META = {}

META.ClassName = "Rect"

META.NumberType = "float"
META.Args = {{"x", "left"}, {"y", "top"}, {"w", "right"}, {"h", "bottom"}}

function META.Constructor(a, b, c, d)
	if a and not b and not c and not d then
		return a, a, a, a
	end
	
	return a or 0, b or 0, c or 0, d or 0
end

structs.AddAllOperators(META)

function META:Shrink(amt)

	self.x = self.x + amt
	self.y = self.y + amt
	self.w = self.w - (amt * 2)
	self.h = self.h - (amt * 2)

	return self
end

function META:Expand(amt)
	amt = -amt 
	
	self.x = self.x + amt
	self.y = self.y + amt
	self.w = self.w - (amt * 2)
	self.h = self.h - (amt * 2)

	return self
end

function META:Center()

	self.x = self.x - (self.w / 2)
	self.y = self.y - (self.h / 2)

	return self
end

function META:SetPosition(x, y)
	self.x = x
	self.y = y

	return self
end

function META:IsPosInside(v)
	return 
		v.x > self.x and
		v.y > self.y and
		v.x < self.w and
		v.y < self.h
end

function META.IsRectInside(a, b)
	return 
		not 
		(
			b.x > a.x + a.w or
			b.x + b.w < a.x or 
			b.y > a.y + a.h or
			b.y + b.h < a.y
		)		
end

function META:SetSize(w, h)
	self.w = w
	self.h = h

	return self
end

function META:SetX(x)
	self.x = x
	return self
end

function META:SetY(y)
	self.y = y
	return self
end

function META:SetWidth(w)
	self.w = w
	return self
end

function META:SetHeight(h)
	self.h = h
	return self
end

function META:GetPosition()
	return structs.Vec2(self.x, self.y)
end

function META:GetSize()	
	return structs.Vec2(self.w, self.h)
end

function META:GetPosSize()
	return structs.Vec2(self:GetXW(), self:GetYH())
end

function META:GetXW()
	return self.x + self.w
end

function META:GetYH()
	return self.y + self.h
end

function META:GetWidth()
	return self.w - self.x
end

function META:GetHeight()
	return self.h - self.y
end

function META:GetUV4(siz)
	return
	self.x / siz.x,
	self.y / siz.y,
	(self.x + self.w) / siz.x,
	(self.y + self.h) / siz.y
end

function META.GetUV8(R, S)

	local xtl = R.x
	local ytl = R.y
	local xtr = R.x + R.w
	local ytr = R.y

	xtl = xtl / S.x 
	ytl = ytl / S.y
	xtr = xtr / S.x 
	ytr = ytr / S.y

	local xbl = R.x
	local ybl = R.y + R.h
	local xbr = R.x + R.w
	local ybr = R.y + R.h
	
	xbl = xbl / S.x 
	ybl = ybl / S.y
	xbr = xbr / S.x 
	ybr = ybr / S.y

	return
	xtl, ytl,
	xtr, ytr,

	xbl, ybl,
	xbr, ybr
end

structs.Register(META)