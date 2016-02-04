local map = console.CreateVariable("default_map", "gm_old_flatgrass")

local function go()
	console.RunString("map " .. map:Get())

	for i = 1, 10 do
		local body = entities.CreateEntity("physical")
		body:SetName("those boxes " .. i)

		body:SetModelPath("models/cube.obj")

		--body:SetPhysicsModelPath("models/cube.obj")
		--body:InitPhysicsConvexTriangles(true)

		body:InitPhysicsBox(-Vec3(1, 1, 1))

		body:SetMass(10)
		body:SetPosition(Vec3(0,0,-100+i*2))

		body:SetSize(-1)  -- FIX ME
	end
end

if RELOAD then
	go()
end

event.AddListener("NetworkStarted", function()
	go()
end)
