local ffi = require("ffi")
local physics = ... or _G.physics

local META = prototype.CreateTemplate("physics_body")

local vec3_from_bullet = physics.Vec3FromBullet
local vec3_to_bullet = physics.Vec3ToBullet

META:StartStorable()

local function check(obj)
	return physics.init and obj.body
end

do -- damping
	META:GetSet("LinearDamping", 0)
	META:GetSet("AngularDamping", 0)

	function META:SetLinearDamping(damping)
		self.LinearDamping = damping
		if not check(self) then return end
		physics.bullet.RigidBodySetDamping(self.body, self:GetLinearDamping(), self:GetAngularDamping())
	end

	function META:GetLinearDamping()
		return self.LinearDamping
	end

	function META:SetAngularDamping(damping)
		self.AngularDamping = damping
		if not check(self) then return end
		physics.bullet.RigidBodySetDamping(self.body, self:GetLinearDamping(), self:GetAngularDamping())
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

		-- update mass when mass origin is modified
		self:SetMass(self:GetMass())
	end

	function META:SetMass(val)
		self.Mass = val

		if check(self) then
			physics.bullet.RigidBodySetMass(self.body, val, vec3_to_physics.bullet(self:GetMassOrigin():Unpack()))
		end
	end

	--local out = ffi.new("float[1]")

	function META:GetMass()
		--if check(self) then
		--	physics.bullet.RigidBodyGetMass(self.body, out)
		--	return out[0]
		--end

		return self.Mass
	end
end

local function update_params(self)
	self:SetLinearDamping(self:GetLinearDamping())
	self:SetAngularDamping(self:GetAngularDamping())
	self:SetLinearSleepingThreshold(self:GetLinearSleepingThreshold())
	self:SetAngularSleepingThreshold(self:GetAngularSleepingThreshold())
end

do -- init sphere options
	META:GetSet("PhysicsSphereRadius", 1)

	function META:InitPhysicsSphere(rad)
		if rad then self:SetPhysicsSphereRadius(rad) end

		if physics.init then
			self.body = physics.bullet.CreateRigidBodySphere(self:GetMass(), self:GetMatrix():GetFloatCopy(), self:GetPhysicsSphereRadius())
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
			self.body = physics.bullet.CreateRigidBodyBox(self:GetMass(), self:GetMatrix():GetFloatCopy(), vec3_to_physics.bullet(self:GetPhysicsBoxScale():Unpack()))
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
			self.body = physics.bullet.CreateCapsuleZ(self:GetMass(), self:GetMatrix():GetFloatCopy(), self:GetPhysicsCapsuleZRadius(), self:GetPhysicsCapsuleZHeight())
			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)
	end
end

do -- mesh init options

	function META:InitPhysicsConvexHull(tbl)
		if not physics.init then return end

		-- if you don't do this "tbl" will get garbage collected and physics.bullet will crash
		-- because bullet says it does not make any copies of indices or vertices

		local mesh = ffi.new("float["..#tbl.."]", tbl)

		self.mesh = tbl

		if physics.init then
			self.body = physics.bullet.CreateRigidBodyConvexHull(self:GetMass(), self:GetMatrix():GetFloatCopy(), mesh)
			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)
	end

	function META:InitPhysicsConvexTriangles(tbl)
		if not physics.init then return end

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

		update_params(self)
	end

	function META:InitPhysicsTriangles(tbl, quantized_aabb_compression)
		if not physics.init then return end

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
			self.body = physics.bullet.CreateRigidBodyTriangleMesh(self:GetMass(), self:GetMatrix():GetFloatCopy(), mesh, not not quantized_aabb_compression)
			physics.StoreBodyPointer(self.body, self)
		end

		update_params(self)
	end
end


do -- generic get set

	local function GET_SET(name, default)
		local set_func = physics.bullet and physics.bullet["RigidBodySet" .. name] or function() end
		local get_func = physics.bullet and physics.bullet["RigidBodyGet" .. name] or function() end

		META:GetSet(name, default)

		if type(default) == "number" then
			META["Set" .. name] = function(self, var)
				self[name] = var
				if not check(self) then return end
				set_func(self.body, var)
			end

			local out = ffi.new("float[?]", 1)

			META["Get" .. name] = function(self)
				if not self.body then return self[name] end
				get_func(self.body, out)
				return out[0]
			end
		elseif typex(default) == "vec3" then
			META["Set" .. name] = function(self, var)
				self[name] = var
				if not check(self) then return end
				set_func(self.body, vec3_to_physics.bullet(var.x, var.y, var.z))
			end

			local out = ffi.new("float[?]", 3)

			META["Get" .. name] = function(self)
				if not self.body then return self[name] end
				get_func(self.body, out)
				return Vec3(vec3_from_physics.bullet(out[0], out[1], out[2]))
			end
		elseif typex(default) == "matrix44" then
			META["Set" .. name] = function(self, var)
				self[name] = var
				if not check(self) then return end
				set_func(self.body, var:GetFloatCopy())
			end

			local out = Matrix44()

			META["Get" .. name] = function(self)
				if not self.body then return self[name] end
				get_func(self.body, out:GetFloatCopy())
				local mat = Matrix44()
				ffi.copy(mat, out, ffi.sizeof(mat))
				return mat
			end
		end
	end

	GET_SET("Matrix", Matrix44())
	GET_SET("Gravity", Vec3())

	GET_SET("Velocity", Vec3())
	GET_SET("AngularVelocity", Vec3())

	GET_SET("AngularFactor", Vec3())
	GET_SET("LinearFactor", Vec3())

	GET_SET("LinearSleepingThreshold", 0)
	GET_SET("AngularSleepingThreshold", 0)
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
		physics.bullet.RemoveBody(self.body)
	end
end

META:Register()

function physics.CreateBody()
	local self = META:CreateObject()

	table.insert(physics.bodies, self)

	return self
end

--[[
local DOF6CONSTRAINT = {
	IsValid = function() return true end,
	SetUpperAngularLimit = ADD_FUNCTION(physics.bullet.6DofConstraintSetUpperAngularLimit),
	GetUpperAngularLimit = ADD_FUNCTION(physics.bullet.6DofConstraintGetUpperAngularLimit, 3),
	SeLowerAngularLimit = ADD_FUNCTION(physics.bullet.6DofConstraintSeLowerAngularLimit),
	GeLowerAngularLimit = ADD_FUNCTION(physics.bullet.6DofConstraintGeLowerAngularLimit, 3),
	SetUpperLinearLimit = ADD_FUNCTION(physics.bullet.6DofConstraintSetUpperLinearLimit),
	GetUpperLinearLimit = ADD_FUNCTION(physics.bullet.6DofConstraintGetUpperLinearLimit, 3),
	SeLowerLinearLimit = ADD_FUNCTION(physics.bullet.6DofConstraintSeLowerLinearLimit),
	GeLowerLinearLimit = ADD_FUNCTION(physics.bullet.6DofConstraintGeLowerLinearLimit, 3),
}

DOF6CONSTRAINT.__index = DOF6CONSTRAINT

function physics.bullet.CreateBallsocketConstraint(body_a, body_b, matrix_a, matrix_b, linear_frame_ref)
	return ffi.metatype("btGeneric6DofConstraint", physics.bullet.Create6DofConstraint(body_a, body_b, matrix_a, matrix_b, linear_frame_ref or 1))
end
]]