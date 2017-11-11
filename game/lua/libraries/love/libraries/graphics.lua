if not GRAPHICS then return end

local love = ... or _G.love
local ENV = love._line_env

ENV.textures = ENV.textures or utility.CreateWeakTable()
ENV.graphics_filter_min = ENV.graphics_filter_min or "linear"
ENV.graphics_filter_mag = ENV.graphics_filter_mag or "linear"
ENV.graphics_filter_anisotropy = ENV.graphics_filter_anisotropy or 1

love.graphics = love.graphics or {}

local function ADD_FILTER(obj)
	obj.setFilter = function(s, min, mag, anistropy)

		ENV.textures[s]:SetMinFilter(min)
		ENV.textures[s]:SetMagFilter(mag)

		s.filter_min = min
		s.filter_mag = mag
		s.filter_anistropy = anistropy
	end

	obj.getFilter = function() return s.filter_min, s.filter_mag, s.filter_anistropy end
end

do -- filter
	function love.graphics.setDefaultImageFilter(min, mag, anisotropy)
		ENV.graphics_filter_min = min
		ENV.graphics_filter_mag = mag
		ENV.graphics_filter_anisotropy = anisotropy
	end

	love.graphics.setDefaultFilter = love.graphics.setDefaultImageFilter
end

do -- quad
	local Quad = line.TypeTemplate("Quad")

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

	function Quad:flip()

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


	function love.graphics.newQuad(x,y,w,h, sw,sh)
		local self = line.CreateObject("Quad")

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

	line.RegisterType(Quad)
end

love.graphics.origin = render2d.LoadIdentity
love.graphics.translate = render2d.Translate
love.graphics.shear = render2d.Shear
love.graphics.rotate = render2d.Rotate
love.graphics.push = render2d.PushMatrix
love.graphics.pop = render2d.PopMatrix

function love.graphics.scale(x, y)
	y = y or x
	render2d.Scale(x, y)
end

function love.graphics.setCaption(title)
	window.SetTitle(title)
end


function love.graphics.getWidth()
	return render.GetWidth()
end

function love.graphics.getHeight()
	return render.GetHeight()
end

function love.graphics.setMode(width, height, fullscreen, vsync, fsaa)
	window.SetSize(Vec2(width, height))
	return true
end

function love.graphics.getDimensions()
	return render.GetWidth(), render.GetHeight()
end

function love.graphics.reset()

end

function love.graphics.isSupported(what)
	llog("is supported: %s", what)
	return true
end

do
	ENV.graphics_color_r = 255
	ENV.graphics_color_g = 255
	ENV.graphics_color_b = 255
	ENV.graphics_color_a = 255

	function love.graphics.setColor(r, g, b, a)
		if type(r) == "number" then
			ENV.graphics_color_r = r or 0
			ENV.graphics_color_g = g or 0
			ENV.graphics_color_b = b or 0
			ENV.graphics_color_a = a or 255
		else
			ENV.graphics_color_r = r[1] or 0
			ENV.graphics_color_g = r[2] or 0
			ENV.graphics_color_b = r[3] or 0
			ENV.graphics_color_a = r[4] or 255
		end

		render2d.SetColor(ENV.graphics_color_r/255, ENV.graphics_color_g/255, ENV.graphics_color_b/255, ENV.graphics_color_a/255)
	end

	function love.graphics.getColor()
		return ENV.graphics_color_r, ENV.graphics_color_g, ENV.graphics_color_b, ENV.graphics_color_a
	end
end

