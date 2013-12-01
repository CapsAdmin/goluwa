local cam_pos = Vec3(0, 0, -10)
local cam_ang = Ang3(0, 0, 0)
local cam_fov = 90
 
event.AddListener("OnUpdate", "fly_camera", function(dt)
	if not window.IsOpen() then return end
	
	if menu and menu.visible then return end
	cam_ang:Normalize()
	local speed = dt * 100

	local delta = window.GetMouseDelta() * dt / 2
		
	cam_ang.p = math.clamp(cam_ang.p + delta.y, -math.pi/2, math.pi/2)
	cam_ang.y = cam_ang.y - delta.x		
	
	if input.IsKeyDown("r") then
		cam_ang.r = 0
		cam_fov = 90
	end
	
	if input.IsMouseDown("button_2") then
		cam_fov = math.clamp(cam_fov + delta.y * 1000, 0, 180)
		cam_ang.r = cam_ang.r - delta.x
	end

	if input.IsKeyDown("left_shift") then
		speed = speed * 8
	elseif input.IsKeyDown("left_control") then
		speed = speed / 4
	end

	if input.IsKeyDown("space") then
		cam_pos = cam_pos + cam_ang:GetUp() * speed
	end

	local offset = cam_ang:GetForward() * speed

	if input.IsKeyDown("w") then
		cam_pos = cam_pos + offset
	elseif input.IsKeyDown("s") then
		cam_pos = cam_pos - offset
	end

	offset = cam_ang:GetRight() * speed

	if input.IsKeyDown("a") then
		cam_pos = cam_pos + offset
	elseif input.IsKeyDown("d") then
		cam_pos = cam_pos - offset
	end

	render.SetupView(cam_pos, cam_ang:GetDeg(), cam_fov)
end) 
