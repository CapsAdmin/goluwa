local love=love
local lovemu=lovemu
love.image={}

function love.image.newImageData(a, b)
	check(a, "string", "number")
	check(b, "number", "nil")

	local w
	local h
	local buffer
	
	if type(a) == "number" and type(b) == "number" then
		w = a
		h = a
	elseif not b and type(a) == "string" then
		local path = "/lovers/".. lovemu.demoname .. "/" .. a
		
		if vfs.Exists(path) then
			w, h, buffer = freeimage.LoadImage(vfs.Read(path, "rb"))
		else
			w, h, buffer = freeimage.LoadImage(a)
		end
	end

	local tex = Texture(w, h, buffer, {
		mag_filter = e.GL_LINEAR,
		min_filter = e.GL_LINEAR_MIPMAP_LINEAR ,
	}) 
	
	tex.getWidth = function(s) return s.w end
	tex.getHeight = function(s) return s.h end
	tex.setFilter = function() end
	
	tex.mapPixel = function(s, cb) s:Fill(function(x,y,i, r,g,b,a) cb(x,y,r,g,b,a) end, false, true) end
	
	return tex
end