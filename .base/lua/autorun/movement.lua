include("libraries/ecs.lua")

if CLIENT then
	local angles = Ang3(0, 0, 0)

	event.AddListener("CreateMove", "spooky", function(ply, prev_cmd)
	
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
		
		return cmd
	end)
	
	-- 2d
	event.AddListener("DrawHUD", "cursors", function()

		if not menu.IsVisible() then return end
		
		surface.SetColor(1,1,1,1)
		surface.SetFont("default")
		
		for _, ply in pairs(players.GetAll()) do
			if not ply:IsBot() then
				local cmd = ply:GetCurrentCommand()
				surface.SetTextPos(cmd.mouse_pos.x, cmd.mouse_pos.y)
				local str = ply:GetNick()
				local coh = ply:GetChatAboveHead()
				
				if #coh > 0 then
					str = str .. ": " .. coh
				end
				
				surface.DrawText(str)
			end
		end
		
		surface.SetAlphaMultiplier(1)
	end)
end 


for k,v in pairs(players.GetAll()) do
	if v.ghost and v.ghost:IsValid() then
		v.ghost:Remove()
	end
end 

event.AddListener("Move", "spooky", function(ply, cmd)
	if not ecs then return end
	
	ply.ghost = ply.ghost or NULL
	
	if not ply.ghost:IsValid() then
		ply.ghost = ecs.CreateEntity("shape2")
		ply.ghost:SetModelPath("models/box.obj")
		ply.ghost:InitPhysics("box", 85, 1, 1, 1)
		--ply.ghost:SetScale(Vec3(1,1,1))
		ply.ghost:SetPosition(Vec3(0,0,10))
	end
	
	local pos = ply.ghost:GetPosition()
	
	if ply == players.GetLocalPlayer() then
		render.SetupView3D(pos, cmd.angles:GetDeg(), cmd.fov)
	end
			
	local vel = cmd.angles:GetForward() * cmd.velocity
				
	vel:SetMaxLength(100000)
					
	ply.ghost:SetVelocity(ply.ghost:GetVelocity() + vel)
	--ply.ghost:SetAngles(cmd.angles) 
	--ply.ghost:SetScale(Vec3(1,(-(cmd.fov / 90) + 2) ^ 4,1))
end) 

event.Delay(function()
	local world = ecs.CreateEntity("shape2")
	world:SetModelPath("models/cube.obj")  
	world:InitPhysics("box", 0, 500, 1, 500)  
	world:SetPosition(Vec3(0,0,0)) 
	world:SetAngles(Ang3(0,0,0))
	world:SetScale(Vec3(500, 500, 0))			
	
	for i = 1, 10 do
		local body = ecs.CreateEntity("shape2")
		body:SetModelPath("models/cube.obj")
		body:SetPosition(Vec3(0,0,1+i*10)) 
		body:InitPhysics("convex", 10, "models/cube.obj", true)  
		body:SetSize(1)
		ASDF = body
	end
end) 
 