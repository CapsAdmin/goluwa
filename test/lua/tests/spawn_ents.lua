for k,v in pairs(entities.GetAll()) do v:Remove() end

local world = entities.CreateEntity("networked")
world:SetModelPath("models/skpfile.obj")  
world:InitPhysics("concave", 0, "models/skpfile.obj", true)  
world:SetPosition(Vec3(170,-170,0))  
world:SetAngles(Ang3(0,0,0))
world:SetCull(false)

WORLD = world
 
for i = 1, 10 do
	local body = entities.CreateEntity("networked")
	body:SetModelPath("models/cube.obj")
	body:SetPosition(Vec3(0,0,100+i*2)) 
	body:InitPhysics("box", 10, 1, 1, 1)  
	body:SetSize(1) 
end 