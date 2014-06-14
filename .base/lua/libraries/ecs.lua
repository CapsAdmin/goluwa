local ecs = _G.ecs or {}

ecs = {}

ecs.entities = ecs.entities or {}
ecs.configurations = ecs.configurations or {}
ecs.active_components = ecs.active_components or {}

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

local events = {}
local ref_count = {}

local function add_event(event_type, component)
	ref_count[event_type] = (ref_count[event_type] or 0) + 1
	
	local func_name = "On" .. event_type
	
	events[event_type] = events[event_type] or {}
	events[event_type][component.Name] = events[event_type][component.Name] or {}
	
	table.insert(events[event_type][component.Name], component)
	
	event.AddListener(event_type, "ecs", function(...) 
		for name, components in pairs(events[event_type]) do
			for i, component in ipairs(components) do
				component[func_name](component, ...)
			end
		end
	end)
end

local function remove_event(event_type, component)
	ref_count[event_type] = (ref_count[event_type] or 0) - 1
	
	events[event_type] = events[event_type] or {}
	events[event_type][component.Name] = events[event_type][component.Name] or {}
	
	for i, other in pairs(events[event_type][component.Name]) do
		if other == component then
			events[event_type][component.Name][i] = nil
			break
		end
	end
	
	table.fixindices(events[event_type][component.Name])

	for i, component in ipairs(events[event_type]) do
		component[func_name](component)
	end
	
	if ref_count[event_type] <= 0 then
		event.RemoveListener(event_type, "ecs")
	end
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
				
		for i, other in ipairs(obj.Require) do
			if not self.Components[other] then
				error("component " .. name .. " requires component " .. other, 2)
			end
		end
		
		obj.Id = id
		obj.Entity = self
				
		for i, event_type in ipairs(obj.Events) do
			add_event(event_type, obj)
		end
		
		self.Components[name][id] = obj
		
		obj:OnAdd(self, ...)
	end

	function ENTITY:RemoveComponent(name, id)
		id = id or "no_id"
		
		if not self.Components[name] then return end
			
		local obj = self.Components[name][id] or NULL
		
		if obj:IsValid() then
		
			for i, event_type in ipairs(obj.Events) do
				remove_event(event_type, obj)
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
	
	BASE.Require = {}
	BASE.Events = {}
	
	metatable.GetSet(BASE, "Id")
	metatable.Delegate(BASE, "Entity", "GetComponent")
	metatable.Delegate(BASE, "Entity", "AddComponent")
	metatable.Delegate(BASE, "Entity", "RemoveComponent")
	
	function BASE:OnAdd()
	
	end
		
	function BASE:OnRemove()
	
	end
	
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
		local obj = ecs.GetComponent(name):New()
		
		table.insert(ecs.active_components, obj)
		
		return obj
	end
end

