local ecs = _G.ecs or {}

ecs.entities = ecs.entities or {}
ecs.configurations = ecs.configurations or {}

for k,v in pairs(ecs.entities) do
	if v:IsValid() then
		v:Remove()
	end
end

function ecs.GetAll()
	return ecs.entities
end

function ecs.SetupComponents(name, components)
	
	local functions = {}
	
	for _, name in ipairs(components) do
		for k, v in pairs(ecs.GetComponent(name)) do
			if type(v) == "function" then			
				functions[k] = function(ent, ...)
					local obj = ent:GetComponent(name)
					return obj[k](obj, ...)
				end
			end
		end
	end

	ecs.configurations[name] = {
		components = components,
		functions = functions,
	}
end

do -- entity
	local ENTITY = metatable.CreateTemplate("ecs_base")

	metatable.GetSet(ENTITY, "Components", {})
	metatable.GetSet(ENTITY, "Entity", NULL)

	function ENTITY:AddComponent(name, id)
		id = id or "no_id"
		
		self:RemoveComponent(name, id)
		
		self.Components[name] = self.Components[name] or {}
		
		local obj = ecs.CreateComponent(name)
		
		if obj.Require then
			for i, other in ipairs(obj.Require) do
				if not self.Components[other] then
					error("component " .. name .. " requires component " .. other, 2)
				end
			end
		end
		
		obj.Id = id
		obj.Entity = self
		
		for i, event_type in pairs(obj.Events) do
			event.AddListener({
				event_type = event_type,
				id = obj,
				self_arg = obj,
				callback = obj["On" .. event_type],
			})
		end
		
		self.Components[name][id] = obj
		
		obj:OnAdd(self)
	end

	function ENTITY:RemoveComponent(name, id)
		id = id or "no_id"
		
		if not self.Components[name] then return end
			
		local obj = self.Components[name][id] or NULL
		
		if obj:IsValid() then
		
			for i, event_type in pairs(obj.Events) do
				event.RemoveListener(event_type, obj)
			end
		
			obj:OnRemove(self)
			obj:Remove()
		end
	end

	function ENTITY:GetComponent(name, id)
		if not self.Components[name] then return NULL end
		
		id = id or "no_id"
		
		return self.Components[name][id] or NULL
	end
	
	function ENTITY:OnRemove()
		for name, components in pairs(self:GetComponents()) do
			for id, obj in pairs(components) do
				self:RemoveComponent(name, id)
			end
		end
	end
	
	function ecs.CreateEntity(config)
		local ent = ENTITY:New()
		
		table.insert(ecs.entities, ent)
		
		if ecs.configurations[config] then
			for _, name in ipairs(ecs.configurations[config].components) do
				ent:AddComponent(name)
			end
			
			for name, func in pairs(ecs.configurations[config].functions) do
				ent[name] = ent[name] or func
			end
		end
		
		return ent
	end
end

do -- components 
	local BASE = {}
	
	metatable.GetSet(BASE, "Id")
	metatable.Delegate(BASE, "Entity", "GetComponent")
	metatable.Delegate(BASE, "Entity", "AddComponent")
	metatable.Delegate(BASE, "Entity", "RemoveComponent")
	
	ecs.components = {}

	function ecs.RegisterComponent(COMPONENT)
		
		for k, v in pairs(BASE) do
			COMPONENT[k] = COMPONENT[k] or v
		end
		
		local template = metatable.CreateTemplate(COMPONENT.Name)
		
		for k,v in pairs(COMPONENT) do
			template[k] = v
		end
		
		ecs.components[COMPONENT.Name:lower()] = template
	end

	function ecs.GetComponent(name)
		name = name:lower()
		return ecs.components[name]
	end

	function ecs.CreateComponent(name)
		return ecs.GetComponent(name):New()
	end
end

