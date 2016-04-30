local META = prototype.CreateTemplate()

local spawned_networked = {}
local queued_packets = {}


META.Name = "network"
META.Events = {"Update"}

-- these are either part the base object or the entity itself
META.Network = {
	Name = {"string", 1/10, "reliable"},
	Parent = {"entity", 1/5, "reliable"},
--	HideFromEditor = {"boolean", 1/5, "reliable"},
	GUID = {"string", 1/5, "reliable"},
}

META:GetSet("NetworkId", -1)
META:GetSet("NetworkChannel", 0)

function META:Initialize()
	self.server_synced_vars = {}
	self.server_synced_vars_stringtable = {}
	self.client_synced_vars = {}
	self.last_var = {}
	self.smooth_vars = {}
	self.last_update = {}
	self.queued_packets = {}
end

do
	function META:ServerSyncVar(component_name, key, type, rate, flags, skip_default, smooth)
		self:ServerDesyncVar(component_name, key)

		local info = {
			component = component_name,
			key = key,
			key2 = component_name .. key,
			get_name = "Get" .. key,
			set_name = "Set" .. key,
			type = type,
			rate = rate,
			id = SERVER and network.AddString(component_name .. key) or (component_name .. key),
			flags = flags,
			skip_default = skip_default,
			smooth = smooth,
		}

		table.insert(self.server_synced_vars, info)

		self.server_synced_vars_stringtable[component_name..key] = info

		if SERVER then
			if info.flags ~= "unreliable" then
				if info.component == "unknown" then
					info.old_set_func = info.old_set_func or self:GetEntity()[info.set_name]

					self:GetEntity()[info.set_name] = function(...)
						local ret = info.old_set_func(...)
						self:UpdateVariableFromSyncInfo(info, nil, true)
						return ret
					end
				else
					local component = self:GetEntity():GetComponent(component_name)

					info.old_set_func = info.old_set_func or component[info.set_name]
					component[info.set_name] = function(...)
						local ret = info.old_set_func(...)
						self:UpdateVariableFromSyncInfo(info, nil, true)
						return ret
					end
				end
			end
		end
	end

	function META:ServerDesyncVar(component_name, key)
		if not key then
			key = component_name
			component_name = nil
		end

		local i, info

		if component_name and key then
			for i_, info_ in ipairs(self.server_synced_vars) do
				if info_.key == key and info_.component == component_name then
					i, info = i_, info_
					break
				end
			end
		elseif key then
			for i_, info_ in ipairs(self.server_synced_vars) do
				if info_.key == key then
					i, info = i_, info_
					break
				end
			end
		end

		if i then
			table.remove(self.server_synced_vars, i)

			self.server_synced_vars_stringtable[info.component..key] = nil

			if info.old_set_func then
				if info.component == "unknown" then
					info.old_set_func = info.old_set_func or self:GetEntity()[info.set_name]
					self:GetEntity()[info.set_name] = info.old_set_func
				else
					local component = self:GetEntity():GetComponent(component_name)
					info.old_set_func = info.old_set_func or component[info.set_name]
					component[info.set_name] = info.old_set_func
				end
			end
		end
	end

	function META:ServerFilterSync(filter, component_name, key)
		if not key then
			key = component_name
			component_name = nil
		end

		if component_name and key then
			for _, info in ipairs(self.server_synced_vars) do
				if info.key == key and info.component == component_name then
					info.filter = filter
				end
			end
		elseif key then
			for _, info in ipairs(self.server_synced_vars) do
				if info.key == key then
					info.filter = filter
				end
			end
		end
	end

	function META:SetupSyncVariables()
		local done = {}

		for _, component in ipairs(self:GetEntityComponents()) do
			if component.Network then
				for key, info in pairs(component.Network) do
					if not done[key] then
						local name = component.Name
						if name == "network" then name = "unknown" end -- see top of script
						self:ServerSyncVar(name, key, unpack(info))
						done[key] = true
					end
				end
			end
		end
	end
