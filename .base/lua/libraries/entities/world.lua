local world = _G.world or {}

world.vars = {}

function world.Initialize()
	entities.SafeRemove(world.sun)
	world.sun = entities.CreateEntity("light")
	
	for k, v in pairs(world.vars) do
		v.set(v.get())
	end
end

function world.Set(key, val)
	world.vars[key].set(val)
end

function world.Get(key, val)
	return world.vars[key].get()
end

local function ADD(name, default, callback)
	local set = function(var)
		world.vars[name].value = var
		
		if type(callback) == "function" then 
			callback(var) 
		elseif type(callback) == "string" then
			world.vars[callback].set(world.vars[callback].get())
		else
			render.gbuffer_shader[name] = var
		end
	end
	
	local get = function()
		return world.vars[name].value or default
	end
	
	world.vars[name] = {default = default, value = default, get = get, set = set}
end

-- lerping
do
	local function lerp(mult, tbl)
		local out = {}

		for i = 1, #tbl - 1 do
			out[i] = world.Lerp(mult, tbl[i], tbl[i + 1])
		end

		if #out > 1 then
			return lerp(mult, out) 
		else 
			return out[1] 
		end
	end 

	function world.Lerp(mult, a, b)	
		local params = {}
		
		for key, val in pairs(a) do
			if type(val) == "number" then
				params[key] =  math.lerp(mult, val, b[key] or val)
			elseif val.Lerp then
				params[key] = val:Lerp(val, mult, b[key] or val)
			end
		end
		
		return params
	end

	function world.LerpConfigs(mult, ...)
		return lerp(mult, {...})
	end 
end


do -- sun
	ADD("sun_angles", Ang3(-45,-45,0), function(var)
		local vec = var:GetForward()
		local size = world.Get("sun_size")
		
		world.sun:SetPosition(vec * size)
		world.sun:SetSize(size)
	end)

	ADD("sun_size", 2000, "sun_angles") 
	ADD("sun_color", Color(1, 0.95, 0.8), function(var) world.sun:SetColor(var) end)
	ADD("sun_intensity", 1, function(var) world.sun:SetDiffuseIntensity(var) end)
	ADD("sun_specular_intensity", 0.2, function(var) world.sun:SetSpecularIntensity(var) end)
	ADD("sun_roughness", 0.75, function(var) world.sun:SetRoughness(var) end)
	ADD("ambient_lighting", Color(1, 0.95, 0.8) * 0.6)
end

do -- fog 
	ADD("fog_color", Color(0.8, 0.95, 1, 1))
	ADD("fog_intensity", 1)
	ADD("fog_start", 1)
	ADD("fog_end", 4000)
end

do -- ao
	ADD("ao_amount", 0)
	ADD("ao_cap", 1)
	ADD("ao_multiplier", 1)
	ADD("ao_depthtolerance", 0.0)
	ADD("ao_range", 100000)
	ADD("ao_scale", 2.75)
end

do -- gamma
	ADD("gamma", 1)
end

if CLIENT then
	if RELOAD then
		world.Initialize() 
	end

	event.AddListener("GBufferInitialized", "world_parameters", function()
		world.Initialize()
	end)
end
 

return world