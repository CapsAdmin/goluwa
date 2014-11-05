local prototype = _G.prototype or {}

prototype.registered = prototype.registered or {}
prototype.prepared_metatables = prototype.prepared_metatables or {}

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
		
		prototype.RebuildMetatables()
		
		prototype.UpdateObjects(meta)
		
		return super_type, sub_type
	end
end

function prototype.RebuildMetatables()
	for super_type, sub_types in pairs(prototype.registered) do
		for sub_type, meta in pairs(sub_types) do
			
			local copy = {}
			
			-- first add all the base functions from the base object			
			for k, v in pairs(prototype.base_metatable) do
				copy[k] = v
			end
			
			-- if this metatable has a type base derive from it first
			if meta.TypeBase then 
				for k, v in pairs(sub_types[meta.TypeBase]) do
					copy[k] = v
				end
			end
			
			-- then go through the list of bases and derive from them in reversed order
			local base_list = {}
			
			if meta.Base then 		
				table.insert(base_list, meta.Base) 
				
				local base = meta
				
				for i = 1, 50 do
					base = sub_types[base.Base]
					if not base or not base.Base then break end 
					table.insert(base_list, 1, base.Base)
				end
				
				for k, v in ipairs(base_list) do
					local base = sub_types[v]
					
					-- the base might not be registered yet
					-- however this will be run again once it actually is
					if base then
						for k, v in pairs(base) do
							copy[k] = v
						end
					end
				end
			end
			
			-- finally the actual metatable
			for k, v in pairs(meta) do
				copy[k] = v
			end
			
			copy.__index = copy
			
			copy.BaseClass = sub_types[base_list[#base_list] or meta.TypeBase]
			
			prototype.prepared_metatables[super_type] = prototype.prepared_metatables[super_type] or {}				
			prototype.prepared_metatables[super_type][sub_type] = copy
		end
	end
end

function prototype.GetRegistered(super_type, sub_type)
	sub_type = sub_type or super_type
	
	super_type = super_type:lower()
	sub_type = sub_type:lower()
			
	if prototype.prepared_metatables[super_type] and prototype.prepared_metatables[super_type][sub_type] then
		return prototype.prepared_metatables[super_type][sub_type]
	end
	
	return prototype.registered[super_type] and prototype.registered[super_type][sub_type]
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

function prototype.Delegate(meta, key, func_name, func_name2)
	if not func_name2 then func_name2 = func_name end
	
	meta[func_name] = function(self, ...)
		return self[key][func_name2](self[key], ...)
	end
end

function prototype.GetSetDelegate(meta, func_name, def, key)
	local get = "Get" .. func_name
	local set = "Set" .. func_name
	prototype.GetSet(meta, func_name, def)
	prototype.Delegate(meta, key, get)
	prototype.Delegate(meta, key, set)
end

include("base_template.lua", prototype)
include("get_is_set.lua", prototype)
include("templates/*", prototype)
include("null.lua", prototype)
include("ecs_entity.lua", prototype)
include("base_ecs_component.lua", prototype)

return prototype