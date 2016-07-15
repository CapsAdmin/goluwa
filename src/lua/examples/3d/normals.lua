entities.Panic()

render.camera_3d:SetPosition(Vec3(2.4, 0, -0))
render.camera_3d:SetAngles(Ang3(0, math.pi, 0))

local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/cube.obj")
ent:SetSize(1)

local max = 1
local lights = {}

for i = 1, max do
	local light = entities.CreateEntity("light")
	light:SetColor(ColorHSV(i/max, 0.5, 1))
	light:SetSize(2)
	light:SetIntensity(1.25)
	light.seed = math.random()*math.pi
	table.insert(lights, light)
end

event.AddListener("Update", "test", function()
	local time = system.GetElapsedTime() / 10
	for i, light in ipairs(lights) do
		i = i / max
		i = i * math.pi * 2
		time = time + light.seed
		light:SetPosition(Vec3(1.05, math.sin(time + i) * math.cos(time/2), math.cos(time + i) * math.sin(time/2)))
	end
	--ent:SetAngles(Ang3(time,time,0))
end)

local mat = render.CreateMaterial("model")
mat:SetAlbedoTexture(render.CreateTextureFromPath("textures/Cerberus_A.tga"))
mat:SetNormalTexture(render.CreateTextureFromPath("textures/Cerberus_N.tga", false))
mat:SetRoughnessTexture(render.CreateTextureFromPath("textures/Cerberus_R.tga"))
mat:SetMetallicTexture(render.CreateTextureFromPath("textures/Cerberus_M.tga"))

ent:SetMaterialOverride(mat)

pbr_test = ent