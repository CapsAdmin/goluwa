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

	local obj = lovemu.NewObject("ImageData")
	
	obj.tex = Texture(w, h, buffer, {
		mag_filter = e.GL_LINEAR,
		min_filter = e.GL_LINEAR_MIPMAP_LINEAR ,
	}) 
	
	obj.getSize = function(s) return #buffer end
	obj.getWidth = function(s) return w end
	obj.getHeight = function(s) return h end
	obj.setFilter = function() end
	
	obj.paste = function(source, dx, dy, sx, sy, sw, sh) end
	obj.encode = function(outfile) end
	obj.getString = function() return buffer end
	
	
	obj.getPixel = function(s, x,y, r,g,b,a) 
		local rr, rg, rb, ra 
		s.tex:Fill(function(_x,_y, i, r,g,b,a) 
			if _x == x and _y == y then 
				rr = r 
				rg = g 
				rb = b 
				ra = a 
			end
		end)
		return rr, rg, rb, ra 
	end
	
	obj.setPixel = function(s, x,y, r,g,b,a) 
		s.tex:Fill(function(_x,_y, i) 
			if _x == x and _y == y then 
				return r,g,b,a
			end
		end, true)
	end
	
	obj.mapPixel = function(s, cb) 
		s.tex:Fill(function(x,y,i, r,g,b,a) 
			cb(x,y,r,g,b,a) 
		end, false, true)
	end
	
	return obj
end