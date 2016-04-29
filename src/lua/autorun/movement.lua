if CLIENT then

	event.AddListener("CreateMove", "spooky", function(client, prev_cmd, dt)
		local ghost = client.nv.ghost or NULL
		if ghost:IsValid() then
			local pos = ghost:GetComponent("physics"):GetPosition()
			render.camera_3d:SetPosition(Vec3(-pos.y, -pos.x, -pos.z))
		end

		if not window.IsOpen() or not window.GetMouseTrapped() then return end

		local angles = render.camera_3d:GetAngles()
		local fov = render.camera_3d:GetFOV()

		local dir, angles, fov = CalcMovement(1, angles, fov)

		local side = Vec3()
		local forward = Vec3()
		local up = Vec3()
		do
			local speed = 5

			if input.IsKeyDown("left_shift") and input.IsKeyDown("left_control") then
				speed = speed * 4
			elseif input.IsKeyDown("left_shift") then
				speed = speed * 2
			elseif input.IsKeyDown("left_control") then
				speed = speed / 4
			end

			local offset = Ang3(0,angles.y,0):GetForward() * speed

			if input.IsKeyDown("w") then
				side = side + offset
			elseif input.IsKeyDown("s") then
				side = side - offset
			end

			offset = Ang3(0,angles.y,0):GetRight() * speed

			if input.IsKeyDown("a") then
				forward = forward - offset
			elseif input.IsKeyDown("d") then
				forward = forward + offset
			end

			if input.IsKeyDown("space") then
				up.z = 2000
			end
		end

		local cmd = {}

		cmd.velocity = side + forward + up
		cmd.angles = angles
		cmd.fov = fov
		cmd.mouse_pos = window.GetMousePosition()

		render.camera_3d:SetAngles(cmd.angles)
		render.camera_3d:SetFOV(cmd.fov)

		return cmd
	end)
end

for _,v in pairs(clients.GetAll()) do
	if v.nv.ghost and v.nv.ghost:IsValid() then
		v.nv.ghost:Remove()
	end
end

event.AddListener("PhysicsCollide", "ground_enttiy", function(a, b)
	print(a, b)
end)

event.AddListener("Move", "spooky", function(client, cmd)
	if CLIENT and not network.IsConnected() then return end

	local ghost = NULL

	if SERVER then
		if not client.nv.ghost or not client.nv.ghost:IsValid() then
			ghost = entities.CreateEntity("physical")
			ghost:SetName(client:GetNick() .. "'s ghost")

			local filter = clients.CreateFilter():AddAllExcept(client)

			ghost:ServerFilterSync(filter, "Position")
			ghost:ServerFilterSync(filter, "Rotation")

			--ghost:SetNetworkChannel(1)
			ghost:SetPhysicsModelPath("models/cube.obj")
			ghost:SetModelPath("models/cube.obj")
			ghost:SetPhysicsCapsuleZHeight(1.5)
			ghost:SetPhysicsCapsuleZRadius(0.5)
			ghost:InitPhysicsCapsuleZ()
			ghost:SetMass(85)
			ghost:SetPosition(Vec3(0,0,-20))
			ghost:SetAngularFactor(Vec3(0,0,0))
			ghost:SetScale(-Vec3(0.5,0.5,1.85))
 			ghost:SetSimulateOnClient(true)

			ghost:SetAngles(Ang3(0,0,0))


			client.nv.ghost = ghost
		end
	end

	if client.nv.ghost and client.nv.ghost:IsValid() then
		ghost = client.nv.ghost
	end

	if not ghost:IsValid() then return end

	local physics = ghost:GetComponent("physics")
	local pos =  physics:GetPosition()

	if CLIENT then
		if cmd.net_position then
			physics.sync_now = physics.sync_now or 0

			local distance = cmd.net_position:Distance(pos)

			if distance > 2 then
				physics:SetPosition(cmd.net_position)
				physics:SetAngles(cmd.angles)
				physics:SetVelocity(cmd.net_velocity)
				physics.sync_now = os.clock() + 2
				logn("prediction error: physics position differs too much ", distance)
			end

			local distance = cmd.net_position:Distance(pos)

			if physics.sync_now < os.clock() and distance > 0.1 then
				physics:SetPosition(cmd.net_position)
				physics.sync_now = os.clock() + 2
				logn("prediction error: (timer check) physics position differs too much ", distance)
			end
		end

		if cmd.net_velocity then
			local distance = cmd.net_velocity:Distance(physics:GetVelocity())

			if distance > 2 then
				physics:SetVelocity(cmd.net_velocity)
				logn("prediction error: physics velocity differs too much by ", distance)
			end
		end
	end

	-- WHY
	physics:SetAngularVelocity(Vec3(0,0,0))
	physics:SetAngularFactor(Vec3(0,0,0))
	physics:SetAngularSleepingThreshold(0)
	physics:SetLinearSleepingThreshold(0)
	--

	local hit = _G.physics.RayCast(physics:GetPosition(), physics:GetPosition() + (physics:GetRotation():GetUp()*1.36))
	if hit then
		local vel = cmd.velocity

		vel.x = math.clamp(vel.x, -10, 10)
		vel.y = math.clamp(vel.y, -10, 10)
		vel.z = math.clamp(vel.z, 0, 7)

		physics:SetVelocity(physics:GetVelocity() + vel)
		physics:SetVelocity(physics:GetVelocity() * 0.5)
	else
		local velocity = cmd.velocity:GetNormalized() * 4
		velocity.z = 0

		local lol = physics:GetVelocity()

		velocity.x = velocity.x + lol.x
		velocity.y = velocity.y + lol.y
		velocity.z = lol.z

		if velocity:GetLength() - lol:GetLength() < 2 then
			physics:SetVelocity(velocity)
		end
	end

	--physics:SetAngles(cmd.angles)

	return pos, physics:GetVelocity()
end)

if SERVER then
	event.AddListener("ClientMouseInput", "bsp_lol", function(client, button, press)
		if button == "button_3" and press then
			local cmd = client:GetCurrentCommand()

			local ent = entities.CreateEntity("physical")
			ent:SetPhysicsModelPath("models/cube.obj")
			ent:SetModelPath("models/cube.obj")
			ent:SetMass(85)
			ent:InitPhysicsBox(-Vec3(0.15,1,0.15))
			ent:SetScale(-Vec3(0.15,1,0.15))
			ent:SetPosition(cmd.net_position + (cmd.angles:GetForward()*5))
			ent:SetVelocity(cmd.angles:GetForward() * 10)

			event.Delay(3, function()
				entities.SafeRemove(ent)
			end)
		end
	end)
end