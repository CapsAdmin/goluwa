local love=love
love.graphics={}

local string=string
local math=math
local surface=surface
local render=render
local freeimage=freeimage
local gl=gl
local window=window
local type=type
local lovemu=lovemu

local textures = lovemu.textures

local function ADD_FILTER(obj)
	obj.setFilter = function(s, min, mag, anistropy) 
		
		textures[s].format.min_filter = min == "linear" and e.GL_LINEAR or e.GL_NEAREST
		textures[s].format.mag_filter = mag == "linear" and e.GL_LINEAR or e.GL_NEAREST
				
		textures[s]:UpdateFormat()
		
		s.filter_min = min
		s.filter_mag = mag
		s.filter_anistropy = anistropy
	end
	
	obj.getFilter = function() return s.filter_min, s.filter_mag, s.filter_anistropy end
end

function love.graphics.newQuad(...)
	local obj = lovemu.NewObject("Quad", ...)
	
	-- FFI THIS!!!!!!!!!!!!!!!!!!!!!
	
	local vertices = {}
	
	for i = 0, 3 do
		vertices[i] = {x = 0, y = 0, s = 0, t = 0}
	end
	
	obj.vertices = vertices
	
	local function refresh(x,y,w,h, sw, sh)
		
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
	
	obj.flip = function() end
	obj.getViewport = function(s) return s[1], s[2], s[3], s[4] end
	obj.setViewport = function(s, x,y,w,h) 
		s[1] = x
		s[2] = y
		s[3] = w
		s[4] = h
		refresh(x,y,w,h, s[3], s[4]) 
	end
	
	return obj
end

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
	return render.w
end

function love.graphics.getHeight()
	return render.h
end

function love.graphics.setMode()

end

function love.graphics.reset()
	
end

function love.graphics.isSupported(what)
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
	
	surface.Color(cr/255, cg/255, cb/255, ca/255)
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
		surface.Color(br/255,bg/255,bb/255,ba/255)
		surface.DrawRect(0, 0, render.w, render.h)
		surface.Color(cr/255,cg/255,cb/255,ca/255)
	end
end

do
	local MODE = "alpha"

	function love.graphics.setBlendMode(mode)
		gl.AlphaFunc(e.GL_GEQUAL, 0)
		
		if mode == "alpha" then
			gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)
		elseif mode == "multiplicative" then
			gl.BlendFunc(e.GL_DST_COLOR, e.GL_ONE_MINUS_SRC_ALPHA)
		elseif mode == "premultiplied" then
			gl.BlendFunc(e.GL_ONE, e.GL_ONE_MINUS_SRC_ALPHA)
		else
			gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE)
		end
		
		MODE = mode
	end
	
	function love.graphics.getBlendMode()
		return MODE
	end
end

do -- points
	local SIZE = 1
	local STYLE = "smooth"

	function love.graphics.setPointStyle(style)
		if style == "smooth" then
			gl.Enable(e.GL_POINT_SMOOTH)
		else
			gl.Disable(e.GL_POINT_SMOOTH)
		end
		
		STYLE = style
	end
	
	function love.graphics.getPointStyle()
		return STYLE
	end
	
	function love.graphics.setPointSize(size)
		gl.PointSize(size)
		SIZE = size
	end
	
	function love.graphics.getPointSize()
		return SIZE
	end
	
	function love.graphics.setPoint(size, style)
		love.graphics.setPointSize(size)
		love.graphics.setPointStyle(style)
	end

	function love.graphics.point(x,y)
		gl.Disable(e.GL_TEXTURE_2D)
		gl.Begin(e.GL_POINTS)
			gl.Vertex2f(x, y)
		gl.End()
	end
end


do -- font

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
		
		local obj = lovemu.NewObject("Font")
		
		obj.Name = surface.CreateFont("lovemu_" .. font, {
			size = size,
			path = font,
		})
		
		surface.SetFont(obj.Name)
		local w, h = surface.GetTextSize("W")

		obj.Size = size
		
		obj.getWidth = function(_, str) 
			return surface.GetTextSize(str)
		end
		
		obj.getHeight = function(_, str) 
			return select(2, surface.GetTextSize(str))
		end
				
		return obj
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
		
		surface.SetTextScale(sx, sy)
		surface.SetTextPos(x, y)
		surface.DrawText(text, r)
		surface.SetTextScale(1, 1)
	end

	function love.graphics.printf(text, x, y, limit, align, r, sx, sy)
		
		y = y or 0
		limit = limit or 0
		align = align or "left"
		sx = sx or 1
		sy = sy or 1
		r=r or 0
		r=r/0.0174532925
		
		local lines = string.explode(text, "\n")
		
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
	function love.graphics.newCanvas(w, h)
		w = w or render.w
		h = h or render.h
				
		local obj = lovemu.NewObject("Canvas")
		
		obj.fb = render.CreateFrameBuffer(w, h, {
			attach = e.GL_COLOR_ATTACHMENT1,
			texture_format = {
				internal_format = e.GL_RGB32F,
				mag_filter = FILTER,
				min_filter = FILTER,
			}
		})
		
		obj.renderTo = function(cb)
			obj.fb:Begin()
			cb()
			obj.fb:End()
		end
		
		obj.getWidth = function() return w end
		obj.getHeight = function() return h end
		obj.getImageData = function() end
		ADD_FILTER(obj)
		obj.clear = function(_, ...) obj.fb:Begin() love.graphics.clear(...) obj.fb:End() end
		
		obj.setWrap = function() end
		obj.getWrap = function() end
		
		textures[obj] = obj.fb:GetTexture("diffuse")
		
		return obj
	end
	
	local CANVAS

	function love.graphics.setCanvas(canvas)
		if canvas then
			canvas.fb:Begin()
		elseif CANVAS then
			CANVAS.fb:End()
		end
		
		CANVAS = canvas
	end
	
	function love.graphics.getCanvas()
		return CANVAS
	end
