local client_command_length = 33 -- sample length in ms
local client_tick_rate = 33 -- in ms

local server_command_length = client_command_length
local server_tick_rate = 10

local META = (...) or prototype.GetRegistered("client")

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
	v.client_name = "client_" .. v.name
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
		cmd.queue[i].time = system.GetTime() + (time - time_stamp)

		for _, v in ipairs(layout) do
			cmd.queue[i][v.name] = buffer:ReadType(v.type)
		end

		if CLIENT then
			cmd.queue[i].net_position = buffer:ReadVec3()
			cmd.queue[i].net_velocity = buffer:ReadVec3()
		end

		if buffer:TheEnd() then
			break
		end

		if i == 32 then
			warning("command too big: ", 2, client)
		end
	end

	--table.sort(client.current_command.queue, function(a, b) return a.time > b.time end)
end

local function process_usercommand(client)
	local cmd = client:GetCurrentCommand()

	local data = cmd.queue[1]

	if data and data.time < system.GetTime() then

		for k,v in pairs(data) do
			cmd[k] = v
		end

		local pos, vel =  event.Call("Move", client, cmd)

		cmd.net_position = pos
		cmd.net_velocity = vel

		table.remove(cmd.queue, 1)
	end
end

local lol = 0

event.AddListener("Update", "interpolate_user_command", function()
	local time = system.GetTime()
	if lol < time - (1/33) then
		if CLIENT and network.IsConnected() then
			process_usercommand(clients.GetLocalClient())
		end

		if SERVER then
			for _, client in pairs(clients.GetAll()) do
				process_usercommand(client)
			end
		end
		lol = time
	end
end)


if CLIENT then
	client_command_length = client_command_length / 1000
	client_tick_rate = 1/client_tick_rate

	do
		local buffer = packet.CreateBuffer()
		local last_send = 0
		local last_tick = 0

		event.AddListener("Update", "user_command_tick", function(dt)
			if not network.IsConnected() then return end

			local cmd = clients.GetLocalClient():GetCurrentCommand()
			local move = event.Call("CreateMove", clients.GetLocalClient(), cmd, dt)

			local time = system.GetElapsedTime()

			if time > last_tick then
				buffer:WriteDouble(time)

				for _, v in ipairs(layout) do
					buffer:WriteType(move and move[v.name] or v.default, v.type)
					cmd[v.client_name] = move and move[v.name] or v.default
				end

				if last_send < time then
					packet.Send("user_command", buffer)
					buffer:Clear()
					last_send = time + client_command_length
				end

				last_tick = time + client_tick_rate
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

		system.SetServerTime(time)
	end)
end

if SERVER then
	server_command_length = server_command_length / 1000
	server_tick_rate = 1/server_tick_rate

	do
		local buffer = packet.CreateBuffer()
		local last_send = 0

		event.CreateTimer("server_command_tick", server_tick_rate, function()
			buffer:WriteDouble(system.GetTime())

			if last_send < system.GetTime() then
				packet.Broadcast("server_command", buffer)
				buffer:Clear()
				last_send = system.GetTime() + server_command_length
			end
		end)
	end

	packet.AddListener("user_command", function(buffer, client)
		read_buffer(client, buffer)

		local cmd = client:GetCurrentCommand()

		local buffer = packet.CreateBuffer()
		buffer:WriteString(client:GetUniqueID())

		buffer:WriteDouble(system.GetTime())

		for _, v in ipairs(layout) do
			buffer:WriteType(cmd.queue[1][v.name], v.type)
		end

		buffer:WriteVec3(cmd.net_position or Vec3(0, 0, 0))
		buffer:WriteVec3(cmd.net_velocity or Vec3(0, 0, 0))

		packet.Send("user_command", buffer)
	end)
end

prototype.UpdateObjects(META)