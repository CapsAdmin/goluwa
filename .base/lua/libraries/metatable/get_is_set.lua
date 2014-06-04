local metatable = (...) or _G.metatable

local __store = false

function metatable.StartStorable()
	__store = true
end

function metatable.EndStorable()
	__store = false
end

function metatable.GetSet(tbl, name, def)

	local store_name = name:gsub("%u", function(l) return "_" .. l:lower() end):sub(2)

    if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[store_name] = tonumber(var) or def end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tonumber(self[store_name]) or def end
	elseif type(def) == "string" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[store_name] = tostring(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tostring(self[store_name]) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) if var == nil then var = def end self[store_name] = var end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) if self[store_name] ~= nil then return self[store_name] end return def end
	end

    tbl[store_name] = def

	if __store then
		tbl.storable_variables = tbl.storable_variables or {}
		table.insert(tbl.storable_variables, store_name)
	end
end

function metatable.IsSet(tbl, name, def)
	
	local store_name = name:gsub("%u", function(l) return "_" .. l:lower() end):sub(2)

	if type(def) == "number" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[store_name] = tonumber(var) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[store_name] = var end
	end
	
    tbl["Is" .. name] = tbl["Is" .. name] or function(self, var) if self[store_name] ~= nil then return self[store_name] end return def end

    tbl[name] = def

	if __store then
		tbl.storable_variables = tbl.storable_variables or {}
		table.insert(tbl.storable_variables, store_name)
	end
end

function metatable.RemoveField(tbl, name)
	tbl["Set" .. name] = nil
    tbl["Get" .. name] = nil
    tbl["Is" .. name] = nil

    tbl[name] = nil
end