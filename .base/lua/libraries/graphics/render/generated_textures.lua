local render = (...) or _G.render

function render.GetWhiteTexture()

	if not render.white_texture then
		render.white_texture = render.CreateTexture(8,8, nil, {no_remove = true}):Fill(function() return 255, 255, 255, 255 end)
	end
	
	return render.white_texture
end

function render.GetBlackTexture()

	if not render.black_texture then
		render.black_texture = render.CreateTexture(8,8, nil, {no_remove = true}):Fill(function() return 0, 0, 0, 255 end)
	end
	
	return render.black_texture
end

function render.GetErrorTexture()

	if not render.error_tex then
		render.error_tex = render.CreateTexture(256, 256, nil, {no_remove = true})
		local size = 16
		render.error_tex:Fill(function(x, y)
			if (math.floor(x/size) + math.floor(y/size % 2)) % 2 < 1 then
				return 255, 0, 255, 255
			else
				return 0, 0, 0, 255
			end
		end)
	end
	
	return render.error_tex
end

local freeimage = require("lj-freeimage") -- image decoder

function render.GetLoadingTexture()
	
	if not render.loading_texture then
		local buffer, w, h = freeimage.LoadImage(vfs.Read("textures/loading.jpg", "b")) --rb flags used on old one.
		render.loading_texture = render.CreateTexture(w, h, buffer, {no_remove = true})
	end
	
	return render.loading_texture
end
