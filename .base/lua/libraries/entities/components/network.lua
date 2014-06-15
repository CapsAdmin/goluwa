local entities = (...) or _G.entities
local COMPONENT = {}

COMPONENT.Name = "networked"
COMPONENT.Require = {"transform"}
--	COMPONENT.Events = {"Update"}

metatable.GetSet(COMPONENT, "NetworkId", -1)

local spawned = {}

local id = 0

local SPAWN = 1
local REMOVE = 2 

packet.AddListener("ecs_network", function(buffer)
	local typ = buffer:ReadByte()
	local id = buffer:ReadUnsignedShort()
	local config =  buffer:ReadString()
										
	if typ == SPAWN then
		local ent = entities.CreateEntity(config)
		ent:SetNetworkId(id)
		spawned[id] = ent
	elseif typ == REMOVE then
		spawned[id]:Remove() 
	end
end)

function COMPONENT:OnAdd(ent)		
	if SERVER then
		self.NetworkId = id
		
		id = id + 1
		
		local buffer = Buffer()
		
		buffer:WriteByte(SPAWN)
		buffer:WriteUnsignedShort(self.NetworkId)
		buffer:WriteString(ent.config)
		
		packet.Broadcast("ecs_network", buffer)
	end
end

function COMPONENT:OnRemove(ent)
	if SERVER then	
		local buffer = Buffer()
		
		buffer:WriteByte(REMOVE) 
		buffer:WriteUnsignedShort(self.NetworkId)
		
		packet.Broadcast("ecs_network", buffer)
	end
end

entities.RegisterComponent(COMPONENT)