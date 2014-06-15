local client_command_length = 100 -- sample length in ms
local client_tick_rate = 33 -- in ms

local server_command_length = client_command_length
local server_tick_rate = 10

local META = (...) or metatable.Get("client")

local layout = {
	{name = "mouse_pos", default = Vec2(0, 0), type = "vec2short"},
	{name = "velocity", default = Vec3(0, 0, 0)},
	{name = "angles", default = Ang3(0, 0, 0)},
	{name = "fov", default = 75},
}

local default = {
	time = 0,
	queue = {},
}

for i, v in ipairs(layout) do
	v.type = v.type or typex(v.default)
	default[v.name] = v.default
end

function META:GetCurrentCommand()
	if not self.current_command then
		self.current_command = table.copy(default)
	end
	return self.current_command
end

local function read_buffer(client, buffer)
	local cmd = client:GetCurrentCommand() -- get or create the cmd table
	local time_stamp -- first time is the base time
	
	for i = 1, 32 do
		local time = buffer:ReadDouble()
		
		if not time_stamp then
			time_stamp = time 
		end
		
		cmd.queue[i] = cmd.queue[i] or table.copy(default)		
		cmd.queue[i].time = timer.GetSystemTime() + (time - time_stamp)
		
		for _, v in ipairs(layout) do
			cmd.queue[i][v.name] = buffer:ReadType(v.type)
		end
		
		if CLIENT then
			cmd.queue[i].net_position = buffer:ReadVec3()
		end
		
		if buffer:TheEnd() then 
			break 
		end
		
		if i == 32 then
			logn("command too big: ", client)
		end
	end
		
	--table.sort(client.current_command.queue, function(a, b) return a.time > b.time end)
end

event.AddListener("Update", "interpolate_user_command", function()
	for _, client in pairs(clients.GetAll()) do
		local cmd = client:GetCurrentCommand()
		
		local data = cmd.queue[1]
				
		if data and data.time < timer.GetSystemTime() then

			for k,v in pairs(data) do
				cmd[k] = v
			end
			
			local pos, ang =  event.Call("Move", client, cmd)
			
			cmd.net_position = pos
			
			table.remove(cmd.queue, 1)
		end
	end
end)


if CLIENT then		
	client_command_length = client_command_length / 1000
	client_tick_rate = 1/client_tick_rate
	
	do
		local buffer = Buffer()
		local last_send = 0
		
		event.CreateTimer("user_command_tick", client_tick_rate, function()
			if not clients.GetLocalClient():IsValid() then return end
		
			buffer:WriteDouble(timer.GetSystemTime())
			
			local move = event.Call("CreateMove", clients.GetLocalClient(), clients.GetLocalClient():GetCurrentCommand())
			 
			for _, v in ipairs(layout) do
				buffer:WriteType(move and move[v.name] or v.default, v.type)
			end
				
			if last_send < timer.GetSystemTime() then
				packet.Send("user_command", buffer)
				buffer:Clear()
				last_send = timer.GetSystemTime() + client_command_length
			end
		end)
	end
		
	packet.AddListener("user_command", function(buffer)
		local client = clients.GetByUniqueID(buffer:ReadString())
		if client:IsValid() then
			read_buffer(client, buffer)
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

	packet.AddListener("user_command", function(client, buffer)
		read_buffer(client, buffer)
		
		local cmd = client:GetCurrentCommand()

		local buffer = Buffer()
		buffer:WriteString(client:GetUniqueID())
		
		buffer:WriteDouble(timer.GetSystemTime())
		
		for _, v in ipairs(layout) do
			buffer:WriteType(cmd.queue[1][v.name], v.type)
		end
		
		buffer:WriteVec3(cmd.net_position or Vec3(0, 0, 0))
		
		packet.Send("user_command", nil, buffer)
	end)
end 