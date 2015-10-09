local render = (...) or _G.render

function render.GenerateTextures()
	render.white_texture = Texture(Vec2()+8):Fill(function() return 255,255,255,255 end)
	render.black_texture = Texture(Vec2()+8):Fill(function() return 0,0,0,255 end)
	render.grey_texture = Texture(Vec2()+8):Fill(function() return 127,127,127,255 end)
	render.noise_texture = Texture(Vec2()+2048, "return vec4(random(uv*1), random(uv*2), random(uv*3), random(uv*4));")
	render.noise_texture:SetMinFilter("nearest")

	if not render.environment_probe_texture then
		local tex = render.CreateTexture("cube_map")
		tex:SetMipMapLevels(1)

		render.environment_probe_texture = tex
	end

	do
		render.error_tex = Texture(Vec2() + 256)

		local size = 16
		render.error_tex:Fill(function(x, y)
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

		local loading = render.CreateFrameBuffer(256, 256)
		--loading:SetSize(Vec2()+256)

		event.Timer("update_loading_texture", 1/15, 0, function()
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

function render.GetEnvironmentProbeTexture()
	return render.environment_probe_texture
end

if RELOAD then
	render.GenerateTextures()
end