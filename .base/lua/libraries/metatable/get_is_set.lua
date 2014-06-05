local metatable = (...) or _G.metatable

local __store = false

function metatable.StartStorable()
	__store = true
end

function metatable.EndStorable()
	__store = false
end

function metatable.GetSet(tbl, name, def)

    if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) or def end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tonumber(self[name]) or def end
	elseif type(def) == "string" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tostring(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tostring(self[name]) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) if var == nil then var = def end self[name] = var end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) if self[name] ~= nil then return self[name] end return def end
	end

    tbl[name] = def

	if __store then
		tbl.storable_variables = tbl.storable_variables or {}
		table.insert(tbl.storable_variables, name)
	end
end

function metatable.IsSet(tbl, name, def)
	
	if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = var end
	end
	
    tbl["Is" .. name] = tbl["Is" .. name] or function(self, var) if self[name] ~= nil then return self[name] end return def end

    tbl[name] = def

	if __store then
		tbl.storable_variables = tbl.storable_variables or {}
		table.insert(tbl.storable_variables, name)
	end
end

function metatable.RemoveField(tbl, name)
	tbl["Set" .. name] = nil
    tbl["Get" .. name] = nil
    tbl["Is" .. name] = nil

    tbl[name] = nil
end