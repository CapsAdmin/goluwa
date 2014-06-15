local world = entities.CreateEntity("networked")
world:SetModelPath("models/skpfile.obj")  
world:InitPhysics("concave", 0, "models/skpfile.obj", true)  
world:SetPosition(Vec3(170,-170,0))  
world:SetAngles(Ang3(0,0,0))
world:SetCull(false)

for i = 1, 10 do
	local body = entities.CreateEntity("networked")
	body:SetModelPath("models/cube.obj")
	body:SetPosition(Vec3(0,0,100+i*2)) 
	body:InitPhysics("convex", 10, "models/cube.obj", true)  
	body:SetSize(1) 
end