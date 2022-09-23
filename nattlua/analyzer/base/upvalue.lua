local class = require("nattlua.other.class")
local shallow_copy = require("nattlua.other.shallow_copy")
local mutation_solver = require("nattlua.analyzer.mutation_solver")
local META = class.CreateTemplate("upvalue")
META:GetSet("Value")
META:GetSet("Hash")
META:GetSet("Key")
META:IsSet("Immutable")
META:GetSet("Node")
META:GetSet("Position")
META:GetSet("Shadow")
META:GetSet("Scope")
META:GetSet("Mutations")

function META:__tostring()
	return "[" .. tostring(self.key) .. ":" .. tostring(self.value) .. "]"
end

function META:SetValue(value)
	self.Value = value
	value:SetUpvalue(self)
end

do
	function META:GetMutatedValue(scope)
		self.Mutations = self.Mutations or {}
		return mutation_solver(shallow_copy(self.Mutations), scope, self)
	end

	function META:Mutate(val, scope, from_tracking)
		val:SetUpvalue(self)
		self.Mutations = self.Mutations or {}
		table.insert(self.Mutations, {scope = scope, value = val, from_tracking = from_tracking})

		if from_tracking then scope:AddTrackedObject(self) end
	end

	function META:ClearMutations()
		self.Mutations = nil
	end

	function META:HasMutations()
		return self.Mutations ~= nil
	end

	function META:ClearTrackedMutations()
		local mutations = self:GetMutations()

		for i = #mutations, 1, -1 do
			local mut = mutations[i]

			if mut.from_tracking then table.remove(mutations, i) end
		end
	end
end

local id = 0

function META.New(obj)
	local self = setmetatable({}, META)
	self:SetHash(tostring(id))
	id = id + 1
	self:SetValue(obj)
	return self
end

return META