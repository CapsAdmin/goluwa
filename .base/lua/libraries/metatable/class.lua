local metatable = ... or _G.metatable

local function handle_base_field(meta, base)	
	local t = type(base)
	
	if t == "string" then
		handle_base_field(meta, metatable.GetRegistered(meta.Type, base))
	elseif t == "table" then
		-- if it's a table and does not have the Type field we assume it's a table of bases
		if not base.Type then
			for key, base in pairs(base) do
				handle_base_field(meta, base)
			end
		else
			-- make a copy of it so we don't alter the meta template
			base = table.copy(base)
			
			meta.BaseList = meta.BaseList or {}
			
			table.insert(meta.BaseList, base)
		end
	end
end

function metatable.CreateDerivedObject(super_type, sub_type, override, skip_gc_callback)
    local meta = metatable.GetRegistered(super_type, sub_type)
	
    if not meta then
        logf("tried to create unknown %s %q!\n", type or "no type", class_name or "no class")
        return
    end
	
	meta = table.copy(meta)
		
	if meta.Base then 
		handle_base_field(meta, meta.Base) 
	end
	
	if meta.TypeBase then 
		handle_base_field(meta, meta.TypeBase) 
	end

	if meta.BaseList then	
		local current = meta
		for i, base in pairs(meta.BaseList) do
			for key, val in pairs(base) do
				meta[key] = meta[key] or val
			end
			current.BaseClass = base
			current = base
		end
	end
		
	-- copy all structs and such
	for key, val in pairs(meta) do
		if hasindex(val) and val.Copy then
			meta[key] = val:Copy()
		end
	end

	meta = metatable.CreateTemplate(meta, nil, true)
		
	return metatable.CreateObject(meta, override, skip_gc_callback)
end