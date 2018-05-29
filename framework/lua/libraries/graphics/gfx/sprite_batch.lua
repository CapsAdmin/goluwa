local gfx = ... or _G.gfx

local META = prototype.CreateTemplate("sprite_batch")

META:GetSet("AutoFlush", true)

function gfx.CreateSpriteBatch(count)
	local self = META:CreateObject()

	self.count = count
	self.poly = gfx.CreatePolygon2D(6 * count)
	self.poly:SetWorldMatrixMultiply(true)
	self.i = 1

	return self
end

function META:Draw(i)
	render2d.PushMatrix()
	render2d.LoadIdentity()
		self.poly:Draw(i or ((self.i - 1) * 6))
	render2d.PopMatrix()
end

function META:Flush()
	render2d.PushTexture(self.last_tex)
	render2d.PushColor(1,1,1,1)
	render2d.PushAlphaMultiplier(1,1,1,1)
	self:Draw()
	render2d.PopAlphaMultiplier()
	render2d.PopColor()
	render2d.PopTexture()
	self.last_tex = render2d.GetTexture()
	self.i = 1
end

function META:AddRectangle(x,y, w,h, a, ox,oy)
	if render2d.GetTexture() ~= self.last_tex or self.i > self.count then
		if self.AutoFlush then
			self:Flush()
		end
	end

	render2d.PushMatrix()
		if x and y then
			render2d.Translate(x, y)
		end

		if a then
			render2d.Rotate(a)
		end

		if ox then
			render2d.Translate(-ox, -oy)
		end

		if w and h then
			render2d.Scale(w, h)
		end

		local r,g,b,a = render2d.GetColor()
		a = a * render2d.GetAlphaMultiplier()
		self.poly:SetColor(r,g,b,a)
		self.poly:SetUV(render2d.GetRectUV())
		self.poly:SetRect(self.i, 0,0,1,1)
		self.i = self.i + 1

	render2d.PopMatrix()
end

META:Register()