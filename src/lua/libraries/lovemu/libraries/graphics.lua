if not GRAPHICS then return end

local love = (...) or _G.lovemu.love

local love = ... or love

love.graphics = {}

local function ADD_FILTER(obj)
	obj.setFilter = function(s, min, mag, anistropy)

		lovemu.textures[s]:SetMinFilter(min)
		lovemu.textures[s]:SetMagFilter(mag)

		s.filter_min = min
		s.filter_mag = mag
		s.filter_anistropy = anistropy
	end

	obj.getFilter = function() return s.filter_min, s.filter_mag, s.filter_anistropy end
end

local FILTER_MIN = "linear"
local FILTER_MAG = "linear"
local FILTER_ANISOTROPY = 1

do -- filter
	function love.graphics.setDefaultImageFilter(min, mag, anisotropy) --partial
		FILTER_MIN = min
		FILTER_MAG = mag
		FILTER_ANISOTROPY = anisotropy
	end

	love.graphics.setDefaultFilter = love.graphics.setDefaultImageFilter
end

do -- quad
	local Quad = {}
	Quad.Type = "Quad"

	local function refresh(vertices, x,y,w,h, sw, sh)
		vertices[0].x = 0;
		vertices[0].y = 0;
		vertices[1].x = 0;
		vertices[1].y = h;
		vertices[2].x = w;
		vertices[2].y = h;
		vertices[3].x = w;
		vertices[3].y = 0;

		vertices[0].s = x/sw;
		vertices[0].t = y/sh;
		vertices[1].s = x/sw;
		vertices[1].t = (y+h)/sh;
		vertices[2].s = (x+w)/sw;
		vertices[2].t = (y+h)/sh;
		vertices[3].s = (x+w)/sw;
		vertices[3].t = y/sh;
	end

	function Quad:flip() -- partial

	end

	function Quad:getViewport()
		return self.x, self.y, self.w, self.h
	end

	function Quad:setViewport(x,y,w,h)
		self.x = x
		self.y = y
		self.w = w
		self.h = h

		refresh(self.vertices, self.x,self.y,self.w,self.h, self.sw, self.sh)
	end


	function love.graphics.newQuad(x,y,w,h, sw,sh) -- partial
		local self = lovemu.CreateObject(Quad)

		local vertices = {}

		for i = 0, 3 do
			vertices[i] = {x = 0, y = 0, s = 0, t = 0}
		end

		self.x = x
		self.y = y
		self.w = w
		self.h = h

		self.sw = sw or 1
		self.sh = sh or 1

		self.vertices = vertices

		refresh(self.vertices, x,y,w,h, sw,sh)

		return self
	end
end

love.graphics.origin = surface.LoadIdentity
love.graphics.translate = surface.Translate
love.graphics.scale = surface.Scale
love.graphics.rotate = surface.Rotate
love.graphics.push = surface.PushMatrix
love.graphics.pop = surface.PopMatrix

local cr, cg, cb, ca = 0, 0, 0, 0

function love.graphics.setCaption(title)
	window.SetTitle(title)
end


function love.graphics.getWidth()
	return render.GetWidth()
end

function love.graphics.getHeight()
	return render.GetHeight()
end

function love.graphics.setMode() -- partial

end

function love.graphics.reset() -- partial

end

function love.graphics.isSupported(what) -- partial
	if what == "multicanvas" then
		return false
	end
	return true
end

function love.graphics.setColor(r, g, b, a)
	if type(r) == "number" then
		cr = r or 0
		cg = g or 0
		cb = b or 0
		ca = a or 255
	else
		cr = r[1] or 0
		cg = r[2] or 0
		cb = r[3] or 0
		ca = r[4] or 255
	end

	surface.SetColor(cr/255, cg/255, cb/255, ca/255)
end

function love.graphics.getColor()
	return cr, cg, cb, ca
end

do -- background
	local br, bg, bb, ba = 0, 0, 0, 0

	function love.graphics.setBackgroundColor(r, g, b, a)
		if type(r) == "number" then
			br = r or 0
			bg = g or 0
			bb = b or 0
			ba = a or 255
		else
			br = r[1] or 0
			bg = r[2] or 0
			bb = r[3] or 0
			ba = r[4] or 255
		end
	end

	function love.graphics.getBackgroundColor()
		return br, bg, bb, ba
	end

	function love.graphics.clear()
		surface.SetWhiteTexture()
		surface.SetColor(br/255,bg/255,bb/255,ba/255)
		surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
		surface.SetColor(cr/255,cg/255,cb/255,ca/255)
	end
end

do
	function love.graphics.setBlendMode(mode)
		render.SetBlendMode(mode)
	end

	function love.graphics.getBlendMode()
		return render.GetBlendMode()
	end
