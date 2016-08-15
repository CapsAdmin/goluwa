local META = prototype.CreateTemplate()

META.Name = "physics"
META.Require = {"transform"}
META.Events = {"Update"}

META.Network = {
	Position = {"vec3", 1/30, "unreliable", false, 70},
	Rotation = {"quat", 1/30, "unreliable", false, 70},

	Mass = {"unsigned long", 1/5},
	LinearDamping = {"float", 1/5},
	AngularDamping = {"float", 1/5},
	MassOrigin = {"vec3", 1/5},
	PhysicsBoxScale = {"vec3", 1/5},
	PhysicsSphereRadius = {"float", 1/5},
	PhysicsCapsuleZRadius = {"float", 1/5},
	PhysicsCapsuleZHeight = {"float", 1/5},
	PhysicsModelPath = {"string", 1/10, "reliable", true}, -- last true means don't send default path (blank path in this case)
}

function META:Initialize()
	self.rigid_body = NULL
end

META:StartStorable()

	META:GetSet("Position", Vec3(0, 0, 0))
	META:GetSet("Rotation", Quat(0, 0, 0, 1))
	META:GetSet("PhysicsModelPath", "")
	prototype.DelegateProperties(META, prototype.GetRegistered("physics_body"), "rigid_body")

META:EndStorable()

META:GetSet("PhysicsModel", nil)

local function to_physics_body(self)
	if not self.rigid_body:IsValid() or not self.rigid_body:IsPhysicsValid() then return end

	local pos = self.Position
	local rot = self.Rotation

	local out = Matrix44()
	out:SetTranslation(pos.x, pos.y, pos.z)
	out:SetRotation(rot)

	self.rigid_body:SetMatrix(out)
end

local function from_physics_body(self)
	if not self.rigid_body:IsValid() or not self.rigid_body:IsPhysicsValid() then return Matrix44() end

	local out = self.rigid_body:GetMatrix()

--	local x,y,z = out:GetTranslation()
	--local p,y,r = out:GetAngles()

--	local out = Matrix44()

	--out:Translate(x, y, z)


	--out:Rotate(math.deg(y), 0, 1, 0)
	--out:Rotate(math.deg(r), 1, 0, 0)

	--out:Scale(1,-1,-1)

--	print(self:GetEntity(), self.Position, out:GetTranslation())

	return out:Copy()
end

function META:UpdatePhysicsObject()
	to_physics_body(self)
end

function META:SetPosition(vec)
	self.Position = vec
	to_physics_body(self)
end

function META:GetPosition()
	return Vec3(from_physics_body(self):GetTranslation())
end

function META:SetRotation(rot)
	self.Rotation = rot
	to_physics_body(self)
end

function META:GetRotation()
	return from_physics_body(self):GetRotation()
end

function META:SetAngles(ang)
	self:SetRotation(Quat(0,0,0,1):SetAngles(ang))
end

function META:GetAngles()
	return self:GetRotation():GetAngles()
end

