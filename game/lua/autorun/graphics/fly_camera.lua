local held_ang
local held_mpos
local drag_view = false

function CalcMovement(dt, cam_ang, cam_fov)
	cam_ang:Normalize()
	local speed = dt * 10
	local delta = window.GetMouseDelta() / 2
	local r = cam_ang.z
	local cs = math.cos(r)
	local sn = math.sin(r)
	local x = delta.x * cs - delta.y * sn
	local y = delta.x * sn + delta.y * cs
	local original_delta = delta:Copy()
	delta.x = x
	delta.y = y

	if input.IsKeyDown("r") then
		cam_ang.z = 0
		cam_fov = math.rad(75)
	end

	delta = delta * (cam_fov / 175)

	if input.IsKeyDown("left_shift") and input.IsKeyDown("left_control") then
		speed = speed * 32
	elseif input.IsKeyDown("left_shift") then
		speed = speed * 8
	elseif input.IsKeyDown("left_control") then
		speed = speed / 4
	end

	if input.IsKeyDown("left") then
		delta.x = delta.x - speed / 3
	elseif input.IsKeyDown("right") then
		delta.x = delta.x + speed / 3
	end

	if input.IsKeyDown("up") then
		delta.y = delta.y - speed / 3
	elseif input.IsKeyDown("down") then
		delta.y = delta.y + speed / 3
	end

	if input.IsMouseDown("button_2") then
		cam_ang.z = cam_ang.z + original_delta.x / 100
		cam_fov = math.clamp(
			cam_fov + original_delta.y / 100 * (cam_fov / math.pi),
			math.rad(0.1),
			math.rad(175)
		)
	else
		if window.GetMouseTrapped() then
			cam_ang.x = math.clamp(cam_ang.x + delta.y, -math.pi / 2, math.pi / 2)
			cam_ang.y = cam_ang.y - delta.x
		else
			if drag_view then
				held_mpos = held_mpos or window.GetMousePosition()
				local delta = (held_mpos - window.GetMousePosition())
				delta = delta / 300
				held_ang = held_ang or cam_ang:Copy()
				cam_ang.x = math.clamp(held_ang.x - delta.y, -math.pi / 2, math.pi / 2)
				cam_ang.y = held_ang.y + delta.x
			else
				held_mpos = nil
				held_ang = cam_ang:Copy()
			end
		end
	end

	local forward = Vec3(0, 0, 0)
	local side = Vec3(0, 0, 0)
	local up = Vec3(0, 0, 0)

	if input.IsKeyDown("space") then up = up + cam_ang:GetUp() * speed end

	local offset = cam_ang:GetForward() * speed

	if input.IsKeyDown("w") then
		side = side + offset
	elseif input.IsKeyDown("s") then
		side = side - offset
	end

	offset = cam_ang:GetRight() * speed

	if input.IsKeyDown("a") then
		forward = forward - offset
	elseif input.IsKeyDown("d") then
		forward = forward + offset
	end

	if input.IsKeyDown("left_alt") then
		cam_ang.z = math.rad(math.round(math.deg(cam_ang.z) / 45) * 45)
	end

	if cam_fov > math.rad(90) then
		side = side / ((cam_fov / math.rad(90)) ^ 4)
	else
		side = side / ((cam_fov / math.rad(90)) ^ 0.25)
	end

	return forward + side + up, cam_ang, cam_fov
end

event.AddListener("GBufferInitialized", function()
	event.AddListener(
		"Update",
		"fly_camera_3d",
		function(dt)
			if network.IsConnected() then return end

			if not window.IsFocused() then return end

			local cam_pos = render3d.camera:GetPosition()
			local cam_ang = render3d.camera:GetAngles()
			local cam_fov = render3d.camera:GetFOV()
			local dir, ang, fov = CalcMovement(dt, cam_ang, cam_fov)
			cam_pos = cam_pos + dir
			render3d.camera:SetPosition(cam_pos)
			render3d.camera:SetAngles(ang)
			render3d.camera:SetFOV(fov)
		end,
		{priority = -math.huge}
	)

	event.AddListener("MouseInput", "fly_camera_3d", function(button, press)
		if press then
			if gui.IsMouseHoveringPanel() then return end

			drag_view = true
		else
			drag_view = false
		end
	end)
end)

input.Bind("o", "cam_ortho", function()
	render3d.camera:SetOrtho(not render3d.camera:GetOrtho())
end)

do
	return
end

local roll = 0
local pos = Vec2(0, 0)
local zoom = 1
local max_zoom = 100
local min_zoom = 0.01

event.AddListener("Update", "fly_camera_2d", function(dt)
	if gui and (gui.GetHoveringPanel() ~= gui.world or gui.focus_panel:IsValid()) then
		return
	end

	local speed = dt * 1000

	if input.IsKeyDown("kp_5") then
		pos = Vec2(0, 0)
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
		roll = roll - speed / 360
	elseif input.IsKeyDown("kp_9") then
		roll = roll + speed / 360
	end

	if input.IsKeyDown("left_alt") then
		roll = math.round(roll / math.rad(45)) * math.rad(45)
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

	local pos = pos:GetRotated(-roll)
	render2d.camera:SetPosition(Vec3(pos.x, pos.y, 0))
	render2d.camera:SetAngles(Ang3(0, roll))
	render2d.camera:SetZoom(1 / zoom)
end)