entities.Panic()

render3d.camera:SetPosition(Vec3(2.5, 0.8, 0))
render3d.camera:SetAngles(Ang3(-0.04, -2.8, 0))

local light = entities.CreateEntity("light")
light:SetSize(50)
light:SetPosition(Vec3(5,0,0))

local mat1 = render.CreateMaterial("model")
mat1:SetAlbedoTexture(render.GetWhiteTexture())
mat1:SetTranslucent(true)

local ent1 = entities.CreateEntity("visual")
ent1:SetModelPath("models/sphere.obj")
ent1:SetSize(0.25)
ent1:SetMaterialOverride(mat1)
ent1:SetPosition(Vec3(-5,0,0))

local mat2 = render.CreateMaterial("model")
mat2:SetAlbedoTexture(render.GetWhiteTexture())
mat2:SetTranslucent(true)

local ent2 = entities.CreateEntity("visual")
ent2:SetModelPath("models/sphere.obj")
ent2:SetSize(0.25)
ent2:SetMaterialOverride(mat2)

function goluwa.Update()
	local t = system.GetElapsedTime()

	local color = ent1:GetColor()
	color.a = math.abs(math.sin(t+0.5)) + 0.1
	ent1:SetColor(color)

	local color = ent2:GetColor()
	color.a = math.abs(math.cos(t)) + 0.1
	ent2:SetColor(color)

	light:SetPosition(Vec3(5 + math.sin(t),math.cos(t),0))
end

local max = 30
for i = 1, max+1 do

	local mat2 = render.CreateMaterial("model")
	mat2:SetAlbedoTexture(render.GetWhiteTexture())
	mat2:SetTranslucent(true)

	local ent2 = entities.CreateEntity("visual")
	ent2:SetModelPath("models/sphere.obj")
	ent2:SetSize(0.35)
	ent2:SetMaterialOverride(mat2)
	ent2:SetPosition(Vec3(i*2.5,20,0))

	if i == max or i == 1 then
		ent2:SetColor(Color(1,1,1,1))
	else
		ent2:SetColor(ColorHSV((i/max)*8,1,1):SetAlpha(i/max))
	end

end