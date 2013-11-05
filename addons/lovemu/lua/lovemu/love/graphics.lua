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


local function getWidth(self,arg1)
	if self.w then --is image
		return self.w
	elseif type(self)=="string" then --is font
		arg1=arg1 or "1"
		return fonts[self]*(#arg1)
	end
	return 32
end

local function getHeight(self,arg1)
	if self.h then --is image
		return self.h
	elseif type(self)=="string" then --is font
		arg1=arg1 or "1"
		return fonts[self]*(#arg1)
	end
	return 32
end

function love.graphics.newFont(font,siz)
	if type(font)=="number" then
		siz=font
		local FontObject={}
		FontObject.Name=surface.CreateFont("fonts/verdana.ttf", {
			size = siz,
			path = R("fonts/verdana.ttf"),
		})
		FontObject.Size=siz
		FontObject.getWidth=getWidth
		FontObject.getHeight=getHeight
		return FontObject
	else
		local FontObject={}
		FontObject.Name=surface.CreateFont(lovemu.demoname .. "_" .. font, {
			size = siz,
			path = R("lovers/"..lovemu.demoname.."/"..font),
		})
		print("loaded font: "..font)
		FontObject.Size=siz
		FontObject.getWidth=getWidth
		FontObject.getHeight=getHeight
		return FontObject
	end
end


local currentFont=love.graphics.newFont(12)
function love.graphics.setFont(font)
	currentFont=font
	surface.SetFont(font.Name)
end

function love.graphics.setNewFont(arg1,arg2)
	love.graphics.setFont(love.graphics.newFont(arg1,arg2))
end

function love.graphics.getFont(font)
	return currentFont
end


local br,bg,bb,ba=0,0,0,0
function love.graphics.setBackgroundColor(r,g,b,a)
	r=r or 0
	g=g or 0
	b=b or 0
	a=a or 255
	br=r
	bg=g
	bb=b
	ba=a
end

function love.graphics.getBackgroundColor()
	return br,bg,bb,ba
end

local cr,cg,cb,ca=0,0,0,0
function love.graphics.setColor(r,g,b,a)
	if type(r)=="number" then
		r=r or 0
		g=g or 0
		b=b or 0
		a=a or 255
		cr=r
		cg=g
		cb=b
		ca=a
		surface.Color(cr/255, cg/255, cb/255, ca/255)
	else
		local tab=r
		r=tab[1] or 0
		g=tab[2] or 0
		b=tab[3] or 0
		a=tab[4] or 255
		cr=r
		cg=g
		cb=b
		ca=a
		surface.Color(cr/255, cg/255, cb/255, ca/255)
	end
end

function love.graphics.getColor()
	return cr,cg,cb,ca
end

function love.graphics.getWidth()
	return render.w
end

function love.graphics.getHeight()
	return render.h
end

function love.graphics.setMode() --partial
end

do
	local size = 1

	function love.graphics.setPointStyle(s)
		size = s
	end

	function love.graphics.point(x,y)
		surface.SetWhiteTexture()
		surface.DrawRect(x,y,size,size)
	end
end

function love.graphics.print(text,x,y,r,sx,sy)
	x=x+lovemu.translate_x
	y=y+lovemu.translate_y
	r=r or 0
	if r > 0 then
		r=r/0.0174532925
	end
	sx=sx or lovemu.scale_x 
	sy=sy or lovemu.scale_y
	surface.SetTextScale(sx,sy)
	surface.SetTextPos((x+lovemu.translate_x)*lovemu.scale_x, (y+lovemu.translate_y)*lovemu.scale_y)
	surface.DrawText(text,r)
	surface.SetTextScale(1,1)
end

local cache = {}

function love.graphics.printf(text,x,y,limit,align,r, sx, sy) --partial
	x=x+lovemu.translate_x
	y=y+lovemu.translate_y
	r=r or 0
	if r > 0 then
		r=r/0.0174532925
	end
	y=y or 0
	limit=limit or 0
	align=align or "left"
	sx=sx or lovemu.scale_x 
	sy=sy or lovemu.scale_y
	
	local lines = cache[text] or string.explode(text,"\n")
	cache[text] = lines 
	
	surface.SetTextScale(sx,sy)
	for i=1,#lines do
		surface.SetTextPos((x+lovemu.translate_x)*lovemu.scale_x,((y+lovemu.translate_y)*lovemu.scale_y)+(currentFont.Size*i*2.1))
		surface.DrawText(lines[i])
	end
	surface.SetTextScale(1,1)
end

function love.graphics.setLineStyle(s) --partial
end

function love.graphics.setPointStyle() --partial
end

function love.graphics.setPointSize() --partial
end

function love.graphics.setPoint() --partial
end

function love.graphics.newQuad(...) --partial
	return {quad = true, ...}
end

function love.graphics.drawq() --partial
	return {}
end

function love.graphics.rectangle(mode,x,y,w,h)
	if mode=="fill" then
		surface.SetTexture()
		surface.DrawRect((x+lovemu.translate_x)*lovemu.scale_x, (y+lovemu.translate_y)*lovemu.scale_y, w*lovemu.scale_x, h*lovemu.scale_y,0,0,0)
	else
		x=(x+lovemu.translate_x)*lovemu.scale_x
		y=(y+lovemu.translate_y)*lovemu.scale_y
		w=w*lovemu.scale_x
		h=h*lovemu.scale_y
		surface.DrawLine(x,y, x+w,y, LineWidth, true)
		surface.DrawLine(x,y, x,y+h, LineWidth, true)
		surface.DrawLine(x+w,y, x+w,y+h, LineWidth, true)
		surface.DrawLine(x,y+h, x+w,y+h, LineWidth, true)
	end
end

function love.graphics.circle(mode,x,y,w,h) --partial
	x=x or 0
	y=y or 0
	w=w or 0
	h=h or 0
	surface.SetTexture()
	surface.DrawRect((x+lovemu.translate_x)*lovemu.scale_x, (y+lovemu.translate_y)*lovemu.scale_y, w*lovemu.scale_x, h*lovemu.scale_y,0,0,0)
end

function love.graphics.reset()
end

function love.graphics.clear()
	surface.SetTexture()
	surface.Color(br/255,bg/255,bb/255,ba/255)
	surface.DrawRect(0,0,render.w,render.h,0,0,0)
	surface.Color(cr/255,cg/255,cb/255,ca/255)
end

local BlendMode="alpha"
function love.graphics.getBlendMode() --partial
	return BlendMode
end

function love.graphics.setBlendMode(b) --partial
	BlendMode=b
end

function love.graphics.isSupported() --partial
	return true
end

function love.graphics.setCanvas(canvas)
	canvas:Bind()
end

local canvas_config={
	{
		name = "diffuse",
		attach = e.GL_COLOR_ATTACHMENT1,
		texture_format = {
			internal_format = e.GL_RGB32F,
		}
	}
}
		
function love.graphics.newCanvas(w,h) --partial
	return render.CreateFrameBuffer(w,h,canvas_config)
end

local LineWidth=1
function love.graphics.setLineWidth(w)
	LineWidth=w
end

function love.graphics.line(x1,y1,x2,y2)
	surface.DrawLine(x1,y1,x2,y2,LineWidth,false)
end

local DefaultFilter=e.GL_LINEAR
local DefaultMipmapFilter=e.GL_LINEAR_MIPMAP_LINEAR
function love.graphics.setDefaultFilter(filter)
	if filter=="nearest" then
		local DefaultFilter=e.GL_NEAREST
		local DefaultMipmapFilter=e.GL_NEAREST_MIPMAP_NEAREST
	elseif filter=="linear" then
		local DefaultFilter=e.GL_LINEAR
		local DefaultMipmapFilter=e.GL_LINEAR_MIPMAP_LINEAR
	end
end
love.graphics.setDefaultImageFilter=setDefaultFilter


function setFilter(self,filter)
	if filter=="nearest" then
		DefaultFilter=e.GL_NEAREST
	elseif filter=="linear" then
		DefaultFilter=e.GL_LINEAR
	end
end

function love.graphics.newImage(path)
	path="/lovers/".. lovemu.demoname .. "/" .. path
	local w, h, buffer = freeimage.LoadImage(vfs.Read(path, "rb"))
	
	local tex = Texture(
		w, h, buffer, 
		{
			mip_map_levels = 1,  
			mag_filter = e.GL_LINEAR,
			min_filter = e.GL_LINEAR_MIPMAP_LINEAR,
		}  
	) 
	tex.getWidth=function(s) return s.w end
	tex.getHeight=function(s) return s.h end
	tex.setFilter=function() end
	return tex
end

function love.graphics.newStencil(func) --partial
end 

function love.graphics.setStencil(func) --partial
end

function love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
	x=x or 0
	y=y or 0
	r=r or 0
	r=(r/0.0174532925)
	sx=sx or 1
	sy=sy or 1
	ox=ox or 0
	oy=oy or 0
	if drawable.id then
		if type(x) == "table" and x.quad then
			--x = x[1]
			y = x[2] * x[6]
			sx = x[3]
			sy = x[4]
			
			x = x[1] * x[5]
		end
		surface.SetTexture(drawable)
		surface.DrawRect((x+lovemu.translate_x)*lovemu.scale_x,(y+lovemu.translate_y)*lovemu.scale_y, drawable.w*sx*lovemu.scale_x, drawable.h*sy*lovemu.scale_y,r,ox*sx*lovemu.scale_x,oy*sy*lovemu.scale_y)
	end
end

function love.graphics.translate(x,y)
	x=x or 0
	y=y or 0 
	lovemu.translate_x=lovemu.translate_x+x
	lovemu.translate_y=lovemu.translate_y+y
end

function love.graphics.scale(sx,sy)
	sx=sx or 1
	sy=sy or 1
	lovemu.scale_x=sx
	lovemu.scale_y=sy
end

love.graphics.rotate=function() end
 
function love.graphics.push()
	lovemu.stack[lovemu.stack_index]={
										translate_x=lovemu.translate_x,
										translate_y=lovemu.translate_y,
										scale_x=lovemu.scale_x,
										scale_y=lovemu.scale_y,
										angle=lovemu.angle
									}
	lovemu.stack_index=lovemu.stack_index+1
end

function love.graphics.pop()
	if lovemu.stack_index>1 then
		lovemu.stack_index=lovemu.stack_index-1
		lovemu.translate_x=lovemu.stack[lovemu.stack_index].translate_x
		lovemu.translate_y=lovemu.stack[lovemu.stack_index].translate_y
		lovemu.scale_x=lovemu.stack[lovemu.stack_index].scale_y
		lovemu.scale_y=lovemu.stack[lovemu.stack_index].scale_y
		lovemu.angle=lovemu.stack[lovemu.stack_index].angle
	end
end
function love.graphics.setCaption(title)
	window.SetTitle(title)
end