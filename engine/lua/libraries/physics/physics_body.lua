local ffi = require("ffi")
local ode = desire("ode")
local physics = ... or _G.physics
local META = prototype.CreateTemplate("physics_body")
META:StartStorable()
META:IsSet("Movable", true)

function META:SetMovable(b)
	self.Movable = b
end

local function check_body(obj)
	return physics.init and obj.body
end

local function check_geom(obj)
	return physics.init and obj.geom
end

do -- matrix44
	META:GetSet("Matrix", Matrix44())

	function META:SetMatrix(m)
		if self.Movable then
			if check_body(self) then
				ode.BodySetPosition(self.body, physics.Vec3ToEngine(m:GetTranslation()))
				ode.BodySetQuaternion(self.body, m:GetRotation():GetDoublePointer())
			end
		else
			if check_geom(self) then
				ode.GeomSetPosition(self.geom, physics.Vec3ToEngine(m:GetTranslation()))
				ode.GeomSetQuaternion(self.geom, m:GetRotation():GetDoublePointer())
			end
		end

		self.Matrix = m
	end

	function META:GetMatrix()
		local p
		local r

		if self.Movable then
			if check_body(self) then
				p = ode.BodyGetPosition(self.body)
				r = ode.BodyGetQuaternion(self.body)
			end
		else
			if check_geom(self) then
				p = ode.GeomGetPosition(self.geom)
				r = ffi.new("double[4]")
				ode.GeomGetQuaternion(self.geom, r)
			end
		end

		local m = Matrix44()

		if p and r then
			m:Translate(physics.Vec3FromEngine(p[0], p[1], p[2]))
			m:SetRotation(Quat(r[0], r[1], r[2], r[3]))
		end

		return m
	end
end

do -- damping
	META:GetSet("LinearDamping", 0)
	META:GetSet("AngularDamping", 0)

	function META:SetLinearDamping(damping)
		self.LinearDamping = damping

		if not check_body(self) then return end

		ode.BodySetLinearDamping(self.body, self:GetLinearDamping())
	end

	function META:GetLinearDamping()
		return self.LinearDamping
	end

	function META:SetAngularDamping(damping)
		self.AngularDamping = damping

		if not check_body(self) then return end

		ode.BodySetAngularDamping(self.body, self:GetAngularDamping())
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

		if check_body(self) then
			local info = ffi.new("struct dMass[1]")
			ode.BodyGetMass(self.body, info)
			local x, y, z = physics.Vec3ToEngine(self:GetMassOrigin():Unpack())
			info[0].c[0] = x
			info[0].c[1] = y
			info[0].c[2] = z
			ode.BodySetMass(self.body, info)
		end
	end

	function META:SetMass(val)
		self.Mass = val

		if check_body(self) then
			local info = ffi.new("struct dMass[1]")
			ode.BodyGetMass(self.body, info)
			info[0].mass = self:GetMass()
			ode.BodySetMass(self.body, info)
		end
	end

	--local out = ffi.new("float[1]")
	function META:GetMass()
		if check_body(self) then
			local out = ffi.new("struct dMass[1]")
			ode.BodyGetMass(self.body, out)
			return out[0].mass
		end

		return self.Mass
	end

	function META:GetMassOrigin()
		if check_body(self) then
			local out = ffi.new("struct dMass[1]")
			ode.BodyGetMass(self.body, out)
			return Vec3(physics.Vec3ToEngine(out[0].c[0], out[0].c[2], out[0].c[2]))
		end

		return self.MassOrigin
	end
end

do -- init sphere options
	META:GetSet("PhysicsSphereRadius", 1)

	function META:InitPhysicsSphere(rad)
		if rad then self:SetPhysicsSphereRadius(rad) end

		if physics.init then
			self.geom = ode.CreateSphere(physics.hash_space, self:GetPhysicsSphereRadius())

			if self.Movable then
				self.body = ode.BodyCreate(physics.world)
				ode.GeomSetBody(self.geom, self.body)
			end

			physics.StoreBodyPointer(self)
		end
	end
end

