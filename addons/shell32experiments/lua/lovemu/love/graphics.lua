local love=love
love.graphics={}

local surface=surface
local render=render
local gl=gl
local type=type

local glTranslatef = gl.Translatef
local glRotatef = gl.Rotatef
local glScalef = gl.Scalef
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix

function getWidth(self,arg1)
	if self.w then --is image
		return self.w
	elseif type(self)=="string" then --is font
		arg1=arg1 or "1"
		return fonts[self]*(#arg1)
	end
	return 32
end

function getHeight(self,arg1)
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
		FontObject.Name=surface.CreateFont("fonts/verdana.ttf"..siz, {
			size = siz,
			path = "fonts/verdana.ttf",
		})
		FontObject.Size=siz
		FontObject.getWidth=getWidth
		FontObject.getHeight=getHeight
		return FontObject
	else
		local FontObject={}
		print( love.filesystem.getAppdataDirectory()..font)
		FontObject.Name=surface.CreateFont(font..siz, {
			size = siz,
			path = e.ABSOLUTE_BASE_FOLDER.."addons/shell32experiments/demos/"..lovemu.demoname.."/"..font,
		})
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
	br=r/255
	bg=g/255
	bb=b/255
	ba=a/255
end

local cr,cg,cb,ca=0,0,0,0
function love.graphics.setColor(r,g,b,a)
	if type(r)=="number" then
		r=r or 0
		g=g or 0
		b=b or 0
		a=a or 255
		cr=r/255
		cg=g/255
		cb=b/255
		ca=a/255
		render.r=cr
		render.g=cg
		render.b=cb
		render.a=ca
	else
		local tab=r
		r=tab[1] or 0
		g=tab[2] or 0
		b=tab[3] or 0
		a=tab[4] or 255
		cr=r/255
		cg=g/255
		cb=b/255
		ca=a/255
		render.r=cr
		render.g=cg
		render.b=cb
		render.a=ca
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

function love.graphics.print(text,x,y,r,sx,sy)
	x=x+lovemu.translate_x
	y=y+lovemu.translate_y
	r=r or 0
	if r > 0 then
		r=r/0.0174532925
	end
	sx=sx or 1
	sy=sy or 1
	glScalef(sx, sy, 0)
	if r==0 then
		for i=1,#text do
			surface.SetTextPos((x+(i*(currentFont.Size*0.8)))*sx,y)
			surface.DrawChar(text:sub(i,i))
		end
	else
		for i=1,#text do
			surface.SetTextPos((x+(i*(currentFont.Size*0.8)))*sx,y)
			surface.DrawChar(text:sub(i,i),r)
		end
	end
end

function love.graphics.printf(text,x,y,limit,align,r, sx, sy)
	x=x+lovemu.translate_x
	y=y+lovemu.translate_y
	r=r or 0
	if r > 0 then
		r=r/0.0174532925
	end
	y=y or 0
	limit=limit or 0
	align=align or "left"
	sx=sx or 1
	sy=sy or 1
	glScalef(sx, sy, 0)
	
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
				if ((accumulator_x*currentFont.Size)*sx)>limit then
					accumulator_x=1
					accumulator_y=accumulator_y+1.5
					surface.SetTextPos(x+((accumulator_x*(currentFont.Size*0.8))*sx),(y+((accumulator_y*currentFont.Size))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				else
					surface.SetTextPos(x+((accumulator_x*(currentFont.Size*0.8))*sx),(y+((accumulator_y*currentFont.Size))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				end
			end
		end
	else
		glRotatef(r, 0, 0, 1)
		for i=1,#text do
			char=text:sub(i,i)
			if char=="\t" then
				accumulator_x=accumulator_x+4
			elseif char=="\n" then
				accumulator_x=1
				accumulator_y=accumulator_y+1.5
			else
				if ((accumulator_x*currentFont.Size)*sx)>limit then
					accumulator_x=1
					accumulator_y=accumulator_y+1.5
					surface.SetTextPos(x+((accumulator_x*currentFont.Size)*sx),(y+((accumulator_y*currentFont.Size))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				else
					surface.SetTextPos(x+((accumulator_x*currentFont.Size)*sx),(y+((accumulator_y*currentFont.Size))*sy))
					surface.DrawChar(text:sub(i,i))
					accumulator_x=accumulator_x+1
				end
			end
		end
		glRotatef(-r, 0, 0, 1)
	end
end

function love.graphics.setLineStyle(s) --partial
end

function love.graphics.setPointStyle() --partial
end

function love.graphics.setPointSize() --partial
end

function love.graphics.setPoint() --partial
end

function love.graphics.rectangle(mode,x,y,w,h)
	surface.DrawRectEx(x,y,w,h,0,0,0)
end

function love.graphics.reset()
end

function love.graphics.clear()
	surface.white_texture:Bind()
	render.r=br
	render.g=bg
	render.b=bb
	render.a=ba
	surface.DrawRectEx(0,0,render.w,render.h,0,0,0)
	render.r=cr
	render.g=cg
	render.b=cb
	render.a=ca
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

function love.graphics.newImage(path)
	path="/demos/".. lovemu.demoname .. "/" .. path
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
	tex.setFilter=setFilter
	return tex
end

function love.graphics.newStencil(func) --partial
end 

function love.graphics.setStencil(func) --partial
end

function love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
	y=y or 0
	r=r or 0
	r=(r/0.0174532925) + lovemu.angle
	sx=sx or 1
	sy=sy or 1
	ox=ox or 0
	oy=oy or 0
	if drawable.id then
		drawable:Bind()
		surface.bound_texture=drawable
		surface.DrawRectEx(x+lovemu.translate_x,y+lovemu.translate_y*lovemu.scale_y,drawable.w*sx,drawable.h*sy*lovemu.scale_y,r,ox,oy)
	end
end

function love.graphics.translate(x,y)
	lovemu.translate_x=lovemu.translate_x+x
	lovemu.translate_y=lovemu.translate_y+y
end

function love.graphics.scale(sx,sy) --partial
	lovemu.scale_x=lovemu.scale_x*sx
	lovemu.scale_y=lovemu.scale_y*sy
end

function love.graphics.rotate(r) 
	lovemu.angle=lovemu.angle+r
end

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
	glw.SetWindowTitle(title)
end