local love=love
love.graphics={}


fonts={}
function love.graphics.newFont(font,siz)
	if type(font)=="number" then
		siz=font
		font="fonts/easycode.ttf"
		fonts[font]=siz
		return surface.CreateFont(font, {
			size = siz,
			path = font,
		})
	else
		fonts[font]=siz
		return surface.CreateFont(font, {
			size = siz,
			path = font,
		})
	end
end

local currentFont=""
local currentFontSize=0
function love.graphics.setFont(font)
	currentFont=font
	currentFontSize=fonts[font]
	surface.SetFont(font)
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

local cr,cg,cb,ca=0,0,0,0
function love.graphics.setColor(r,g,b,a)
	r=r or 0
	g=g or 0
	b=b or 0
	a=a or 255
	cr=r/255
	cg=g/255
	cb=b/255
	ca=a/255
	surface.Color(cr,cg,cb,ca)
end

function love.graphics.getColor()
	return cr,cg,cb,ca
end

function love.graphics.print(text,x,y,r,sx,sy)
	r=r or 0
	if r > 0 then
		r=r/0.0174532925
	end
	sx=sx or 1
	sy=sy or 1
	surface.Scale(sx,sy)
	if r==0 then
		for i=1,#text do
			surface.SetTextPos((x+(i*(currentFontSize*0.8)))*sx,y)
			surface.DrawChar(text:sub(i,i))
		end
	else
		for i=1,#text do
			surface.SetTextPos((x+(i*(currentFontSize*0.8)))*sx,y)
			surface.DrawChar(text:sub(i,i),r)
		end
	end
end

function love.graphics.printf(text,x,y,limit,align,r, sx, sy)
	r=r or 0
	if r > 0 then
		r=r/0.0174532925
	end
	y=y or 0
	limit=limit or 0
	align=align or "left"
	sx=sx or 1
	sy=sy or 1
	surface.Scale(sx,sy)
	
	local accumulator_x,accumulator_y=1,1
	local char=""

	if r==0 then
		for i=1,#text do
			char=text:sub(i,i)
			if char=="\t" then
				accumulator_x=accumulator_x+4
			elseif char=="\n" then
				accumulator_x=1
				accumulator_y=accumulator_y+1.5
			else
				if ((accumulator_x*currentFontSize)*sx)>limit then
					accumulator_x=1
					accumulator_y=accumulator_y+1.5
					surface.SetTextPos(x+((accumulator_x*(currentFontSize*0.8))*sx),(y+((accumulator_y*currentFontSize))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				else
					surface.SetTextPos(x+((accumulator_x*(currentFontSize*0.8))*sx),(y+((accumulator_y*currentFontSize))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				end
			end
		end
	else
		surface.Rotate(r)
		for i=1,#text do
			char=text:sub(i,i)
			if char=="\t" then
				accumulator_x=accumulator_x+4
			elseif char=="\n" then
				accumulator_x=1
				accumulator_y=accumulator_y+1.5
			else
				if ((accumulator_x*currentFontSize)*sx)>limit then
					accumulator_x=1
					accumulator_y=accumulator_y+1.5
					surface.SetTextPos(x+((accumulator_x*currentFontSize)*sx),(y+((accumulator_y*currentFontSize))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				else
					surface.SetTextPos(x+((accumulator_x*currentFontSize)*sx),(y+((accumulator_y*currentFontSize))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				end
			end
		end
		surface.Rotate(-r)
	end
end

function love.graphics.setLineStyle(s)
end

function love.graphics.setPointStyle()
end

function love.graphics.setPointSize()
end

function love.graphics.setPoint()
end

function love.graphics.reset()
end

function love.graphics.clear()
	local x,y=surface.GetScreenSize()
	surface.SetWhiteTexture()
	surface.Color(br,bg,bb,ba)
	surface.DrawRectEx(0,0,x,y,0,0,0)
	surface.Color(cr,cg,cb,ca)
end

local BlendMode="alpha"
function love.graphics.getBlendMode()
	return BlendMode
end

function love.graphics.setBlendMode(b)
	BlendMode=b
end

function love.graphics.isSupported()
	return true
end

local LineWidth=1
function love.graphics.setLineWidth(w)
	LineWidth=w
end

function love.graphics.line(x1,y1,x2,y2)
	surface.DrawLine(x1,y1,x2,y2,w,false)
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

function setFilter(self,filter)
	if filter=="nearest" then
		DefaultFilter=filter
	elseif filter=="linear" then
		DefaultFilter=filter
	end
end


function getWidth(self)
	return self.w
end
function getHeight(self)
	return self.h
end
function love.graphics.newImage(path)
	path="/demos/".. love.demoname .. "/" .. path
	local w, h, buffer = freeimage.LoadImage(vfs.Read(path, "rb"))
	
	local tex = Texture(
		w, h, buffer, 
		{
			stride = 0, 
			mip_map_levels = 1,  
			mag_filter = e.GL_LINEAR,
			min_filter = e.GL_LINEAR_MIPMAP_LINEAR ,
			mip_map_levels = 1,
			
			wrap_r = e.GL_MIRRORED_REPEAT,
			wrap_s = e.GL_MIRRORED_REPEAT,
			wrap_t = e.GL_MIRRORED_REPEAT,
		}  
	) 
	tex.getWidth=getWidth
	tex.getHeight=getHeight
	return tex
end

love.timer={}

function love.timer.getTime()
	return glfw.GetTime()
end

function love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
	y=y or 0
	r=r or 0
	r=r/0.0174532925
	sx=sx or 1
	sy=sy or 1
	ox=ox or 0
	oy=oy or 0
	if drawable.id then
		surface.SetTexture(drawable)
		surface.DrawRectEx(x,y,drawable.w,drawable.h,r,ox,oy)
	end
end