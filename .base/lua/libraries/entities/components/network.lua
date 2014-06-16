local entities = (...) or _G.entities
local COMPONENT = {}

local _debug = false

COMPONENT.Name = "networked"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Update"}

metatable.GetSet(COMPONENT, "NetworkId", -1)

local server_synced_vars = {}
local client_synced_vars = {}

local ACCEPT_ID_BASE = 3
local SYNC_ID_BASE = 2

local function SERVER_SYNC(component, key, type, rate)
	table.insert(server_synced_vars, {
		component = component, 
		key = key,
		get_name = "Get" .. key,
		set_name = "Set" .. key,
		type = type,
		rate = rate,
		id = SYNC_ID_BASE,
	})
	
	SYNC_ID_BASE = SYNC_ID_BASE + 1
end

local function ACCEPT_VAR(component, type)
	table.insert(accepted_vars, {
		component = component, 
		key = key,
		type = type,
		id = ACCEPT_ID_BASE,
	})
	
	ACCEPT_ID_BASE = ACCEPT_ID_BASE + 1
end

-- unknown will make it get it from the entity
-- this might be the transform or physics component
SERVER_SYNC("unknown", "Position", "vec3", 1/30)
SERVER_SYNC("unknown", "Angles", "ang3", 1/30)

SERVER_SYNC("transform", "Scale", "vec3", 1/15)
SERVER_SYNC("transform", "Size", "float", 1/15)

SERVER_SYNC("mesh", "ModelPath", "string", 1/5)
SERVER_SYNC("mesh", "Cull", "boolean", 1/5)

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

local id = 0

local SPAWN = 1
local REMOVE = 2

COMPONENT.last = {}
COMPONENT.last_update = {}

local vars = SERVER and server_synced_vars or CLIENT and client_synced_vars

function COMPONENT:UpdateVars(client, force_update)
	for i, info in ipairs(vars) do
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
				buffer:WriteByte(i + SYNC_ID_BASE)
				buffer:WriteShort(self.NetworkId)
				buffer:WriteType(var, info.type)
				
				if _debug then logf("%s: sending %s to %s\n", self, utilities.FormatFileSize(buffer:GetSize()), client) end
				
				packet.Send("ecs_network", buffer, client, force_update and "reliable" or nil)
				
				self.last[info.key] = var
			end

			self.last_update[info.key] = timer.GetSystemTime() + info.rate
		end
	end
end

packet.AddListener("ecs_network", function(buffer, client)
	local typ = buffer:ReadByte()
	
	if typ >= 3 then
		local id = buffer:ReadShort()
		local ent = spawned[id]
		
		if ent and ent:IsValid() then
			local info = server_synced_vars[typ - SYNC_ID_BASE]
			
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
				logn("received unknown sync packet ", typ)
				if SERVER then
					client:Kick("malformed packets")
				end
			end
		else
			logf("received sync packet %i but entity[%i] is NULL\n", typ, id)
			if SERVER then
				--client:Kick("malformed packets")
			end
		end
	else
		local id = buffer:ReadUnsignedShort()
		local config =  buffer:ReadString()

		if typ == SPAWN then
			local ent = entities.CreateEntity(config)
			ent:SetNetworkId(id)
			spawned[id] = ent
			--logf("entity %s with id %s spawned from server\n", config, id)
		elseif typ == REMOVE then
			spawned[id]:Remove() 
		end
	end
end)

if SERVER then
	function COMPONENT:SpawnEntity(id, config, client)
		local buffer = Buffer()
		
		buffer:WriteByte(SPAWN)
		buffer:WriteUnsignedShort(id)
		buffer:WriteString(config)
		
		--logf("spawning entity %s with id %s for %s\n", config, id, client)
		
		packet.Send("ecs_network", buffer, client, "reliable")
	end
	
	function COMPONENT:RemoveEntity(id, client)
		local buffer = Buffer()
		
		buffer:WriteByte(REMOVE) 
		buffer:WriteUnsignedShort(id)
		
		packet.Broadcast("ecs_network", buffer, client, "reliable")
	end

	function COMPONENT:OnAdd(ent)
		self.NetworkId = id
		
		spawned[id] = ent
		
		id = id + 1
		
		self:SpawnEntity(self.NetworkId, ent.config)
	end

	function COMPONENT:OnRemove(ent)
		
		spawned[self.NetworkId] = nil
	
		self:RemoveEntity(self.NetworkId)
	end
end

entities.RegisterComponent(COMPONENT) 