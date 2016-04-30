do return end
local META = prototype.CreateTemplate()

META.Name = "physics_container"

local PHYSICS = prototype.GetRegistered("component", "physics")

if not PHYSICS then return end

for k,v in pairs(PHYSICS) do

	local info = PHYSICS.prototype_variables[k:sub(4)]
	if info then
		--prototype.GetSet()
		table.print(info)
	elseif type(v) == "function" then
		META[k] = function(self, ...)
			for i, body in ipairs(self.bodies) do
				v(body[k], ...)
			end
		end
	end
end



function META:Initialize()
	self.bodies = {}
end

function META:OnAdd(ent)

end

function META:OnRemove(ent)

end

META:RegisterComponent()