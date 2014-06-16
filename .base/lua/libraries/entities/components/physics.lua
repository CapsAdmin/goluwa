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
		local mat = transform:GetMatrix()
		body:SetMatrix(mat.m)
	end
end

local temp = Matrix44()

function COMPONENT:GetPosition()
	if self.rigid_body:IsValid() then
		temp.m = self.rigid_body:GetMatrix()
		local x, y, z = temp:GetTranslation()
		vec = Vec3(-y, -x, -z)
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
	
	local body = self.rigid_body
	if body:IsValid() then
		body:SetMatrix(transform:GetMatrix().m)
	end
end

function COMPONENT:GetAngles()
	if self.rigid_body:IsValid() then
		temp.m = self.rigid_body:GetMatrix()
		
		local p,y,r = temp:GetAngles()
		local ang = Ang3((-y),p - math.pi / 2,r + -(math.pi)):Deg()
		--if math.round(p, 2) == 0 or math.round(y, 2) == 0 or math.round(r, 2) == 0 then print(ang) end
		return ang
	end
	
	return Ang3()
end

do
	local assimp = require("lj-assimp")

	function COMPONENT:InitPhysics(type, mass, ...)
		local transform = self:GetComponent("transform")
		transform:InvalidateScaleMatrix()
		
		if (type == "convex" or type == "concave") and _G.type((...)) == "string" and vfs.Exists((...)) then
			local rest = {select(2, ...)}
			
			local scene = assimp.ImportFile(R((...)), assimp.e.aiProcessPreset_TargetRealtime_Quality)
			
			if scene.mMeshes[0].mNumVertices == 0 then
				error("no vertices found in " .. (...), 2)
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

function COMPONENT:OnRemove(ent)
	if self.rigid_body:IsValid() then
		self.rigid_body:Remove()
	end
end

entities.RegisterComponent(COMPONENT)