do -- background
	ENV.graphics_bg_color_r = 0
	ENV.graphics_bg_color_g = 0
	ENV.graphics_bg_color_b = 0
	ENV.graphics_bg_color_a = 255

	function love.graphics.setBackgroundColor(r, g, b, a)
		if type(r) == "number" then
			ENV.graphics_bg_color_r = r or 0
			ENV.graphics_bg_color_g = g or 0
			ENV.graphics_bg_color_b = b or 0
			ENV.graphics_bg_color_a = a or 255
		else
			ENV.graphics_bg_color_r = r[1] or 0
			ENV.graphics_bg_color_g = r[2] or 0
			ENV.graphics_bg_color_b = r[3] or 0
			ENV.graphics_bg_color_a = r[4] or 255
		end
	end

	function love.graphics.getBackgroundColor()
		return ENV.graphics_bg_color_r, ENV.graphics_bg_color_g, ENV.graphics_bg_color_b, ENV.graphics_bg_color_a
	end

	function love.graphics.clear()
		local canvas = love.graphics.getCanvas()
		if canvas then
			canvas:clear()
		else
			local br, bg, bb, ba = love.graphics.getBackgroundColor()
			render2d.SetTexture()
			render2d.SetColor(br/255,bg/255,bb/255,ba/255)
			render2d.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
			love.graphics.setColor(love.graphics.getColor())
		end
	end
end

do
	local COLOR_MODE = "alpha"
	local ALPHA_MODE = "alphamultiply"

	function love.graphics.setBlendMode(color_mode, alpha_mode)
		alpha_mode = alpha_mode or "alphamultiply"
		local func   = "add"
		local srcRGB = "one"
		local srcA   = "one"
		local dstRGB = "zero"
		local dstA   = "zero"

		if color_mode == "alpha" then
			srcRGB = "one"
			srcA = "one"

			dstRGB = "one_minus_src_alpha"
			dstA = "one_minus_src_alpha"
		elseif color_mode == "multiply" or "multiplicative" then
			srcRGB = "dst_color"
			srcA = "dst_color"

			dstRGB = "zero"
			dstA = "zero"
		elseif color_mode == "subtract" or color_mode == "subtractive" then
			func = "subtract"
		elseif color_mode == "add" or color_mode == "additive" then
			srcRGB = "one"
			srcA = "zero"

			dstRGB = "one"
			dstA = "one"
		elseif color_mode == "lighten" then
			func = "max"
		elseif color_mode == "darken" then
			func = "min"
		elseif color_mode == "screen" then
			srcRGB = "one"
			srcA = "one"

			dstRGB = "one_minus_src_color"
			dstA = "one_minus_src_color"
		else --if color_mode == "replace" then
			srcRGB = "one"
			srcA = "one"

			dstRGB = "zero"
			dstA = "zero"
		end

		if srcRGB == "one" and alpha_mode == "alphamultiply" then
			srcRGB = "src_alpha"
		end

		render.SetBlendMode(srcRGB, dstRGB, func, srcA, dstA, func)

		COLOR_MODE = color_mode
		ALPHA_MODE = alpha_mode
	end

	function love.graphics.getBlendMode()
		return COLOR_MODE, ALPHA_MODE
	end
end

do
	function love.graphics.setColorMode(mode)
		if mode == "replace" then mode = "none" end
		--render.SetColorMode(mode)
	end

	function love.graphics.getColorMode()
		--return render.GetBlendMode()
		return "modulate"
	end
end

do -- points
	local SIZE = 1
	local STYLE = "rough"

	function love.graphics.setPointStyle(style)
		STYLE = style
	end

	function love.graphics.getPointStyle()
		return STYLE
	end

	function love.graphics.setPointSize(size)
		SIZE = size
	end

	function love.graphics.getPointSize()
		return SIZE
	end

	function love.graphics.setPoint(size, style)
		love.graphics.setPointSize(size)
		love.graphics.setPointStyle(style)
	end

	function love.graphics.point(x, y)
		if STYLE == "rough" then
			render2d.PushTexture(render.GetWhiteTexture())
			render2d.DrawRect(x, y, SIZE, SIZE, nil, SIZE/2, SIZE/2)
			render2d.PopTexture()
		else
			gfx.DrawFilledCircle(x, y, SIZE)
		end
	end

	function love.graphics.points(...)
		local points = ...

		if type(points) == "number" then
			points = {...}
		end

		if type(points[1]) == "number" then
			for i = 1, #points, 2 do
				love.graphics.point(points[i + 0], points[i + 1])
			end
		else
			for i, point in ipairs(points) do
				if point[3] then
					render2d.SetColor(point[3], point[4], point[5], point[6])
				end
				love.graphics.point(point[1], point[2])
			end
		end
	end
end