end

do -- points
	function love.graphics.setPointStyle(style)
		surface.SetPointStyle(style)
	end

	function love.graphics.getPointStyle()
		return surface.GetPointStyle()
	end

	function love.graphics.setPointSize(size)
		surface.SetPointSize(size)
	end

	function love.graphics.getPointSize()
		return surface.GetPointSize()
	end

	function love.graphics.setPoint(size, style)
		surface.SetPointSize(size)
		surface.SetPointStyle(style)
	end

	function love.graphics.point(x, y)
		--surface.DrawPoint(x, y)
		surface.DrawRect(x, y, 1, 1)
	end
end


do -- font

	local Font = {}

	Font.Type = "Font"

	function Font:getWidth(str)
		str = str or "W"
		return self.font:GetTextSize()
	end

	function Font:getHeight(str)
		str = str or "W"
		return select(2, self.font:GetTextSize())
	end

	function Font:setLineHeight(num)
		self.line_height = num
	end

	function Font:getLineHeight(num)
		self.line_height = num
	end

	function Font:getWrap() -- partial
		return 1, 1
	end

	function Font:setFilter(filter)
		self.filter = filter
	end

	function Font:getFilter()
		return self.filter
	end

	function Font:setFallbacks(...)

	end

	local i = 0

	local function create_font(path, size, glyphs, texture)
		local self = lovemu.CreateObject(Font)

		self.font = surface.CreateFont("lovemu_" .. path .. i, {
			size = size,
			path = path,
			filtering = FILTER_MIN,
			glyphs = glyphs,
			texture = texture,
		})


		self.Name = self.font:GetName()

		i = i + 1

		local w, h = self.font:GetTextSize("W")
		self.Size = size or w

		return self
	end

	function love.graphics.newFont(a, b)
		local font = a
		local size = b

		if type(a) == "number" then
			font = "fonts/vera.ttf"
			size = a
		end

		if not a then
			font = "fonts/vera.ttf"
			size = b or 12
		end

		size = size or 12

		return create_font(font, size)
	end

	function love.graphics.newImageFont(path, glyphs)
		local tex
		if lovemu.Type(path) == "Image" then
			tex = lovemu.textures[path]
			path = "memory"
		end
		return create_font(path, nil, glyphs, tex)
	end

	local current_font
	local default_font

	function love.graphics.setFont(font)
		current_font = font
		surface.SetFont(font.font)
	end

	function love.graphics.getFont()
		if not default_font then
			default_font = love.graphics.newFont(12)
		end
		return current_font or default_font
	end

	function love.graphics.setNewFont(...)
		love.graphics.setFont(love.graphics.newFont(...))
	end

	function love.graphics.print(text, x, y, r, sx, sy)
		x = x or 0
		y = y or 0
		sx = sx or 1
		sy = sy or 1
		r = r or 0

		surface.SetColor(cr/255, cg/255, cb/255, ca/255)
		--surface.Scale(sx, sy)
		surface.SetTextPosition(x, y)
		surface.DrawText(text)
		--surface.Scale(-sx, -sy)
	end

	function love.graphics.printf(text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky)

		text = tostring(text)
		x = x or 0
		y = y or 0
		limit = limit or 0
		align = align or "left"
		sx = sx or 1
		sy = sy or 1
		r = r or 0
		ox = ox or 0
		oy = oy or 0
		kx = kx or 0
		ky = ky or 0

		if align == "center" then
			x = x - (surface.GetTextSize(text) / 2)
		end

		surface.SetColor(cr/255, cg/255, cb/255, ca/255)
		surface.SetTextPosition(0, 0)
		surface.Translate(x, y)
		surface.DrawText(text)
		surface.Translate(-x, -y)
		do return end
		-- todo: is this really a format function?

		local lines = string.explode(text, "\n")

		surface.SetColor(cr/255, cg/255, cb/255, ca/255)
		--surface.Scale(sx, sy)

		for i = 1, #lines do
			surface.SetTextPosition(x, y + (current_font.Size+(current_font.Size*125/100) * (i - 1)))
			surface.DrawText(lines[i])
		end

		--surface.Scale(-sx, -sy)
	end
end

do -- line
	local WIDTH = 1
	local STYLE = "huh"

	function love.graphics.setLineStyle(s)
		STYLE = s
	end

	function love.graphics.setLineStyle(s)
		STYLE = s
	end

	function love.graphics.setLineWidth(w)
		WIDTH = w
	end

	function love.graphics.getLineStyle()
		return STYLE
	end

	function love.graphics.getLineWidth()
		return WIDTH
	end

	function love.graphics.line(...)
		local tbl = {...}

		if type(tbl[1]) == "table" then
			tbl = tbl[1]
		end

		for i = 1, #tbl, 4 do
			local x1, y1, x2, y2 = tbl[i+0], tbl[i+2], tbl[i+2], tbl[i+3]
			if x1 and y1 and x2 and y2 then
				surface.DrawLine(x1, y1, x2, y2, WIDTH, false)
			end
		end
	end
