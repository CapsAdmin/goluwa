local gmod = ... or _G.gmod

local ents = gmod.env.ents

ents.created = utility.CreateWeakTable()

local ENT = gmod.env.FindMetaTable("Entity")
ENT.__index = ENT

function ents.Create(class)
	local ent = entities.CreateEntity("visual")
	
	return setmetatable({__glw_ent = ent}, ENT)
end

function ents.GetAll()
	return ents.created
end