do -- font

	local Font = line.TypeTemplate("Font")
	function Font:getWidth(str)
		str = str or "W"
		return (self.font:GetTextSize(str)) + 2
	end

	function Font:getHeight(str)
		str = str or "W"
		return select(2, self.font:GetTextSize(str)) + 2
	end

	function Font:setLineHeight(num)
		self.line_height = num
	end

	function Font:getLineHeight(num)
		self.line_height = num
	end

	function Font:getWrap(str, width)
		str = tostring(str)
		local old = gfx.GetFont()
		gfx.SetFont(self.font)
		local res = gfx.WrapString(str, width)
		local w = self.font:GetTextSize(str) + 2
		gfx.SetFont(old)

		if love._version_minor >= 10 then
			return w, res
		end

		return w, math.max(res:count("\n"),1)
	end

	function Font:setFilter(filter)
		self.filter = filter
	end

	function Font:getFilter()
		return self.filter
	end

	function Font:setFallbacks(...)

	end

	local function create_font(path, size, glyphs, texture)
		local self = line.CreateObject("Font")

		self:setLineHeight(1)
		path = line.FixPath(path)

		self.font = fonts.CreateFont({
			size = size and (size-1),
			path = path,
			filtering = ENV.graphics_filter_min,
			glyphs = glyphs,
			texture = texture,
		})


		self.Name = self.font:GetName()

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
			size = b or 11
		end

		size = size or 12

		return create_font(font, size)
	end

	function love.graphics.newImageFont(path, glyphs)
		local tex
		if line.Type(path) == "Image" then
			tex = ENV.textures[path]
			path = "memory"
		end
		return create_font(path, nil, glyphs, tex)
	end

	function love.graphics.setFont(font)
		font = font or love.graphics.getFont()
		ENV.current_font = font
		gfx.SetFont(font.font)
	end

	function love.graphics.getFont()
		if not ENV.default_font then
			ENV.default_font = love.graphics.newFont()
		end
		return ENV.current_font or ENV.default_font
	end

	function love.graphics.setNewFont(...)
		love.graphics.setFont(love.graphics.newFont(...))
	end

	local function draw_text(text, x, y, r, sx, sy, ox, oy, kx, ky, align, limit)
		local font = love.graphics.getFont()
		love.graphics.setFont(font)
		text = tostring(text)
		x = x or 0
		y = y or 0
		sx = sx or 1
		sy = sy or sx
		r = r or 0
		ox = ox or 0
		oy = oy or 0
		kx = kx or 0
		ky = ky or 0

		local cr, cg, cb, ca = love.graphics.getColor()
		render2d.PushColor(cr/255, cg/255, cb/255, ca/255)
		render2d.PushMatrix(x, y, sx, sy, r)
		render2d.Translate(ox, oy)
			if align then
				local max_width = 0
				local t = gfx.WrapString(text, limit):split("\n")

				for i, line in ipairs(t) do
					local w, h = gfx.GetTextSize(line)
					if w > max_width then
						max_width = w
					end
				end

				for i, line in ipairs(t) do
					local w, h = gfx.GetTextSize(line)

					local align_x = 0

					if align == "right" then
						align_x = max_width - w
					elseif align == "center" then
						align_x = (max_width - w) / 2
					end

					gfx.SetTextPosition(align_x, (i-1) * h * font.line_height)
					gfx.DrawText(line)
				end
			else
				gfx.SetTextPosition(0, 0)
				gfx.DrawText(text)
			end
		render2d.PopMatrix()
		render2d.PopColor()
	end

	function love.graphics.print(text, x, y, r, sx, sy, ox, oy, kx, ky)
		return draw_text(text, x, y, r, sx, sy, ox, oy, kx, ky)
	end

	function love.graphics.printf(text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky)
		return draw_text(text, x, y, r, sx, sy, ox, oy, kx, ky, align or "left", limit or 0)
	end

	line.RegisterType(Font)
end