end

do -- canvas
	local Canvas = {}
	Canvas.Type = "Canvas"

	ADD_FILTER(Canvas)

	function Canvas:renderTo(cb)
		self.fb:Begin()
		cb()
		self.fb:End()
	end

	function Canvas:getWidth()
		return self.w
	end

	function Canvas:getHeight()
		return self.h
	end

	function Canvas:getImageData()

	end

	function Canvas:clear(...)
		self.fb:Begin()
		love.graphics.clear(...)
		self.fb:End()
	end

	function Canvas:setWrap()

	end

	function Canvas:getWrap()

	end

	function love.graphics.newCanvas(w, h) -- partial
		w = w or render.GetWidth()
		h = h or render.GetHeight()

		local self = lovemu.CreateObject(Canvas)

		self.fb = render.CreateFrameBuffer(Vec2(w, h), {
			mag_filter = FILTER_MAG,
			min_filter = FILTER_MIN,
		})

		lovemu.textures[self] = self.fb:GetTexture()

		return self
	end

	local CANVAS

	function love.graphics.setCanvas(canvas) -- partial
		CANVAS = canvas

		if canvas then
			canvas.fb:Bind()
			render.SetViewport(0, 0, canvas.fb:GetTexture():GetSize().x, canvas.fb:GetTexture():GetSize().y)
		else
			render.GetScreenFrameBuffer():Bind()
			render.SetViewport(0, 0, window.GetSize():Unpack())
		end
	end

	function love.graphics.getCanvas() -- partial
		return CANVAS
	end
end

do -- image
	local Image = {}

	Image.Type = "Image"

	function Image:getWidth()
		return lovemu.textures[self]:GetSize().x
	end

	function Image:getHeight()
		return lovemu.textures[self]:GetSize().y
	end

	function Image:getDimensions()
		return lovemu.textures[self]:GetSize().x, lovemu.textures[self]:GetSize().y
	end

	function Image:getHeight()
		return lovemu.textures[self]:GetSize().y
	end

	ADD_FILTER(Image)

	function Image:setWrap()  --partial

	end

	function Image:getWrap() --partial

	end

	function love.graphics.newImage(path) -- partial
		if lovemu.Type(path) == "ImageData" then
			return path
		else
			local self = lovemu.CreateObject(Image)

			local tex = render.CreateTextureFromPath(path)
			tex:SetMinFilter(FILTER_MIN)
			tex:SetMagFilter(FILTER_MAG)
			lovemu.textures[self] = tex

			return self
		end
	end

	function love.graphics.newImageData(path) -- partial
		local self = lovemu.CreateObject(Image)

		local tex = render.CreateTextureFromPath(path)
		tex:SetMinFilter(FILTER_MIN)
		tex:SetMagFilter(FILTER_MAG)
		lovemu.textures[self] = tex

		return self
	end
end

do -- stencil
	local STENCIL = false

	function love.graphics.newStencil(func) --partial

	end

	function love.graphics.setStencil(func) --partial

	end

	function love.graphics.setStencilTest(b)
		STENCIL = b
	end

	function love.graphics.getStencilTest()
		return STENCIL
	end

	function love.graphics.stencil(stencilfunction, keepbuffer)

	end
end

function love.graphics.rectangle(mode, x, y, w, h)
	if mode == "fill" then
		surface.SetWhiteTexture()
		surface.DrawRect(x, y, w, h)
	else
		love.graphics.line(x,y, x+w,y)
		love.graphics.line(x,y, x,y+h)
		love.graphics.line(x+w,y, x+w,y+h)
		love.graphics.line(x,y+h, x+w,y+h)
	end
end

function love.graphics.circle(mode,x,y,w,h) --partial
	surface.SetWhiteTexture()
	surface.DrawRect(x or 0, y or 0, w or 0, h or 0)
end

function love.graphics.drawq(drawable, quad, x,y, r, sx,sy, ox,oy) -- partial
	x=x or 0
	y=y or 0
	sx=sx or 1
	sy=sy or 1
	ox=ox or 0
	oy=oy or 0
	r=r or 0

	surface.SetColor(cr/255, cg/255, cb/255, ca/255)
	surface.SetTexture(lovemu.textures[drawable])
	surface.SetRectUV(quad.x,quad.y, quad.w,quad.h, quad.sw,quad.sh)
	surface.DrawRect(x,y, quad.w*sx, quad.h*sy,r,ox*sx,oy*sy)
	surface.SetRectUV()
