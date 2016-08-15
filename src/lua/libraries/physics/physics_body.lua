local ffi = require("ffi")
local physics = ... or _G.physics

local META = prototype.CreateTemplate("physics_body")

META:StartStorable()

local function check(obj)
	return physics.init and obj.body
end

do -- matrix44
	META:GetSet("Matrix", Matrix44())

	function META:SetMatrix(m)
		if check(self) then
			physics.ode.BodySetPosition(self.body, physics.Vec3ToODE(m:GetTranslation()))
			physics.ode.BodySetQuaternion(self.body, m:GetRotation():GetFloatPointer())
		end
		self.Matrix = m
	end

	function META:GetMatrix()
		if check(self) then
			local p = physics.ode.BodyGetPosition(self.body)
			local r = physics.ode.BodyGetQuaternion(self.body)
			local m = Matrix44()
			m:SetRotation(Quat(r[0], r[1], r[2], r[3]))
			m:Translate(physics.Vec3FromODE(p[0], p[1], p[2]))
			return m
		end

		return self.Matrix
	end
end

do -- damping
	META:GetSet("LinearDamping", 0)
	META:GetSet("AngularDamping", 0)

	function META:SetLinearDamping(damping)
		self.LinearDamping = damping
		if not check(self) then return end
		physics.ode.BodySetLinearDamping(self.body, self:GetLinearDamping())
	end

	function META:GetLinearDamping()
		return self.LinearDamping
	end

	function META:SetAngularDamping(damping)
		self.AngularDamping = damping
		if not check(self) then return end
		physics.ode.BodySetAngularDamping(self.body, self:GetAngularDamping())
	end

	function META:GetAngularDamping()
		return self.AngularDamping
	end
end

do -- mass
	META:GetSet("MassOrigin", Vec3())
	META:GetSet("Mass", 1)

	function META:SetMassOrigin(origin)
		self.MassOrigin = origin

		if check(self) then
			local info = ffi.new("struct dMass[1]")
			physics.ode.BodyGetMass(self.body, info)

			local x,y,z = physics.Vec3ToODE(self:GetMassOrigin():Unpack())
			info[0].c[0] = x
			info[0].c[1] = y
			info[0].c[2] = z

			physics.ode.BodySetMass(self.body, info)
		end
	end

	function META:SetMass(val)
		self.Mass = val

		if check(self) then
			local info = ffi.new("struct dMass[1]")
			physics.ode.BodyGetMass(self.body, info)

			info[0].mass = self:GetMass()

			physics.ode.BodySetMass(self.body, info)
		end
	end

	--local out = ffi.new("float[1]")

	function META:GetMass()
		if check(self) then
			local out = ffi.new("struct dMass[1]")
			physics.ode.BodyGetMass(self.body, out)
			return out[0].mass
		end

		return self.Mass
	end

	function META:GetMassOrigin()
		if check(self) then
			local out = ffi.new("struct dMass[1]")
			physics.ode.BodyGetMass(self.body, out)
			return Vec3(physics.Vec3ToODE(out[0].c[0], out[0].c[2], out[0].c[2]))
		end

		return self.Mass
	end
end

local function update_params(self)
	self:SetMass(self:GetMass())
	self:SetLinearDamping(self:GetLinearDamping())
	self:SetAngularDamping(self:GetAngularDamping())
end

do -- init sphere options
	META:GetSet("PhysicsSphereRadius", 1)

	function META:InitPhysicsSphere(rad)
		if rad then self:SetPhysicsSphereRadius(rad) end

		if physics.init then
			self.body = physics.ode.BodyCreate(physics.world)
			self.geom = physics.ode.CreateSphere(physics.hash_space, self:GetPhysicsSphereRadius())
			physics.ode.GeomSetBody(self.geom, self.body)

			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)
	end
end

do -- init box options
	META:GetSet("PhysicsBoxScale", Vec3(1, 1, 1))

	function META:InitPhysicsBox(scale)
		if scale then self:SetPhysicsBoxScale(scale) end

		if physics.init then
			self.body = physics.ode.BodyCreate(physics.world)
			self.geom = physics.ode.CreateBox(physics.hash_space, physics.Vec3ToODE(self:GetPhysicsBoxScale():Unpack()))
			physics.ode.GeomSetBody(self.geom, self.body)

			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)
	end
