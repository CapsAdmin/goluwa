include("libraries/ecs.lua")

if CLIENT then
	local angles = Ang3(0, 0, 0)

	event.AddListener("CreateMove", "spooky", function(client, prev_cmd)
		do return end
	
		if not window.IsOpen() then return end
		if chat and chat.IsVisible() then return end
		if menu and menu.visible then return end
		
		local cmd = {}
		local fov = 75
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
		cmd.angles = angles
		cmd.fov = fov
		cmd.mouse_pos = window.GetMousePos()
		
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
	if v.ghost and v.ghost:IsValid() then
		v.ghost:Remove()
	end
end  

event.AddListener("Move", "spooky", function(client, cmd)
	do return end
	if not ecs then return end
	
	client.ghost = client.ghost or NULL
	
	if not client.ghost:IsValid() then
		client.ghost = ecs.CreateEntity("shape2")
		client.ghost:SetModelPath("models/cube.obj")
		client.ghost:InitPhysics("box", 85, 1, 1, 1)
		--client.ghost:SetScale(Vec3(1,1,1))
		client.ghost:SetPosition(Vec3(0,0,10))
	end
	
	local pos = client.ghost:GetPosition() 
	
	if CLIENT then
		if client == clients.GetLocalClient() then
			render.SetupView3D(pos, cmd.angles:GetDeg(), cmd.fov)
			
			if cmd.net_position and cmd.net_position:Distance(pos) > 0.25 then
				client.ghost:SetPosition(cmd.net_position)
				client.ghost:SetVelocity(Vec3(0,0,0))
				--print(cmd.net_position - pos)
			end
		end		
	end
			
	local vel = cmd.angles:GetForward() * cmd.velocity
	
	client.ghost:SetVelocity(client.ghost:GetVelocity() + vel)
		
	--client.ghost:SetAngles(cmd.angles) 
	--client.ghost:SetScale(Vec3(1,(-(cmd.fov / 90) + 2) ^ 4,1))
	 if SERVER then print(pos) end 
	return pos
end) 