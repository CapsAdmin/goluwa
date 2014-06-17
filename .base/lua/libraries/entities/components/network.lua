local entities = (...) or _G.entities
local COMPONENT = {}

local _debug = false

COMPONENT.Name = "networked"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Update", "RigidBodyInitialized"}

metatable.GetSet(COMPONENT, "NetworkId", -1)

local client_synced_vars = {}

do
	COMPONENT.server_synced_vars = {}
	COMPONENT.server_synced_vars_stringtable = {}

	function COMPONENT:ServerSyncVar(component, key, type, rate, flags)
		self:ServerDesyncVar(component, key)
		
		local info = {
			component = component, 
			key = key,
			get_name = "Get" .. key,
			set_name = "Set" .. key,
			type = type,
			rate = rate,
			id = SERVER and network.AddString(component .. key) or (component .. key),
			flags = flags,
		}
		
		table.insert(self.server_synced_vars, info)
		
		self.server_synced_vars_stringtable[component..key] = info
	end

	function COMPONENT:ServerDesyncVar(component, key)
		for k, v in ipairs(self.server_synced_vars) do
			if v.component == component and v.key == key then
				table.remove(self.server_synced_vars, k)
				self.server_synced_vars_stringtable[component..key] = nil
				break
			end
		end
	end
end

function COMPONENT:OnEvent(component, name, event, func_name)
	if name == "physics" and event == "physics_initialized" then
		
	end
end

function COMPONENT:OnUpdate()
	self:UpdateVars()
end

local spawned = {}

if SERVER then
	table.insert(COMPONENT.Events, "ClientEntered")
	
	function COMPONENT:OnClientEntered(client)
		self:SpawnEntity(self.NetworkId, self:GetEntity().config, client)
		self:UpdateVars(client, true)
	end
end

COMPONENT.last = {}
COMPONENT.last_update = {}
COMPONENT.unhandled_sync_packets = {}

local function handle_packet(buffer)
	local typ = network.IDToString(buffer:ReadShort())
	local id = buffer:ReadShort()
	local ent = spawned[id] or NULL
	
	if ent:IsValid() then	
		local self = ent:GetComponent("networked")
		local info = self.server_synced_vars_stringtable[typ]
				
		if info then
			local var = buffer:ReadType(info.type)
			
			if info.component == "unknown" then
				ent[info.set_name](ent, var)
			else
				local component = ent:GetComponent(info.component)
				component[info.set_name](component, var)
			end
			if _debug then logf("%s: received %s\n", self, var) end
		else				
			table.insert(self.unhandled_sync_packets, buffer)
			logn("received unknown sync packet ", typ)
		end
	elseif typ == "entity_networked_spawn" then
		local config =  buffer:ReadString()

		local ent = entities.CreateEntity(config)
		local self = ent:GetComponent("networked")

		self:SetupSyncVariables()
		
		ent:SetNetworkId(id)
		spawned[id] = ent
		logf("entity %s with id %s spawned from server\n", config, id)
	elseif typ == "entity_networked_remove" then
		ent:Remove() 
	else
		---table.insert(self.unhandled_sync_packets, buffer)
		logf("received sync packet %s but entity[%s] is NULL\n", typ, id)
	end
end



function COMPONENT:UpdateVars(client, force_update)
	if SERVER then
		for i, info in ipairs(self.server_synced_vars) do
			if force_update or not self.last_update[info.key] or self.last_update[info.key] < timer.GetSystemTime() then
				
				local var
				
				if info.component == "unknown" then
					var = self:GetEntity()[info.get_name](self:GetEntity())
				else
					local component = self:GetComponent(info.component)
					var = component[info.get_name](component)
				end
				
				if force_update or var ~= self.last[info.key] then
					local buffer = Buffer()
					
					buffer:WriteShort(info.id)
					buffer:WriteShort(self.NetworkId)
					buffer:WriteType(var, info.type)
					
					if _debug then logf("%s: sending %s to %s\n", self, utilities.FormatFileSize(buffer:GetSize()), client) end
					
					packet.Send("ecs_network", buffer, client, force_update and "reliable" or info.flags)
					
					self.last[info.key] = var
				end

				self.last_update[info.key] = timer.GetSystemTime() + info.rate
			end
		end
	end
	
	if CLIENT then
		local buffer = table.remove(self.unhandled_sync_packets)
		if buffer then
			handle_packet(buffer)
		end
	end
end

if CLIENT then
	packet.AddListener("ecs_network", handle_packet)
end

function COMPONENT:SetupSyncVariables()
	local done = {}
	
	for i, component in npairs(self:GetEntityComponents()) do
		if component.Network then
			for key, info in pairs(component.Network) do
				if not done[key] then
					self:ServerSyncVar(component.Name, key, unpack(info))
					done[key] = true
				end
			end
		end
	end
end

if SERVER then
	function COMPONENT:SpawnEntity(id, config, client)
		local buffer = Buffer()
		
		buffer:WriteShort(network.AddString("entity_networked_spawn"))
		buffer:WriteShort(id)
		buffer:WriteString(config)
		
		--logf("spawning entity %s with id %s for %s\n", config, id, client)
		
		packet.Send("ecs_network", buffer, client, "reliable")
	end
	
	function COMPONENT:RemoveEntity(id, client)
		local buffer = Buffer()
		
		buffer:WriteShort(network.AddString("entity_networked_remove"))
		buffer:WriteShort(id)
		
		packet.Broadcast("ecs_network", buffer, client, "reliable")
	end
	
	local id = 0
	
	function COMPONENT:OnAdd(ent)
		self.NetworkId = id
		
		spawned[id] = ent
		
		id = id + 1
		
		self:SpawnEntity(self.NetworkId, ent.config)
		
		self:SetupSyncVariables()
	end
	
	function COMPONENT:OnRemove(ent)
		
		spawned[self.NetworkId] = nil
	
		self:RemoveEntity(self.NetworkId)
	end
end

entities.RegisterComponent(COMPONENT) 