local ffi = require("ffi")

local bt = loadfile("./bullet.lua")()

local collision_config = bt.CreateDefaultCollisionConfiguration()
local dispatcher = bt.CreateCollisionDispatcher(collision_config.ptr)

local broadphase = bt.CreateDbvtBroadphase(nil)

local solver = bt.CreateSequentialImpulseConstraintSolver()

local dynamics_world = bt.CreateDiscreteDynamicsWorld(dispatcher.ptr, broadphase.ptr, solver.ptr, collision_config.ptr)
dynamics_world:SetGravity(ffi.new("float[3]", 0, -10, 0))

local bodies = {}

for i = 1, 1 do
	do -- ground
		local shape = bt.CreateBoxShape(ffi.new("float[3]", 50, 50, 50))

		local m = Matrix44()
		m:Translate(0, -100, 0)

		local body = bt.CreateRigidBody(bt.CreateRigidBody_btRigidBodyConstructionInfo2(
			0,
			bt.CreateDefaultMotionState(m:GetTransposed():GetFloatCopy()).ptr,
			shape.ptr,
			ffi.new("float[3]", 0, 0, 0)
		).ptr)

		dynamics_world:AddRigidBody(body.ptr)

		table.insert(bodies, body)
	end
end

do -- ground
	local shape = bt.CreateBoxShape(ffi.new("float[3]", 1, 1, 1))

	local m = Matrix44()
	m:Translate(0, 100, 0)

	local mass = 1
	local intertia = ffi.new("float[3]", 0, 1, 0)

	shape:CalculateLocalInertia(mass, intertia)

	local body = bt.CreateRigidBody(bt.CreateRigidBody_btRigidBodyConstructionInfo2(
		mass,
		bt.CreateDefaultMotionState(m:GetTransposed():GetFloatCopy()).ptr,
		shape.ptr,
		intertia
	).ptr)

	dynamics_world:AddRigidBody(body.ptr)

	table.insert(bodies, body)
end

event.AddListener("Update", "bullet", function()
	dynamics_world:StepSimulation(1/60, 1, 1/60)

	for _, body in ipairs(bodies) do
		local ptr = ffi.cast("float *", body:GetMotionState())

		local m = Matrix44()

		for i = 0, 16 - 1 do
			m:SetI(i, ptr[i])
		end

		print(body, m)
	end
end)
