local function go()
	if not RELOAD then
		entities.SafeRemove(WORLD)
		
		local world = entities.CreateEntity("networked")
		world:SetModelPath("models/skpfile.obj")  
		world:SetMass(0)
		world:SetPhysicsModelPath("models/skpfile.obj")
		world:InitPhysicsConcave()
		world:SetCull(false)

		WORLD = world	
	end
	
	WORLD:SetPosition(Vec3(-170,170,0))  
	WORLD:SetAngles(Ang3(90,0,0))        
	 
	for i = 1, 1 do
		local body = entities.CreateEntity("networked")
		body:SetModelPath("models/cube.obj")
		body:SetMass(10)
		body:InitPhysicsBox(Vec3(1, 1, 1))  
		body:SetPosition(Vec3(0,0,-100+i*2)) 
		--body:SetScale(Vec3(1,5,1  )) 
		body:SetSize(1) 
	end 
end

event.AddListener("NetworkStarted", "spawn_world", function()
	go()
end)
           
if RELOAD then go() end