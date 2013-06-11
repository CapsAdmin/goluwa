local printf = function(fmt, ...) MsgN(string.format(fmt, ...)) end
local check = function() end
local table = {insert = table.insert}

do -- table copy
	local lookup_table = {}
	
	local function copy(obj, skip_meta)
	
		if typex(obj) == "vec3" or typex(obj) == "ang3" then
			return obj * 1
		elseif lookup_table[obj] then
			return lookup_table[obj]
		elseif type(obj) == "table" then
			local new_table = {}
			
			lookup_table[obj] = new_table
					
			for key, val in pairs(obj) do
				new_table[copy(key, skip_meta)] = copy(val, skip_meta)
			end
			
			return skip_meta and new_table or setmetatable(new_table, getmetatable(obj))
		else
			return obj
		end
	end

	function table.copy(obj, skip_meta)
		lookup_table = {}
		return copy(obj, skip_meta)
	end
end

local class = {}

class.Registered = {}

local function checkfield(tbl, key, def)
    tbl[key] = tbl[key] or def
	
    if not tbl[key] then
        error(string.format("The type field %q was not found!", key), 3)
    end

    return tbl[key]
end

function class.GetSet(tbl, name, def)

    if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tonumber(self[name]) end
	elseif type(def) == "string" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tostring(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tostring(self[name]) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = var end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return self[name] end
	end
		
    tbl[name] = def
end

function class.IsSet(tbl, name, def)
	if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = var end
	end
    tbl["Is" .. name] = tbl["Is" .. name] or function(self, var) return self[name] end

    tbl[name] = def
end

function class.RemoveField(tbl, name)
	tbl["Set" .. name] = nil
    tbl["Get" .. name] = nil
    tbl["Is" .. name] = nil

    tbl[name] = nil
end

function class.Get(type_name, class_name)
    check(type_name, "string")
    check(class_name, "string")
	
    return class.Registered[type_name] and class.Registered[type_name][class_name] or nil
end

function class.GetAll(type_name)
	check(type_name, "string")
	return class.Registered[type_name]
end

function class.Register(META, type_name, name)
    local type_name = checkfield(META, "Type", type_name)
    local name = checkfield(META, "ClassName", name)

    class.Registered[type_name] = class.Registered[type_name] or {}
    class.Registered[type_name][name] = META
end

function class.HandleBaseField(META, var)
	if not var then return end
	
	local t = type(var)
	
	if t == "string" then
		class.HandleBaseField(META, class.Get(META.Type, var))
	elseif t == "table" then
		-- if it's a table and does not have the Type field we assume it's a table of bases
		if not var.Type then
			for key, base in pairs(var) do
				class.HandleBaseField(META, base)
			end
		else
			-- make a copy of it so we don't alter the meta template
			var = table.copy(var)
			
			META.BaseList = META.BaseList or {}
			
			table.insert(META.BaseList, var)
		end
	end
end

function class.Create(type_name, class_name)
    local META = class.Get(type_name, class_name)
	
    if not META then
        printf("tried to create unknown %s %q!", type or "no type", class_name or "no class")
        return
    end
	
	local obj = table.copy(META)
	class.HandleBaseField(obj, obj.Base)
	class.HandleBaseField(obj, obj.TypeBase)

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
		
	obj.MetaTable = META

	setmetatable(obj, obj)
	
	return obj
end

class.Copy = table.copy

return class