do -- line
	ENV.graphics_line_width = 1
	ENV.graphics_line_style = "rough"
	ENV.graphics_line_join = "miter"

	function love.graphics.setLineStyle(s)
		ENV.graphics_line_style = s
	end

	function love.graphics.getLineStyle()
		return ENV.graphics_line_style
	end

	function love.graphics.setLineJoin(s)
		ENV.graphics_line_join = s
	end

	function love.graphics.getLineJoin(s)
		return ENV.graphics_line_join
	end

	function love.graphics.setLineWidth(w)
		ENV.graphics_line_width = w
	end

	function love.graphics.getLineWidth()
		return ENV.graphics_line_width
	end

	function love.graphics.setLine(w, s)
		love.graphics.setLineWidth(w)
		love.graphics.setLineStyle(s)
	end
end

do -- canvas
	local Canvas = line.TypeTemplate("Canvas")

	ADD_FILTER(Canvas)

	function Canvas:renderTo(cb)
		local old = love.graphics.getCanvas()
		love.graphics.setCanvas(self)

		local ok, err = pcall(cb)
		if not ok then wlog(err) end

		love.graphics.setCanvas(old)
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
		self.fb:ClearAll()
	end

	function Canvas:setWrap()

	end

	function Canvas:getWrap()

	end

	function love.graphics.newCanvas(w, h)
		w = w or render.GetWidth()
		h = h or render.GetHeight()

		local self = line.CreateObject("Canvas")

		self.fb = render.CreateFrameBuffer(Vec2(w, h), {
			mag_filter = ENV.graphics_filter_mag,
			min_filter = ENV.graphics_filter_min,
		})

		ENV.textures[self] = self.fb:GetTexture()

		return self
	end

	function love.graphics.setCanvas(canvas)
		ENV.graphics_current_canvas = canvas

		if canvas then
			canvas.fb:Bind()
			render.SetViewport(0, 0, canvas.fb:GetTexture():GetSize().x, canvas.fb:GetTexture():GetSize().y)
		else
			render.GetScreenFrameBuffer():Bind()
			render.SetViewport(0, 0, window.GetSize():Unpack())
		end
	end

	function love.graphics.getCanvas()
		return ENV.graphics_current_canvas
	end

	line.RegisterType(Canvas)
end

do -- image
	local Image = line.TypeTemplate("Image")

	function Image:getWidth()
		return ENV.textures[self]:GetSize().x
	end

	function Image:getHeight()
		return ENV.textures[self]:GetSize().y
	end

	function Image:getDimensions()
		return ENV.textures[self]:GetSize().x, ENV.textures[self]:GetSize().y
	end

	function Image:getHeight()
		return ENV.textures[self]:GetSize().y
	end

	function Image:getData()
		local tex = ENV.textures[self]
		local data = tex:Download()
		local img_data = love.image.newImageData(self:getDimensions())
		img_data.buffer = data.buffer
		img_data.tex = tex
		return img_data
	end

	ADD_FILTER(Image)

	function Image:setWrap()

	end

	function Image:getWrap()

	end

	function love.graphics.newImage(path)
		if line.Type(path) == "ImageData" then
			return path
		else
			local self = line.CreateObject("Image")

			path = line.FixPath(path)

			local tex = render.CreateTextureFromPath(path)
			tex:SetMinFilter(ENV.graphics_filter_min)
			tex:SetMagFilter(ENV.graphics_filter_mag)
			ENV.textures[self] = tex

			return self
		end
	end

	function love.graphics.newImageData(path)
		local self = line.CreateObject("Image")

		path = line.FixPath(path)

		local tex = render.CreateTextureFromPath(path)
		tex:SetMinFilter(ENV.graphics_filter_min)
		tex:SetMagFilter(ENV.graphics_filter_mag)
		ENV.textures[self] = tex

		return self
	end

	line.RegisterType(Image)
end

do -- stencil
	function love.graphics.newStencil(func)

	end

	function love.graphics.setStencil(func)

	end

	function love.graphics.setStencilTest(b)
		ENV.graphics_stencil_test = b
	end

	function love.graphics.getStencilTest()
		return ENV.graphics_stencil_test
	end

	function love.graphics.stencil(stencilfunction, keepbuffer)

	end
end

function love.graphics.rectangle(mode, x, y, w, h)
	if mode == "fill" then
		render2d.SetTexture()
		render2d.DrawRect(x, y, w, h)
	else
		gfx.DrawLine(x,y, x+w,y)
		gfx.DrawLine(x,y, x,y+h)
		gfx.DrawLine(x+w,y, x+w,y+h)
		gfx.DrawLine(x,y+h, x+w,y+h)
	end
