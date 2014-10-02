if CLIENT then
	local angles = Ang3(0, 0, 0)
	local fov = 75

	event.AddListener("CreateMove", "spooky", function(client, prev_cmd)	
		if not window.IsOpen() then return end
		if chat and chat.IsVisible() then return end
		if menu and menu.visible then return end
		
		local cmd = {}
		local velocity = Vec3(0, 0, 0)
		local speed = 10
		local delta = window.GetMouseDelta() / 100
		
		angles:Normalize()
		
		if input.IsKeyDown("r") then
			angles.r = 0
			fov = 90
		end
		
		delta = delta * (fov / 175)
		
		if input.IsMouseDown("button_2") then
			angles.r = angles.r + delta.x / 2
			fov = math.clamp(fov + delta.y * 100, 0.1, 175)
		else
			angles.p = math.clamp(angles.p + delta.y, -math.pi/2, math.pi/2)
			angles.y = angles.y - delta.x
		end

		if input.IsKeyDown("left_shift") then
			speed = speed * 8
		elseif input.IsKeyDown("left_control") then
			speed = speed / 4
		end
		
		local forward = Vec3(0,0,0)
		local side = Vec3(0,0,0)
		local up = Vec3(0,0,0)

		if input.IsKeyDown("space") then
			up = up + angles:GetUp() * speed
		end

		local offset = angles:GetForward() * speed

		if input.IsKeyDown("w") then
			side = side + offset
		elseif input.IsKeyDown("s") then
			side = side - offset
		end

		offset = angles:GetRight() * speed

		if input.IsKeyDown("a") then 
			forward = forward + offset
		elseif input.IsKeyDown("d") then
			forward = forward - offset
		end

		if input.IsKeyDown("left_alt") then
			angles.r = math.round(angles.r / math.rad(45)) * math.rad(45)
		end
		
		cmd.velocity = forward + side + up
		cmd.angles = angles:GetDeg()
		cmd.fov = fov
		cmd.mouse_pos = window.GetMousePos()
		
		render.SetCamAng(cmd.angles)
		render.SetCamFOV(cmd.fov)
		
		local ghost = client.nv.ghost or NULL
		if ghost:IsValid() then
			local pos = ghost:GetComponent("physics"):GetPosition() 
			render.SetCamPos(Vec3(-pos.y, -pos.x, -pos.z))
		end

		return cmd
	end)
	
	-- 2d
	event.AddListener("DrawHUD", "cursors", function()

		if not menu.IsVisible() then return end
		
		surface.SetColor(1,1,1,1)
		surface.SetFont("default")
		
		for _, client in pairs(clients.GetAll()) do
			if not client:IsBot() then
				local cmd = client:GetCurrentCommand()
				surface.SetTextPos(cmd.mouse_pos.x, cmd.mouse_pos.y)

				local str = client:GetNick()
				local coh = client:GetChatAboveHead()
				
				if #coh > 0 then
					str = str .. ": " .. coh
				end
				
				surface.DrawText(str)
			end
		end
		
		surface.SetAlphaMultiplier(1)
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
			ghost = entities.CreateEntity("networked")
				
			local filter = clients.CreateFilter():AddAllExcept(client)
			
			ghost:ServerFilterSync(filter, "Position")
			ghost:ServerFilterSync(filter, "Rotation")
			
			--ghost:SetNetworkChannel(1) 
			ghost:SetModelPath("models/sphere.obj")
			ghost:SetMass(85)
			ghost:InitPhysicsSphere(0.5)
			ghost:SetPosition(Vec3(0,0,-40))  
			ghost:SetLinearSleepingThreshold(0)  
			ghost:SetAngularSleepingThreshold(0)  
			ghost:SetSize(1/12)  
 			ghost:SetSimulateOnClient(true) 
			
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
	
	physics:SetVelocity(physics:GetVelocity() + cmd.velocity * 0.2)
	physics:SetVelocity(physics:GetVelocity() * 0.75)   
	physics:SetAngularVelocity(physics:GetAngularVelocity() * 0.75)   
	
	return pos, physics:GetVelocity()
end) 
 
if SERVER then
	event.AddListener("ClientMouseInput", "bsp_lol", function(client, button, press)	
		if button == "button_1" and press then
			local cmd = client:GetCurrentCommand()
			
			local ent = entities.CreateEntity("networked")
			ent:InitPhysicsBox(Vec3(1, 1, 1)/12)
			ent:SetSize(1/12)
			ent:SetModelPath("models/cube.obj")
			ent:SetMass(100)
			ent:SetPosition(cmd.net_position) 
			ent:SetVelocity(cmd.angles:GetRad():GetForward() * 100)
			
			event.Delay(3, function()
				entities.SafeRemove(ent)
			end)
			
			print(client, button, press, ent, cmd.net_position)
		end
	end)
end