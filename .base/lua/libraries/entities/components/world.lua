local COMPONENT = {}

COMPONENT.Name = "world"

function COMPONENT:OnAdd(ent)
	prototype.SafeRemove(self.sun)
	
	self.sun = entities.CreateEntity("light", ent)
	self.sun:SetLensFlare(true)
	self.sun:SetName("sun")
	self.sun:SetHideFromEditor(false)
	self.sun:SetProjectFromCamera(true)
	self.sun:SetOrthoSize(80)
	self.sun:SetShadow(true)
	
	for _, info in ipairs(prototype.GetStorableVariables(self)) do		
		self[info.set_name](self, self[info.get_name](self))
	end
end

function COMPONENT:OnRemove(ent)
	prototype.SafeRemove(self.sun)
end

local function ADD(name, default, callback)
	local var_name = ("_" .. name):gsub("_(%l)", string.upper)
	
	prototype.GetSet(var_name, default)
	
	local callback_set_name
	local callback_get_name
	
	if type(callback) == "string" then
		local temp = ("_" .. callback):gsub("_(%l)", string.upper)
		callback_set_name = "Set" .. temp
		callback_get_name = "Get" .. temp
	end

	COMPONENT["Set" .. var_name] = function(self, var)
		self[var_name] = var
			
		if callback_set_name then
			self[callback_set_name](self, self[callback_get_name](self))
		elseif callback then
			callback(self, var) 
		else
			render.SetGBufferValue(name, var)
		end
	end
end

prototype.StartStorable(COMPONENT)
do -- sun
	ADD("sun_angles", Deg3(-45,-45,0), function(self, var)
		local vec = var:GetForward()
		local size = self:GetSunSize()
		local sun_pos = vec * size/10
		self.sun:SetAngles(Ang3(var.p, var.y, var.r))
		--self.sun:GetTRRotation():Conjugate()
		self.sun:SetPosition(sun_pos)
		self.sun:SetSize(size)
	end)

	ADD("sun_size", 10000, "sun_angles") 
	ADD("sun_color", Color(1, 0.95, 0.8), function(self, var) self.sun:SetColor(var) end)
	ADD("sun_intensity", 1, function(self, var) self.sun:SetDiffuseIntensity(var) end)
	ADD("sun_specular_intensity", 0.2, function(self, var) self.sun:SetSpecularIntensity(var) end)
	ADD("sun_roughness", 0.75, function(self, var) self.sun:SetRoughness(var) end)
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

prototype.EndStorable()

prototype.RegisterComponent(COMPONENT)