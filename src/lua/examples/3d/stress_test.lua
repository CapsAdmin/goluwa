entities.Panic()

render.camera_3d:SetPosition(Vec3(100, 0, 100))
render.camera_3d:SetAngles(Ang3(1.1, math.pi, 0))

for _, v in ipairs(vfs.Find("/home/caps/.steam/steamapps/common/GarrysMod/garrysmod/addons/fallout", true)) do
	vfs.Mount(v)
end

local models = {}
for _, mdl in ipairs(vfs.Find("models/props_fallout/.+%.mdl", true)) do
	table.insert(models, mdl)
end


local function generate_material()
	local tex = render.CreateTexture("2d")
	tex:SetSize(Vec2() + 1024)
	tex:SetupStorage()
	render.SetBlendMode()
	tex:Shade("return vec4(random(uv), random(uv*23.512), random(uv*6.53330), random(uv*122.260));")
	tex:GenerateMipMap()

	local mat = render.CreateMaterial("model")
	mat:SetAlbedoTexture(tex)

	return mat
end

local plane = entities.CreateEntity("visual", plane)
plane:SetModelPath("models/cube.obj")
plane:SetScale(Vec3(100,100,0.01))
--plane:SetMaterialOverride(generate_material())
plane:SetHideFromEditor(true)

for i = 1, 50 do
	local ent = entities.CreateEntity("visual")
	--ent:SetModelPath("models/sphere.obj")
	ent:SetPosition(Vec3():GetRandom()*Vec3(100,100,10))
	--ent:SetSize(math.randomf(0.25, 1.5))
	ent:SetHideFromEditor(true)
	--ent:SetMaterialOverride(generate_material())
	ent:SetModelPath(table.random(models))
end
do return end
do
	local max = 50
	local lights = {}

	for i = 1, max do
		local light = entities.CreateEntity("light")
		light:SetColor(ColorHSV(i/max, math.randomf(0.25, 1), math.randomf(0.25, 1)))
		light:SetIntensity(math.randomf(0.5, 1.5))
		light:SetHideFromEditor(true)
		light.seed = math.random()*math.pi
		light:SetSize(light.seed*100+10)
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
end