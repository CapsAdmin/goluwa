if not PHYSICS then return end

commands.RunString("mount gmod")
pvars.Setup("default_map", "gm_old_flatgrass")
local go = function()
	commands.RunString("map " .. pvars.Get("default_map"))

	for i = 1, 10 do
		local body = entities.CreateEntity("physical")
		body:SetName("those boxes " .. i)
		body:SetModelPath("models/cube.obj")
		body:SetPhysicsModelPath("models/cube.obj")
		body:InitPhysicsTriangles()
		--body:InitPhysicsBox(Vec3(1, 1, 1))
		--body:SetMass(100)
		body:SetPosition(Vec3(0, 0, -100 + i * 2))
		--body:SetVelocity(Vec3():Random(-10,10))
		body:SetAngularVelocity(Vec3():Random() * 10)
	--body:SetSize(2)  -- FIX ME
	end
end

if RELOAD then go() end

event.AddListener("NetworkStarted", function()
	go()
end)