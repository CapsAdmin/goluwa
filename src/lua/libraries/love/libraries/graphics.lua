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

love.graphics.origin = surface.LoadIdentity
love.graphics.translate = surface.Translate
love.graphics.shear = surface.Shear
love.graphics.rotate = surface.Rotate
love.graphics.push = surface.PushMatrix
love.graphics.pop = surface.PopMatrix

function love.graphics.scale(x, y)
	y = y or x
	surface.Scale(x, y)
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

		surface.SetColor(ENV.graphics_color_r/255, ENV.graphics_color_g/255, ENV.graphics_color_b/255, ENV.graphics_color_a/255)
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
			surface.SetWhiteTexture()
			surface.SetColor(br/255,bg/255,bb/255,ba/255)
			surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
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
			surface.PushTexture(render.GetWhiteTexture())
			surface.DrawRect(x, y, SIZE, SIZE, nil, SIZE/2, SIZE/2)
			surface.PopTexture()
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
					surface.SetColor(point[3], point[4], point[5], point[6])
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
		surface.PushColor(cr/255, cg/255, cb/255, ca/255)
		surface.PushMatrix(x, y, sx, sy, r)
		surface.Translate(ox, oy)
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
						align_x = (-w / 2) + limit/2 - x
					end

					gfx.SetTextPosition(align_x, (i-1) * h * font.line_height)
					gfx.DrawText(line)
				end
			else
				gfx.SetTextPosition(0, 0)
				gfx.DrawText(text)
			end
		surface.PopMatrix()
		surface.PopColor()
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
		surface.SetWhiteTexture()
		surface.DrawRect(x, y, w, h)
	else
		surface.DrawLine(x,y, x+w,y)
		surface.DrawLine(x,y, x,y+h)
		surface.DrawLine(x+w,y, x+w,y+h)
		surface.DrawLine(x,y+h, x+w,y+h)
	end
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
	surface.SetColor(cr/255, cg/255, cb/255, ca/255)
	surface.PushTexture(ENV.textures[drawable])
	surface.SetRectUV(quad.x,quad.y, quad.w,quad.h, quad.sw,quad.sh)
	surface.DrawRect(x,y, quad.w*sx, quad.h*sy,r,ox*sx,oy*sy)
	surface.SetRectUV()
	surface.PopTexture()
end

function love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
	if ENV.textures[drawable] then
		if line.Type(x) == "Quad" then
			love.graphics.drawq(drawable, x, y, r, sx, sy, ox, oy, quad_arg)
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

			surface.PushTexture(tex)
			surface.DrawRect(x,y, tex:GetSize().x*sx, tex:GetSize().y*sy, r, ox*sx,oy*sy)
			surface.PopTexture()
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
			surface.PushColor(1,1,1,1)
			surface.PushTexture(ENV.textures[drawable.img])
			surface.PushMatrix(x,y)
				surface.Translate(ox,oy)
				surface.Rotate(r)
				surface.Scale(sx,sy)
				drawable:Draw()
			surface.PopMatrix()
			surface.PopTexture()
			surface.PopColor()
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
	local Shader = line.TypeTemplate("Shader")

	function Shader:getWarnings()
		return ""
	end

	function Shader:send()

	end

	function love.graphics.newShader()
		local obj = line.CreateObject("Shader")

		return obj
	end

	line.RegisterType(Shader)
end

love.graphics.newPixelEffect = love.graphics.newShader

function love.graphics.setShader()
end

