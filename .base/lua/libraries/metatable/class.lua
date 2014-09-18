local metatable = ... or _G.metatable

metatable.registered_classes = metatable.registered_classes or {}

local function checkfield(tbl, key, def)
    tbl[key] = tbl[key] or def
	
    if not tbl[key] then
        error(string.format("The type field %q was not found!", key), 3)
    end

    return tbl[key]
end

local function handle_base_field(META, var)
	if not var then return end
	
	local t = type(var)
	
	if t == "string" then
		handle_base_field(META, metatable.GetRegisteredClass(META.Type, var))
	elseif t == "table" then
		-- if it's a table and does not have the Type field we assume it's a table of bases
		if not var.Type then
			for key, base in pairs(var) do
				handle_base_field(META, base)
			end
		else
			-- make a copy of it so we don't alter the meta template
			var = table.copy(var)
			
			META.BaseList = META.BaseList or {}
			
			table.insert(META.BaseList, var)
		end
	end
end

function metatable.RegisterClass(META, type_name, name)
    local type_name = checkfield(META, "Type", type_name)
    local name = checkfield(META, "ClassName", name)

    metatable.registered_classes[type_name] = metatable.registered_classes[type_name] or {}
    metatable.registered_classes[type_name][name] = META
	
	if metatable and metatable.Register then
		metatable.Register(META, name)
	end
	
	return type_name, name
end

function metatable.GetRegisteredClass(type_name, class_name)
    check(type_name, "string")
    check(class_name, "string")
	
    return metatable.registered_classes[type_name] and metatable.registered_classes[type_name][class_name] or nil
end

function metatable.GetRegisteredClasses(type_name)
	check(type_name, "string")
	return metatable.registered_classes[type_name]
end

--[[metatable.active_classes = {}
-- metatable.GetRegisteredClasses("panel_textbutton"):SetText("asdfasd")
function metatable.GetAllObjects(type_name, class_name)
	
	if not class_name then
		type_name, class_name = type_name:match("(.-)_(.+)")
	end
	
	local META = metatable.GetRegisteredClass(type_name, class_name)
	local types = metatable.active_classes[type_name]
	if types then
		local objects = types[class_name] 
		if objects then
			return setmetatable(
				{},
				{
					__index = function(_, key)
						return function(_, ...)
							for k,v in pairs(objects) do
								META[key](v, ...)
							end
						end
					end,
				}
			)
		end
	end
end]]

function metatable.CreateClass(type_name, class_name)
    local META = metatable.GetRegisteredClass(type_name, class_name)
	
    if not META then
        logf("tried to create unknown %s %q!\n", type or "no type", class_name or "no class")
        return
    end
	
	local obj = table.copy(META)
	handle_base_field(obj, obj.Base)
	handle_base_field(obj, obj.TypeBase)

	if obj.BaseList then	
		if #obj.BaseList == 1 then
			for key, val in pairs(obj.BaseList[1]) do
				obj[key] = obj[key] or val
			end
			obj.BaseClass = obj.BaseList[1]
		else		
			local current = obj
			for i, base in pairs(obj.BaseList) do
				for key, val in pairs(base) do
					obj[key] = obj[key] or val
				end
				current.BaseClass = base
				current = base
			end
		end
	end
		
	META.__index = META
	obj.MetaTable = META

	setmetatable(obj, META)
	
	-- copy all structs and such
	for key, val in pairs(obj) do
		if hasindex(val) and val.Copy then
			obj[key] = val:Copy()
		end
	end
	
	--metatable.active_classes[type_name] = metatable.active_classes[type_name] or {}
	--metatable.active_classes[type_name][class_name] = metatable.active_classes[type_name][class_name] or utility.CreateWeakTable()
	--table.insert(metatable.active_classes[type_name][class_name], obj)
			
	return obj
end