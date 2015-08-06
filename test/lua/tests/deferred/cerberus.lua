for k,v in pairs(entities.GetAll()) do v:Remove() end

render.camera_3d:SetPosition(Vec3(2.1400938034058, -3.7667279243469, 2.0517530441284))
render.camera_3d:SetAngles(Ang3(0.51163148880005, 2.1237199306488, 0))


local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/cerebus/Cerberus_LP.FBX")
ent:SetSize(-0.05)
ent:SetPosition(Vec3(2,0,0))
ent:SetCull(false)

local max = 8
local lights = {}

for i = 1, max do
	local light = entities.CreateEntity("light")
	light:SetColor(HSVToColor(i/max, 0.5, 1))
	light:SetSize(4)
	light:SetIntensity(2.5)
	light.seed = math.random()*math.pi
	light.dir = Vec3():GetRandom()
	table.insert(lights, light)
end

event.AddListener("Update", "test", function()
	local time = system.GetElapsedTime() 
	for i, light in ipairs(lights) do
		i = i / max
		i = i * math.pi * 2
		time = time + light.seed
		light:SetPosition((light.dir:GetRotated(Vec3(1,0,0), math.cos(time)) + light.dir:GetRotated(Vec3(0,1,0), math.sin(time))) * 4)
	end
	--ent:SetAngles(Ang3(time,time,0))
end)

local mat = render.CreateMaterial("model")
mat:SetDiffuseTexture(Texture("textures/Cerberus_A.tga"))
mat:SetNormalTexture(Texture("textures/Cerberus_N.tga")) 
mat:SetRoughnessTexture(Texture("textures/Cerberus_R.tga"))
mat:SetMetallicTexture(Texture("textures/Cerberus_M.tga"))

ent:SetMaterialOverride(mat)
