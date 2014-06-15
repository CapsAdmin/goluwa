local entities = (...) or _G.entities
local COMPONENT = {}

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

SERVER_SYNC("transform", "Position", "vec3", 1/30)
SERVER_SYNC("transform", "Angles", "ang3", 1/30)

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
		for _, ent in pairs(spawned) do
			self:SpawnEntity(ent.NetworkId, client)
		end
		self:UpdateVars(client, true)
	end
end

local id = 0

local SPAWN = 1
local REMOVE = 2

COMPONENT.last = {}

local vars = SERVER and server_synced_vars or CLIENT and client_synced_vars

function COMPONENT:UpdateVars(client, force_update)
	for i, info in ipairs(vars) do
		if not info.rate or wait(info.rate) then
			local component = self:GetComponent(info.component)
			local var = component[info.get_name](component)
			
			if force_update or var ~= self.last[info.key] then
				local buffer = Buffer()
				buffer:WriteByte(i + SYNC_ID_BASE)
				buffer:WriteShort(self.NetworkId)
				buffer:WriteType(var, info.type)
				
				packet.Send("ecs_network", buffer, client)
				
				self.last[info.key] = var
			end	
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
				local component = ent:GetComponent(info.component)
				component[info.set_name](component, var)
			else
				logn("received unknown sync packet ", typ)
				if SERVER then
					client:Kick("malformed packets")
				end
			end
		else
			logf("received sync packet %i but entity[%i] is NULL\n", typ, id)
			if SERVER then
				client:Kick("malformed packets")
			end
		end
	else
		local id = buffer:ReadUnsignedShort()
		local config =  buffer:ReadString()

		if typ == SPAWN then
			local ent = entities.CreateEntity(config)
			ent:SetNetworkId(id)
			spawned[id] = ent
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
		
		packet.Send("ecs_network", buffer, client)
	end
	
	function COMPONENT:RemoveEntity(id, client)
		local buffer = Buffer()
		
		buffer:WriteByte(REMOVE) 
		buffer:WriteUnsignedShort(id)
		
		packet.Broadcast("ecs_network", buffer, client)
	end

	function COMPONENT:OnAdd(ent)
		self.NetworkId = id
		
		id = id + 1
		
		self:SpawnEntity(self.NetworkId, ent.config)
	end

	function COMPONENT:OnRemove(ent)
		self:RemoveEntity(self.NetworkId)
	end
end

entities.RegisterComponent(COMPONENT) 