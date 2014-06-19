local cam_pos = Vec3(0, 0, 0)   
local cam_ang = Ang3(0, 0, 0)  
local cam_fov = 90
  
event.AddListener("Update", "fly_camera_3d", function(dt)
	if network.IsConnected() then return end
	if not window.IsOpen() then return end
	if chat and chat.IsVisible() then return end
	
	if menu and menu.visible then return end
	cam_ang:Normalize()
	local speed = dt * 10

	local delta = window.GetMouseDelta() / 100
	
	if input.IsKeyDown("r") then
		cam_ang.r = 0
		cam_fov = 90
	end
	
	delta = delta * (cam_fov / 175)
	
	if input.IsMouseDown("button_2") then
		cam_ang.r = cam_ang.r + delta.x / 2
		cam_fov = math.clamp(cam_fov + delta.y * 100, 0.1, 175)
	else
		cam_ang.p = math.clamp(cam_ang.p + delta.y, -math.pi/2, math.pi/2)
		cam_ang.y = cam_ang.y - delta.x
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
		up = up + cam_ang:GetUp() * speed
	end

	local offset = cam_ang:GetForward() * speed

	if input.IsKeyDown("w") then
		side = side + offset
	elseif input.IsKeyDown("s") then
		side = side - offset
	end

	offset = cam_ang:GetRight() * speed

	if input.IsKeyDown("a") then
		forward = forward + offset
	elseif input.IsKeyDown("d") then
		forward = forward - offset
	end

	if input.IsKeyDown("left_alt") then
		cam_ang.r = math.round(cam_ang.r / math.rad(45)) * math.rad(45)
	end
	
	cam_pos = cam_pos + forward + side + up
	
	render.SetupView3D(cam_pos, cam_ang:GetDeg(), cam_fov)
end)

local roll = 0
local pos = Vec2(0, 0)
local zoom = 1

local max_zoom = 100
local min_zoom = 0.01

event.AddListener("Update", "fly_camera_2d", function(dt)
	if not window.IsOpen() then return end
	
	local speed = dt * 1000

	local delta = window.GetMouseDelta() / 100
	
	if input.IsKeyDown("kp_5") then
		pos = Vec2(0,0)
		zoom = 1
		roll = 0
	end
	
	if input.IsKeyDown("left_shift") then
		speed = speed * 8
	elseif input.IsKeyDown("left_control") then
		speed = speed / 4
	end
	
	
	if input.IsKeyDown("kp_subtract") then
		zoom = math.clamp(zoom - speed / 1000, min_zoom, max_zoom)
	elseif input.IsKeyDown("kp_add") then
		zoom = math.clamp(zoom + speed / 1000, min_zoom, max_zoom)
	end

	if input.IsKeyDown("kp_7") then
		roll = roll - speed / 4
	elseif input.IsKeyDown("kp_9") then
		roll = roll + speed / 4 
	end
	
	if input.IsKeyDown("kp_8") then
		pos.y = pos.y + speed
	elseif input.IsKeyDown("kp_2") then
		pos.y = pos.y - speed
	end

	if input.IsKeyDown("kp_4") then
		pos.x = pos.x + speed
	elseif input.IsKeyDown("kp_6") then
		pos.x = pos.x - speed
	end

	if input.IsKeyDown("left_alt") then
		roll = math.round(roll / math.rad(45)) * math.rad(45)
	end
	
	render.SetupView2D(pos, roll, 1/zoom)
end)  