end

function love.graphics.roundrect(mode, x, y, w, h)
	return love.graphics.rectangle(mode, x, y, w, h)
end

function love.graphics.drawq(drawable, quad, x,y, r, sx,sy, ox,oy, kx,ky)
	x = x or 0
	y = y or 0
	sx = sx or 1
	sy = sy or sx
	ox = ox or 0
	oy = oy or 0
	r = r or 0
	kx = kx or 0
	ky = ky or 0

	local cr, cg, cb, ca = love.graphics.getColor()
	render2d.SetColor(cr/255, cg/255, cb/255, ca/255)
	render2d.PushTexture(ENV.textures[drawable])
	render2d.SetRectUV(quad.x,quad.y, quad.w,quad.h, quad.sw,quad.sh)
	render2d.DrawRect(x,y, quad.w*sx, quad.h*sy,r,ox*sx,oy*sy)
	render2d.SetRectUV()
	render2d.PopTexture()
end

function love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx,ky, quad_arg)
	if ENV.textures[drawable] then
		if line.Type(x) == "Quad" then
			love.graphics.drawq(drawable, x, y, r, sx, sy, ox, oy, kx,ky, quad_arg)
		else
			x = x or 0
			y = y or 0
			sx = sx or 1
			sy = sy or sx
			ox = ox or 0
			oy = oy or 0
			r = r or 0
			kx = kx or 0
			ky = ky or 0

			local tex = ENV.textures[drawable]

			--if drawable.fb then  sx = 5 sy = 6 end

			render2d.PushTexture(tex)
			render2d.DrawRect(x,y, tex:GetSize().x*sx, tex:GetSize().y*sy, r, ox*sx,oy*sy)
			render2d.PopTexture()
		end
	else
		x = x or 0
		y = y or 0
		sx = sx or 1
		sy = sy or sx
		ox = ox or 0
		oy = oy or 0
		r = r or 0
		kx = kx or 0
		ky = ky or 0

		if line.Type(drawable) == "SpriteBatch" or line.Type(drawable) == "Mesh" then
			render2d.PushColor(1,1,1,1)
			render2d.PushTexture(ENV.textures[drawable.img])
			render2d.PushMatrix(x,y)
				render2d.Translate(ox,oy)
				render2d.Rotate(r)
				render2d.Scale(sx,sy)
				drawable:Draw()
			render2d.PopMatrix()
			render2d.PopTexture()
			render2d.PopColor()
		elseif line.Type(drawable) == "ParticleSystem" then

		else
			table.print(drawable)
			debug.trace()
		end
	end
end

function love.graphics.present()
end

function love.graphics.setIcon()
end

