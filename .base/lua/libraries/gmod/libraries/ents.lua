local gmod = ... or _G.gmod

local ents = gmod.env.ents

ents.created = {}

local ENT = gmod.env.FindMetaTable("Entity")

function ENT:__index(key)
	if ENT[key] then
		return ENT[key]
	end
	
	if self.BaseClass[key] then
		return self.BaseClass[key]
	end
end

function ENT:SetPos(vec)
	self.__glw_ent:SetPosition(vec.v)
end

function ENT:GetPos(vec)
	return gmod.env.Vector(self.__glw_ent:GetPosition():Unpack())
end

function ENT:Remove()
	self.__glw_ent:Remove()
	table.removevalue(ents.created, self)
end

function ents.Create(class)
	local ent = entities.CreateEntity("visual")
	
	local self = setmetatable({__glw_ent = ent}, ENT)
	
	self.ClassName = class
	self.BaseClass = gmod.env.scripted_ents.Get(class)
	
	table.insert(ents.created, self)
	
	return self
end

function ents.GetAll()
	local out = {}
	
	for i, ent in ipairs(ents.created)
		out[i] = ent
	end
	
	return out
end

function ents.FindByClass(name)
	local out = {}
	
	for _,v in ipairs(ents.created) do
		if v.ClassName:find(name) then
			table.insert(out, v)
		end
	end
	
	return out
end