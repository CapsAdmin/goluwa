local cam_pos = Vec3(0, 0, 200) 
local cam_ang = Ang3(0, 0, 0)  
local cam_fov = 90

local pos_2d = Vec2(0, 0)
local zoom = 1
local zoom2d = 1

local max_zoom2d = 100
local min_zoom2d = 0.01
 
event.AddListener("OnUpdate", "fly_camera", function(dt)
	if not window.IsOpen() then return end
	
	if menu and menu.visible then return end
	cam_ang:Normalize()
	local speed = dt * 1000

	local delta = window.GetMouseDelta() / 100
	
	if input.IsKeyDown("r") then
		cam_ang.r = 0
		cam_fov = 90
		zoom = 1
		zoom2d = 1
		pos_2d = Vec2(0,0)
	end
	
	if input.IsMouseDown("button_2") then
		cam_ang.r = cam_ang.r - delta.x / 2
		
		zoom = math.clamp(zoom + delta.y, 0.1, 5)
		zoom2d = math.clamp(zoom2d + delta.y * 2, min_zoom2d, max_zoom2d)
		cam_fov = math.clamp(cam_fov + delta.y * 100, 0.1, 120)
	else
		cam_ang.p = math.clamp(cam_ang.p + delta.y, -math.pi/2, math.pi/2)
		cam_ang.y = cam_ang.y - delta.x
	end
	
	if input.IsMouseDown("mwheel_up") then
		zoom2d = math.clamp(zoom2d - 0.25, min_zoom2d, max_zoom2d)
	elseif input.IsMouseDown("mwheel_down") then
		zoom2d = math.clamp(zoom2d + 0.25, min_zoom2d, max_zoom2d)
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
		pos_2d.y = pos_2d.y + speed
	elseif input.IsKeyDown("s") then
		cam_pos = cam_pos - offset
		pos_2d.y = pos_2d.y - speed
	end

	offset = cam_ang:GetRight() * speed

	if input.IsKeyDown("a") then
		cam_pos = cam_pos + offset
		pos_2d.x = pos_2d.x + speed
	elseif input.IsKeyDown("d") then
		cam_pos = cam_pos - offset
		pos_2d.x = pos_2d.x - speed
	end

	if input.IsKeyDown("left_alt") then
		cam_ang.r = math.round(cam_ang.r / math.rad(45)) * math.rad(45)
	end
	
	local deg = cam_ang:GetDeg()
	render.SetupView3D(cam_pos, deg, cam_fov)
	render.SetupView2D(pos_2d, deg.r, 1/zoom2d)
end)  