end

function META:OnUpdate(dt)
	if not network.IsConnected() then return end

	self:UpdateVars()

	if self.smooth_vars then
		for info, var in pairs(self.smooth_vars) do
			if type(var) == "number" then
				info.smooth_var = math.lerp(dt * info.smooth, info.smooth_var, var)
			else
				info.smooth_var:Lerp(dt * info.smooth, var)
			end

			if info.component == "unknown" then
				local ent = self:GetEntity()
				ent[info.set_name](ent, info.smooth_var)
			else
				local component = self:GetComponent(info.component)
				component[info.set_name](component, info.smooth_var)
			end
		end
	end
end

do -- synchronization server > client
	local function handle_packet(buffer)
		local what = buffer:ReadNetString()
		local id = buffer:ReadShort()
		local self = spawned_networked[id] or NULL

		if what == "entity_networked_spawn" then
			local config =  buffer:ReadString()

			local ent = entities.CreateEntity(config)
			ent:SetNetworkId(id)

			local self = ent:GetComponent("network")
			self:SetupSyncVariables()

			spawned_networked[id] = self

			if self.debug then logf("entity %s with id %s spawned from server\n", config, id) end
		elseif self:IsValid() then
			if what == "entity_networked_remove" then
				self:GetEntity():Remove()
			elseif self:IsValid() then
				local info = self.server_synced_vars_stringtable[what]

				if info then
					local var = buffer:ReadType(info.type)

					if info.smooth then
						if type(var) == "number" then
							info.smooth_var = info.smooth_var or var
						elseif var.GetLerped then
							info.smooth_var = info.smooth_var or var:Copy()
						end

						self.smooth_vars[info] = var
					else
						if info.component == "unknown" then
							local ent = self:GetEntity()
							ent[info.set_name](ent, var)
						else
							local component = self:GetComponent(info.component)
							component[info.set_name](component, var)

						end
					end
					if self.debug then logf("%s - %s: received %s\n", self, info.component, var) end
				elseif info.flags == "reliable" then
					buffer:SetPosition(1)
					table.insert(self.queued_packets, buffer)
				end
			end
		else
			buffer:SetPosition(1)
			table.insert(queued_packets, buffer)
			--logf("received sync packet %s but entity[%s] is NULL\n", typ, id)
		end
	end

	packet.AddListener("ecs_network", handle_packet)

	function META:UpdateVariableFromSyncInfo(info, client, force_update)
		local var

		if info.component == "unknown" then
			var = self:GetEntity()[info.get_name](self:GetEntity())
		else
			local component = self:GetComponent(info.component)
			local func = component[info.get_name]
			if func then
				var = func(component)
			else
				llog("%s: unable to find function %s", component, info.get_name)
			end

			if info.skip_default and var == getmetatable(component)[info.key] then return end
		end


		if force_update or var ~= self.last_var[info.key2] then
			local buffer = packet.CreateBuffer()

			buffer:WriteShort(info.id)
			buffer:WriteShort(self.NetworkId)
			buffer:WriteType(var, info.type)

			if self.debug then logf("%s - %s: sending %s = %s to %s\n", self, info.component, info.key, utility.FormatFileSize(buffer:GetSize()), client) end

			packet.Send("ecs_network", buffer, client or info.filter, force_update and "reliable" or info.flags, self.NetworkChannel)

			self.last_var[info.key2] = var
		end

		if info.set_name:find("Position") then
			--print(info.key2)
		end


		self.last_update[info.key2] = system.GetElapsedTime() + info.rate
	end

	function META:UpdateVars(client, force_update)

		for _, info in ipairs(SERVER and self.server_synced_vars or CLIENT and self.client_synced_vars) do
			if force_update or not self.last_update[info.key2] or self.last_update[info.key2] < system.GetElapsedTime() then
				self:UpdateVariableFromSyncInfo(info, client, force_update)
			end
		end


		if CLIENT then
			if self.queued_packets[1] then
				local buffer = table.remove(self.queued_packets)

				if buffer then
					handle_packet(buffer)
				end
			end

			if queued_packets[1] then
				local buffer = table.remove(queued_packets)

				if buffer then
					handle_packet(buffer)
				end
			end
		end
	end

	if SERVER then
		table.insert(META.Events, "ClientEntered")

		function META:OnClientEntered(client)
			self:SpawnEntityOnClient(client, self.NetworkId, self:GetEntity().config)

			-- force send all packets once to this new client as reliable
			-- so all the entities' positions will update properly
			self:UpdateVars(client, true)

			self:SendCallOnClientToClient(client)
		end
	end
