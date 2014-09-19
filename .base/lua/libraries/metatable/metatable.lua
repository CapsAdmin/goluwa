local metatable = _G.metatable or {}

metatable.registered = metatable.registered or {}

do
	local function checkfield(tbl, key, def)
		tbl[key] = tbl[key] or def
		
		if not tbl[key] then
			error(string.format("The type field %q was not found!", key), 3)
		end

		return tbl[key]
	end

	function metatable.Register(meta, super_type, sub_type)
		local super_type = checkfield(meta, "Type", super_type)
		sub_type = sub_type or super_type
		local sub_type = checkfield(meta, "ClassName", sub_type)
				
		super_type = super_type:lower()
		sub_type = sub_type:lower()
		
		metatable.registered[super_type] = metatable.registered[super_type] or {}
		metatable.registered[super_type][sub_type] = meta
		
		metatable.UpdateObjects(meta)
		
		return super_type, sub_type
	end
end

function metatable.GetRegistered(super_type, sub_type)
	sub_type = sub_type or super_type
	
	super_type = super_type:lower()
	sub_type = sub_type:lower()
		
	return metatable.registered[super_type][sub_type]
end

function metatable.GetRegisteredSubTypes(super_type)
	super_type = super_type:lower()

	return metatable.registered[super_type]
end


function metatable.GetAllRegistered()
	local out = {}
	
	for super_type, sub_types in pairs(metatable.registered) do
		for sub_type, meta in pairs(sub_types) do
			table.insert(out, meta)
		end
	end
	
	return out
end

function metatable.Delegate(meta, key, func_name)
	meta[func_name] = function(self, ...)
		return self[key][func_name](self[key], ...)
	end
end

include("base_template.lua", metatable)
include("get_is_set.lua", metatable)
include("templates/*", metatable)
include("null.lua", metatable)
include("class.lua", metatable)
include("ecs_entity.lua", metatable)
include("base_ecs_component.lua", metatable)

return metatable