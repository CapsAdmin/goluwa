entities.Panic()

local z = -300

render.camera_3d:SetPosition(Vec3(0, 0, z + 50))
render.camera_3d:SetFOV(0.15)
render.camera_3d:SetAngles(Ang3(math.pi/2, 0, 0))

local group = entities.CreateEntity("group", entities.GetWorld())
group:SetName("pbr test")

local max = 11

for x = -max/2, max/2 do
	local x = x/max*2

	for y = -max/2, max/2 do
		local y = y/max*2

		local ent = entities.CreateEntity("visual", group)
		ent:SetPosition(Vec3(x*3.25, y*3.25, z))

		ent:SetModelPath("models/sphere.obj")
		ent:SetSize(0.05)
		ent:SetAngles(Ang3(90,0,0))

		--ent:SetModelPath("models/mitsuba-sphere.obj")
		--ent:SetSize(0.2)
		--ent:SetAngles(Ang3(-math.pi/2,math.pi/4,0))

		ent:SetCull(false)

		local mat = render.CreateMaterial("model")

		mat:SetAlbedoTexture(render.GetWhiteTexture())
		mat:SetMetallicTexture(render.GetWhiteTexture())
		mat:SetRoughnessTexture(render.GetWhiteTexture())
		--mat:SetColor(Color(1,1,1, 1))
		mat:SetColor(ColorHSV(1,0.5,1))

		mat:SetRoughnessMultiplier((x+1) / 2)
		mat:SetMetallicMultiplier(-(y+1) / 2+1)

		ent:SetMaterialOverride(mat)
	end
end
