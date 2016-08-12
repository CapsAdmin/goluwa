local render = (...) or _G.render

function render.InitializeNoiseTexture(size)
	if not render.noise_texture or size ~= render.noise_texture:GetSize() then
		local tex = render.CreateTexture("2d")
		tex:SetSize(size)
		--tex:SetInternalFormat("rgba16f")
		tex:SetupStorage()
		render.SetBlendMode()
		tex:Shade("return vec4(random(uv), random(uv*23.512), random(uv*6.53330), random(uv*122.260));")
		tex:SetMinFilter("nearest")
		render.noise_texture = tex
	end
end

function render.GenerateTextures()
	render.white_texture = render.CreateBlankTexture(Vec2()+8):Fill(function() return 255,255,255,255 end)
	render.black_texture = render.CreateBlankTexture(Vec2()+8):Fill(function() return 0,0,0,255 end)
	render.grey_texture = render.CreateBlankTexture(Vec2()+8):Fill(function() return 127,127,127,255 end)
	render.hemisphere_normals_texture = utility.CreateHemisphereNormalsTexture(8)
	render.InitializeNoiseTexture(render.GetScreenSize())

	if not render.environment_probe_texture then
		local tex = render.CreateTexture("cube_map")
		tex:SetMipMapLevels(1)

		render.environment_probe_texture = tex
	end

	do
		render.error_texture = render.CreateBlankTexture(Vec2() + 256)

		local size = 16
		render.error_texture:Fill(function(x, y)
			if (math.floor(x/size) + math.floor(y/size % 2)) % 2 < 1 then
				return 255, 255, 255, 255
			else
				return 255, 0, 0, 255
			end
		end)
	end

	do
		local center_size = 70
		local outter_size = 0.9
		local width = 15
		local arms = 13
		local speed = 16
		local trail_duration = 7
		local base_arm_brightness = 0.4

		local loading = render.CreateFrameBuffer(Vec2() + 256)
		if loading then
			--loading:SetSize(Vec2()+256)

			event.Timer("update_loading_texture", 1/5, 0, function()
				if not surface.IsReady() then return end
				loading:Begin()
					local time = system.GetElapsedTime()
					surface.SetColor(0.2, 0.2, 0.2, 1)
					surface.SetWhiteTexture()
					surface.DrawRect(0, 0, loading:GetSize():Unpack())
					local deg = 360 / arms

					for i = 0, arms do
						local n = (-((time*speed + i)%arms / arms) + 1) ^ trail_duration

						surface.SetColor(base_arm_brightness + n, base_arm_brightness + n, base_arm_brightness + n, 1)

						local ang = math.rad(deg * i)
						local X, Y = math.sin(ang), math.cos(ang)
						local W2, H2 = loading:GetSize().x/2, loading:GetSize().y/2

						surface.DrawLine(X*center_size+W2, Y*center_size+H2, X*outter_size*W2 + W2, Y*outter_size*H2 + H2, width)
					end
				loading:End()
			end)
			render.loading_texture = loading:GetTexture()
		end
	end

	for k,v in pairs(render) do
		if type(k) == "string" and k:endswith("_texture") and typex(v) == "texture" then
			local name = k:match("(.+)_texture")
			render.texture_path_cache[name] = v
			v.Path = name
		end
	end
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
	return render.error_texture
end

function render.GetLoadingTexture()
	return render.loading_texture or render.error_texture
end

function render.GetNoiseTexture()
	return render.noise_texture
end

function render.GetEnvironmentProbeTexture()
	return render.environment_probe_texture
end

function render.GetHemisphereNormalsTexture()
	return render.hemisphere_normals_texture
end

if RELOAD then
	render.GenerateTextures()
end