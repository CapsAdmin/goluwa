local where = render.camera_3d:GetPosition()

if party_lights then
	for k,v in pairs(party_lights) do
		v:Remove()
	end
	table.clear(party_lights)
end

party_lights = {}

for y = -5, 5 do
	for x = -5, 5 do
		local light = entities.CreateEntity("light")
		light.start_pos = Vec3(x * where.x, y * where.y, where.z)
		light.seed = math.random()
		light:SetColor(Color(math.randomf(0, 1), math.randomf(0, 1), math.randomf(0, 1)))
		light:SetSize(math.randomf(2, 10))
		light:SetIntensity(1)
		table.insert(party_lights, light)
	end
end

--[[local light = entities.CreateEntity("light")
light:SetPosition(Vec3(-341, 135, 25))
light:SetSize(40)
light:SetIntensity(5)]]

event.AddListener("Update", "light movement", function()
	local t = system.GetElapsedTime()
	for i, v in ipairs(party_lights) do
		v:SetPosition(v.start_pos + (Vec3(math.sin(t + v.seed + i), math.cos(t + v.seed + i), math.sin(t + v.seed + i)) * 20))
	end
end)