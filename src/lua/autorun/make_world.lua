if SCITE then return end

local map = console.CreateVariable("default_map", "gm_old_flatgrass")

local function go()
	if SERVER then
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
end

if RELOAD  then
	go()
end

if CLIENT then
	event.Delay(function()
		go()
	end)
end

if SERVER then
	event.AddListener("NetworkStarted", "spawn_world", function()
		go()
	end)
end