for k,v in pairs(entities.GetAll()) do v:Remove() end

local z = -300

render.camera_3d:SetPosition(Vec3(0, 0, z + 50))
render.camera_3d:SetFOV(0.15)
render.camera_3d:SetAngles(Ang3(math.pi/2, 0, 0))

--local world = entities.CreateEntity("world")
--world:SetSunAngles(Ang3(-0.5, -2.5, 0))
--world:GetChildren()[1]:SetShadow(false)
--world:GetChildren()[1]:SetIntensity(1)
 
local max = 11
 
local light = entities.CreateEntity("light") 
light:SetSize(2000)
light:SetIntensity(1)
light:SetPosition(Vec3(0,0,z+15)+Vec3(10,-10, 25)*5)

for x = -max/2, max/2 do
	local x = x/max*2

	for y = -max/2, max/2 do
		local y = y/max*2
		
		local ent = entities.CreateEntity("visual")
		ent:SetModelPath("models/sphere.obj")
		ent:SetPosition(Vec3(x*3.25, y*3.25, z))
		ent:SetSize(0.05)
		ent:SetAngles(Ang3():GetRandom())
		ent:SetAngles(Ang3(90,0,0))
		ent:SetCull(false)
		
		local mat = render.CreateMaterial("model")
		
		mat:SetDiffuseTexture(render.GetWhiteTexture())
		mat:SetMetallicTexture(render.GetWhiteTexture())
		mat:SetRoughnessTexture(render.GetWhiteTexture())
		mat:SetColor(Color(1,0,0, 1))
		
		mat:SetRoughnessMultiplier((x+1) / 2)
		mat:SetMetallicMultiplier(-(y+1) / 2+1)
		
		ent:SetMaterialOverride(mat)
	end
end