end

do -- init capsule options
	META:GetSet("PhysicsBoxScale", Vec3(1, 1, 1))
	META:GetSet("PhysicsCapsuleZRadius", 0.5)
	META:GetSet("PhysicsCapsuleZHeight", 1.85)

	function META:InitPhysicsCapsuleZ()
		if physics.init then
			self.body = physics.ode.BodyCreate(physics.world)
			self.geom = physics.ode.CreateCCylinder(physics.hash_space, self:GetPhysicsCapsuleZRadius(), self:GetPhysicsCapsuleZHeight())
			physics.ode.GeomSetBody(self.geom, self.body)

			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)
	end
end

do -- mesh init options

	function META:InitPhysicsConvexHull(tbl)
		warning("NYI")
		--[[if not physics.init then return end

		-- if you don't do this "tbl" will get garbage collected and physics.bullet will crash
		-- because bullet says it does not make any copies of indices or vertices

		local mesh = ffi.new("float["..#tbl.."]", tbl)

		self.mesh = tbl

		if physics.init then
			self.body = physics.bullet.CreateRigidBodyConvexHull(self:GetMass(), self:GetMatrix():GetFloatCopy(), mesh)
			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)
		]]
	end

	function META:InitPhysicsConvexTriangles(tbl)
		warning("NYI")
		--[[if not physics.init then return end

		-- if you don't do this "tbl" will get garbage collected and bullet will crash
		-- because bullet says it does not make any copies of indices or vertices

		local mesh = physics.bullet.CreateMesh(
			tbl.triangles.count,
			tbl.triangles.pointer,
			tbl.triangles.stride,

			tbl.vertices.count,
			tbl.vertices.pointer,
			tbl.vertices.stride
		)

		self.mesh = tbl

		if physics.init then
			self.body = physics.bullet.CreateRigidBodyConvexTriangleMesh(self:GetMass(), self:GetMatrix():GetFloatCopy(), mesh)
			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)]]
	end

	function META:InitPhysicsTriangles(tbl)
		if not physics.init then return end

		self.mesh = tbl

		if physics.init then
			local data = physics.ode.GeomTriMeshDataCreate()

			physics.ode.GeomTriMeshDataBuildSingle(
				data,
				tbl.vertices.pointer,
				tbl.vertices.stride,
				tbl.vertices.count,

				tbl.triangles.pointer,
				tbl.triangles.count,
				tbl.triangles.stride
			)

			self.body = physics.ode.BodyCreate(physics.world)
			self.geom = physics.ode.CreateTriMesh(physics.hash_space, data, nil,nil,nil)
			physics.ode.GeomSetBody(self.geom, self.body)

			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)
	end
end


do -- generic get set

	local function GET_SET(name, friendly, default)
		local set_func = physics.ode and physics.ode["BodySet" .. name] or function() end
		local get_func = physics.ode and physics.ode["BodyGet" .. name] or function() end

		META:GetSet(friendly, default)

		if type(default) == "number" then
			META["Set" .. friendly] = function(self, var)
				self[friendly] = var
				if not check(self) then return end
				set_func(self.body, var)
			end

			META["Get" .. friendly] = function(self)
				if not self.body then return self[friendly] end

				return get_func(self.body)
			end
		elseif typex(default) == "vec3" then
			META["Set" .. friendly] = function(self, var)
				self[friendly] = var
				if not check(self) then return end
				set_func(self.body, physics.Vec3ToODE(var.x, var.y, var.z))
			end

			META["Get" .. friendly] = function(self)
				if not self.body then return self[friendly] end
				local out = get_func(self.body)
				return Vec3(physics.Vec3FromODE(out[0], out[1], out[2]))
			end
		end
	end

	GET_SET("LinearVel", "Velocity", Vec3())
	GET_SET("AngularVel", "AngularVelocity", Vec3())
end

META:EndStorable()

function META:IsPhysicsValid()
	return self.body ~= nil
end

function META:OnRemove()
	for k,v in ipairs(physics.bodies) do
		if v == self then
			table.remove(physics.bodies, k)
			break
		end
	end
	if check(self) then
		physics.ode.BodyDestroy(self.body)
	end
end

META:Register()

function physics.CreateBody()
	local self = META:CreateObject()

	table.insert(physics.bodies, self)

	return self
end