end

if SERVER then
	function META:SpawnEntityOnClient(client, id, config)
		local buffer = packet.CreateBuffer()

		buffer:WriteNetString("entity_networked_spawn")
		buffer:WriteShort(id)
		buffer:WriteString(config)

		--logf("spawning entity %s with id %s for %s\n", config, id, client)

		packet.Send("ecs_network", buffer, client, "reliable")
	end

	function META:RemoveEntityOnClient(client, id)
		local buffer = packet.CreateBuffer()

		buffer:WriteNetString("entity_networked_remove")
		buffer:WriteShort(id)

		packet.Send("ecs_network", buffer, client, "reliable")
	end

	local id = 1

	function META:OnAdd(ent)
		self.NetworkId = id

		spawned_networked[self.NetworkId] = self

		self:SpawnEntityOnClient(nil, self.NetworkId, ent.config)

		id = id + 1
	end

	function META:OnRemove()
		spawned_networked[self.NetworkId] = nil

		self:RemoveEntityOnClient(nil, self.NetworkId)
	end

	function META:OnEntityAddComponent()
		self:SetupSyncVariables()
	end
end

packet.ExtendBuffer(
	"Entity",
	function(buffer, ent)
		if ent:IsValid() and ent.GetNetworkId then
			buffer:WriteLong(ent:GetNetworkId())
		end
	end,
	function(buffer)
		local component = spawned_networked[buffer:ReadLong()] or NULL
		if component:IsValid() then
			return component:GetEntity()
		end
		return NULL
	end
)

do -- call on client
	if CLIENT then
		message.AddListener("ecs_network_call_on_client", function(id, component, name, ...)
			local self = spawned_networked[id] or NULL

			if self:IsValid() then
				if component == "unknown" then
					local ent = self:GetEntity()
					local func = ent[name]
					if func then
						func(ent, ...)
					else
						llog("call on client: function %s does not exist in entity", name)
						print(name, ...)
					end
				else
					local obj = self:GetComponent(component)
					if obj:IsValid() then
						local func = obj[name]

						if func then
							func(obj, ...)
						else
							llog("call on client: function %s does not exist in component %s", name, component)
							print(name, ...)
						end
					else
						llog("call on client: component %s does not exist in entity (%s)", component, id)
						print(name, ...)
					end
				end
			else
				llog("call on client: entity (%s) is NULL", id)
				print(name, ...)
			end
		end)
	end

	if SERVER then
		META.call_on_client_persist = {}

		function META:SendCallOnClientToClient()
			for _, args in ipairs(self.call_on_client_persist) do
				self:CallOnClient(client, unpack(args))
			end
		end

		function META:CallOnClient(filter, component, name, ...)
			message.Send("ecs_network_call_on_client", filter, self.NetworkId, component, name, ...)
		end

		function META:CallOnClients(component, name, ...)
			message.Broadcast("ecs_network_call_on_client", self.NetworkId, component, name, ...)
		end

		function META:CallOnClientsPersist(component, name, ...)
			table.insert(self.call_on_client_persist, {component, name, ...})
			return self:CallOnClients(component, name, ...)
		end
	end
end

META:RegisterComponent()