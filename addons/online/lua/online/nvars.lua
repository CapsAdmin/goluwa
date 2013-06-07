nvars = nvars or {}
 
nvars.Environments = nvars.Environments or {} 

if CLIENT then
	message.AddListener("nv", function(env, key, value)
		nvars.Set(key, value, env)
	end)
end

if SERVER then
	function nvars.FullUpdate(ply)
		for env, vars in pairs(nvars.Environments) do
			for key, value in pairs(vars) do
				nvars.Set(key, value, env, ply)
			end
		end
	end
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