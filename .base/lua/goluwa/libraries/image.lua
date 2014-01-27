
render.active_textures = render.active_textures or {}

local loading_data = vfs.Read("textures/loading.jpg", "rb")

function Image(path, format)
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
		
	format = format or {}
	
	local w, h, buffer = freeimage.LoadImage(loading_data)
	local tex = Texture(w, h, buffer, format)
	
	tex.loading = true

	vfs.ReadAsync(path, function(data)
		tex.loading = false
		
		if not data then
			logf("failed to download %q", path)
			logf("data is nil!")
			return
		end
		
		local w, h, buffer = freeimage.LoadImage(data)
		
		if w == 0 or h == 0 then
			logf("could not decode %q properly (w = %i, h = %i)", 2, path, w, h)
			logf("data is %s", utilities.FormatFileSize(#data))
			return
		end
		
		tex:Replace(buffer, w, h) 
		
		render.active_textures[path] = tex		
	end)
	
	return tex
end