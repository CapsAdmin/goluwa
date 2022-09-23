event.AddListener("NetworkStarted", function()
	if CLIENT then
		event.AddListener("CreateMove", "spooky", function(client, prev_cmd, dt)
			local ghost = client.nv.ghost or NULL

			if ghost:IsValid() then
				if PHYSICS then
					local pos = ghost:GetComponent("physics"):GetPosition()
					render3d.camera:SetPosition(Vec3(-pos.y, -pos.x, -pos.z))
				else
					render3d.camera:SetPosition(ghost:GetPosition())
				end
			end

			if not window.IsOpen() or not window.GetMouseTrapped() then return end

			local angles = render3d.camera:GetAngles()
			local fov = render3d.camera:GetFOV()
			local dir, angles, fov = CalcMovement(1, angles, fov)
			local side = Vec3()
			local forward = Vec3()
			local up = Vec3()

			if PHYSICS then
				local speed = 5

				if input.IsKeyDown("left_shift") and input.IsKeyDown("left_control") then
					speed = speed * 4
				elseif input.IsKeyDown("left_shift") then
					speed = speed * 2
				elseif input.IsKeyDown("left_control") then
					speed = speed / 4
				end

				local offset = Ang3(0, angles.y, 0):GetForward() * speed

				if input.IsKeyDown("w") then
					side = side + offset
				elseif input.IsKeyDown("s") then
					side = side - offset
				end

				offset = Ang3(0, angles.y, 0):GetRight() * speed

				if input.IsKeyDown("a") then
					forward = forward - offset
				elseif input.IsKeyDown("d") then
					forward = forward + offset
				end

				if input.IsKeyDown("space") then up.z = 2000 end
			else
				local speed = 1

				if input.IsKeyDown("space") then up = up + angles:GetUp() * speed end

				local offset = angles:GetForward() * speed

				if input.IsKeyDown("w") then
					side = side + offset
				elseif input.IsKeyDown("s") then
					side = side - offset
				end

				offset = angles:GetRight() * speed

				if input.IsKeyDown("a") then
					forward = forward - offset
				elseif input.IsKeyDown("d") then
					forward = forward + offset
				end

				if input.IsKeyDown("left_alt") then
					angles.z = math.rad(math.round(math.deg(angles.z) / 45) * 45)
				end
			end

			local cmd = {}
			cmd.velocity = side + forward + up
			cmd.angles = angles
			cmd.fov = fov
			cmd.mouse_pos = window.GetMousePosition()
			render3d.camera:SetAngles(cmd.angles)
			render3d.camera:SetFOV(cmd.fov)
			return cmd
		end)
	end

	for _, v in ipairs(clients.GetAll()) do
		if v.nv.ghost and v.nv.ghost:IsValid() then v.nv.ghost:Remove() end
	end

	event.AddListener("PhysicsCollide", "ground_enttiy", function(a, b)
		print(a, b)
	end)

	event.AddListener("Move", "spooky", function(client, cmd)
		if CLIENT and not network.IsConnected() then return end

		local ghost = NULL

		if SERVER then
			if not client.nv.ghost or not client.nv.ghost:IsValid() then
				ghost = entities.CreateEntity(PHYSICS and "physical" or "visual")
				ghost:SetName(client:GetNick() .. "'s ghost")
				local filter = clients.CreateFilter():AddAllExcept(client)
				ghost:ServerFilterSync(filter, "Position")
				ghost:ServerFilterSync(filter, "Rotation")
				ghost:SetModelPath("models/cube.obj")

				if PHYSICS then
					--ghost:SetNetworkChannel(1)
					ghost:SetPhysicsModelPath("models/cube.obj")
					ghost:SetPhysicsCapsuleZHeight(1.5)
					ghost:SetPhysicsCapsuleZRadius(0.5)
					ghost:InitPhysicsCapsuleZ()
					ghost:SetMass(85)
					ghost:SetPosition(Vec3(0, 0, -20))
					ghost:SetAngularFactor(Vec3(0, 0, 0))
					ghost:SetScale(-Vec3(0.5, 0.5, 1.85))
					ghost:SetSimulateOnClient(true)
					ghost:SetAngles(Ang3(0, 0, 0))
				end

				client.nv.ghost = ghost
			end
		end

		if client.nv.ghost and client.nv.ghost:IsValid() then
			ghost = client.nv.ghost
		end

		if not ghost:IsValid() then return end

		if not PHYSICS then
			if CLIENT then
				ghost:SetPosition(cmd.net_position)
				ghost:SetAngles(cmd.angles)
			end

			ghost:SetPosition(ghost:GetPosition() + cmd.velocity)
			return ghost:GetPosition(), cmd.velocity
		end

		local physics = ghost:GetComponent("physics")
		local pos = physics:GetPosition()

		if CLIENT then
			if cmd.net_position then
				physics.sync_now = physics.sync_now or 0
				local distance = cmd.net_position:Distance(pos)

				if distance > 2 then
					physics:SetPosition(cmd.net_position)
					physics:SetAngles(cmd.angles)
					physics:SetVelocity(cmd.net_velocity)
					physics.sync_now = system.GetElapsedTime() + 2
					logn("prediction error: physics position differs too much ", distance)
				end

				local distance = cmd.net_position:Distance(pos)

				if physics.sync_now < system.GetElapsedTime() and distance > 0.1 then
					physics:SetPosition(cmd.net_position)
					physics.sync_now = system.GetElapsedTime() + 2
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
		physics:SetAngularVelocity(Vec3(0, 0, 0))
		physics:SetAngularFactor(Vec3(0, 0, 0))
		physics:SetAngularSleepingThreshold(0)
		physics:SetLinearSleepingThreshold(0)
		--
		local hit = _G.physics.RayCast(
			physics:GetPosition(),
			physics:GetPosition() + (physics:GetRotation():GetUp() * 1.36)
		)

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
				local ent = entities.CreateEntity(PHYSICS and "physical" or "visual")

				if PHYSICS then
					ent:SetPhysicsModelPath("models/cube.obj")
					ent:SetMass(85)
					ent:InitPhysicsBox(-Vec3(0.15, 1, 0.15))
					ent:SetVelocity(cmd.angles:GetForward() * 10)
				end

				ent:SetModelPath("models/cube.obj")
				ent:SetScale(-Vec3(0.15, 1, 0.15))
				ent:SetPosition(cmd.net_position + (cmd.angles:GetForward() * 5))

				timer.Delay(3, function()
					entities.SafeRemove(ent)
				end)
			end
		end)
	end
end)