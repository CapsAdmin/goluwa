local prototype = _G.prototype or {}

prototype.registered = prototype.registered or {}
prototype.prepared_metatables = prototype.prepared_metatables or {}

function prototype.CreateTemplate(super_type, sub_type)
	local template = type(super_type) == "table" and super_type or {}
	
	if type(super_type) == "string" then
		template.Type = super_type
		template.ClassName = sub_type or super_type
	end
	
	return template
end

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
		
		if RELOAD then
			prototype.UpdateObjects(meta)
		end
		
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

function prototype.CreateObject(meta, override, skip_gc_callback)
	override = override or {}
	
	if type(meta) == "string" then
		meta = prototype.GetRegistered(meta)
	end
	
	-- this has to be done in order to ensure we have the prepared metatable with bases
	meta = prototype.GetRegistered(meta.Type, meta.ClassName) or meta
		
	local self = setmetatable(override, table.copy(meta))
		
	if not skip_gc_callback then
		utility.SetGCCallback(self, function(self)
			if self:IsValid() then 
				self:Remove() 
			end
			prototype.created_objects[self] = nil
		end)
	end
	
	--print(meta, "!!!")
	
	self:SetDebugTrace(debug.trace(true))
	
	prototype.created_objects = prototype.created_objects or utility.CreateWeakTable()
	prototype.created_objects[self] = self
	
	self:SetCreationTime(os.clock())
	
	return self
end

function prototype.CreateDerivedObject(super_type, sub_type, override, skip_gc_callback)
    local meta = prototype.GetRegistered(super_type, sub_type)
	
    if not meta then
        logf("tried to create unknown %s %q!\n", super_type or "no type", sub_type or "no class")
        return
    end

	return prototype.CreateObject(meta, override, skip_gc_callback)
end

function prototype.SafeRemove(obj)
	if hasindex(obj) and obj.IsValid and obj.Remove and obj:IsValid() then
		obj:Remove()
	end
end

function prototype.GetCreated(sorted, super_type, sub_type)
	if sorted then
		local out = {}
		for k,v in pairs(prototype.created_objects) do
			if (not super_type or v.Type == super_type) and (not sub_type or v.ClassName == sub_type) then
				table.insert(out, v)
			end
		end
		table.sort(out, function(a, b) return a.creation_time < b.creation_time end)
		return out
	end
	return prototype.created_objects or {}
end

function prototype.UpdateObjects(meta)	
	if type(meta) == "string" then
		meta = prototype.GetRegistered(meta)
	end
	
	if not meta then return end
	
	for key, obj in pairs(prototype.GetCreated()) do
		if obj.Type == meta.Type and obj.ClassName == meta.ClassName then
			for k, v in pairs(meta) do
				-- update entity functions only
				-- updating variables might mess things up
				if type(v) == "function" and k:sub(1, 2) ~= "On" then
					obj[k] = v
				end
			end
		end
	end	
end

function prototype.RemoveObjects(super_type, sub_type)
	sub_type = sub_type or super_type
	for _, obj in pairs(prototype.GetCreated()) do
		if obj.Type == super_type and obj.ClassName == sub_type then
			if obj:IsValid() then
				obj:Remove()
			end
		end
	end
end

include("base_object.lua", prototype)
include("get_is_set.lua", prototype)
include("templates/*", prototype)
include("null.lua", prototype)
include("ecs_entity.lua", prototype)
include("base_ecs_component.lua", prototype)

return prototype