do
	do
		local Shader = line.TypeTemplate("Shader")

		function Shader:getWarnings()
			return ""
		end

		function Shader:sendColor(name, tbl, ...)
			if ... then warning("uh oh") end

			local loc = self.shader.program:GetUniformLocation(name)

			self.shader.program:UploadColor(loc, ColorBytes(unpack(tbl)))
		end

		function Shader:send(name, var, ...)
			if ... then warning("uh oh") end

			local loc = self.shader.program:GetUniformLocation(name)

			local t = type(var)
			if t == "number" then
				self.shader.program:UploadNumber(loc, var)
			elseif t == "boolean" then
				self.shader.program:UploadBoolean(loc, var)
			elseif ENV.textures[var] then
				self.shader.program:UploadTexture(loc, ENV.textures[var], 0, 0)
			elseif t == "table" then
				if type(var[1]) == "number" then
					if #var == 2 then
						self.shader.program:UploadVec2(loc, Vec2(unpack(var)))
					elseif #var == 3 then
						self.shader.program:UploadVec3(loc, Vec3(unpack(var)))
					elseif #var == 16 then
						self.shader.program:UploadMatrix44(loc, Vec2(unpack(var)))
					end
				else
					if #var == 4 then
						self.shader.program:UploadMatrix44(loc, Matrix44(
							var[1][1], var[1][2], var[1][3], var[1][4],
							var[2][1], var[2][2], var[2][3], var[2][4],
							var[3][1], var[3][2], var[3][3], var[3][4],
							var[4][1], var[4][2], var[4][3], var[4][4]
						))
					elseif #var == 3 then
						warning("uh oh")
					end
				end
			end
		end

		function love.graphics.newShader(frag, vert)
			local obj = line.CreateObject("Shader")

			local shader = render.CreateShader({
				fragment = {
					mesh_layout = {
						{uv = "vec2"},
					},
					variables = {
						current_texture = {texture = function() return render2d.shader.tex end},
						current_color = {color = function() return render2d.shader.color_override end},
					},
					include_directories = {
						"shaders/include/",
					},
					source = [[
						#version 430 core

						#define number float
						#define Image sampler2D
						#define Texel texture2D
						#define extern uniform

						]] .. frag .. [[

						out vec4 out_color;

						void main()
						{
							out_color = effect(current_color, current_texture, uv, get_screen_uv());
						}
					]],
				},
			})

			obj.shader = shader

			return obj
		end

		line.RegisterType(Shader)
	end

	love.graphics.newPixelEffect = love.graphics.newShader

	function love.graphics.setShader(obj)
		render2d.shader_override = obj and obj.shader or nil
	end

	love.graphics.setPixelEffect = love.graphics.setShader

end

function love.graphics.isCreated()
	return true
end

function love.graphics.getModes()
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

function love.graphics.getStats()
	return {
		fonts = 1,
		images = 1,
		canvases = 1,
		images = 1,
		texturememory = 1,
		canvasswitches = 1,
		drawcalls = 1,
	}
end

do
	function love.graphics.setScissor(x,y,w,h)
		render.SetScissor(x, y, w, h)
	end

	function love.graphics.getScissor()
		return render.GetScissor()
	end
end

do -- shapes
	local mesh = render2d.CreateMesh(2048)
	for i = 1, 2048 do
		mesh:SetVertex(i, "color", 1,1,1,1)
	end
	local mesh_idx = render.CreateIndexBuffer()
	mesh_idx:LoadVertices(2048)

	local function polygon(mode, points, join)
		render2d.PushTexture(render.GetWhiteTexture())
		local idx = 1

		if mode == "line" then
			local draw_mode, vertices, indices = math2d.CoordinatesToLines(points, love.graphics.getLineWidth(), join, love.graphics.getLineJoin(), 1, false)--love.graphics.getLineStyle() == "smooth", true)
			mesh:SetMode(draw_mode)

			if indices then
				for i, v in ipairs(indices) do
					mesh_idx:SetIndex(i, v)
				end
				idx = #indices
			else
				for i = 1, #vertices do
					mesh_idx:SetIndex(i, i-1)
				end
				idx = #vertices
			end

			for i, v in ipairs(vertices) do
				mesh:SetVertex(i, "pos", v.x, v.y)
			end
		else
			for i = 1, #points, 2 do
				mesh:SetVertex(idx, "pos", points[i + 0], points[i + 1])
				idx = idx + 1
			end
			for i = 1, #points do
				mesh:SetIndex(i, i-1)
			end

			-- connect the end
			mesh_idx:SetIndex(idx, 0)

			mesh:SetMode("triangle_fan")
		end

		mesh:UpdateBuffer()
		mesh_idx:UpdateBuffer()
		render2d.BindShader()
		mesh:Draw(mesh_idx)

		render2d.PopTexture()
	end

	function love.graphics.polygon(mode, ...)
		local points = type(...) == "table" and ... or {...}
		polygon(mode, points, true)
	end

	function love.graphics.arc(...)
		local draw_mode, arc_mode, x, y, radius, angle1, angle2, points

		if type(select(2, ...)) == "number" then
			draw_mode, x, y, radius, angle1, angle2, points = ...
			arc_mode = "pie"
		else
			draw_mode, arc_mode, x, y, radius, angle1, angle2, points = ...
		end

		if draw_mode == "line" and arc_mode == "closed" and math.abs(angle1 - angle2) < math.rad(4) then
			arc_mode = "open"
		end

		if draw_mode == "fill" and arc_mode == "open" then
			arc_mode = "closed"
		end

		local coords = math2d.ArcToCoordinates(arc_mode, x, y, radius, angle1, angle2, points)

		if coords then
			polygon(draw_mode, coords)
		end
	end

	function love.graphics.ellipse(mode, x, y, radiusx, radiusy, points)
		local coords = math2d.EllipseToCoordinates(x, y, radiusx, radiusy, points)

		polygon(mode, coords)
	end

	function love.graphics.circle(mode, x, y, radius, points)
		if not points then
			if radius and radius > 10 then
				points = math.ceil(radius)
			else
				points = 10
			end
		end

		love.graphics.ellipse(mode, x, y, radius, radius, points)
	end

	function love.graphics.line(...)
		local tbl = ...

		if type(tbl) == "number" then
			tbl = {...}
		end

		polygon("line", tbl)
	end

	function love.graphics.triangle(mode, x1, y1, x2, y2, x3, y3)
		polygon(mode, {x1,y1, x2,y2, x3,y3, x1,y1})
	end

	function love.graphics.rectangle(mode, x, y, w, h, rx, ry, points)
		rx = rx or 0
		ry = ry or rx
		if mode == "fill" then
			render2d.SetTexture()
			render2d.DrawRect(x, y, w, h)
		else
			local coords = math2d.RoundedRectangleToCoordinates(x, y, w, h, rx, ry, points)

			polygon("line", coords, true)
		end
	end