do -- test
	do -- transform
		local COMPONENT = {}
		
		COMPONENT.Name = "transform"
		COMPONENT.Events = {"Update"}
		
		metatable.AddParentingSystem(COMPONENT)
		
		metatable.GetSet(COMPONENT, "Matrix", Matrix44())
		
		metatable.StartStorable()		
			metatable.GetSet(COMPONENT, "Position", Vec3(0, 0, 0))
			metatable.GetSet(COMPONENT, "Angles", Ang3(0, 0, 0))
			metatable.GetSet(COMPONENT, "Scale", Vec3(1, 1, 1))
			metatable.GetSet(COMPONENT, "Size", 1)
		metatable.EndStorable()
		
		function COMPONENT:OnAdd(ent)
			self.temp_scale = Vec3(1, 1, 1)
		end
		
		function COMPONENT:OnRemove(ent)

		end
		
		function COMPONENT:SetPos(vec3)
			self.Position = vec3
			self:InvalidateMatrix()
		end
		
		function COMPONENT:SetAngles(ang3)
			self.Angles = ang3
			self:InvalidateMatrix()
		end
	
		function COMPONENT:SetScale(vec3) 
			self.Scale = vec3
			self.temp_scale = vec3 * self.Size
			self:InvalidateMatrix()
		end
		
		function COMPONENT:SetSize(num) 
			self.Size = num
			self.temp_scale = num * self.Scale
			self:InvalidateMatrix()
		end

		function COMPONENT:InvalidateMatrix()
			self.rebuild_matrix = true
		end
				
		function COMPONENT:OnUpdate()
			if self.rebuild_matrix then
				self.Matrix:Identity()

				self.Matrix:Translate(-self.Position.x, -self.Position.y, -self.Position.z)

				self.Matrix:Rotate(self.Angles.p, 0, 1, 0)
				self.Matrix:Rotate(-self.Angles.y, 0, 0, 1)
				self.Matrix:Rotate(-self.Angles.r, 1, 0, 0)				

				self.Matrix:Scale(self.temp_scale.x, self.temp_scale.y, self.temp_scale.z) 

				self.rebuild_matrix = false
			end
		end

		ecs.RegisterComponent(COMPONENT)
	end

	do -- visual
		local COMPONENT = {}
		
		COMPONENT.Name = "visual"
		COMPONENT.Require = {"transform"}
		COMPONENT.Events = {"Draw2D"}
		
		metatable.StartStorable()		
			metatable.GetSet(COMPONENT, "Texture", NULL)
			metatable.GetSet(COMPONENT, "Color", Color(1, 1, 1, 1))
			metatable.GetSet(COMPONENT, "Alpha", 1)
		metatable.EndStorable()

		function COMPONENT:OnAdd(ent)

		end

		function COMPONENT:OnRemove(ent)

		end
		
		function COMPONENT:OnDraw2D(dt)
			local matrix = self:GetComponent("transform"):GetMatrix()
			
			render.PushWorldMatrixEx(matrix)
			
				if self.Texture:IsValid() then
					surface.SetTexture(self.Texture)
				else
					surface.SetWhiteTexture(self.Texture)
				end
				
				surface.SetColor(self.Color.r, self.Color.g, self.Color.b, self.Alpha)
				surface.DrawRect(0,0,1,1)
				
			render.PopWorldMatrix()
		end

		ecs.RegisterComponent(COMPONENT)
	end
	
	do -- test
		ecs.SetupComponents("shape", {"transform", "visual"})
	
		local ent = ecs.CreateEntity("shape")
		
		ent:SetTexture(Texture("textures/debug/brain.jpg"))
		ent:SetColor(Color(1,0,1))
		ent:SetAlpha(0.5)
		ent:SetPosition(Vec3(-200,-134,0))
		ent:SetAngles(Ang3(0,0,0)) 
		ent:SetScale(Vec3(50,50,1))
		
		event.AddListener("Update", "test", function()
		end)
	end
	
end

_G.ecs = ecs