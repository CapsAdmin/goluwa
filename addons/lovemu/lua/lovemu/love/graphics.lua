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

function love.graphics.newQuad(...)
	local obj = lovemu.NewObject("Quad", ...)
	
	obj.flip = function() end
	obj.getViewPort = function() end
	obj.setViewPort = function() end
	
	return obj
end

love.graphics.translate = surface.Translate
love.graphics.scale = surface.Scale
love.graphics.rotate = surface.Rotate
love.graphics.push = gl.PushMatrix
love.graphics.pop = gl.PopMatrix

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
		br = r or 0
		bg = g or 0
		bb = b or 0
		ba = a or 255
	end

	function love.graphics.getBackgroundColor()
		return br, bg, bb, ba
	end

	function love.graphics.clear()
		surface.SetTexture()
		surface.Color(br/255,bg/255,bb/255,ba/255)
		surface.DrawRect(0,0,render.w,render.h,0,0,0)
		surface.Color(cr/255,cg/255,cb/255,ca/255)
	end
end

do
	local MODE = "alpha"

	function love.graphics.setBlendMode(mode)
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
		gl.Disable(GL_TEXTURE_2D)
		g.lBegin(GL_POINTS)
			gl.Vertex2f(x, y)
		gl.End()
		gl.Enable(GL_TEXTURE_2D)
	end
end


do -- font

	function love.graphics.newFont(a, b)
		local font = R("lovers/" .. lovemu.demoname .. "/" .. a)
		local size = b
		
		if not b then
			font = R("fonts/verdana.ttf")
			size = a
		end
		
		local obj = lovemu.NewObject("Font")
		
		obj.Name = surface.CreateFont("lovemu_" .. font, {
			size = size,
			path = font,
		})	

		obj.Size = size
		obj.getWidth = function(s) return w end
		obj.getHeight = function(s) return h end
				
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
		sx = sx or 1
		sy = sy or 1
		
		if r and r > 0 then
			r = r / 0.0174532925
		else
			r = 0
		end
		
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
		
		if r and r > 0 then
			r = r / 0.0174532925
		else
			r = 0
		end
		
		local lines = string.explode(text, "\n")
		
		surface.SetTextScale(sx, sy)
		
		for i = 1, #lines do
			surface.SetTextPos(x, y + (currentFont.Size * i))
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
	
	function love.graphics.setLineWidth(w)
		WIDTH = w
	end

	function love.graphics.line(x1, y1, x2, y2)
		surface.DrawLine(x1, y1, x2, y2, WIDTH, false)
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

do -- canvas
	local canvas_config={
		{
			name = "diffuse",
			attach = e.GL_COLOR_ATTACHMENT1,
			texture_format = {
				internal_format = e.GL_RGB32F,
			}
		}
	}
	
	function love.graphics.newCanvas(w, h)
		w = w or render.w
		h = h or render.h
		
		local obj = lovemu.NewObject("Canvas")
		
		obj.fb = render.CreateFrameBuffer(w,h,canvas_config)
		
		obj.renderTo = function(cb)
			
		end
		
		return obj
	end
	
	local CANVAS

	function love.graphics.setCanvas(canvas)
		if canvas then
			canvas.fb:Begin()
		elseif CANVAS then
			canvas.fb:End()
		end
		
		CANVAS = canvas
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
		path = "/lovers/".. lovemu.demoname .. "/" .. path
		
		local w, h, buffer = freeimage.LoadImage(vfs.Read(path, "rb"))
		
		local obj = lovemu.NewObject("Image")
		
		obj.tex = Texture(w, h, buffer, {
			mag_filter = FILTER,
			min_filter = FILTER,
		}) 
		
		obj.getWidth = function(s) return w end
		obj.getHeight = function(s) return h end
		obj.setFilter = function() end
		
		return obj
	end

end

do -- stencil
	function love.graphics.newStencil(func) --partial
	
	end 

	function love.graphics.setStencil(func) --partial
	
	end
end

function love.graphics.drawq(drawable,quad,x,y,r,sx,sy,ox,oy)
	x=x or 0
	y=y or 0
	r=r or 0
	sx=sx or 1
	sy=sy or 1
	ox=ox or 0
	oy=oy or 0
	
	if r and r > 0 then
		r = r / 0.0174532925
	else
		r = 0
	end
	
	surface.SetTexture(drawable)
	surface.SetRectUV(quad[1]*quad[5],quad[2]*quad[6],quad[3]*quad[5],quad[4]*quad[6])
	surface.DrawRect(x,y, quad[3]*sx, quad[4]*sy,r,ox*sx,oy*sy)
	surface.SetRectUV(0,0,1,1)
end

local drawq = love.graphics.drawq

function love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
	if drawable.tex then
		if type(x) == "table" and x.quad then
			drawq(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
		else
			x=x or 0
			y=y or 0
			r=r or 0
			sx=sx or 1
			sy=sy or 1
			ox=ox or 0
			oy=oy or 0
					
			if r and r > 0 then
				r = r / 0.0174532925
			else
				r = 0
			end
			
			surface.SetTexture(drawable.tex)
			surface.DrawRect(x,y, drawable.tex.w*sx, drawable.tex.h*sy, r, ox*sx,oy*sy)
		end
	end
end