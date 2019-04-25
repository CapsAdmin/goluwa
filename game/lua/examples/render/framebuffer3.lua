
local size = Vec2()+256

local fb = render.CreateFrameBuffer()

fb:SetTexture(1, render.CreateBlankTexture(size))
--fb:SetTexture("depth_stencil", {internal_format = "depth_stencil", size = size})

event.Timer("lol", 0.25, 0, function(i)
	local t = system.GetElapsedTime()
	fb:ClearColor(1,0,0,0)
	fb:Begin()
		gfx.DrawRect(size.x/2 + math.sin(t)*size.x/2 - 16, size.y/2 + math.cos(t)*size.y/2 - 16, 32,32)
	fb:End()
end)

function goluwa.PreDrawGUI()

	render2d.SetTexture(fb:GetTexture(1))
	render2d.SetColor(1, 1, 1, 1)
	render2d.DrawRect(50, 50, 128, 128)

	--gmod.render.ClearRenderTarget(fb:GetRenderTarget(), gmod.Color(255, 255, 0, 255))

	gmod.render.DrawTextureToScreenRect(fb:GetRenderTarget(), 200, 200, 128, 128)
end