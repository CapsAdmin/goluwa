local nvars = _G.nvars or {}
 
nvars.Environments = nvars.Environments or {} 
nvars.added_cvars = nvars.added_cvars or {}

local function get_is_set(is, tbl, name, def, cvar)
	
	local get = is and "Is" or "Get"
	local set = "Set"
	
	if cvar then
		cvar = "cl_" .. name:lower()
		nvars.added_cvars[cvar] = name
		
		if CLIENT then
			console.CreateVariable(cvar, def, function(var)
				message.Send("ncv", cvar, var)
			end)
		end
	end

    if type(def) == "number" then
		tbl[set .. name] = tbl[set .. name] or function(self, var) self.nv[name] = tonumber(var) end
		tbl[get .. name] = tbl[get .. name] or function(self, var) return tonumber(self.nv[name]) or def end
	elseif type(def) == "string" then
		tbl[set .. name] = tbl[set .. name] or function(self, var) self.nv[name] = tostring(var) end
		tbl[get .. name] = tbl[get .. name] or function(self, var) return tostring(self.nv[name]) end
	else
		tbl[set .. name] = tbl[set .. name] or function(self, var) if var == nil then var = def end self.nv[name] = var end
		tbl[get .. name] = tbl[get .. name] or function(self, var) if self.nv[name] ~= nil then return self.nv[name] end return def end
	end
	
end

nvars.GetSet = function(...) return get_is_set(false, ...) end
nvars.IsSet = function(...) return get_is_set(true, ...) end

if CLIENT then
	message.AddListener("nv", function(env, key, value)
		if key == nil and value == nil then
			nvars.Environments[env] = nil
		else
			nvars.Set(key, value, env)
		end
	end)
	
	message.AddListener("nvars_fullupdate", function()
		for cvar in pairs(nvars.added_cvars) do
			console.RunCommand(cvar, console.GetVariable(cvar))
		end
		message.Send("nvars_update_done")
	end)
end

if SERVER then
	function nvars.FullUpdate(ply)
		for env, vars in pairs(nvars.Environments) do
			for key, value in pairs(vars) do
				nvars.Set(key, value, env, ply)
			end
		end
		
		message.Send("nvars_fullupdate", ply)
	end
	
	message.AddListener("ncv", function(ply, cvar, var)
		local key = nvars.added_cvars[cvar]
		if key then
			ply.nv[key] = var
		end
	end)
	
	message.AddListener("nvars_update_done", function(ply)
		network.HandleMessage(ply.socket, network.SYNCHRONIZED)
	end)
end

function nvars.Set(key, value, env, ply)
	env = env or "g"
		
	nvars.Environments[env] = nvars.Environments[env] or {}
	nvars.Environments[env][key] = value
	
	if SERVER then
		message.Send("nv", ply, env, key, value)
	end
end

function nvars.Get(key, def, env)
	env = env or "g"

	if nvars.Environments[env] and nvars.Environments[env][key] ~= nil then
		return nvars.Environments[env][key]
	end
	
	return def
end

function nvars.GetAll(env)
	return nvars.Environments[env]
end

do
	local META = {}

	function META:__index(key)
		local val = nvars.Get(key, nil, self.Env)
		if val ~= nil then
			return val
		end
		return META[key]
	end

	function META:__newindex(key, value)
		nvars.Set(key, value, self.Env)
	end
	
	function META:Remove()
		nvars.RemoveObject(self.Env)
	end

	nvars.ObjectMeta = META
end

function nvars.CreateObject(env)
	return setmetatable({Env = env}, nvars.ObjectMeta)
end

function nvars.RemoveObject(env)
	nvars.Environments[env] = nil
	if SERVER then
		message.Send("nv", nil, env)
	end	
end

return nvars