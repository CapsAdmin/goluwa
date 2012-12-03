local class = {}

class.Registered = {}

function class.SetupLib(tbl, type, base)
	base = base or "base"

	function tbl.Create(name)
		local obj = class.Create(type, name, base)
		
		if not obj then return end
				
		if obj.Initialize then
			obj:Initialize()
		end

		return obj
	end

	function tbl.Register(META, name)
		if not META.Base and base then
			class.InsertIntoBaseField(META, base, 1)
		end
		class.Register(META, type, name)
	end
	
	function tbl.GetRegistered(name)
		return class.Get(type, name)
	end

	function tbl.GetAllRegistered()
		return class.GetAll(type)
	end
end

local function checkfield(tbl, key, def)
    tbl[key] = tbl[key] or def

    if not tbl[key] then
        error(string.format("The key %q was not found!", key), 3)
    end

    return tbl[key]
end

function class.GetSet(tbl, name, def)
    tbl["Set" .. name] = function(self, var) self[name] = var end
    tbl["Get" .. name] = function(self, var) return self[name] end
    tbl[name] = def
end

function class.IsSet(tbl, name, def)
    tbl["Set" .. name] = function(self, var) self[name] = var end
    tbl["Is" .. name] = function(self, var) return self[name] end
    tbl[name] = def
end

function class.Get(type, name)
    if not type then return end
    if not name then return end
    return class.Registered[type] and class.Registered[type][name] or nil
end

function class.Register(META, type, name)
    local type = checkfield(META, "Type", type)
    local name = checkfield(META, "ClassName", name)

    class.Registered[type] = class.Registered[type] or {}

    class.Registered[type][name] = META
end

function class.DeriveObjectFromVar(obj, var)
    local T = type(var)

    if T == "string" then
        obj:DeriveFrom(var)
    end

    if T == "table" then
        if var.Type and var.ClassName then
            obj:DeriveFrom(var)
        else
            for idx, var in pairs(var) do
                obj:DeriveFrom(var)
            end
        end
    end
end

function class.SetupBases(obj)
    for i=1, #obj.__bases do
        local base = obj.__bases[i]
        base.BaseClass = obj.__bases[i+1] --or base
        setmetatable(base, { __index = obj  })
    end
end

function class.InsertIntoBaseField(META, var, pos)

	local T1 = type(META.Base)
	local T2 = type(var)

	if T1 == "table" then
		if T2 == "table" and not var.Type then
			for key, base in ipairs(var) do
				table.insert(META.Base, key, base)
			end
		else
			if table.HasValue(META.Base, var) then return end

			if pos then
				table.insert(META.Base, pos, var)
			else
				table.insert(META.Base, var)
			end
		end
	end

	if META.ClassName == var then return end

	if T1 == "string" then
		META.Base = {META.Base}
		class.InsertIntoBaseField(META, var, pos)
	end

	if T1 == "nil" then
		META.Base = {var}
	end
end

function class.Create(_type, name, base, override)
    local META = class.Get(_type, name)

    if not META then
        printf("tried to create unknown %s %q!", _type, name)
        return
    end

	local obj = table.copy(class.Base)

	if override then
		table.merge(override, obj)
	end
	
    setmetatable(override or obj, class.Base)

    obj.Type = _type
    obj.ClassName = name

    obj:DeriveFrom(META)

	if base then
		obj:DeriveFrom(base)
	end

	events.Call("OnClassCreated", obj)

    return obj
end

do -- base meta
    local BASE = {}

    BASE.__bases = {}

    BASE.__tostring = function(self) return string.format("%s[%p][%s]", self.Type, self, self.ClassName) end
    BASE.OnIndexNotFound= function() end

    local value
    function BASE:__index(key)
        for idx, base in ipairs(self.__bases) do
            value = rawget(base, key)
            if value then
                return value
            end
        end
        return self:OnIndexNotFound(key)
    end

    function BASE:InsertBase(tbl)
        local idx = table.insert(self.__bases, table.copy(tbl))
        class.SetupBases(self)
        return idx
    end

    function BASE:DeriveFrom(var)
        local T = type(var)

        if T == "nil" then
            return
        end

        if T == "string" then
            var = class.Get(self.Type, var)
            T = type(var)
        end

        if T == "table" then
            self:InsertBase(var)
            if var.Base then
                self:DeriveFrom(var.Base)
            end
        end
    end

    function BASE:RemoveBase(idx)
        if idx then
            if type(idx) == "string" then
                for key, base in pairs(self.__bases) do
                    if base.ClassName == idx then
                        table.remove(self.__bases, key)
                    end
                end
            else
                table.remove(self.__bases, idx)
            end
            class.SetupBases(self)
        end
    end

    class.Base = BASE
end

return class