end

do
	local Mesh = line.TypeTemplate("Mesh")

	function love.graphics.newMesh(...)
		local vertices
		local vertex_count
		local vertex_format
		local mode
		local usage
		local texture

		if type(select(1, ...)) == "table" and (line.Type(select(2, ...)) == "Image" or line.Type(select(2, ...)) == "Canvas") then--(mesh_vertices, texture, 'triangles')
			vertices, texture, mode = ...
			vertex_count = #vertices
		elseif type(select(1, ...)) == "table" and type(select(2, ...)) == "table" then
			vertex_format, vertices, mode, usage = ...
			vertex_count = #vertices
		elseif type(...) == "number" then
			vertex_count, mode, usage = ...
		elseif type(...) == "table" then
			vertices, mode, usage = ...
			vertex_count = #vertices
		end

		local self = line.CreateObject("Mesh")
		self.vertex_buffer = render2d.CreateMesh(vertex_count)

		if vertex_format then
			self.vertex_buffer:ClearAttributes()
			for i, v in ipairs(vertex_format) do
				self.vertex_buffer:SetAttribute(i, v[1], v[2], v[3])
			end
		end

		self.vertex_buffer:SetDrawHint(usage)
		self:setDrawMode(mode)

		if vertices then
			self:setVertices(vertices)
		end

		if texture then
			self:setTexture(texture)
		end

		return self
	end

	function Mesh:setTexture(tex)
		self.img = tex
	end

	function Mesh:getTexture()
		return self.img
	end

	Mesh.setImage = Mesh.setTexture
	Mesh.getImage = Mesh.getTexture

	function Mesh:setVertices(vertices)
		for i, v in ipairs(vertices) do
			self:setVertex(i, v)
		end
		self.vertex_buffer:UpdateBuffer()
	end

	function Mesh:getVertices()
		local out = {}
		for i = 1, self.vertex_buffer.Vertices:GetLength() do
			out[i] = {self:getVertex()}
		end
		return out
	end

	function Mesh:setVertex(index, vertex, ...)
		if type(vertex) == "number" then
			vertex = {vertex, ...}
		end

		if vertex[1] then
			self.vertex_buffer:SetVertex(index, "pos", vertex[1], vertex[2])
		end
		if vertex[3] then
			self.vertex_buffer:SetVertex(index, "uv", vertex[3], -vertex[4]+1)
		end
		if vertex[5] then
			local r = (vertex[5] or 255) / 255
			local g = (vertex[6] or 255) / 255
			local b = (vertex[7] or 255) / 255
			local a = (vertex[8] or 255) / 255
			self.vertex_buffer:SetVertex(index, "color", r,g,b,a)
		end
	end

	function Mesh:getVertex(index)
		local x,y = self.vertex_buffer:GetVertex(index, "pos")
		local u,v = self.vertex_buffer:GetVertex(index, "uv")
		local r,g,b,a = self.vertex_buffer:GetVertex(index, "color")

		return x,y,u,v,r,g,b,a
	end

	function Mesh:setDrawRange(min, max)
		self.draw_range_min = min
		self.draw_range_man = max
	end

	function Mesh:getDrawRange()
		return self.draw_range_min, self.draw_range_max
	end

	function Mesh:Draw()
		self.vertex_buffer:Draw(self.index_buffer, self.draw_range)
	end

	function Mesh:setVertexColors()

	end

	function Mesh:hasVertexColors()
		return true
	end

	function Mesh:setVertexMap(...)
		local indices = type(...) == "table" and ... or {...}
		for i, i2 in ipairs(indices) do
			self.index_buffer:SetIndex(i, i2-1)
		end
	end

	function Mesh:getVertexMap()
		local out = {}
		for i = 1, self.index_buffer.Indices:GetLength() do
			out[i] = self.index_buffer.Indices.Pointer[i - 1] + 1
		end
		return out
	end

	function Mesh:getVertexCount()
		return self.vertex_buffer.Vertices:GetLength()
	end

	function Mesh:setVertexAttribute(index, pos, ...)
		self:setVertex(index, self.vertex_buffer.mesh_layout.attributes[pos].name, ...)
	end

	function Mesh:getVertexAttribute(index, pos)
		return self:getVertex(index, self.vertex_buffer.mesh_layout.attributes[pos].name)
	end

	function Mesh:setAttributeEnabled(name, enable)

	end

	function Mesh:isAttributeEnabled()

	end

	function Mesh:attachAttribute()

	end

	do
		local tr = {
			pos = "VertexPosition",
			uv = "VertexTexCoord",
			color = "VertexColor",
		}

		function Mesh:getVertexFormat()
			local out = {}
			for i, info in ipairs(self.vertex_buffer.mesh_layout.attributes) do
				table.insert(out, {tr[info.name] or info.name, info.type_info.type, info.type_info.arg_count})
			end
			return out
		end
	end

	function Mesh:flush()
		self:UpdateBuffers()
	end

	do
		local tr = {
			fan = "triangle_fan",
			strip = "triangle_strip",
		}

		function Mesh:setDrawMode(mode)
			mode = tr[mode] or mode
			self.vertex_buffer:SetMode(mode)
		end

		local tr2 = {}

		for k,v in pairs(tr) do
			tr[v] = k
		end

		function Mesh:getDrawMode()
			local mode = self.vertex_buffer:GetMode()
			return tr2[mode] or mode
		end
	end

	line.RegisterType(Mesh)
