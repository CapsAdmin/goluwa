entities.Panic()

render3d.camera:SetPosition(Vec3(-3, 0, 0))
render3d.camera:SetAngles(Ang3(0, 0, 0))

local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/cube.obj")
ent:SetSize(1)

entities.world:SetSunAngles(Ang3(0.5,0,0))
entities.world:SetSunColor(Color())

local light = entities.CreateEntity("light")
light:SetColor(ColorHSV(1, 0.1, 1))
light:SetSize(2)
light:SetIntensity(1)

function goluwa.Update()
	--render2d.Start3D2D()

	local pos = Vec2(gfx.GetMousePosition())/window.GetSize() * 2 - 1

	light:SetPosition(Vec3(0, -pos.x, -pos.y) + Vec3(-1.2, 0, 0))
	--ent:SetAngles(Ang3(time,time,0))

--	render2d.End3D2D()
end

local mat = render.CreateMaterial("model")
mat:SetAlbedoTexture(render.GetWhiteTexture())
mat:SetNormalTexture(render.CreateTextureFromPath("http://robbylamb.com/Images/Normal_Test.jpg", false))
--mat:SetFlipXNormal(true)
mat:SetFlipYNormal(true)
--mat:SetFlipZNormal(true)

ent:SetMaterialOverride(mat)