entities.Panic()

local ent = entities.CreateEntity("visual")
ent:SetModelPath("maps/gm_old_flatgrass.bsp")

local max = 4

local i = 0

for m = 0, max do
	local m = math.clamp(m / max, 0, 1)
	for r = 0, max do
		local r = math.clamp(r / max, 0, 1)

		local ent = entities.CreateEntity("visual")
		ent:SetPosition((Vec3(r, m, 0)*10) + Vec3(20,0,1))

		ent:SetModelPath("models/sphere.obj")
		ent:SetSize(0.25)
		ent:SetAngles(Deg3(-90,0,0))

		--ent:SetModelPath("models/mitsuba-sphere.obj")
		--ent:SetSize(0.2)
		--ent:SetAngles(Ang3(-math.pi/2,math.pi/4,0))

		ent:SetColor(Color(1, 0.765557, 0.336057))
		ent:SetRoughnessMultiplier(r)
		ent:SetMetallicMultiplier(m)

		i = i + 1
	end
end