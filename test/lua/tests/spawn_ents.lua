for k,v in pairs(entities.GetAll()) do v:Remove() end

local world = entities.CreateEntity("physical")
world:SetModelPath("models/skpfile.obj")  
world:SetMass(0)
world:SetPhysicsModelPath("models/skpfile.obj")
world:InitPhysicsConcave()
world:SetPosition(Vec3(170,-170,0))  
world:SetAngles(Ang3(0,0,0))
world:SetCull(false)

WORLD = world
 
for i = 1, 10 do
	local body = entities.CreateEntity("physical")
	body:SetModelPath("models/cube.obj")
	body:SetMass(10)
	body:InitPhysicsBox(Vec3(1, 1, 1))  
	body:SetPosition(Vec3(0,0,100+i*2)) 
	body:SetSize(1) 
end 