render3d.Initialize()

entities.Panic()

--local mat = render.CreateMaterial("model")
--mat:SetTranslucent(true)

local i = 0
local oh = 2
for x = -oh, oh do
for y = -oh, oh do
for z = -oh, oh do
	local ent = entities.CreateEntity("visual")
	ent:SetModelPath("models/cube.obj")
	--ent:SetMaterialOverride(mat)
	ent:SetPosition(Vec3(x,y,z)*2)
	ent:SetColor(ColorHSV(i,1,1))
	i = i + 0.1
end
end
end

local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/cube.obj")
--ent:SetMaterialOverride(mat)
ent:SetPosition(Vec3(1,1,1)+50)
ent:SetSize(5)
ent:SetColor(ColorHSV(i,1,1))
ent:SetName("LOL")