local entities = (...) or _G.entities

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

COMPONENT.Network = {
	Position = {"vec3", 1/30, "unreliable"},
	Angles = {"ang3", 1/30, "unreliable"},
	
	Gravity = {"vec3", 1/5},
	Mass = {"unsigned long", 1/5},
	LinearDamping = {"float", 1/5},
	AngularDamping = {"float", 1/5},
	MassOrigin = {"vec3", 1/5},
	PhysicsBoxScale = {"vec3", 1/5},
	PhysicsSphereRadius = {"float", 1/5},
	PhysicsModelPath = {"string", 1/10},
}

COMPONENT.matrix = Matrix44()
COMPONENT.rigid_body = NULL

local function DELEGATE(META, field, typ)
	
	if typ == "vec3" then
		local name = "Set" .. field
		META[name] = function(s, vec)
			s[field] = vec
			if s.rigid_body:IsValid() then
				s.rigid_body[name](s.rigid_body, -vec.y, -vec.x, -vec.z)
			end
		end
				
		local name = "Get" .. field
		META[name] = function(s, ...)
			if s.rigid_body:IsValid() then
				local x, y, z = s.rigid_body[name](s.rigid_body, ...)
				return Vec3(-y, -x, -z)
			end
			return s[field]
		end
	elseif typ == "ang3" then
		local name = "Set" .. field
		META[name] = function(s, ang)
			s[field] = ang
			if s.rigid_body:IsValid() then
				s.rigid_body[name](s.rigid_body, ang.p, ang.y, ang.r)
			end
		end
				
		local name = "Get" .. field
		META[name] = function(s, ...)
			if s.rigid_body:IsValid() then
				local x, y, z = s.rigid_body[name](s.rigid_body, ...)
				return Ang3(x, y, z) 
			end
			return s[field]
		end
	else
		local name = "Set" .. field
		META[name] = function(s, val)
			s[field] = val
			if s.rigid_body:IsValid() then
				s.rigid_body[name](s.rigid_body, val)
			end
		end
		
		local name = "Get" .. field
		META[name] = function(s, val)
			if s.rigid_body:IsValid() then
				return s.rigid_body[name](s.rigid_body)
			end
			return s[field]
		end
	end
end
 
DELEGATE(COMPONENT, "MassOrigin", "vec3")
DELEGATE(COMPONENT, "Gravity", "vec3")
DELEGATE(COMPONENT, "Velocity", "vec3")
DELEGATE(COMPONENT, "AngularVelocity", "vec3")
DELEGATE(COMPONENT, "PhysicsBoxScale", "vec3")
DELEGATE(COMPONENT, "PhysicsSphereRadius")

DELEGATE(COMPONENT, "Mass")
DELEGATE(COMPONENT, "AngularDamping")
DELEGATE(COMPONENT, "LinearDamping")
DELEGATE(COMPONENT, "LinearSleepingThreshold")
DELEGATE(COMPONENT, "AngularSleepingThreshold")

function COMPONENT:SetPosition(vec)
	local transform = self:GetComponent("transform")
	transform:SetPosition(vec)
		
	if self.rigid_body:IsValid() and self.rigid_body:IsPhysicsValid() then
		local mat = transform:GetMatrix()
		self.rigid_body:SetMatrix(mat.m)
	end
end

local temp = Matrix44()

function COMPONENT:GetPosition()
	if self.rigid_body:IsValid() and self.rigid_body:IsPhysicsValid() then
		temp.m = self.rigid_body:GetMatrix()
		local x, y, z = temp:GetTranslation()
		local vec = Vec3(-y, -x, -z)
		--if x == 0 or y == 0 or z == 0 then	
		--	print(vec)
		--end
		return vec
	end
	
	return Vec3()
end

function COMPONENT:SetAngles(ang)
	local transform = self:GetComponent("transform")
	transform:SetAngles(ang)
	
	if self.rigid_body:IsValid() and self.rigid_body:IsPhysicsValid() then
		self.rigid_body:SetMatrix(transform:GetMatrix().m)
	end
end

function COMPONENT:GetAngles()
	if self.rigid_body:IsValid() and self.rigid_body:IsPhysicsValid() then
		temp.m = self.rigid_body:GetMatrix()
		
		local p,y,r = temp:GetAngles()
		local ang = Ang3(-y, p - math.pi / 2, r + -(math.pi)):Deg()
		--if math.round(p, 2) == 0 or math.round(y, 2) == 0 or math.round(r, 2) == 0 then print(ang) end
		return ang
	end
	
	return Ang3()
