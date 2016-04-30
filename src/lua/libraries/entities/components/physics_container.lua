do return end
local COMPONENT = prototype.CreateTemplate()

COMPONENT.Name = "physics_container"

local PHYSICS = prototype.GetRegistered("component", "physics")

if not PHYSICS then return end

for k,v in pairs(PHYSICS) do

	local info = PHYSICS.prototype_variables[k:sub(4)]
	if info then
		--prototype.GetSet()
		table.print(info)
	elseif type(v) == "function" then
		COMPONENT[k] = function(self, ...)
			for i, body in ipairs(self.bodies) do
				v(body[k], ...)
			end
		end
	end
end



function COMPONENT:Initialize()
	self.bodies = {}
end

function COMPONENT:OnAdd(ent)

end

function COMPONENT:OnRemove(ent)

end

COMPONENT:RegisterComponent()