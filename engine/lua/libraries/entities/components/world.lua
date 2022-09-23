event.AddListener("GBufferInitialized", function()
	local META = prototype.CreateTemplate()
	META.Name = "world"
	META.sun = NULL

	function META:OnAdd(ent)
		if (not GRAPHICS or render3d.shader_name ~= "flat") then
			prototype.SafeRemove(self.sun)
			self.sun = entities.CreateEntity("light", ent)
			self.sun:SetHideFromEditor(true)
			self.sun:SetProjectFromCamera(true)
			ent.sun = self.sun
		end

		for _, info in ipairs(prototype.GetStorableVariables(self)) do
			self[info.set_name](self, self[info.get_name](self))
		end
	end

	function META:OnRemove(ent)
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

		META["Set" .. var_name] = function(self, var)
			self[var_name] = var

			if callback_set_name then
				self[callback_set_name](self, self[callback_get_name](self))
			elseif callback then
				if self.sun:IsValid() then callback(self, var) end
			else
				render.SetGBufferValue("world_" .. name, var)

				-- grr
				if name == "sun_intensity" then self.sun:SetIntensity(var) end
			end
		end
	end

	META:StartStorable()

	do -- sun
		ADD("sun_angles", Deg3(-45, -45, 0), function(self, var)
			local vec = var:GetForward()
			local size = 50000
			local sun_pos = vec * size / 10
			local grr = Matrix44()
			grr:Rotate(-var.x - math.pi / 2, -1, 0, 0)
			grr:Rotate(var.y, 0, 0, 1)
			self.sun:SetRotation(grr:GetRotation())
			self.sun:SetPosition(sun_pos)
			self.sun:SetSize(size)
		end)

		ADD("sun_color", Color(1, 1, 1), function(self, var)
			self.sun:SetColor(var)
		end)

		ADD("sun_shadow", true, function(self, var)
			self.sun:SetShadow(var)
		end)

		ADD("sun_shadow_size", 2048, function(self, var)
			self.sun:SetShadowSize(var)
		end)

		ADD("sun_ortho_size_min", 20, function(self, var)
			self.sun:SetOrthoSizeMin(var)
		end)

		ADD("sun_ortho_size_max", 400, function(self, var)
			self.sun:SetOrthoSizeMax(var)
		end)

		ADD("sun_ortho_bias", 4, function(self, var)
			self.sun:SetOrthoBias(var)
		end)
	end

	for _, info in pairs(render3d.GetGBufferValues()) do
		if info.k:starts_with("world_") then ADD(info.k:sub(7), info.v) end
	end

	META:EndStorable()
	META:RegisterComponent()
	prototype.SetupComponents("world", {"world", "network"}, "textures/silkicons/world.png")
end)

if RELOAD then -- CALL LAST ADDED EVENT?
end