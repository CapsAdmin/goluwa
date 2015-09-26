local nvars = _G.nvars or {}

nvars.Environments = nvars.Environments or {}
nvars.added_cvars = nvars.added_cvars or {}

local function get_is_set(is, meta, name, default, cvar)

	local get = is and "Is" or "Get"
	local set = "Set"

	if cvar then
		cvar = "cl_" .. name:lower()
		nvars.added_cvars[cvar] = name

		if CLIENT then
			console.CreateVariable(cvar, default, function(var)
				if network.IsConnected() then
					message.Send("ncv", cvar, var)
				else
					clients.GetLocalClient().nv[name] = var
				end
			end)
		end
	end

    if type(default) == "number" then
		meta[set .. name] = function(self, var) self.nv[name] = tonumber(var) end
		meta[get .. name] = function(self, var) return tonumber(self.nv[name]) or default end
	elseif type(default) == "string" then
		meta[set .. name] = function(self, var) self.nv[name] = tostring(var) end
		meta[get .. name] = function(self, var) if self.nv[name] ~= nil then return tostring(self.nv[name]) end return default end
	else
		meta[set .. name] = function(self, var) if var == nil then var = default end self.nv[name] = var end
		meta[get .. name] = function(self, var) if self.nv[name] ~= nil then return self.nv[name] end return default end
	end

	-- this is important because it sets up property info for this object for editors and such to use
	return is and prototype.IsSet(meta, name, default) or prototype.GetSet(meta, name, default)
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

	function nvars.Synchronize()
		for cvar in pairs(nvars.added_cvars) do
			console.RunCommand(cvar, console.GetVariable(cvar))
		end

		if network.debug or nvars.debug then
			logn("done synchronizing nvars")
		end

		message.Send("nvsync")
	end

	message.AddListener("nvsync", nvars.Synchronize)
end

if SERVER then
	local waiting_for = {}

	function nvars.Synchronize(client, callback)
		for env, vars in pairs(nvars.Environments) do
			for key, value in pairs(vars) do
				nvars.Set(key, value, env, client)
			end
		end
		waiting_for[client] = callback

		message.Send("nvsync")
	end

	message.AddListener("nvsync", function(client)
		if network.debug or nvars.debug then
			logf("client %s said it was done synchronizing nvars\n", client)
		end

		if waiting_for[client] then
			waiting_for[client](client)
			waiting_for[client] = nil
		end
	end)

	message.AddListener("ncv", function(client, cvar, var)
		local key = nvars.added_cvars[cvar]

		if key then
			client.nv[key] = var
		end
	end)
end

function nvars.Set(key, value, env, client)
	env = env or "g"

	nvars.Environments[env] = nvars.Environments[env] or {}
	nvars.Environments[env][key] = value

	if network.debug or nvars.debug then
		if not env:find("string_table") then
			logf("nvars.%s.%s = %s\n", env, key, value)
		end
	end

	if SERVER then
		message.Send("nv", client, env, key, value)
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