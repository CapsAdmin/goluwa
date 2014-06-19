local love = (...) or _G.lovemu.love

local gl = require("lj-opengl") -- OpenGL

love.graphics = {}

local function ADD_FILTER(obj)
	obj.setFilter = function(s, min, mag, anistropy) 
		
		lovemu.textures[s].format.min_filter = min 
		lovemu.textures[s].format.mag_filter = mag
				
		lovemu.textures[s]:UpdateFormat()
		
		s.filter_min = min
		s.filter_mag = mag
		s.filter_anistropy = anistropy
	end
	
	obj.getFilter = function() return s.filter_min, s.filter_mag, s.filter_anistropy end
end

local DEFAULT_FILTER = "linear"

do -- filter

	function love.graphics.setDefaultFilter(filter)
		DEFAULT_FILTER = filter
	end

	love.graphics.setDefaultImageFilter = setDefaultFilter
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
		return self.data[1], self.data[2], self.data[3], self.data[4] 
	end
	
	function Quad:setViewport(s, x,y,w,h) 
		self.data[1] = x
		self.data[2] = y
		self.data[3] = w
		self.data[4] = h
		
		refresh(self.vertices, x,y,w,h, self.data[3], self.data[4]) 
	end
	
	
	function love.graphics.newQuad(...) -- partial
		local self = lovemu.CreateObject(Quad)
		
		local vertices = {}

		for i = 0, 3 do
			vertices[i] = {x = 0, y = 0, s = 0, t = 0}
		end
		
		self.args = {...}
		self.vertices = vertices
			
		return self
	end
end

love.graphics.origin = render.LoadIdentity
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
		surface.DrawRect(0, 0, render.w, render.h)
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
		surface.DrawPoint(x, y)
	end
end


do -- font
	
	local Font = {}
	
	Font.Type = "Font"
		
	function Font:getWidth(str) 
		surface.SetFont(self.Name)
		return surface.GetTextSize(str)
	end
	
	function Font:getHeight(str) 
		surface.SetFont(self.Name)
		return select(2, surface.GetTextSize(str))
	end

	local i = 0
	
	function love.graphics.newFont(a, b)
		local font = a
		local size = b
		
		if type(a) == "number" then
			font = R("fonts/vera.ttf")
			size = a
		end
		
		if not a then
			font = R("fonts/vera.ttf")
			size = b or 12
		end
		
		size = size or 12
				
		local self = lovemu.CreateObject(Font)
		
		self.Name = surface.CreateFont("lovemu_" .. font .. i, {
			size = size,
			path = font,
		})
		
		i = i + 1
		
		surface.SetFont(self.Name)
		local w, h = surface.GetTextSize("W")

		self.Size = size

		return self
	end
	
	local currentFont = love.graphics.newFont(12)
	
	function love.graphics.setFont(font)
		currentFont = font
		surface.SetFont(font.Name)
	end
	
	function love.graphics.getFont(font)
		return currentFont
	end

	function love.graphics.setNewFont(...)
		love.graphics.setFont(love.graphics.newFont(...))
	end
	
	function love.graphics.print(text, x, y, r, sx, sy)
		x = x or 0
		y = y or 0
		sx = sx or 1
		sy = sy or 1
		r=r or 0
		r=r/0.0174532925
		
		surface.SetColor(cr/255, cg/255, cb/255, ca/255)
		surface.SetTextScale(sx, sy)
		surface.SetTextPos(x, y)
		surface.DrawText(text, r)
		surface.SetTextScale(1, 1)
	end

	function love.graphics.printf(text, x, y, limit, align, r, sx, sy)
		
		text = tostring(text)
		y = y or 0
		limit = limit or 0
		align = align or "left"
		sx = sx or 1
		sy = sy or 1
		r=r or 0
		r=r/0.0174532925
		
		local lines = string.explode(text, "\n")
		
		surface.SetColor(cr/255, cg/255, cb/255, ca/255)
		surface.SetTextScale(sx, sy)
		
		for i = 1, #lines do
			surface.SetTextPos(x, y + (currentFont.Size+(currentFont.Size*125/100) * i))
			surface.DrawText(lines[i])
		end
		
		surface.SetTextScale(1, 1)
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

	function love.graphics.line(x1, y1, x2, y2)
		surface.DrawLine(x1, y1, x2, y2, WIDTH, false)
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
	
	function Canvas:clear(self, ...) 
		self.fb:Begin() love.graphics.clear(...) self.fb:End() 
	end
	
	function Canvas:setWrap() 
		
	end
	
	function Canvas:getWrap() 
		
	end

	function love.graphics.newCanvas(w, h) -- partial
		w = w or render.GetWidth()
		h = h or render.GetHeight()
				
		local self = lovemu.CreateObject(Canvas)
		
		self.fb = render.CreateFrameBuffer(w, h, {
			attach = gl.e.GL_COLOR_ATTACHMENT1,
			texture_format = {
				internal_format = gl.e.GL_RGB32F,
				mag_filter = DEFAULT_FILTER,
				min_filter = DEFAULT_FILTER,
			}
		})
				
		lovemu.textures[self] = self.fb:GetTexture("diffuse")
		
		return self
	end
	
	local CANVAS

	function love.graphics.setCanvas(canvas) -- partial
		if canvas then
			canvas.fb:Begin()
		elseif CANVAS then
			CANVAS.fb:End()
		end
		
		CANVAS = canvas
	end
	
	function love.graphics.getCanvas() -- partial
		return CANVAS
	end
