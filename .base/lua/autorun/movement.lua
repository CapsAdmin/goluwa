if CLIENT then

	event.AddListener("CreateMove", "spooky", function(client, prev_cmd, dt)	
		local ghost = client.nv.ghost or NULL
		if ghost:IsValid() then
			local pos = ghost:GetComponent("physics"):GetPosition() 
			render.SetCameraPosition(Vec3(-pos.y, -pos.x, -pos.z))
		end
		
		if not window.IsOpen() or not window.GetMouseTrapped() then return end
		
		local angles = render.GetCameraAngles()
		local fov = render.GetCameraFOV()
		
		local dir, angles, fov = CalcMovement(1, angles, fov)
		
		local side = Vec3()
		local forward = Vec3()
		local up = Vec3()
		do
			local speed = 40
			
			if input.IsKeyDown("left_shift") and input.IsKeyDown("left_control") then
				speed = speed * 3
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
				up.z = 150
			end			
		end
		
		local cmd = {}
		
		cmd.velocity = side + forward + up
		cmd.angles = angles
		cmd.fov = fov
		cmd.mouse_pos = window.GetMousePosition()
		
		render.SetCameraAngles(cmd.angles)
		render.SetCameraFOV(cmd.fov)
		
		return cmd
	end) 
end
 
for k,v in pairs(clients.GetAll()) do
	if v.nv.ghost and v.nv.ghost:IsValid() then
		v.nv.ghost:Remove()
	end
end    
	
event.AddListener("Move", "spooky", function(client, cmd)
	if CLIENT and not network.IsConnected() then return end
	
	local ghost = NULL
	
	if SERVER then
		if not client.nv.ghost or not client.nv.ghost:IsValid() then
			ghost = entities.CreateEntity("physical")
			ghost:SetName(client:GetNick() .. "'s ghost")
				
			local filter = clients.CreateFilter():AddAllExcept(client)
			
			--ghost:ServerFilterSync(filter, "Position")
			--ghost:ServerFilterSync(filter, "Rotation")
			
			--ghost:SetNetworkChannel(1) 
			ghost:SetPhysicsModelPath("models/cube.obj")
			ghost:SetModelPath("models/cube.obj")
			ghost:SetMass(85)
			ghost:SetPhysicsCapsuleZHeight(1.5)   
			ghost:SetPhysicsCapsuleZRadius(0.5)
			ghost:InitPhysicsCapsuleZ()
			ghost:SetPosition(Vec3(0,0,-20))
			ghost:SetAngularFactor(Vec3(0,0,1))
			ghost:SetLinearSleepingThreshold(0)  
			ghost:SetAngularSleepingThreshold(0)  
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
		if cmd.net_position and cmd.net_position:Distance(pos) > 1 then
			physics:SetPosition(cmd.net_position)   
			physics:SetAngles(cmd.angles)
		end
	end
			
	--physics:SetAngularVelocity(physics:GetAngularVelocity() * 0.75)
	
	local hit = _G.physics.RayCast(physics:GetPosition(), physics:GetPosition() + (physics:GetRotation():GetUp()*1.25)) 
	if hit then
		physics:SetVelocity(physics:GetVelocity() + cmd.velocity * 0.05)  
		physics:SetVelocity(physics:GetVelocity() * 0.75)   
		
		local velocity = physics:GetVelocity()
		local speed = velocity:GetLength()
		if speed > 20 then
			velocity = velocity * 20/speed
			physics:SetVelocity(velocity)
		end
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