end

do -- image

	local FILTER = e.GL_LINEAR

	function love.graphics.setDefaultFilter(filter)
		if filter == "nearest" then
			FILTER = e.GL_NEAREST
		elseif filter=="linear" then
			FILTER = e.GL_LINEAR
		end
	end

	love.graphics.setDefaultImageFilter = setDefaultFilter
	
	function love.graphics.newImage(path)		
		if lovemu.debug then print("LOADING IMAGE FROM PATH "..path) end
		local buffer, w, h = freeimage.LoadImage(vfs.Read(path, "rb"))
		
		local obj = lovemu.NewObject("Image")
		
		textures[obj] = Texture(w, h, buffer, {
			mag_filter = FILTER,
			min_filter = FILTER,
		}) 
		
		obj.getWidth = function(s) return w end
		obj.getHeight = function(s) return h end
		ADD_FILTER(obj)
		obj.setWrap = function()  end
		obj.getWrap = function()  end
		
		return obj
	end
	
	function love.graphics.newImageData(path)		
		if lovemu.debug then print("LOADING IMAGEDATA FROM PATH "..path) end
		local w, h, buffer = freeimage.LoadImage(vfs.Read(path, "rb"))
		
		local obj = lovemu.NewObject("Image")
		
		textures[obj] = Texture(w, h, buffer, {
			mag_filter = FILTER,
			min_filter = FILTER,
		}) 
		
		obj.getWidth = function(s) return w end
		obj.getHeight = function(s) return h end
		obj.setWrap = function()  end
		obj.getWrap = function()  end
		
		ADD_FILTER(obj)
		
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

function love.graphics.drawq(drawable,quad,x,y,r,sx,sy,ox,oy)
	x=x or 0
	y=y or 0
	sx=sx or 1
	sy=sy or 1
	ox=ox or 0
	oy=oy or 0
	r=r or 0
	r=r/0.0174532925
	
	surface.SetTexture(textures[drawable])
	surface.SetRectUV(quad[1]*quad[5],quad[2]*quad[6],quad[3]*quad[5],quad[4]*quad[6])
	surface.DrawRect(x,y, quad[3]*sx, quad[4]*sy,r,ox*sx,oy*sy)
	surface.SetRectUV(0,0,1,1)
end

local drawq = love.graphics.drawq

function love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
	if type(drawable) == "table" and drawable.typeOf and drawable:typeOf("SpriteBatch") then
		surface.Color(1,1,1,1)
		surface.SetTexture(textures[drawable.img])
		drawable.poly:Draw()
	else
		if textures[drawable] then
			if type(x) == "table" and x:typeOf("Quad") then
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
				
				local tex = textures[drawable]
				
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

function love.graphics.newShader() --partial
	local obj = lovemu.NewObject("Shader")
	
	obj.getWarnings = function() return "" end
	obj.send = function() end
	
	return obj
end

love.graphics.newPixelEffect = love.graphics.newShader 

function love.graphics.setShader() --partial
end

function love.graphics.setPixelEffect() --partial
end

function love.graphics.setScissor() --partial
end

function love.graphics.isCreated()
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

function love.graphics.setScissor(x,y,w,h)
	render.ScissorRect(x,y,w,h)  
end

function love.graphics.getScissor()

end

function love.graphics.polygon()

end

function love.graphics.newSpriteBatch(image, size, usagehint)
	local obj = lovemu.NewObject("SpriteBatch")
	local poly = surface.CreatePoly(size+1)
	local i = 0
	
	obj.poly = poly
	obj.img = image
	
	local W = image:getWidth()
	local H = image:getHeight()
	
	local function set_rect(i, x,y, r, sx,sy, ox,oy, kx,ky)	
		sx = sx or W
		sy = sy or H
		
		sx = sx * W
		sy = sy * H
		poly:SetRect(i, x,y, sx,sy, r, ox,oy)		
	end
		
	obj.set = function(_, id, q, ...)
		if type(q) == "table" then
			poly:SetUV(q[1]*q[5], q[2]*q[6], q[3]*q[5], q[4]*q[6])
			set_rect(id, ...)
		else
			set_rect(id, q, ...)
		end
	end
	
	obj.setq = obj.set
	
	obj.add = function(_, q, ...)
		obj:set(i, q, ...)
		
		i = i + 1
		
		return i
	end
	
	obj.addq = obj.add
	
	obj.setColor = function(_, r,g,b,a) 
		
		r = r or 255 
		g = g or 255 
		b = b or 255 
		a = a or 255 
		
		poly:SetColor(r/255,g/255,b/255,a/255) 
	end
	obj.clear = function() end
	obj.getImage = function() return image end
	obj.bind = function() end
	obj.unbind = function() end
	
	return obj
end