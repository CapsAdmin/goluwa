for k,v in pairs(entities.GetAll()) do v:Remove() end

--render.camera_3d:SetPosition(Vec3(-0.8, 5, 4))
--render.camera_3d:SetAngles(Ang3(1.0157809257507, -0.41439121961594, 0))

--local world = entities.CreateEntity("world")
--world:SetSunAngles(Ang3(-0.5, -2.5, 0))
--world:GetChildren()[1]:SetShadow(false)
--world:GetChildren()[1]:SetIntensity(1)
 
local max = 11 
 
local light = entities.CreateEntity("light") 
light:SetSize(500)
light:SetIntensity(0.4)
light:SetPosition(Vec3(3.5,3.5,50))

for x = 0, max-1 do
for y = 0, max-1 do
	local ent = entities.CreateEntity("visual")
	ent:SetModelPath("models/sphere.obj")
	ent:SetPosition(Vec3(x, y, 0 )/1.5)
	ent:SetSize(-0.05)
	ent:SetAngles(Ang3(90,0,0))
	ent:SetCull(false)
	
	local mat = render.CreateMaterial("model")
	local black = render.GetBlackTexture()
	
	mat:SetDiffuseTexture(Texture("sponza/textures_pbr/Sponza_Ceiling_diffuse.tga"))
	mat:SetNormalTexture(Texture("sponza/textures_pbr/Sponza_Ceiling_normal.tga"))  
	mat:SetRoughnessTexture(black)
	mat:SetMetallicTexture(black)
	
	mat:SetRoughnessMultiplier((-(y/max)+1))
	mat:SetMetallicMultiplier((x/max))
	
	ent:SetMaterialOverride(mat)
end
end