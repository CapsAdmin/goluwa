local META = {}

META.ClassName = "RectF"

META.NumberType = "float"
META.Args = {"x", "y", "w", "h"}

function META.Constructor(a,b,c,d)
	if a and not b and not c and not d then
		return a,a,a,a
	end
	
	if typex(a) == "vec2" and typex(b) == "vec2" then
		return a.x, a.y, b.w, b.h
	end
	
	if type(a) == "number" and type(b) == "number" and typex(c) == "vec2" then
		return a, b, c.w, c.h
	end
	
	if type(b) == "number" and type(c) == "number" and typex(a) == "vec2" then
		return a.x, a.y, b, c
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

function META:SetPos(var)
	if typex(var) == "vec2" then
		self.x = var.x
		self.y = var.y
	else
		self.x = var
		self.y = var
	end

	return self
end

function META:SetSize(var)
	if typex(var) == "vec2" then
		self.w = var.x
		self.h = var.y
	else
		self.w = var
		self.h = var
	end

	return self
end

function META:GetPos()
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