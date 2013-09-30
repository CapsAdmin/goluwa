for k,v in pairs(render) do	
	if k:sub(0,6) == "Create" then
		local name = k:sub(7)
		_G[name] = render["Create" .. name]
	end
end

render.active_textures = render.active_textures or {}

function Image(path)
	if render.active_textures[path] then 
		return render.active_textures[path]
	end
	
	local size = 16
	if not ERROR_TEXTURE then
		ERROR_TEXTURE = Texture(128, 128)
		ERROR_TEXTURE:Fill(function(x, y)
			if (math.floor(x/size) + math.floor(y/size % 2)) % 2 < 1 then
				return 255, 0, 255, 255
			else
				return 0, 0, 0, 255
			end
		end)
	end
	
	local img = vfs.Read(path, "rb")
	
	if not img then
		return ERROR_TEXTURE
	end
	
	local w, h, buffer = freeimage.LoadImage(img)
	
	if w == 0 or h == 0 then
		errorf("could not decode %q properly (w = %i, h = %i)", 2, path, w, h)
	end
	
	local tex = Texture(w,h,buffer,{internal_format = e.GL_RGBA8})
	
	render.active_textures[path] = tex
	
	return tex
end