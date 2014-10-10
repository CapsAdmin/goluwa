local atlas = render.CreateTextureAtlas(1024)

local icon = "itwaspoo.001.gif"--table.random(icons)
local icons = vfs.Find("textures/sa/")
for i, icon in ipairs(icons) do	atlas:Insert(Texture("textures/sa/" .. icon), icon) end

--math.randomseed(1)   
--local count = 5000
--for i = 1, count do 
	--local c = HSVToColor(math.random(), math.random())   
	--local alpha = 255
	--atlas:Insert(Texture(math.random(5,15), math.random(5,15)):Fill(function() return c.r*255, c.g*255, c.b*255, alpha end))
--end

atlas:BuildTextures()
event.AddListener("Draw2D", "lol", function()
	atlas:DebugDraw()
	if wait(0.25) then icon = table.random(icons) end
	atlas:Draw(icon, 650, 600)
	surface.SetTextPos(650, 620)
	surface.DrawText(icon)
end)
print(atlas.pages)
--table.print(atlas.pages[1].packer) 