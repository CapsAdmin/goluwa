vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_textures_dir.vpk")

local tex = Image("materials/nature/blendrockdirt002a_tooltexture.vtf")

event.AddListener("OnDraw2D", "lol", function()
	surface.SetTexture(tex)
	surface.Color(1,1,1,1)
	surface.DrawRect(0,0, tex.w, tex.h)
end)