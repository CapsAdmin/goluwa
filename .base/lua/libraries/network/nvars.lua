nvars = _G.nvars or {}
 
nvars.Environments = nvars.Environments or {} 
nvars.added_cvars = nvars.added_cvars or {}

function nvars.GetSet(tbl, name, def, cvar)

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
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self.nv[name] = tonumber(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tonumber(self.nv[name]) or def end
	elseif type(def) == "string" then
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self.nv[name] = tostring(var) end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return tostring(self.nv[name]) end
	else
		tbl["Set" .. name] = tbl["Set" .. name] or function(self, var) self.nv[name] = var end
		tbl["Get" .. name] = tbl["Get" .. name] or function(self, var) return self.nv[name] or def end
	end
	
end

if CLIENT then
	message.AddListener("nv", function(env, key, value)
		nvars.Set(key, value, env)
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
		event.Call("PlayerSpawned", ply)
		event.BroadcastCall("PlayerSpawned", ply)
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

	return nvars.Environments[env] and nvars.Environments[env][key] or def
end

do
	local META = {}

	function META:__index(key)
		return nvars.Get(key, nil, self.Env)
	end

	function META:__newindex(key, value)
		nvars.Set(key, value, self.Env)
	end

	nvars.ObjectMeta = META
end

function nvars.CreateObject(env)
	return setmetatable({Env = env}, nvars.ObjectMeta)
end