do
	function META:InitPhysicsSphere(rad)
		if physics.IsReady() then
			self.rigid_body:SetMatrix(self:GetComponent("transform"):GetMatrix():Copy())
			self.rigid_body:InitPhysicsSphere(rad)
		end

		if SERVER then
			local obj = self:GetComponent("network")
			if obj then obj:CallOnClientsPersist(self.Name, "InitPhysicsSphere", rad) end
		end

		to_physics_body(self)
	end

	function META:InitPhysicsBox(scale)
		if physics.IsReady() then
			self.rigid_body:SetMatrix(self:GetComponent("transform"):GetMatrix():Copy())

			if scale then
				self.rigid_body:InitPhysicsBox(scale)
			else
				self.rigid_body:InitPhysicsBox()
			end
		end

		if SERVER then
			local obj = self:GetComponent("network")
			if obj then obj:CallOnClientsPersist(self.Name, "InitPhysicsBox", scale) end
		end

		to_physics_body(self)
	end

	function META:InitPhysicsCapsuleZ()
		if physics.IsReady() then
			local tr = self:GetComponent("transform")
			self.rigid_body:SetMatrix(tr:GetMatrix():Copy())
			self.rigid_body:InitPhysicsCapsuleZ()
		end

		if SERVER then
			local obj = self:GetComponent("network")
			if obj then obj:CallOnClientsPersist(self.Name, "InitPhysicsCapsuleZ") end
		end

		to_physics_body(self)
	end

	function META:SetPhysicsModelPath(path)
		self.PhysicsModelPath = path

		physics.LoadModel(path, function(physics_meshes)
			if not self:IsValid() then return end

			-- TODO: support for more bodies
			if #physics_meshes > 1 then

				for _, v in pairs(self:GetEntity():GetChildren()) do
					if v.physics_chunk then
						v:Remove()
					end
				end

				for i, mesh in ipairs(physics_meshes) do
					local chunk = entities.CreateEntity("physical", self:GetEntity(), {exclude_components = {"network"}})
					--chunk:SetHideFromEditor(true)
					chunk:SetMovable(false)
					chunk:SetName("physics chunk " .. i)
					chunk:SetModelPath("models/cube.obj")
					chunk:SetPhysicsModel(mesh)
					chunk:InitPhysicsTriangles()
					chunk.physics_chunk = true
				end
			else
				self:SetPhysicsModel(physics_meshes[1])
			end

			to_physics_body(self)
		end, function(err)
			llog("%s failed to load physics model %q: %s", self, path, err)
			for _, v in pairs(self:GetEntity():GetChildren()) do
				if v.physics_chunk then
					v:Remove()
				end
			end
		end)
	end

	function META:InitPhysicsConvexHull()
		if physics.IsReady() then
			local tr = self:GetComponent("transform")
			self.rigid_body:SetMatrix(tr:GetMatrix():Copy())

			if self:GetPhysicsModel() then
				self.rigid_body:InitPhysicsConvexHull(self:GetPhysicsModel().vertices.pointer, self:GetPhysicsModel().vertices.count)
			end
		end

		if SERVER then
			local obj = self:GetComponent("network")
			if obj then obj:CallOnClientsPersist(self.Name, "InitPhysicsConvexHull") end
		end

		to_physics_body(self)
	end

	function META:InitPhysicsConvexTriangles()
		if physics.IsReady() then
			local tr = self:GetComponent("transform")
			self.rigid_body:SetMatrix(tr:GetMatrix():Copy())

			if self:GetPhysicsModel() then
				self.rigid_body:InitPhysicsConvexTriangles(self:GetPhysicsModel())
			end
		end

		if SERVER then
			local obj = self:GetComponent("network")
			if obj then obj:CallOnClientsPersist(self.Name, "InitPhysicsConvexTriangles") end
		end

		to_physics_body(self)
	end

	function META:InitPhysicsTriangles()
		if physics.IsReady() then
			local tr = self:GetComponent("transform")
			self.rigid_body:SetMatrix(tr:GetMatrix():Copy())

			if self:GetPhysicsModel() then
				self.rigid_body:InitPhysicsTriangles(self:GetPhysicsModel())
			end
		end

		if SERVER then
			local obj = self:GetComponent("network")
			if obj then obj:CallOnClientsPersist(self.Name, "InitPhysicsTriangles") end
		end

		to_physics_body(self)
	end
end

local zero = Vec3()

function META:OnUpdate()
	if
		not physics.IsReady() or
		not self.rigid_body:IsValid() or
		not self.rigid_body:IsPhysicsValid()
	then
		return
	end

	local transform = self:GetComponent("transform")

	transform:SetTRMatrix(from_physics_body(self))
end

function META:OnAdd(ent)
	self:GetComponent("transform"):SetSkipRebuild(true)
	if physics.IsReady() then
		self.rigid_body = physics.CreateBody()
		self.rigid_body.ent = self
	end
end

function META:OnRemove(ent)
	if self.rigid_body:IsValid() then
		self.rigid_body:Remove()
	end
end

META:RegisterComponent()

--include("physics_container.lua")