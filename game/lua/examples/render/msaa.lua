local size = Vec2() + 256

local msaa_tex = render.CreateTexture("2d_multisample")
msaa_tex:SetSize(size)
msaa_tex:SetMultisample(16)
msaa_tex:SetInternalFormat("rgba8")
msaa_tex:SetupStorage()
msaa_tex:Clear()

local fb = render.CreateFrameBuffer()
fb:SetSize(size)
fb:SetTexture(1, msaa_tex)

local resolve_tex = render.CreateBlankTexture(size:Copy())

function goluwa.PreDrawGUI()
	fb:Begin()
		fb:ClearColor(0,0,0,0)

		local t = system.GetElapsedTime()/10
		render2d.PushMatrix()
			render2d.Translatef(size.x/2 + math.sin(t) * 50, size.y/2 + math.cos(t) * 50)
			gfx.DrawRect(0, 0, 50, 50)
		render2d.PopMatrix()
	fb:End()

	resolve_tex:Clear()
	resolve_tex:Shade([[
		vec4 color = vec4(0);

		for (int i = 0; i < samples; i++)
		{
			color += texelFetch(msaa_tex, ivec2(uv * textureSize(msaa_tex)), i);
		}

		return color / samples;
	]], {samples = msaa_tex:GetMultisample(), msaa_tex = msaa_tex})

	gfx.DrawRect(0,0,512,512,resolve_tex)
end