function love.graphics.setPixelEffect()
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
	local function edge(anchors, normals, s, len_s, ns, q, r, half_width, mode)
		if mode == "none" then
			table.insert(anchors, q)
			table.insert(anchors, q)
			table.insert(normals, ns)
			table.insert(normals, -ns)

			s = (r - q)
			len_s = s:GetLength()
			ns = s:GetNormal(half_width / len_s)

			table.insert(anchors, q)
			table.insert(anchors, q)
			table.insert(normals, -ns)
			table.insert(normals, ns)
		elseif mode == "miter" then
			local t = r - q
			local len_t = t:GetLength()
			local nt = t:GetNormal(half_width / len_t)

			table.insert(anchors, q)
			table.insert(anchors, q)

			local det = s:GetCrossed(t)
			if math.abs(det) / (len_s * len_t) < 0.05 and s:GetDot(t) > 0 then
				table.insert(normals, ns)
				table.insert(normals, -ns)
			else
				local lambda = (nt - ns):GetCrossed(t) / det
				local d = ns + s * lambda

				--logf("normal = %i\nlambda = %f\nnt= Vec2(%f, %f)\nns= Vec2(%f, %f)\nt = Vec2(%f, %f)\ndet = %f\ns = Vec2(%f, %f)\n", #normals, lambda, nt.x,nt.y, ns.x,ns.y, t.x,t.y, det, s.x, s.y);

				table.insert(normals, d)
				table.insert(normals, -d)
			end

			s = t
			ns = nt
			len_s = len_t

		elseif mode == "bevel" then
			local t = r - q
			local len_t = t:GetLength()

			local det = s:GetCrossed(t)
			if math.abs(det) / (len_s * len_t) < 0.05 and s:GetDot(t) > 0 then
				local n = t:GetNormal(half_width / len_t)
				table.insert(anchors, q)
				table.insert(anchors, q)
				table.insert(normals, n)
				table.insert(normals, -n)
				s = t
				len_s = len_t
				return s, len_s, ns
			end

			local nt = t:GetNormal(half_width / len_t)
			local lambda = (nt - ns):GetCrossed(t) / det
			if not math.isvalid(lambda) then lambda = 0 end -- not really sure why this is needed
			local d = ns + s * lambda

			table.insert(anchors, q)
			table.insert(anchors, q)
			table.insert(anchors, q)
			table.insert(anchors, q)

			if det > 0 then
				table.insert(normals, d)
				table.insert(normals, -ns)
				table.insert(normals, d)
				table.insert(normals, -nt)
			else
				table.insert(normals, ns)
				table.insert(normals, -d)
				table.insert(normals, nt)
				table.insert(normals, -d)
			end

			s = t
			len_s = len_t
			ns = nt
		end

		return s, len_s, ns
	end

	local function line_(mode, coords, count, size_hint, half_width, pixel_size, draw_overdraw, draw_mode, join)
		local overdraw_vertex_count = 0
		local overdraw_vertex_start = 0

		local anchors = table.new(size_hint, 1)
		local normals = table.new(size_hint, 1)

		if draw_overdraw then
			half_width = half_width - pixel_size * 0.3
		end

		if join then
			table.insert(coords, coords[1])
			table.insert(coords, coords[2])
			count = count + 2
		end

		local is_looping = (coords[1] == coords[count - 1]) and (coords[2] == coords[count])
		local s

		if is_looping then
			s = Vec2(coords[1] - coords[count - 3], coords[2] - coords[count - 2])
		else
			s = Vec2(coords[3] - coords[1], coords[4] - coords[2])
		end

		local len_s = s:GetLength()
		local ns = s:GetNormal(half_width / len_s)

		local q
		local r = Vec2(coords[1], coords[2])

		for i = 0, count - 2, 2 do
			q = r
			if i < count - 2 then
				r = Vec2(coords[i + 3], coords[i + 4])
			elseif is_looping then
				r = Vec2(coords[3], coords[4])
			else
				r = r + s
			end
			s, len_s, ns = edge(anchors, normals, s, len_s, ns, q, r, half_width, mode)
		end

		if join then
			table.remove(coords)
			table.remove(coords)
		end

		local vertex_count = #normals
		local extra_vertices = 0

		if draw_overdraw then
			--calc_overdraw_vertex_count(is_looping)
			if mode == "none" then
				overdraw_vertex_count = 4 * vertex_count - 2
			else
				overdraw_vertex_count = 2 * vertex_count + (is_looping and 0 or 2)
			end

			if draw_mode == "triangle_strip" then
				extra_vertices = 2
			end
		end

		local vertices = {}

		for i = 1, vertex_count do
			vertices[i] = anchors[i] + normals[i]
		end

		if draw_overdraw then
			local overdraw = vertices--- + vertex_count + extra_vertices
			overdraw_vertex_start = vertex_count + extra_vertices

			if mode == "none" then
				for i = 2, vertex_count + 3 - 1, 4 do
					local s = vertices[i+1] - vertices[i+3+1]
					local t = vertices[i+1] - vertices[i+1+1]
					s:Normalize(pixel_size)
					t:Normalize(pixel_size)

					local k = 4 * (- 2)
					k = k + overdraw_vertex_start
					k = k + 1
					i = i + 1
					overdraw[k] = vertices[i]
					overdraw[k+1] = vertices[i]   + s + t
					overdraw[k+2] = vertices[i+1] + s - t
					overdraw[k+3] = vertices[i+1]

					overdraw[k+4] = vertices[i+1]
					overdraw[k+5] = vertices[i+1] + s - t
					overdraw[k+6] = vertices[i+2] - s - t
					overdraw[k+7] = vertices[i+2]

					overdraw[k+8]  = vertices[i+2]
					overdraw[k+9]  = vertices[i+2] - s - t
					overdraw[k+10] = vertices[i+3] - s + t
					overdraw[k+11] = vertices[i+3]

					overdraw[k+12] = vertices[i+3]
					overdraw[k+13] = vertices[i+3] - s + t
					overdraw[k+14] = vertices[i]   + s + t
					overdraw[k+15] = vertices[i]
				end
			else
				for i = 0, vertex_count - 1 - 1, 2 do
					overdraw[overdraw_vertex_start + i+1] = vertices[i+1]
					overdraw[overdraw_vertex_start + i+1+1] = vertices[i+1] + normals[i+1] * (pixel_size / normals[i+1]:GetLength())
				end

				for i = 0, vertex_count - 1 - 1, 2 do
					local k = vertex_count - i - 1
					overdraw[overdraw_vertex_start + vertex_count + i+1] = vertices[k]
					overdraw[overdraw_vertex_start + vertex_count + i+1+1] = vertices[k+1] + normals[k+1] * (pixel_size / normals[i+1]:GetLength())
				end

				if not is_looping then
					local spacer = (overdraw[overdraw_vertex_start + 1+1] - overdraw[overdraw_vertex_start + 3+1])
					spacer:Normalize(pixel_size)
					overdraw[overdraw_vertex_start + 1+1] = overdraw[overdraw_vertex_start + 1+1] + spacer

					spacer = (overdraw[overdraw_vertex_start + vertex_count - 1] - overdraw[overdraw_vertex_start + vertex_count - 3])
					spacer:Normalize(pixel_size)
					overdraw[overdraw_vertex_start + vertex_count - 1+1] = overdraw[overdraw_vertex_start + vertex_count - 1+1]  + spacer
					overdraw[overdraw_vertex_start + vertex_count + 1+1] = overdraw[overdraw_vertex_start + vertex_count + 1+1]  + spacer

					overdraw[overdraw_vertex_start + overdraw_vertex_count - 2+1] = overdraw[overdraw_vertex_start + 0+1]
					overdraw[overdraw_vertex_start + overdraw_vertex_count - 1+1] = overdraw[overdraw_vertex_start + 1+1]
				end
			end
		end

		if extra_vertices ~= 0 then
			vertices[vertex_count + 0 + 1] = vertices[vertex_count - 1 + 1]
			vertices[vertex_count + 1 + 1] = vertices[overdraw_vertex_start + 1]
		end

		return vertices, overdraw_vertex_start + overdraw_vertex_count
	end

	local function generate_line(mode, coords, width, pixel_size, draw_overdraw, join)
		width = width * 0.5
		local draw_mode
		if mode == "none" then
			draw_mode = "triangles"
		else
			draw_mode = "triangle_strip"
		end
		local count = #coords
		if mode == "miter" then
			return line_(mode, coords, count, count, width, pixel_size, draw_overdraw, draw_mode, join), nil, draw_mode
		elseif mode == "bevel" then
			return line_(mode, coords, count, 2 * count - 4, width, pixel_size, draw_overdraw, draw_mode, join), nil, draw_mode
		elseif mode == "none" then
			local vertices, overdraw_count = line_(mode, coords, count, 2 * count - 4, width, pixel_size, draw_overdraw, draw_mode, join)
			for i = 0, #vertices - 4 - 1 do
				vertices[i + 1] = vertices[i + 2 + 1]
			end
			table.remove(vertices, #vertices)

			local total_vertex_count = #vertices
			if draw_overdraw then
				total_vertex_count = overdraw_count
			end
			local num_indices = (total_vertex_count / 4) * 6
			local indices = {}

			for i = 0, (num_indices / 6) - 1 do
				indices[(i * 6 + 0) + 1] = i * 4 + 0
				indices[(i * 6 + 1) + 1] = i * 4 + 1
				indices[(i * 6 + 2) + 1] = i * 4 + 2

				indices[(i * 6 + 3) + 1] = i * 4 + 0
				indices[(i * 6 + 4) + 1] = i * 4 + 2
				indices[(i * 6 + 5) + 1] = i * 4 + 3
			end

			return vertices, indices, draw_mode
		end
	end

	local mesh = surface.CreateMesh(2048)
	for i = 1, 2048 do
		mesh:SetVertex(i, "color", 1,1,1,1)
	end
	local function polygon(mode, points, join)
		surface.PushTexture(render.GetWhiteTexture())
		local idx = 1

		if mode == "line" then
			--table.insert(points, points[1])
			--table.insert(points, points[2])
			local vertices, indices, mode = generate_line(love.graphics.getLineJoin(), points, love.graphics.getLineWidth(), 1, false, join)--love.graphics.getLineStyle() == "smooth", true)
			--table.remove(points)
			--table.remove(points)

			if indices then
				for i, v in ipairs(indices) do
					mesh:SetIndex(i, v)
				end
				idx = #indices
			else
				for i = 1, #vertices do
					mesh:SetIndex(i, i-1)
				end
				idx = #vertices
			end

			for i, v in ipairs(vertices) do
				mesh:SetVertex(i, "pos", v.x, v.y)
			end

			mesh:SetMode(mode)
		else
			for i = 1, #points, 2 do
				mesh:SetVertex(idx, "pos", points[i + 0], points[i + 1])
				idx = idx + 1
			end
			for i = 1, #points do
				mesh:SetIndex(i, i-1)
			end

			-- connect the end
			mesh:SetIndex(idx, 0)

			mesh:SetMode("triangle_fan")
		end

		mesh:UpdateBuffer()
		mesh:Draw(idx)

		surface.PopTexture()
	end

	function love.graphics.polygon(mode, ...)
		local points = type(...) == "table" and ... or {...}
		polygon(mode, points, true)
	end

	do
		local Mesh = line.TypeTemplate("Mesh")


		function love.graphics.newMesh(...)
			local vertices
			local vertex_count
			local vertex_format
			local mode
			local usage

			if type(...) == "number" then
				vertex_count, mode, usage = ...
			elseif type(...) == "table" then
				vertices, mode, usage = ...
				vertex_count = #vertices
			elseif type(...) == "string" then
				vertex_format, vertices, mode, usage = ...
				vertex_count = #vertices
			else
				vertex_count, mode, usage = ...
			end

			local self = line.CreateObject("Mesh")
			self.mesh = surface.CreateMesh(vertex_count)
			self.mesh:SetDrawHint(usage)
			self:setDrawMode(mode)

			if vertices then
				self:setVertices(vertices)
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
			self.mesh:UpdateBuffer()
		end

		function Mesh:getVertices()
			local out = {}
			for i = 1, self.mesh.Vertices:GetLength() do
				out[i] = {self:getVertex()}
			end
			return out
		end

		function Mesh:setVertex(index, vertex)
			if vertex[1] then
				self.mesh:SetVertex(index, "pos", vertex[1], vertex[2])
			end
			if vertex[3] then
				self.mesh:SetVertex(index, "uv", vertex[3], -vertex[4]+1)
			end
			if vertex[5] then
				local r = (vertex[5] or 255) / 255
				local g = (vertex[6] or 255) / 255
				local b = (vertex[7] or 255) / 255
				local a = (vertex[8] or 255) / 255
				self.mesh:SetVertex(index, "color", r,g,b,a)
			end
		end

		function Mesh:getVertex(index)
			local x,y = self.mesh:GetVertex(index, "pos")
			local u,v = self.mesh:GetVertex(index, "uv")
			local r,g,b,a = self.mesh:GetVertex(index, "color")

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
			self.mesh:Draw(self.draw_range)
		end

		function Mesh:setVertexColors()

		end

		function Mesh:hasVertexColors()
			return true
		end

		function Mesh:setVertexMap(...)
			local indices = type(...) == "table" and ... or {...}
			for i, i2 in ipairs(indices) do
				self.mesh:SetIndex(i, i2-1)
			end
		end

		function Mesh:getVertexMap()
			local out = {}
			for i = 1, self.mesh.Indices:GetLength() do
				out[i] = self.mesh.Indices.Pointer[i - 1] + 1
			end
			return out
		end

		function Mesh:getVertexCount()
			return self.mesh.Vertices:GetLength()
		end

		function Mesh:setVertexAttribute(index, pos, ...)
			self:setVertex(index, self.mesh.mesh_layout.attributes[pos].name, ...)
		end

		function Mesh:getVertexAttribute(index, pos)
			return self:getVertex(index, self.mesh.mesh_layout.attributes[pos].name)
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
				for i, info in ipairs(self.mesh.mesh_layout.attributes) do
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
				self.mesh:SetMode(mode)
			end

			local tr2 = {}

			for k,v in pairs(tr) do
				tr[v] = k
			end

			function Mesh:getDrawMode()
				local mode = self.mesh:GetMode()
				return tr2[mode] or mode
			end
		end

		line.RegisterType(Mesh)
	end

	do
		local function create_points(coords, points, x, y, radius, phi, angle_shift, offset)
			for i = offset, points-1 do
				coords[(2 * i + 0) + 1] = x + radius * math.cos(phi)
				coords[(2 * i + 1) + 1] = y + radius * math.sin(phi)
				phi = phi + angle_shift
			end
		end

		local function arc(draw_mode, arc_mode, x, y, radius, angle1, angle2, points)
			points = points or radius
			local angle = math.abs(angle1 - angle2)

			if angle < math.pi * 2 then
				points = points * angle / (2 * math.pi)
			end


			points = math.ceil(points)

			if points <= 0 or angle1 == angle2 then
				--return
			end

			if math.abs(angle1 - angle2) >= 2 * math.pi then
				return -- draw circle
			end

			local angle_shift = (angle2 - angle1) / points

			if angle_shift  == 0  then
				return
			end

			if draw_mode == "line" and arc_mode == "closed" and math.abs(angle1 - angle2) < math.rad(4) then
				arc_mode = "open"
			end

			if draw_mode == "fill" and arc_mode == "open" then
				arc_mode = "closed"
			end

			local phi = angle1
			local coords = {}
			local num_coords = 0

			if arc_mode == "pie" then
				coords[1] = x
				coords[2] = y

				create_points(coords, points + 3, x, y, radius, phi, angle_shift, 1)

				coords[#coords - 1] = x
				coords[#coords - 0] = y
			elseif arc_mode == "open" then
				create_points(coords, points + 1, x, y, radius, phi, angle_shift, 0)
			else -- if arc_mode == "closed" then
				create_points(coords, points + 2, x, y, radius, phi, angle_shift, 0)
				coords[#coords - 1] = coords[1]
				coords[#coords - 0] = coords[2]
			end

			polygon(draw_mode, coords)
		end

		function love.graphics.arc(...)
			if type(select(2, ...)) == "number" then
				local draw_mode, x, y, radius, angle1, angle2, segments = ...
				arc(draw_mode, "pie", x, y, radius, angle1, angle2, segments)
			else
				arc(...)
			end
		end
	end

	function love.graphics.ellipse(mode, x, y, radiusx, radiusy, points)
		if not points then
			if radiusx and radiusy and (radiusx + radiusy) > 30 then
				points = math.ceil((radiusx + radiusy) / 2)
			else
				points = 15
			end
		end

		local two_pi = math.pi * 2
		if points <= 0 then points = 1 end
		local angle_shift = two_pi / points
		local phi = 0

		local coords = {}
		for i = 0, points - 1 do
			coords[(2*i+0) + 1] = x + radiusx * math.cos(phi)
			coords[(2*i+1) + 1] = y + radiusy * math.sin(phi)
			phi = phi + angle_shift
		end

		coords[(2*points+0) + 1] = coords[1]
		coords[(2*points+1) + 1] = coords[2]

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
			surface.SetWhiteTexture()
			surface.DrawRect(x, y, w, h)
		else
			if not points then
				if math.max(rx, ry) > 20 then
					points = math.ceil(math.max(rx, ry) / 2)
				else
					points = 10
				end
			end

			if w >= 0.02 then
				rx = math.min(rx, w / 2 - 0.01)
			end

			if h >= 0.02 then
				ry = math.min(ry, h / 2 - 0.01)
			end

			local points = math.max(points, 1)
			local half_pi = math.pi / 2
			local angle_shift = half_pi / (points + 1)

			local coords = {}

			local phi

			phi = 0
			for i = 0, points + 2 do
				coords[(2 * i + 0) + 1] = x + rx * (1 - math.cos(phi))
				coords[(2 * i + 1) + 1] = y + ry * (1 - math.sin(phi))
				phi = phi + angle_shift
			end

			phi = half_pi
			for i = points + 2, 2 * (points + 2) do
				coords[(2 * i + 0) + 1] = x + w - rx * (1 + math.cos(phi))
				coords[(2 * i + 1) + 1] = y + ry * (1 - math.sin(phi))
				phi = phi + angle_shift
			end

			phi = 2 * half_pi
			for i = 2 * (points + 2), 3 * (points + 2) do
				coords[(2 * i + 0) + 1] = x + w - rx * (1 + math.cos(phi))
				coords[(2 * i + 1) + 1] = y + h - ry * (1 + math.sin(phi))
				phi = phi + angle_shift
			end

			phi = 3 * half_pi
			for i = 3 * (points + 2), 4 * (points + 2) do
				coords[(2 * i + 0) + 1] = x + rx * (1 - math.cos(phi))
				coords[(2 * i + 1) + 1] = y + h - ry * (1 + math.sin(phi))
				phi = phi + angle_shift
			end

			--coords[#coords - 1] = coords[3]
			--coords[#coords - 0] = coords[4]

			polygon("line", coords, true)
		end
	end
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
		local poly = gfx.CreatePolygon(size * 6)

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
