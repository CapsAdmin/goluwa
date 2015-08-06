for k,v in pairs(entities.GetAll()) do v:Remove() end

render.camera_3d:SetPosition(Vec3(2.1400938034058, -3.7667279243469, 2.0517530441284))
render.camera_3d:SetAngles(Ang3(0.51163148880005, 2.1237199306488, 0))


local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/cerebus/Cerberus_LP.FBX")
ent:SetSize(-0.05)
ent:SetPosition(Vec3(2,0,0))
ent:SetCull(false)

local max = 4

for i = 1, max do
	local light = entities.CreateEntity("light")
	light:SetSize(10)
	light:SetIntensity(2.5)
	light.seed = math.random()*math.pi
	light.dir = Vec3():GetRandom()
	light:SetPosition((light.dir:GetRotated(Vec3(1,0,0), math.cos(light.seed)) + light.dir:GetRotated(Vec3(0,1,0), math.sin(light.seed))) * 5)
end


local mat = render.CreateMaterial("model")
mat:SetDiffuseTexture(Texture("textures/Cerberus_A.tga"))
mat:SetNormalTexture(Texture("textures/Cerberus_N.tga")) 
mat:SetRoughnessTexture(Texture("textures/Cerberus_R.tga"))
mat:SetMetallicTexture(Texture("textures/Cerberus_M.tga"))

ent:SetMaterialOverride(mat)
