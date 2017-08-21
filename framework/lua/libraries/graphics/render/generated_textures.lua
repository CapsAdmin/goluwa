local render = (...) or _G.render

function render.InitializeNoiseTexture(size)
	if not render.noise_texture or size ~= render.noise_texture:GetSize() then
		local tex = render.CreateTexture("2d")
		tex:SetSize(size)
		--tex:SetInternalFormat("rgba16f")
		tex:SetupStorage()
		render.SetPresetBlendMode("none")
		tex:Shade("return vec4(random(uv), random(uv*23.512), random(uv*6.53330), random(uv*122.260));")
		tex:SetMinFilter("nearest")
		render.noise_texture = tex
	end
end

local function create_simple_texture(r,g,b,a)
	local tex = render.CreateBlankTexture(Vec2() + 1)
	tex:SetMinFilter("nearest")
	tex:Fill(function() return r,g,b,a end)
	return tex
end

function render.GenerateTextures()
	render.white_texture = create_simple_texture(255, 255, 255, 255)
	render.black_texture = create_simple_texture(0, 0, 0, 255)
	render.grey_texture = create_simple_texture(127, 127, 127, 255)

	render.InitializeNoiseTexture(render.GetScreenSize())

	do
		render.error_texture = render.CreateBlankTexture(Vec2() + 256)
		render.error_texture:Shade("return mod(floor(uv.x * 16) + floor(uv.y * 16), 2.0) == 0 ? vec4(1,1,1,1) : vec4(1,0,0,1);")
	end

	if render.IsExtensionSupported("GL_ARB_framebuffer_object") then
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
				if
					not render2d.IsReady() or
					not render.requested_loading_texture or
					render.requested_loading_texture < system.GetElapsedTime() - 1
				then
					return
				end
				loading:Begin()
					local time = system.GetElapsedTime()
					render2d.SetColor(0.2, 0.2, 0.2, 1)
					render2d.SetTexture()
					render2d.DrawRect(0, 0, loading:GetSize():Unpack())
					local deg = 360 / arms

					for i = 0, arms do
						local n = (-((time*speed + i)%arms / arms) + 1) ^ trail_duration

						render2d.SetColor(base_arm_brightness + n, base_arm_brightness + n, base_arm_brightness + n, 1)

						local ang = math.rad(deg * i)
						local X, Y = math.sin(ang), math.cos(ang)
						local W2, H2 = loading:GetSize().x/2, loading:GetSize().y/2

						gfx.DrawLine(X*center_size+W2, Y*center_size+H2, X*outter_size*W2 + W2, Y*outter_size*H2 + H2, width)
					end
				loading:End()
			end)
			render.loading_texture = loading:GetTexture()
			render.loading_texture:SetBindless(true)
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
	render.requested_loading_texture = system.GetElapsedTime()
	return render.loading_texture or render.error_texture
end

function render.GetNoiseTexture()
	return render.noise_texture
end

function render.GetHemisphereNormalsTexture()
	return render.hemisphere_normals_texture
end

if RELOAD then
	render.GenerateTextures()
end