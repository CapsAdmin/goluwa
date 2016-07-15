entities.Panic()

render.camera_3d:SetPosition(Vec3(100, 0, 100))
render.camera_3d:SetAngles(Ang3(1.1, math.pi, 0))

local ent = entities.CreateEntity("visual")
ent:SetModelPath("models/cube.obj")
ent:SetScale(Vec3(100,100,0.01))
ent:SetCull(false)
local mat = render.CreateMaterial("model")
mat:SetAlbedoTexture(render.GetGreyTexture())
ent:SetMaterialOverride(mat)

local max = 500
local lights = {}

for i = 1, max do
	local light = entities.CreateEntity("light")
	light:SetColor(ColorHSV(i/max, 0.5, 1))
	light:SetIntensity(1.25)
	light.seed = math.random()*math.pi
	light:SetSize(light.seed*20+10)
	table.insert(lights, light)
end

event.AddListener("Update", "test", function()
	local time = system.GetElapsedTime() / 10
	for i, light in ipairs(lights) do
		i = i / max
		i = i * math.pi * 2
		time = time + light.seed
		light:SetPosition(Vec3(math.sin(time + i) * math.cos(time/2) * 100, math.cos(time + i) * math.sin(time/2) * 100, 1))
	end
	--ent:SetAngles(Ang3(time,time,0))
end)


pbr_test = ent