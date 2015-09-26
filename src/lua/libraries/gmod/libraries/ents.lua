local gmod = ... or _G.gmod

local ents = gmod.env.ents

function ents.Create(class)
	local ent = entities.CreateEntity("visual")

	local self = gmod.WrapObject(ent, "Entity")

	self.ClassName = class
	self.BaseClass = gmod.env.scripted_ents.Get(class)

	table.insert(ents.created, self)

	return self
end

function ents.GetAll()
	local out = {}
	local i = 1

	for obj, ent in pairs(gmod.objects.Entity) do
		table.insert(out, ent)
	end

	return out
end

function ents.FindByClass(name)
	local out = {}

	for obj, ent in pairs(gmod.objects.Entity) do
		if ent.ClassName:find(name) then
			table.insert(out, ent)
		end
	end

	return out
end