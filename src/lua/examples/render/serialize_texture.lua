local tex = render.CreateTexture("2d")
tex:SetPath("textures/greendog.png")
serializer.WriteFile("msgpack2", "lol.wtf", tex:Save())

local data = serializer.ReadFile("msgpack2", "lol.wtf")
local tex = render.CreateTexture("2d")
tex:Load(data)

function goluwa.PreDrawGUI()
	render2d.SetTexture(tex)
	render2d.SetColor(1, 1, 1, 1)
	render2d.DrawRect(50, 50, 128, 128)
end