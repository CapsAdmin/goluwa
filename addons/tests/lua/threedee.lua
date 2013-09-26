window.Open(1280, 720)

local cam_pos = Vec3(0, 0, -10)
local cam_ang = Ang3(0, 0, 0)

local function calc_camera(dt)
 
	cam_ang:Normalize()
	local speed = dt * 10

	local delta = window.GetMouseDelta() * dt / 2
	cam_ang.p = cam_ang.p + delta.y
	cam_ang.y = cam_ang.y + delta.x
	cam_ang.p = math.clamp(cam_ang.p, -math.pi/2, math.pi/2)

	if input.IsKeyDown("left_shift") then
		speed = speed * 4
	elseif input.IsKeyDown("left_control") then
		speed = speed / 4
	end

	if input.IsKeyDown("space") then
		cam_pos = cam_pos - Vec3(0, speed, 0);
	end

	local offset = cam_ang:GetUp() * speed;
	offset.x = -offset.x;
	offset.y = -offset.y

	if input.IsKeyDown("w") then

		cam_pos = cam_pos + offset
	elseif input.IsKeyDown("s") then
		cam_pos = cam_pos - offset
	end

	offset = cam_ang:GetRight() * speed
	offset.z = -offset.z

	if input.IsKeyDown("a") then
		cam_pos = cam_pos + offset
	elseif input.IsKeyDown("d") then
		cam_pos = cam_pos - offset
	end

	speed = dt * 5
  
	if input.IsKeyDown("up") then
		cam_ang.p = cam_ang.p - speed
	elseif input.IsKeyDown("down") then
		cam_ang.p = cam_ang.p + speed
	end 

	if input.IsKeyDown("left") then
		cam_ang.y = cam_ang.y - speed
	elseif input.IsKeyDown("right") then
		cam_ang.y = cam_ang.y + speed
	end  
end        
  
entities.world_entity:RemoveChildren() 

local obj = Entity("model")
obj:SetPos(Vec3(5,0,0))
obj:SetModel(Model("spider.obj"))

local obj = Entity("model")
obj:SetPos(Vec3(5,0,0))
obj:SetModel(Model("WusonOBJ.obj"))
 
window.SetMouseTrapped(true)
     
event.AddListener("OnDraw3D", "gl", function(dt)
	calc_camera(dt)

	render.Start3D(cam_pos, cam_ang:GetDeg())
		entities.world_entity:Draw()			
end)
