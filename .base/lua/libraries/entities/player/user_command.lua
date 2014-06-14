local client_command_length = 100 -- sample length in ms
local client_tick_rate = 33 -- in ms

local server_command_length = client_command_length
local server_tick_rate = 10

local META = (...) or metatable.Get("player")

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

local function read_buffer(ply, buffer)
	local cmd = ply:GetCurrentCommand() -- get or create the cmd table
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
		
		if buffer:TheEnd() then 
			break 
		end
		
		if i == 32 then
			logn("command too big: ", ply)
		end
	end
		
	--table.sort(ply.current_command.queue, function(a, b) return a.time > b.time end)
end

event.AddListener("Update", "interpolate_user_command", function()
	for _, ply in pairs(players.GetAll()) do
		local cmd = ply:GetCurrentCommand()
		
		local data = cmd.queue[1]
				
		if data and data.time < timer.GetSystemTime() then

			for k,v in pairs(data) do
				cmd[k] = v
			end
			
			event.Call("Move", ply, cmd)
			
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
			if not players.GetLocalPlayer():IsValid() then return end
		
			buffer:WriteDouble(timer.GetSystemTime())
			
			local move = event.Call("CreateMove", players.GetLocalPlayer(), players.GetLocalPlayer():GetCurrentCommand())
			 
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