end

do
	local assimp = require("lj-assimp")

	function COMPONENT:InitPhysicsSphere(rad)
		local tr = self:GetComponent("transform")
		self.rigid_body:SetMatrix(tr:GetMatrix().m)
		
		self.rigid_body:InitPhysicsSphere(rad)
		
		if SERVER then
			local obj = self:GetComponent("networked")
			if obj:IsValid() then obj:CallOnClientsPersist(self.Name, "InitPhysicsSphere", rad) end
		end
	end
	
	function COMPONENT:InitPhysicsBox(scale)
		local tr = self:GetComponent("transform")
		self.rigid_body:SetMatrix(tr:GetMatrix().m)
		
		if scale then
			self.rigid_body:InitPhysicsBox(scale.x, scale.y, scale.z)
		else
			self.rigid_body:InitPhysicsBox()
		end
		
		if SERVER then
			local obj = self:GetComponent("networked")
			if obj:IsValid() then obj:CallOnClientsPersist(self.Name, "InitPhysicsBox", scale) end
		end
	end
	
	metatable.GetSet(COMPONENT, "PhysicsModelPath", "")
	metatable.GetSet(COMPONENT, "PhysicsModel", nil)
	
	function COMPONENT:SetPhysicsModelPath(path)
		self.PhysicsModelPath = path
		
		if vfs.Exists(path) then
			local scene = assimp.ImportFile(R(path), assimp.e.aiProcessPreset_TargetRealtime_Quality)
			if scene.mMeshes[0].mNumVertices == 0 then
				error("no vertices found in " .. path, 2)
			end
								
			local vertices = ffi.new("float[?]", scene.mMeshes[0].mNumVertices  * 3)
			local triangles = ffi.new("unsigned int[?]", scene.mMeshes[0].mNumFaces * 3)
			
			ffi.copy(vertices, scene.mMeshes[0].mVertices, ffi.sizeof(vertices))

			local i = 0
			for j = 0, scene.mMeshes[0].mNumFaces - 1 do
				for k = 0, scene.mMeshes[0].mFaces[j].mNumIndices - 1 do
					triangles[i] = scene.mMeshes[0].mFaces[j].mIndices[k]
					i = i + 1 
				end
			end
						
			local mesh = {	
				triangles = {
					count = tonumber(scene.mMeshes[0].mNumFaces), 
					pointer = triangles, 
					stride = ffi.sizeof("unsigned int") * 3, 
				},					
				vertices = {
					count = tonumber(scene.mMeshes[0].mNumVertices),  
					pointer = vertices, 
					stride = ffi.sizeof("float") * 3,
				},
			}
			
			assimp.ReleaseImport(scene)
			
			self:SetPhysicsModel(mesh)
		end
	end
	
	function COMPONENT:InitPhysicsConcave()
		local tr = self:GetComponent("transform")
		self.rigid_body:SetMatrix(tr:GetMatrix().m)
		
		self.rigid_body:InitPhysicsConcave(self:GetPhysicsModel())
		
		if SERVER then
			local obj = self:GetComponent("networked")
			if obj:IsValid() then obj:CallOnClientsPersist(self.Name, "InitPhysicsConcave") end
		end
	end
	
	function COMPONENT:InitPhysicsConvex(quantized_aabb_compression)
		local tr = self:GetComponent("transform")
		self.rigid_body:SetMatrix(tr:GetMatrix().m)
		
		self.rigid_body:InitPhysicsConvex(self:GetPhysicsModel(), quantized_aabb_compression)
		
		if SERVER then
			local obj = self:GetComponent("networked")
			if obj:IsValid() then obj:CallOnClientsPersist(self.Name, "InitPhysicsConvex", quantized_aabb_compression) end
		end
	end
end		

function COMPONENT:OnUpdate()
	if not self.rigid_body:IsValid() or not self.rigid_body:IsPhysicsValid() then return end
	
	local transform = self:GetComponent("transform")
	
	local matrix = self.matrix
	matrix.m = self.rigid_body:GetMatrix()
	local mat = matrix:Copy()
	
	transform:SetTRMatrix(mat)
end

function COMPONENT:OnAdd(ent)
	self.rigid_body = bullet.CreateRigidBody()
end

function COMPONENT:OnRemove(ent)
	if self.rigid_body:IsValid() then
		self.rigid_body:Remove()
	end
end

entities.RegisterComponent(COMPONENT)