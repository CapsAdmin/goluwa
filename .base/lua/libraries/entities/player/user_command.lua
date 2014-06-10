local client_command_length = 100 -- sample length in ms
local client_tick_rate = 33 -- in ms

local server_command_length = client_command_length
local server_tick_rate = 10

local META = (...) or metatable.Get("player")

local default = {
	time = 0,
	
	cursor = Vec2(0, 0),
	smooth_cursor = Vec2(0, 0),
	
	camera = {
		pos = Vec3(0, 0, 0),
		smooth_pos = Vec3(0, 0, 0),
		
		ang = Ang3(0, 0, 0),
		smooth_ang = Ang3(0, 0, 0),
		
		fov = 0,
		smooth_fov = 0,
	},
	
	queue = {},
}

function META:GetCurrentCommand()
	if not self.current_command then
		self.current_command = table.copy(default)
	end
	return self.current_command
end

local function read_buffer(ply, buffer)
	local cmd = ply:GetCurrentCommand() -- get or create the cmd table
	local time_stamp -- first time is the base time
	
	for i = 1, 32 do
		local time = buffer:ReadDouble()
		
		local cursor = buffer:ReadVec2Short()
		local cam_pos = buffer:ReadVec3()
		local cam_ang = buffer:ReadAng3()
		local cam_fov = buffer:ReadFloat()
		
		if not time_stamp then
			time_stamp = time 
		end
		
		cmd.queue[i] = cmd.queue[i] or table.copy(default)
		
		cmd.queue[i].time = timer.GetSystemTime() + (time - time_stamp)
		
		cmd.queue[i].cursor = cursor
		cmd.queue[i].camera.pos = cam_pos
		cmd.queue[i].camera.ang = cam_ang
		cmd.queue[i].camera.fov = cam_fov

		if buffer:TheEnd() then 
			break 
		end
		
		if i == 32 then
			logn("command too big: ", ply)
		end
	end
		
	--table.sort(ply.current_command.queue, function(a, b) return a.time > b.time end)
end

local function interpolate(ply, cmd)	
	local data = cmd.queue[1]
			
	if data and data.time < timer.GetSystemTime() then

		cmd.smooth_cursor:Lerp(0.3, data.cursor)
		cmd.cursor = data.cursor
	
		cmd.camera.pos = data.camera.pos
		cmd.camera.smooth_pos:Lerp(0.3, data.camera.pos)
		
		cmd.camera.ang = data.camera.ang
		cmd.camera.smooth_ang:Lerp(0.3, data.camera.ang)
		
		cmd.camera.ang = data.camera.ang
		cmd.camera.smooth_fov = math.lerp(0.3, cmd.camera.smooth_fov, data.camera.fov)
		
		table.remove(cmd.queue, 1)
	end
end

event.AddListener("Update", "interpolate_user_command", function()
	for _, ply in pairs(players.GetAll()) do
		interpolate(ply, ply:GetCurrentCommand())
	end
end)

if CLIENT then		
	client_command_length = client_command_length / 1000
	client_tick_rate = 1/client_tick_rate
	
	do
		local buffer = Buffer()
		local last_send = 0
		
		event.CreateTimer("user_command_tick", client_tick_rate, function()
			
			buffer:WriteDouble(timer.GetSystemTime())
			buffer:WriteVec2Short(window.GetMousePos())
			buffer:WriteVec3(render.GetCamPos())
			buffer:WriteAng3(render.GetCamAng())
			buffer:WriteFloat(render.GetCamFOV())
			
			if last_send < timer.GetSystemTime() then
				packet.Send("user_command", buffer)
				buffer:Clear()
				last_send = timer.GetSystemTime() + client_command_length
			end
		end)
	end
		
	packet.AddListener("user_command", function(buffer)
		local ply = players.GetByUniqueID(buffer:ReadString())
		if ply:IsValid() then
			read_buffer(ply, buffer)
		end
	end)
	
	packet.AddListener("server_command", function(buffer)
		local time = buffer:ReadDouble()
		
		timer.SetServerTime(time)
	end)
end 

if SERVER then	
	server_command_length = server_command_length / 1000
	server_tick_rate = 1/server_tick_rate
	
	do
		local buffer = Buffer()
		local last_send = 0
		
		event.CreateTimer("server_command_tick", server_tick_rate, function()			
			buffer:WriteDouble(timer.GetSystemTime())
			
			if last_send < timer.GetSystemTime() then
				packet.Broadcast("server_command", buffer)
				buffer:Clear()
				last_send = timer.GetSystemTime() + server_command_length
			end
		end)
	end

	packet.AddListener("user_command", function(ply, buffer)
		read_buffer(ply, buffer)
		buffer:SetPos(0)
		packet.Send("user_command", nil, buffer:AddHeader(Buffer():WriteString(ply:GetUniqueID())))
	end)
end 