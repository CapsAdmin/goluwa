local prototype = (...) or _G.prototype

local __store = false
local __meta

function prototype.StartStorable(meta)
	__store = true
	__meta = meta
end

function prototype.EndStorable()
	__store = false
	__meta = nil
end

function prototype.GetStorableVariables(meta)
	return meta.storable_variables or {}
end

function prototype.DelegateProperties(meta, from, var_name)
        meta[var_name] = NULL
	for _, info in pairs(prototype.GetStorableVariables(from)) do
		if not meta[info.var_name] then
			 prototype.SetupProperty({
				meta = meta, 
				var_name = info.var_name, 
				default = info.default,
				set_name = info.set_name,
				get_name = info.get_name,
			})
			
			meta[info.set_name] = function(self, var)
				self[info.var_name] = var
				
				if self[var_name]:IsValid() then
					self[var_name][info.set_name](self[var_name], var)
				end
			end
		
			meta[info.get_name] = function(self)			
				if self[var_name]:IsValid() then
					return self[var_name][info.get_name](self[var_name])
				end
				
				return self[info.var_name]
			end
		end
	end
end

local function has_copy(obj)
	assert(type(obj.__copy) == "function")
end

function prototype.SetupProperty(info)
	local meta = info.meta or __meta
	local default = info.default
	local name = info.var_name
	local set_name = info.set_name
	local get_name = info.get_name
	local callback = info.callback
		
	if type(default) == "number" then	
		if callback then
			meta[set_name] = meta[set_name] or function(self, var) self[name] = tonumber(var) or default self[callback](self) end
		else
			meta[set_name] = meta[set_name] or function(self, var) self[name] = tonumber(var) or default end
		end
		meta[get_name] = meta[get_name] or function(self, var) return tonumber(self[name]) or default end
	elseif type(default) == "string" then
		if callback then
			meta[set_name] = meta[set_name] or function(self, var) self[name] = tostring(var) self[callback](self) end
		else
			meta[set_name] = meta[set_name] or function(self, var) self[name] = tostring(var) end
		end
		meta[get_name] = meta[get_name] or function(self, var) if self[name] ~= nil then return tostring(self[name]) end return default end
	else
		if callback then
			meta[set_name] = meta[set_name] or function(self, var) if var == nil then var = default end self[name] = var self[callback](self) end
		else
			meta[set_name] = meta[set_name] or function(self, var) if var == nil then var = default end self[name] = var end
		end
		meta[get_name] = meta[get_name] or function(self, var) if self[name] ~= nil then return self[name] end return default end
	end

    meta[name] = default

	if __store then
		info.type = typex(default)
		
		meta.storable_variables = meta.storable_variables or {}
		table.insert(meta.storable_variables, info)
	end
	
	do
		if pcall(has_copy, info.default) then
			info.copy = function()
				return info.default:__copy()
			end
		elseif typex(info.default) == "table" then
			if not next(info.default) then
				info.copy = function()
					return {}
				end
			else
				info.copy = function()
					return table.copy(info.default)
				end
			end
		end
		
		meta.prototype_variables = meta.prototype_variables or {}
		meta.prototype_variables[info.var_name] = info
	end
	
	return info
end

local function add(meta, name, default, extra_info, get)
	local info = {
		meta = meta, 
		default = default,
		var_name = name, 
		set_name = "Set" .. name,
		get_name = get .. name,
	}
	
	if extra_info then
		if table.isarray(extra_info) and #extra_info > 1 then
			extra_info = {enums = extra_info}
		end
		table.merge(info, extra_info)
	end
	
	return prototype.SetupProperty(info)
end

function prototype.GetSet(meta, name, default, extra_info)
	if type(meta) == "string" and __meta then
		return add(__meta, meta, name, default, "Get")
	else
		return add(meta, name, default, extra_info, "Get")
	end
end

function prototype.IsSet(meta, name, default, extra_info)
	if type(meta) == "string" and __meta then
		return add(__meta, meta, name, default, "Is")
	else
		return add(meta, name, default, extra_info, "Is")
	end
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
	local info = prototype.GetSet(meta, func_name, def)
	prototype.Delegate(meta, key, get)
	prototype.Delegate(meta, key, set)
	return info
end

function prototype.RemoveField(meta, name)
	meta["Set" .. name] = nil
    meta["Get" .. name] = nil
    meta["Is" .. name] = nil

    meta[name] = nil
end
