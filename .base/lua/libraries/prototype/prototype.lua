local prototype = _G.prototype or {}

prototype.registered = prototype.registered or {}

do
	local function checkfield(tbl, key, def)
		tbl[key] = tbl[key] or def
		
		if not tbl[key] then
			error(string.format("The type field %q was not found!", key), 3)
		end

		return tbl[key]
	end

	function prototype.Register(meta, super_type, sub_type)
		local super_type = checkfield(meta, "Type", super_type)
		sub_type = sub_type or super_type
		local sub_type = checkfield(meta, "ClassName", sub_type)
				
		super_type = super_type:lower()
		sub_type = sub_type:lower()
		
		prototype.registered[super_type] = prototype.registered[super_type] or {}
		prototype.registered[super_type][sub_type] = meta
		
		prototype.UpdateObjects(meta)
		
		return super_type, sub_type
	end
end

function prototype.GetRegistered(super_type, sub_type)
	sub_type = sub_type or super_type
	
	super_type = super_type:lower()
	sub_type = sub_type:lower()
		
	return prototype.registered[super_type][sub_type]
end

function prototype.GetRegisteredSubTypes(super_type)
	super_type = super_type:lower()

	return prototype.registered[super_type]
end


function prototype.GetAllRegistered()
	local out = {}
	
	for super_type, sub_types in pairs(prototype.registered) do
		for sub_type, meta in pairs(sub_types) do
			table.insert(out, meta)
		end
	end
	
	return out
end

function prototype.Delegate(meta, key, func_name)
	meta[func_name] = function(self, ...)
		return self[key][func_name](self[key], ...)
	end
end

include("base_template.lua", prototype)
include("get_is_set.lua", prototype)
include("templates/*", prototype)
include("null.lua", prototype)
include("class.lua", prototype)
include("ecs_entity.lua", prototype)
include("base_ecs_component.lua", prototype)

return prototype