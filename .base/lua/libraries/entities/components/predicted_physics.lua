local entities = (...) or _G.entities

local COMPONENT = {}

COMPONENT.Name = "mesh"
COMPONENT.Require = {"physics"}
COMPONENT.Events = {"Update"}

metatable.GetSet(COMPONENT, "Client", NULL)

function COMPONENT:OnUpdate()	

end