do -- test
	do -- transform
		local COMPONENT = {}
		
		COMPONENT.Name = "transform"
		
		metatable.AddParentingTemplate(COMPONENT)
		
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
			
			for _, child in ipairs(self:GetChildren(true)) do
				self.rebuild_tr_matrix = true
			end
		end
		
		function COMPONENT:RebuildMatrix()			
			if self.rebuild_tr_matrix then				
				self.TRMatrix:Identity()

				self.TRMatrix:Translate(-self.Position.y, -self.Position.x, -self.Position.z)
				
				self.TRMatrix:Rotate(-self.Angles.y, 0, 0, 1)
				self.TRMatrix:Rotate(-self.Angles.p + 90, 1, 0, 0)
				self.TRMatrix:Rotate(self.Angles.r + 180, 0, 0, 1)	
				
				if self:HasParent() then
					self.templol = self.templol or Matrix44()
					
					--self.TRMatrix = self.TRMatrix * self.Parent.TRMatrix
					self.TRMatrix:Multiply(self.Parent.TRMatrix, self.templol)
					self.TRMatrix, self.templol = self.templol, self.TRMatrix
				end
				
				self.rebuild_tr_matrix = false
			end
		
			if self.rebuild_scale_matrix and not (self.temp_scale.x == 1 and self.temp_scale.y == 1 and self.temp_scale.z == 1) then
				self.ScaleMatrix:Identity()
				self.ScaleMatrix:Scale(self.temp_scale.x, self.temp_scale.z, self.temp_scale.y)
				--self.ScaleMatrix:Shear(self.Shear)
				
				self.rebuild_scale_matrix = false
			end
		end
		
		function COMPONENT:GetMatrix()
			self:RebuildMatrix()
			
			if self.temp_scale.x == 1 and self.temp_scale.y == 1 and self.temp_scale.z == 1 then
				return self.TRMatrix 
			end
			
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
			metatable.GetSet(COMPONENT, "Texture", NULL)
			metatable.GetSet(COMPONENT, "Color", Color(1, 1, 1))
			metatable.GetSet(COMPONENT, "Alpha", 1)
			metatable.GetSet(COMPONENT, "ModelPath", "models/face.obj")
		metatable.EndStorable()
		
		metatable.GetSet(COMPONENT, "Shader", NULL)
		metatable.GetSet(COMPONENT, "Model", nil)
		
		if CLIENT then			
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
						{texture_blend = "float"},
					},	
					source = "gl_Position = pvm_matrix * vec4(pos, 1.0);"
				},
				fragment = { 
					uniform = {
						color = Color(1,1,1,1),
						diffuse = "sampler2D",
						diffuse2 = "sampler2D",
						--detail = "sampler2D",
						--detailscale = 1,
						
						--bump = "sampler2D",
						--specular = "sampler2D",
					},		
					attributes = {
						{uv = "vec2"},
						{texture_blend = "float"},
					},			
					source = [[
						out vec4 out_color;

						void main() 
						{
							out_color = mix(texture(diffuse, uv), texture(diffuse2, uv), texture_blend) * color;
							//out_color.rgb *= texture(detail, uv * detailscale).rgb;
						}
					]]
				}  
			}
					
			function COMPONENT:OnAdd(ent)
				self.Texture = render.GetWhiteTexture()
				self.Shader = render.CreateShader(SHADER)
			end

			function COMPONENT:OnRemove(ent)

			end	
			
			function COMPONENT:SetModelPath(path)
				self.ModelPath = path
				self.Model = render.Create3DMesh(path)
			end
			
			function COMPONENT:OnDraw3D(dt)
			
				local model = self.Model
				local shader = self.Shader

				if not render.matrices.vp_matrix then return end -- FIX ME			
				if not model then return end
				if not shader then return end

				local matrix = self:GetComponent("transform"):GetMatrix() 
				local temp = Matrix44()
				
				local visible = false
				
				if model.corners then
					model.LOL = model.LOL or {}
					for _, pos in ipairs(model.corners) do
						model.LOL[_] = model.LOL[_] or Matrix44()
						model.LOL[_]:Identity()
						model.LOL[_]:Translate(pos.x, pos.y, pos.z)
						
						model.LOL[_]:Multiply(matrix, temp)
						temp:Multiply(render.matrices.vp_matrix, model.LOL[_])
						
						local x, y, z = model.LOL[_]:GetClipCoordinates()
						
						if x > -1 and x < 1 and y > -1 and y < 1 and z > -1 then
							visible = true
							break
						end
					end
				else
					visible = true
				end
				
				if visible then
					local screen = matrix * render.matrices.vp_matrix
					shader.pvm_matrix = screen.m
					shader.color = self.Color
					
					for i, model in ipairs(model.sub_models) do
						shader.diffuse = model.diffuse or render.GetErrorTexture()
						shader.diffuse2 = model.diffuse2 or render.GetErrorTexture()
						--shader.detail = model.detail or render.GetWhiteTexture()
						shader:Bind()
						model.mesh:Draw()
					end
				else
				--	print(os.clock())
				end
			end 
		end

		ecs.RegisterComponent(COMPONENT)
	end
	
	do -- physics
		local bullet = require("lj-bullet3")
		bullet.Initialize()
		bullet.SetGravity(0,0,9.8) 		 
		
		event.AddListener("Update", "bullet", function(dt)
			bullet.Update(dt)
		end)
		
		local COMPONENT = {}
		
		COMPONENT.Name = "physics"
		COMPONENT.Require = {"transform"}
		COMPONENT.Events = {"Update"}
	
		COMPONENT.matrix = Matrix44()
		COMPONENT.rigid_body = NULL
		
		local function DELEGATE(META, field, typ)
			
			if typ == "vec3" then
				local name = "Set" .. field
				META[name] = function(s, vec)
					if s.rigid_body:IsValid() then
						s.rigid_body[name](s.rigid_body, -vec.y, -vec.x, vec.z)
					end
				end
				
				local ctor = typ == "vec3" and Vec3 or Ang3
				
				local name = "Get" .. field
				META[name] = function(s, ...)
					if s.rigid_body:IsValid() then
						local x, y, z = s.rigid_body[name](s.rigid_body, ...)
						return Vec3(-y, -x, z)
					end
				end
			elseif typ == "ang3" then
				local name = "Set" .. field
				META[name] = function(s, ang)
					if s.rigid_body:IsValid() then
						s.rigid_body[name](s.rigid_body, ang.p, ang.y, ang.r)
					end
				end
				
				local ctor = typ == "vec3" and Vec3 or Ang3
				
				local name = "Get" .. field
				META[name] = function(s, ...)
					if s.rigid_body:IsValid() then
						local x, y, z = s.rigid_body[name](s.rigid_body, ...)
						return Ang3(x, y, z)
					end
				end
			else
				local name = "Set" .. field
				META[name] = function(s, ...)
					if s.rigid_body:IsValid() then
						s.rigid_body[name](s.rigid_body, ...)
					end
				end
				
				local name = "Get" .. field
				META[name] = function(s, ...)
					if s.rigid_body:IsValid() then
						return s.rigid_body[name](s.rigid_body, ...)
					end
				end
			end
		end
		 
		DELEGATE(COMPONENT, "Gravity", "vec3")
		DELEGATE(COMPONENT, "Velocity", "vec3")
		DELEGATE(COMPONENT, "AngularVelocity", "vec3")
		
		DELEGATE(COMPONENT, "Mass")
		DELEGATE(COMPONENT, "Damping")
	
		function COMPONENT:SetPosition(vec)
			local transform = self:GetComponent("transform")
			transform:SetPosition(vec)
				
			local body = self.rigid_body
			if body:IsValid() then
				body:SetMatrix(transform:GetMatrix().m)
			end
		end
		
		function COMPONENT:GetPosition()
			local x, y, z = self:GetComponent("transform").TRMatrix:GetTranslation()
			return Vec3(-y, -x, -z)
		end
		
		function COMPONENT:SetAngles(ang)
			local transform = self:GetComponent("transform")
			transform:SetAngles(ang)
			
			local body = self.rigid_body
			if body:IsValid() then
				body:SetMatrix(transform:GetMatrix().m)
			end
		end
		
		function COMPONENT:GetAngles()
			return self:GetComponent("transform").TRMatrix:GetAngles()
		end
		
		do
			local assimp = require("lj-assimp")
		
			function COMPONENT:InitPhysics(type, mass, ...)
				local transform = self:GetComponent("transform")
				transform:InvalidateScaleMatrix()
				
				if (type == "convex" or type == "concave") and _G.type((...)) == "string" and vfs.Exists((...)) then
					local rest = {select(2, ...)}
					
					local scene = assimp.ImportFile(R((...)), assimp.e.aiProcessPreset_TargetRealtime_Quality)
					
					local vertices = ffi.new("float[?]", scene.mMeshes[0].mNumVertices  * 3)
					local triangles = ffi.new("unsigned int[?]", scene.mMeshes[0].mNumFaces * 3)
					
					-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WTF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WTF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WTF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					PLEASE_DONT_GC_ME = PLEASE_DONT_GC_ME or {}
					
					table.insert(PLEASE_DONT_GC_ME, vertices)
					table.insert(PLEASE_DONT_GC_ME, triangles)
					-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WTF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WTF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! WTF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					
					ffi.copy(vertices, scene.mMeshes[0].mVertices, ffi.sizeof(vertices))
										
					local i = 0
					for j = 0, scene.mMeshes[0].mNumFaces - 1 do
						for k = 0, scene.mMeshes[0].mFaces[j].mNumIndices - 1 do
							triangles[i] = scene.mMeshes[0].mFaces[j].mIndices[k]
							i = i + 1 
						end
					end
				
					assimp.ReleaseImport(scene)
				
					local mesh = {	
						triangles = {
							count = scene.mMeshes[0].mNumFaces, 
							pointer = triangles, 
							stride = ffi.sizeof("unsigned int") * 3, 
						},					
						vertices = {
							count = scene.mMeshes[0].mNumVertices,  
							pointer = ffi.cast("float *", vertices), 
							stride = ffi.sizeof("float") * 3,
						},
					}
					
					self.rigid_body = bullet.CreateRigidBody(type, mass, transform:GetMatrix().m, mesh, unpack(rest))
				else
					self.rigid_body = bullet.CreateRigidBody(type, mass, transform:GetMatrix().m, ...)
				end
				
				return self.rigid_body
			end
		end		
		
		function COMPONENT:OnUpdate()
			if not self.rigid_body:IsValid() then return end
			
			local transform = self:GetComponent("transform")
			
			local matrix = self.matrix
			matrix.m = self.rigid_body:GetMatrix()
			local mat = matrix:Copy()
			
			transform:SetTRMatrix(mat)
		end
		
		ecs.RegisterComponent(COMPONENT)
	end
		
	ecs.SetupComponents("shape", {"transform", "visual"})
	ecs.SetupComponents("shape2", {"transform", "visual", "physics"})

	function ecs.Test()
	
		local parent = ecs.CreateEntity("shape")
		
		parent:SetTexture(Texture("textures/debug/brain.jpg"))
		parent:SetColor(Color(1,1,1))
		parent:SetAlpha(1)
		parent:SetPosition(Vec3(5000, 0, 0))
		parent:SetAngles(Ang3(0,90,0)) 
		parent:SetScale(Vec3(1,1,1))
		--parent:SetShear(Vec3(0,0,0))
		
		if false then
		local node = parent
		
		for i = 1, 2000 do
		
			local child = ecs.CreateEntity("shape", node)
			child:SetPosition(Vec3(60,0,0))
			child:SetAngles(Ang3(0,0,0)) 
			child:SetScale(Vec3(1, 1, 1)) 
			
			--child:SetColor(Color(500,100,500))
			
			-- shortcut this somehow but the argument needs to be transform not entity
			--child:GetComponent("transform"):SetParent(parent:GetComponent("transform"))
			
			node = child
		end
		
		local start = timer.GetElapsedTime()
		
		parent:BuildChildrenList()
		
		event.AddListener("Update", "lol", function()			
			local t = timer.GetElapsedTime() - start 
			for i, child in ipairs(parent:GetAllChildren()) do
				child:SetAngles(Ang3(t,t,t))
				t = t * 1.001
			end
			
		end, {priority = -19})
		end
		
		
		--[[if true then  
			local gl = require("lj-opengl")
			bullet.EnableDebug(
				function(from_x, from_y, from_z, to_x, to_y, to_z, r, g, b) 	
					local pos_a = Vec3(from_x, from_y, from_z):ToScreen()
					local pos_b = Vec3(to_x, to_y, to_z):ToScreen()
					
					surface.SetColor(r,g,b)
					surface.DrawLine(pos_a.x, pos_a.y, pos_b.x, pos_b.y)
				end,
				function(x, y, z, nx, ny, nz, distance, lifetime, r,g,b)
				
					gl.Color3f(r,g,b)
					
					local pos_a = Vec3(x, y, z):ToScreen()
					local pos_b = Vec3(nx, ny, nz):ToScreen()
					
					surface.SetColor(r,g,b)
					surface.DrawLine(pos_a.x, pos_a.y, pos_b.x, pos_b.y)
				end,
				function(x, y, z, str)
					local pos = Vec3(x,y,z):ToScreen()
					surface.SetTextPos(pos.x, pos.y)
					surface.DrawText(ffi.string(str)) 
				end,
				function(str)
					logn("[bullet] ", ffi.string(str))
				end
			)
			event.AddListener("DrawHUD", "bullet_debug", function()
				bullet.DrawDebugWorld()
			end)	
		else
			bullet.DisableDebug()
			event.RemoveListener("Draw3D", "bullet_debug")
		end]]
		event.Delay(function()    
			
			local world = ecs.CreateEntity("shape2")
			world:SetModelPath("models/cube.obj")  
			world:InitPhysics("box", 0, 500, 1, 500)  
			world:SetPosition(Vec3(0,0,0)) 
			world:SetAngles(Ang3(0,0,0))
			world:SetScale(Vec3(500, 500, 0))			
			
			for i = 1, 10 do
				local body = ecs.CreateEntity("shape2")
				body:SetModelPath("models/cube.obj")
				body:SetPosition(Vec3(0,0,1+i*10)) 
				body:InitPhysics("convex", 10, "models/cube.obj", true)  
				body:SetSize(1)
				ASDF = body
			end
		end)
	end
end

_G.ecs = ecs