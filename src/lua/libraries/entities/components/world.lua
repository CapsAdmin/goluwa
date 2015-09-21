local COMPONENT = {}

COMPONENT.Name = "world"

function COMPONENT:OnAdd(ent)
	prototype.SafeRemove(self.sun)
	
	self.sun = entities.CreateEntity("light", ent)
	self.sun:SetName("sun")
	self.sun:SetHideFromEditor(false)
	self.sun:SetProjectFromCamera(true)
	self.sun:SetOrthoSize(400)
	self.sun:SetShadowSize(512)
	
	self.sun:SetShadow(true)
	
	SUN = self.sun
	
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
		
		local grr = Matrix44()
		grr:Rotate(-var.x-math.pi/2, -1,0,0)
		grr:Rotate(var.y, 0,0,1)
		
		self.sun:SetRotation(grr:GetRotation())
		self.sun:SetPosition(sun_pos)
		self.sun:SetSize(size)
	end)

	ADD("sun_size", 50000, "sun_angles") 
	ADD("sun_color", Color(1, 0.95, 0.8), function(self, var) self.sun:SetColor(var) end)
	ADD("sun_intensity", 1, function(self, var) self.sun:SetIntensity(var) end)
end

do -- fog 
	ADD("fog_color", Color(0.18867780436772762, 0.4978442963618773, 0.6616065586417131, 1))
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