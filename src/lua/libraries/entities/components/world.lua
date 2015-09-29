event.AddListener("GBufferInitialized", function()

local COMPONENT = {}

COMPONENT.Name = "world"

function COMPONENT:OnAdd(ent)
	prototype.SafeRemove(self.sun)

	self.sun = entities.CreateEntity("light", ent)
	self.sun:SetHideFromEditor(true)
	self.sun:SetProjectFromCamera(true)

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
			if self.sun:IsValid() then
				callback(self, var)
			end
		else
			render.SetGBufferValue("world_" .. name, var)

			-- grr
			if name == "sun_intensity" then
				self.sun:SetIntensity(var)
			end
		end
	end
end

prototype.StartStorable(COMPONENT)
	do -- sun
		ADD("sun_angles", Deg3(-45,-45,0), function(self, var)
			local vec = var:GetForward()
			local size = 50000
			local sun_pos = vec * size/10

			local grr = Matrix44()
			grr:Rotate(-var.x-math.pi/2, -1,0,0)
			grr:Rotate(var.y, 0,0,1)

			self.sun:SetRotation(grr:GetRotation())
			self.sun:SetPosition(sun_pos)
			self.sun:SetSize(size)
		end)

		ADD("sun_color", Color(1, 0.95, 0.8), function(self, var) self.sun:SetColor(var) end)
		ADD("sun_shadow", true, function(self, var) self.sun:SetShadow(var) end)
		ADD("sun_shadow_size", CAPS and 2048 or 512, function(self, var) self.sun:SetShadowSize(var) end)
		ADD("sun_ortho_size", 400, function(self, var) self.sun:SetOrthoSize(var) end)
	end

	for _, info in pairs(render.GetGBufferValues()) do
		if info.k:startswith("world_") then
			ADD(info.k:sub(7), info.v)
		end
	end
prototype.EndStorable()

prototype.RegisterComponent(COMPONENT)
prototype.SetupComponents("world", {"world", "network"}, "textures/silkicons/world.png")

end)

if RELOAD then
	-- CALL LAST ADDED EVENT?
end