do -- init box options
	META:GetSet("PhysicsBoxScale", Vec3(1, 1, 1))

	function META:InitPhysicsBox(scale)
		if scale then self:SetPhysicsBoxScale(scale) end

		if physics.init then
			self.geom = ode.CreateBox(physics.hash_space, physics.Vec3ToEngine(self:GetPhysicsBoxScale():Unpack()))

			if self.Movable then
				self.body = ode.BodyCreate(physics.world)
				ode.GeomSetBody(self.geom, self.body)
			end

			physics.StoreBodyPointer(self)
		end
	end
end

do -- init capsule options
	META:GetSet("PhysicsBoxScale", Vec3(1, 1, 1))
	META:GetSet("PhysicsCapsuleZRadius", 0.5)
	META:GetSet("PhysicsCapsuleZHeight", 1.85)

	function META:InitPhysicsCapsuleZ()
		if physics.init then
			self.geom = ode.CreateCCylinder(physics.hash_space, self:GetPhysicsCapsuleZRadius(), self:GetPhysicsCapsuleZHeight())

			if self.Movable then
				self.body = ode.BodyCreate(physics.world)
				ode.GeomSetBody(self.geom, self.body)
			end

			physics.StoreBodyPointer(self)
		end
	end
end

do -- mesh init options
	function META:InitPhysicsConvexHull(tbl)
		wlog("NYI")
	--[[if not physics.init then return end

		-- if you don't do this "tbl" will get garbage collected and physics.bullet will crash
		-- because bullet says it does not make any copies of indices or vertices

		local mesh = ffi.new("float["..#tbl.."]", tbl)

		self.mesh = tbl

		if physics.init then
			self.body = physics.bullet.CreateRigidBodyConvexHull(self:GetMass(), self:GetMatrix():GetFloatCopy(), mesh)
			physics.StoreBodyPointer(self)
		end


		]] end

	function META:InitPhysicsConvexTriangles(tbl)
		wlog("NYI")
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
			physics.StoreBodyPointer(self)
		end

		]] end

	function META:InitPhysicsTriangles(tbl)
		if not physics.init then return end

		self.mesh = tbl
		local data = ode.GeomTriMeshDataCreate()
		ode.GeomTriMeshDataBuildSingle(
			data,
			tbl.vertices.pointer,
			tbl.vertices.stride,
			tbl.vertices.count,
			tbl.triangles.pointer,
			tbl.triangles.count,
			tbl.triangles.stride
		)
		ode.GeomTriMeshDataPreprocess(data)
		self.geom = ode.CreateTriMesh(physics.hash_space, data, nil, nil, nil)

		if self.Movable then
			self.body = ode.BodyCreate(physics.world)
			ode.GeomSetBody(self.geom, self.body)
		end

		physics.StoreBodyPointer(self)
	end
end

do -- generic get set
	local function GET_SET(name, friendly, default)
		local set_func = ode and ode["BodySet" .. name] or function() end
		local get_func = ode and ode["BodyGet" .. name] or function() end
		META:GetSet(friendly, default)

		if type(default) == "number" then
			META["Set" .. friendly] = function(self, var)
				self[friendly] = var

				if not check_body(self) then return end

				set_func(self.body, var)
			end
			META["Get" .. friendly] = function(self)
				if not check_body(self) then return self[friendly] end

				return get_func(self.body)
			end
		elseif typex(default) == "vec3" then
			META["Set" .. friendly] = function(self, var)
				self[friendly] = var

				if not check_body(self) then return end

				set_func(self.body, physics.Vec3ToEngine(var.x, var.y, var.z))
			end
			META["Get" .. friendly] = function(self)
				if not check_body(self) then return self[friendly] end

				local out = get_func(self.body)
				return Vec3(physics.Vec3FromEngine(out[0], out[1], out[2]))
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
	for k, v in ipairs(physics.bodies) do
		if v == self then
			list.remove(physics.bodies, k)

			break
		end
	end

	if check_body(self) then
		ode.BodyDestroy(self.body)
		self.body = nil
	end

	if check_geom(self) then
		ode.GeomDestroy(self.geom)
		self.geom = nil
	end
end

META:Register()

function physics.CreateBody()
	local self = META:CreateObject()
	list.insert(physics.bodies, self)
	return self
end