end

function love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
	if lovemu.Type(drawable) == "SpriteBatch" then
		surface.SetColor(1,1,1,1)
		surface.SetTexture(lovemu.textures[drawable.img])
		drawable.poly:Draw()
	else
		if lovemu.textures[drawable] then
			if lovemu.Type(x) == "Quad" then
				love.graphics.drawq(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
			else
				x=x or 0
				y=y or 0
				sx=sx or 1
				sy=sy or 1
				ox=ox or 0
				oy=oy or 0
				r=r or 0

				local tex = lovemu.textures[drawable]

				--if drawable.fb then  sx = 5 sy = 6 end

				surface.SetTexture(tex)
				surface.DrawRect(x,y, tex:GetSize().x*sx, tex:GetSize().y*sy, r, ox*sx,oy*sy)
			end
		end
	end
end

function love.graphics.present() --partial
end

function love.graphics.setIcon() --partial
end

do
	local Shader = {}
	Shader.Type = "Shader"

	function Shader:getWarnings() -- partial
		return ""
	end

	function Shader:send() -- partial

	end

	function love.graphics.newShader() --partial
		local obj = lovemu.CreateObject(Shader)

		return obj
	end
end

love.graphics.newPixelEffect = love.graphics.newShader

function love.graphics.setShader() --partial
end

function love.graphics.setPixelEffect() --partial
end

function love.graphics.setScissor() --partial
end

function love.graphics.isCreated() -- partial
	return true
end

function love.graphics.getModes() --partial
	return {
		{width=720,height=480},
		{width=800,height=480},
		{width=800,height=600},
		{width=852,height=480},
		{width=1024,height=768},
		{width=1152,height=768},
		{width=1152,height=864},
		{width=1280,height=720},
		{width=1280,height=768},
		{width=1280,height=800},
		{width=1280,height=854},
		{width=1280,height=960},
		{width=1280,height=1024},
		{width=1365,height=768},
		{width=1366,height=768},
		{width=1400,height=1050},
		{width=1440,height=900},
		{width=1440,height=960},
		{width=1600,height=900},
		{width=1600,height=1200},
		{width=1680,height=1050},
		{width=1920,height=1080},
		{width=1920,height=1200},
		{width=2048,height=1536},
		{width=2560,height=1600},
		{width=2560,height=2048}
	}
end

do
	function love.graphics.setScissor(x,y,w,h) -- partial
		render.SetScissor(x, y, w, h)
	end

	function love.graphics.getScissor() -- partial
		return render.GetScissor()
	end
end

function love.graphics.polygon() -- partial

end

do -- sprite batch
	local SpriteBatch = {}
	SpriteBatch.Type = "SpriteBatch"

	local function set_rect(self, i, x,y, r, sx,sy, ox,oy, kx,ky)
		sx = sx or self.w
		sy = sy or self.h

		if ox then ox = -ox end
		if oy then oy = -oy end

		self.poly:SetRect(i, x,y, sx,sy, r, ox,oy)
	end

	function SpriteBatch:set(id, q, ...)
		id = id or 1
		if lovemu.Type(q) == "Quad" then
			self.poly:SetUV(q.x,q.y, q.w,q.h, q.sw,q.sh)
			local x,y, r, sx,sy, ox,oy, kx,ky = ...
			set_rect(self, id, x,y, r, q.w,q.h, ox,oy,kx,ky)
		else
			set_rect(self, id, q, ...)
		end
	end

	SpriteBatch.setq = SpriteBatch.set

	function SpriteBatch:add(...)
		if self.i < self.size then
			self:set(self.i, ...)
		end

		self.i = self.i + 1

		return self.i
	end

	SpriteBatch.addq = SpriteBatch.add

	function SpriteBatch:setColor(r,g,b,a)

		r = r or 255
		g = g or 255
		b = b or 255
		a = a or 255

		self.poly:SetColor(r/255,g/255,b/255,a/255)
	end

	function SpriteBatch:clear()  -- partial
		self.i = 1
	end

	function SpriteBatch:getImage()  -- partial
		return self.image
	end

	function SpriteBatch:bind()

	end

	function SpriteBatch:unbind()

	end

	function SpriteBatch:setImage(image)
		self.img = image
		self.w = image:getWidth()
		self.h = image:getHeight()
	end

	function SpriteBatch:getImage(image)
		return self.img
	end

	function love.graphics.newSpriteBatch(image, size, usagehint) -- partial
		local self = lovemu.CreateObject(SpriteBatch)
		local poly = surface.CreatePoly(size)

		self.size = size

		self.poly = poly
		self.img = image
		self.w = image:getWidth()
		self.h = image:getHeight()
		self.i = 1

		return self
	end
end