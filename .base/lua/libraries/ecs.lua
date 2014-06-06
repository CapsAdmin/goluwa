local ecs = _G.ecs or {}

ecs.entities = ecs.entities or {}
ecs.configurations = ecs.configurations or {}

for k,v in pairs(ecs.entities) do
	if v:IsValid() then
		v:Remove()
	end
end

ecs.entities = {}

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

	function ENTITY:AddComponent(name, id, ...)
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
				
		if obj.Events then		
			for i, event_type in pairs(obj.Events) do
				event.AddListener({
					event_type = event_type,
					id = obj,
					self_arg = obj,
					callback = obj["On" .. event_type],
				})
			end
		end
		
		self.Components[name][id] = obj
		
		obj:OnAdd(self, ...)
	end

	function ENTITY:RemoveComponent(name, id)
		id = id or "no_id"
		
		if not self.Components[name] then return end
			
		local obj = self.Components[name][id] or NULL
		
		if obj:IsValid() then
		
			if obj.Events then		
				for i, event_type in pairs(obj.Events) do
					event.RemoveListener(event_type, obj)
				end
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
	
	function ENTITY:HasComponent(name, id)
		id = id or "no_id"
		
		return self.Components[name][id] ~= nil
	end
	
	function ENTITY:OnRemove()
		for name, components in pairs(self:GetComponents()) do
			for id, obj in pairs(components) do
				self:RemoveComponent(name, id)
			end
		end
	end
	
	function ecs.CreateEntity(config, ...)
		local ent = ENTITY:New()
		
		table.insert(ecs.entities, ent)
		
		if ecs.configurations[config] then
			for _, name in ipairs(ecs.configurations[config].components) do
				ent:AddComponent(name, nil, ...)
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
		-- get a copy so vectors and such wont be shared between multiple components
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
		
		metatable.AddParentingSystem(COMPONENT)
		
		metatable.GetSet(COMPONENT, "TRMatrix", Matrix44())
		metatable.GetSet(COMPONENT, "ScaleMatrix", Matrix44())
		
		metatable.StartStorable()		
			metatable.GetSet(COMPONENT, "Position", Vec3(0, 0, 0), "InvalidateTRMatrix")
			metatable.GetSet(COMPONENT, "Angles", Ang3(0, 0, 0), "InvalidateTRMatrix")
			
			metatable.GetSet(COMPONENT, "Scale", Vec3(1, 1, 1), "InvalidateScaleMatrix")
			metatable.GetSet(COMPONENT, "Shear", Vec3(0, 0, 0), "InvalidateScaleMatrix")
			metatable.GetSet(COMPONENT, "Size", 1, "InvalidateScaleMatrix")
		metatable.EndStorable()
	
		function COMPONENT:OnAdd(ent, parent)
			if parent and parent:HasComponent("transform") then
				self:SetParent(parent:GetComponent("transform"))
			end
		end
		
		function COMPONENT:OnRemove(ent)

		end
		
		do
			COMPONENT.temp_scale = Vec3(1, 1, 1)
			
			function COMPONENT:SetScale(vec3) 
				self.Scale = vec3
				self.temp_scale = vec3 * self.Size
				self:InvalidateScaleMatrix()
			end
					
			function COMPONENT:SetSize(num) 
				self.Size = num
				self.temp_scale = num * self.Scale
				self:InvalidateScaleMatrix()
			end
		end

		function COMPONENT:InvalidateScaleMatrix()
			self.rebuild_scale_matrix = true
		end
		
		function COMPONENT:InvalidateTRMatrix()
			self.rebuild_tr_matrix = true
		end
		
		function COMPONENT:RebuildMatrix()			
			if self.rebuild_tr_matrix then				
				self.TRMatrix:Identity()

				self.TRMatrix:Translate(self.Position.x, self.Position.y, self.Position.z)
				
				self.TRMatrix:Rotate(self.Angles.p, 1, 0, 0)
				self.TRMatrix:Rotate(self.Angles.y, 0, 1, 0)
				self.TRMatrix:Rotate(self.Angles.r, 0, 0, 1)				
				
				if self:HasParent() then
					self.TRMatrix = self.TRMatrix * self.Parent.TRMatrix
				end
				
				self.rebuild_tr_matrix = false
			end
		
			if self.rebuild_scale_matrix then
				self.ScaleMatrix:Identity()
				
				self.ScaleMatrix:Scale(self.temp_scale.x, self.temp_scale.y, self.temp_scale.z)
				--self.ScaleMatrix:Shear(self.Shear)
				
				self.rebuild_scale_matrix = false
			end
			
			for _, child in ipairs(self:GetChildren()) do
				child:RebuildMatrix()
			end
		end
		
		function COMPONENT:GetMatrix()
			self:RebuildMatrix()
			
			return self.ScaleMatrix * self.TRMatrix 
		end

		ecs.RegisterComponent(COMPONENT)
	end

	do -- visual
		local COMPONENT = {}
		
		COMPONENT.Name = "visual"
		COMPONENT.Require = {"transform"}
		COMPONENT.Events = {"Draw3D"}
		
		metatable.StartStorable()		
			metatable.GetSet(COMPONENT, "Texture", render.GetWhiteTexture())
			metatable.GetSet(COMPONENT, "Color", Color(1, 1, 1))
			metatable.GetSet(COMPONENT, "Alpha", 1)
		metatable.EndStorable()

		function COMPONENT:OnAdd(ent)

		end

		function COMPONENT:OnRemove(ent)

		end	

		local SHADER = {
			name = "mesh_ecs",
			vertex = { 
				uniform = {
					pvm_matrix = "mat4",
				},			
				attributes = {
					{pos = "vec3"},
					{normal = "vec3"},
					{uv = "vec2"},
				},	
				source = "gl_Position = pvm_matrix * vec4(pos, 1.0);"
			},
			fragment = { 
				uniform = {
					diffuse = "sampler2D",
					bump = "sampler2D",
					specular = "sampler2D",
				},		
				attributes = {
					{pos = "vec3"},
					{normal = "vec3"},
					{uv = "vec2"},
				},			
				source = [[
					out vec4 out_color;
								
					void main() 
					{
						out_color = texture(diffuse, uv);
					}
				]]
			}  
		}
		
		local shader = render.CreateShader(SHADER)
		
		-- this is for the previous system but it has the same vertex attribute layout
		local model = render.Create3DMesh("models/face.obj").sub_models[0]
		
		function COMPONENT:OnDraw3D(dt)							
			shader.diffuse = model.diffuse
			shader.pvm_matrix = (self:GetComponent("transform"):GetMatrix() * render.matrices.view_3d * render.matrices.projection_3d).m
			shader:Bind()
			
			model.mesh:Draw()
		end

		ecs.RegisterComponent(COMPONENT)
	end
		
	do -- test
		ecs.SetupComponents("shape", {"transform", "visual"})
	
		local parent = ecs.CreateEntity("shape")
		
		parent:SetTexture(Texture("textures/debug/brain.jpg"))
		parent:SetColor(Color(1,1,1))
		parent:SetAlpha(1)
		parent:SetPosition(Vec3(40, 0, 0))
		parent:SetAngles(Ang3(0,0,0)) 
		parent:SetScale(Vec3(2,1,1))
		--parent:SetShear(Vec3(0,0,0))
		
			local child = ecs.CreateEntity("shape", parent)
			child:SetPosition(Vec3(20,0,0))
			child:SetAngles(Ang3(0,0,0)) 
			child:SetScale(Vec3(1,1,1)) 
			
			child:SetColor(Color(1,0.5,1))
			
			-- shortcut this somehow but the argument needs to be transform not entity
			--child:GetComponent("transform"):SetParent(parent:GetComponent("transform"))
		
		event.AddListener("Update", "lol", function()
			local t = timer.GetElapsedTime()*100
			--parent:SetAngles(Ang3(0,t,0))
			--child:SetAngles(Ang3(0,t*-0.5,0))
		end)
	end
	
end

_G.ecs = ecs