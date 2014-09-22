local prototype = (...) or _G.prototype

local __store = false

function prototype.StartStorable()
	__store = true
end

function prototype.EndStorable()
	__store = false
end

function prototype.GetSet(tbl, name, def, callback)

	if type(def) == "number" then	
		if callback then
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) or def self[callback](self) end
		else
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) or def end
		end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tonumber(self[name]) or def end
	elseif type(def) == "string" then
		if callback then
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tostring(var) self[callback](self) end
		else
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tostring(var) end
		end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tostring(self[name]) end
	else
		if callback then
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) if var == nil then var = def end self[name] = var self[callback](self) end
		else
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) if var == nil then var = def end self[name] = var end
		end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) if self[name] ~= nil then return self[name] end return def end
	end

    tbl[name] = def

	if __store then
		tbl.storable_variables = tbl.storable_variables or {}
		table.insert(tbl.storable_variables, name)
	end
end

function prototype.IsSet(tbl, name, def, callback)
	
	if type(def) == "number" then
		if callback then
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) self[callback](self) end
		else
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = tonumber(var) end
		end
	else
		if callback then
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = var self[callback](self) end
		else
			tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self[name] = var end
		end
	end
	
	tbl["Is" .. name] = tbl["Is" .. name] or function(self, var) if self[name] ~= nil then return self[name] end return def end

    tbl[name] = def

	if __store then
		tbl.storable_variables = tbl.storable_variables or {}
		table.insert(tbl.storable_variables, name)
	end
end

function prototype.RemoveField(tbl, name)
	tbl["Set" .. name] = nil
    tbl["Get" .. name] = nil
    tbl["Is" .. name] = nil

    tbl[name] = nil
end