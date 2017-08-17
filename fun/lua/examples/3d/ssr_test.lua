entities.Panic()

local ent = entities.CreateEntity("visual", group)
ent:SetPosition(Vec3(0,0,0))
ent:SetModelPath("models/spot.obj")
ent:SetSize(4)
ent:SetAngles(Deg3(-90,0,0))

local spheres = {}

local max = 5

for x = -max/2, max/2 do
	local x = x/max*2

	for y = -max/2, max/2 do
		local y = y/max*2

		local ent = entities.CreateEntity("visual", ent)
		ent:SetPosition(Vec3(x*3.25, y*3.25, 0))

		ent:SetModelPath("models/sphere.obj")
		ent:SetSize(0.1)

		ent:SetColor(ColorHSV(x*y,0.5,1))
		ent:SetRoughnessMultiplier((x+1) / 2)
		ent:SetMetallicMultiplier(-(y+1) / 2+1)

		ent.seed1 = math.random()*100
		ent.seed2 = math.random()*100
		ent.seed3 = math.random()*100
		ent.seed4 = math.random()*100

		table.insert(spheres, ent)
	end
end

function goluwa.Update()
	local t = system.GetElapsedTime()/10
	for i,v in ipairs(spheres) do
		local x = math.sin(t + v.seed1)
		local y = math.cos(t + v.seed2)
		local z = math.sin(t + v.seed3) * math.cos(t + v.seed4)
		v:SetPosition(Vec3(x,y,z)*4)
	end
end