end

do -- sprite batch
	local SpriteBatch = line.TypeTemplate("SpriteBatch")

	local function set_rect(self, i, x,y, r, sx,sy, ox,oy, kx,ky)
		sx = sx or self.w
		sy = sy or self.h

		if ox then ox = -ox end
		if oy then oy = -oy end

		self.poly:SetRect(i, x,y, sx,sy, r, ox,oy)
	end

	function SpriteBatch:set(id, q, ...)
		id = id or 1
		if line.Type(q) == "Quad" then
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
		if type(r) == "table" then
			r,g,b,a = unpack(r)
		end

		r = r or 255
		g = g or 255
		b = b or 255
		a = a or 255

		self.poly:SetColor(r/255,g/255,b/255,a/255)
	end

	function SpriteBatch:clear()
		self.i = 1
	end

	function SpriteBatch:getImage()
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

	function SpriteBatch:getImage()
		return self.img
	end

	function SpriteBatch:Draw()
		self.poly:Draw()
	end

	function love.graphics.newSpriteBatch(image, size, usagehint)
		local self = line.CreateObject("SpriteBatch")
		local poly = gfx.CreatePolygon2D(size * 6)

		self.size = size

		self.poly = poly
		self.img = image
		self.w = image:getWidth()
		self.h = image:getHeight()
		self.i = 1

		return self
	end

	line.RegisterType(SpriteBatch)
end
