local render = (...) or _G.render

function render.GenerateTextures()
	render.white_texture = render.CreateTexture(8,8, nil, {no_remove = true}):Fill(function() return 255, 255, 255, 255 end)
	render.black_texture = render.CreateTexture(8,8, nil, {no_remove = true}):Fill(function() return 0, 0, 0, 255 end)
	render.grey_texture = render.CreateTexture(8,8, nil, {no_remove = true}):Fill(function() return 127, 127, 127, 255 end)
	render.noise_texture = render.CreateTexture(512,512, nil, {no_remove = true}):Fill(function() return math.random(255),math.random(255),math.random(255),math.random(255) end)

	render.error_tex = render.CreateTexture(256, 256, nil, {no_remove = true})
	local size = 16
	render.error_tex:Fill(function(x, y)
		if (math.floor(x/size) + math.floor(y/size % 2)) % 2 < 1 then
			return 255, 0, 255, 255
		else
			return 0, 0, 0, 255
		end
	end)
	
	render.loading_texture = render.CreateTexture("textures/loading.jpg", {no_remove = true})
end

function render.GetWhiteTexture()
	return render.white_texture
end

function render.GetBlackTexture()
	return render.black_texture
end

function render.GetGreyTexture()	
	return render.grey_texture
end

function render.GetErrorTexture()
	return render.error_tex
end

function render.GetLoadingTexture()	
	return render.loading_texture or render.error_tex
end

function render.GetNoiseTexture()	
	return render.noise_texture
end

if RELOAD then
	render.GenerateTextures()
end