end

do -- image	
	local Image = {}
	
	Image.Type = "Image"
	
	function Image:getWidth(s) 
		return lovemu.textures[self].w 
	end
	
	function Image:getHeight(s) 
		return lovemu.textures[self].h 
	end
	
	ADD_FILTER(Image)
	
	function Image:setWrap()  --partial
		
	end
	
	function Image:getWrap() --partial
		
	end
	
	function love.graphics.newImage(path) -- partial		
		local self = lovemu.CreateObject(Image)
		
		lovemu.textures[self] = Texture(path, {
			mag_filter = DEFAULT_FILTER,
			min_filter = DEFAULT_FILTER,
		}) 
		
		return self
	end
	
	function love.graphics.newImageData(path) -- partial
		local obj = lovemu.CreateObject(Image)
		
		lovemu.textures[obj] = Texture(path, {
			mag_filter = DEFAULT_FILTER,
			min_filter = DEFAULT_FILTER,
		}) 
		
		return obj
	end
end

do -- stencil
	function love.graphics.newStencil(func) --partial
	
	end 

	function love.graphics.setStencil(func) --partial
	
	end
end

function love.graphics.rectangle(mode, x, y, w, h)
	if mode == "fill" then
		surface.SetWhiteTexture()
		surface.DrawRect(x, y, w, h)
	else
		surface.DrawLine(x,y, x+w,y, LineWidth, true)
		surface.DrawLine(x,y, x,y+h, LineWidth, true)
		surface.DrawLine(x+w,y, x+w,y+h, LineWidth, true)
		surface.DrawLine(x,y+h, x+w,y+h, LineWidth, true)
	end
end

function love.graphics.circle(mode,x,y,w,h) --partial
	surface.SetWhiteTexture()
	surface.DrawRect(x or 0, y or 0, w or 0, h or 0)
end

function love.graphics.drawq(drawable,quad,x,y,r,sx,sy,ox,oy) -- partial
	x=x or 0
	y=y or 0
	sx=sx or 1
	sy=sy or 1
	ox=ox or 0
	oy=oy or 0
	r=r or 0
	r=r/0.0174532925
	
	surface.SetColor(cr/255, cg/255, cb/255, ca/255)
	surface.SetTexture(lovemu.textures[drawable])
	surface.SetRectUV(quad.args[1]*quad.args[5],quad.args[2]*quad.args[6],quad.args[3]*quad.args[5],quad.args[4]*quad.args[6])
	surface.DrawRect(x,y, quad.args[3]*sx, quad.args[4]*sy,r,ox*sx,oy*sy)
	surface.SetRectUV(0,0,1,1)
end

local drawq = love.graphics.drawq

function love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
	if lovemu.Type(drawable) == "SpriteBatch" then
		surface.SetColor(1,1,1,1)
		surface.SetTexture(lovemu.textures[drawable.img])
		drawable.poly:Draw()
	else
		if lovemu.textures[drawable] then
			if lovemu.Type(x) == "Quad" then
				drawq(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
			else
				x=x or 0
				y=y or 0
				sx=sx or 1
				sy=sy or 1
				ox=ox or 0
				oy=oy or 0
				
				if r then
					r = r / 0.0174532925
				else
					r = 0
				end
				
				local tex = lovemu.textures[drawable]
				
				--if drawable.fb then  sx = 5 sy = 6 end
				
				surface.SetTexture(tex)
				surface.DrawRect(x,y, tex.w*sx, tex.h*sy, r, ox*sx,oy*sy)
			end
		end
	end
end

function love.graphics.present() --partial
end

function love.graphics.setDefaultImageFilter() --partial
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
		
		sx = sx * self.w
		sy = sy * self.h
		self.poly:SetRect(i, x,y, sx,sy, r, ox,oy)		
	end
		
	function SpriteBatch:set(id, q, ...)
		id = id or 1
		if lovemu.Type(q) == "Quad" then
			self.poly:SetUV(q.args[1]*q.args[5], q.args[2]*q.args[6], q.args[3]*q.args[5], q.args[4]*q.args[6])
			set_rect(self, id, ...)
		else
			set_rect(self, id, q, ...)
		end
	end
	
	SpriteBatch.setq = SpriteBatch.set
	
	function SpriteBatch:add(q, ...)
		self:set(i, q, ...)
		
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
		
	end
	
	function SpriteBatch:getImage()  -- partial
		return self.image 
	end
	
	function SpriteBatch:bind() 
		
	end
	
	function SpriteBatch:unbind() 
		
	end

	function love.graphics.newSpriteBatch(image, size, usagehint) -- partial
		local self = lovemu.CreateObject(SpriteBatch)
		local poly = surface.CreatePoly(size+1)
		
		self.poly = poly
		self.img = image
		self.w = image:getWidth()
		self.h = image:getHeight()
		self.i = 0
		
		return self
	end
end