entities.Panic()

render.camera_3d:SetPosition(Vec3(2.5, 0.8, 0))
render.camera_3d:SetAngles(Ang3(-0.048060033470392, -2.8, 0))

local light = entities.CreateEntity("light")
light:SetSize(50)
light:SetPosition(Vec3(5,0,0))

local mat1 = render.CreateMaterial("model")
mat1:SetTranslucent(true)

local mat2 = render.CreateMaterial("model")
mat2:SetTranslucent(true)

local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/sphere.obj")
ent:SetSize(0.25)
ent:SetPosition(Vec3(-5,0,0))
ent:SetMaterialOverride(mat1)

local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/sphere.obj")
ent:SetSize(0.25)
ent:SetMaterialOverride(mat2)

event.AddListener("Update", "test", function()
	local t = system.GetElapsedTime()

	local color = mat1:GetColor()
	color.a = math.abs(math.sin(t+0.5))
	mat1:SetColor(color)

	local color = mat2:GetColor()
	color.a = math.abs(math.cos(t))
	mat2:SetColor(color)

	light:SetPosition(Vec3(5 + math.sin(t),math.cos(t),0))
end)