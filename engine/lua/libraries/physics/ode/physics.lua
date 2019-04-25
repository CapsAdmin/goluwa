local ode = desire("ode")

local physics = ... or _G.physics

local ffi = require("ffi")

function physics.Vec3ToEngine(x, y, z)
--	return -y, -x, -z
	return x,y,z
end

function physics.Vec3FromEngine(x, y, z)
--	return -y, -x, -z
	return x,y,z
end

function physics.BodyToLua(self)
	local udata = ffi.cast("uint32_t *", self.Movable and ode.BodyGetData(self.body) or ode.GeomGetData(self.geom))

	return physics.body_lookup[udata[0]]
end

function physics.StoreBodyPointer(self)
	local idx = ffi.new("uint32_t[1]", tonumber(("%p"):format(self)))

	if self.Movable then
		ode.BodySetData(self.body, idx)
	else
		ode.GeomSetData(self.geom, idx)
	end

	physics.body_lookup[idx[0]] = self
end

runfile("physics_body.lua", physics)

function physics._Initialize()
	if not RELOAD then
		ode.InitODE2(0)

		physics.world = ode.WorldCreate()

		ode.WorldSetCFM(physics.world, 1e-5)
		physics.hash_space = ode.HashSpaceCreate(nil)
		physics.contact_group = ode.JointGroupCreate(0)

		--LOL = ode.CreatePlane(physics.hash_space, 0, 0, -1, 0)

		--local threading = ode.ThreadingAllocateMultiThreadedImplementation()
		--local pool = ode.ThreadingAllocateThreadPool(8, 0, ode.e.AllocateMaskAll, nil)
		--ode.ThreadingThreadPoolServeMultiThreadedImplementation(pool, threading);
		--ode.WorldSetStepThreadingImplementation(world, ode.ThreadingImplementationGetFunctions(threading), threading)

		physics.bodies = {}
		physics.body_lookup = table.weak()
	end

	do
		local function nearCallback (data, o1, o2)
			local b1 = ode.GeomGetBody(o1)
			local b2 = ode.GeomGetBody(o2)

			local MAX_CONTACTS = 8;
			local contact = ffi.new("struct dContact[?]",MAX_CONTACTS);

			local numc = ode.Collide( o1, o2, MAX_CONTACTS, contact[0].geom, ffi.sizeof("struct dContact"))

			for i = 0, numc - 1 do
				contact[i].render2d.mode = ode.e.ContactApprox1;
				contact[i].render2d.mu = 5;

				local  c = ode.JointCreateContact(physics.world, physics.contact_group, contact+i);
				ode.JointAttach (c, b1, b2);
			end
		end

		local nearCallback_cb = ffi.cast("void(*)(void*,struct dxGeom*,struct dxGeom*)", nearCallback)

		local function nearCallBack_checkSpace(data,o1,o2)
			if ode.GeomIsSpace(o1) ~= nil or ode.GeomIsSpace(o2) ~= nil then

				ode.SpaceCollide2( o1, o2, data, nearCallback_cb);

				if ode.GeomIsSpace( o1 ) ~= nil then
					ode.SpaceCollide(ode.GeomGetSpace(o1), data, nearCallback_cb );
				end

				if ode.GeomIsSpace( o2 ) ~= nil then
					ode.SpaceCollide( ode.GeomGetSpace(o2), data, nearCallback_cb );
				end
			else
				nearCallback (data, o1, o2);
			end
		end

		local nearCallBack_checkSpace_cb = ffi.cast("void(*)(void*,struct dxGeom*,struct dxGeom*)", nearCallBack_checkSpace)

		event.AddListener("Update", "ode", function(dt)
			ode.SpaceCollide(physics.hash_space, nil, nearCallBack_checkSpace_cb)
			ode.WorldQuickStep(physics.world, dt)
			ode.JointGroupEmpty(physics.contact_group)

			--[[while ode.ReadCollision(out) do
				local a = physics.BodyToLua(out[0].a)
				local b = physics.BodyToLua(out[0].b)

				if a and b then
					event.Call("PhysicsCollide", a.ent, b.ent)
				end
			end]]
		end)
	end
end

do
	function physics.RayCast(from, to)
		wlog("NYI")
		--[[if ode.RayCast(from.x, from.y, from.z, to.x, to.y, to.z, out) then
			local tbl = {
				hit_pos = Vec3(),
				hit_normal = Vec3(),
				body = NULL,
			}

			ffi.copy(tbl.hit_pos, out[0].hit_pos, ffi.sizeof("float")*3)
			ffi.copy(tbl.hit_normal, out[0].hit_normal, ffi.sizeof("float")*3)

			if out[0].body ~= nil then
				local body = physics.BodyToLua(out[0].body)
				if body then
					tbl.body = body.ent
				end
			end

			return tbl
		end]]
	end
end

do
	local out = ffi.new("double[3]")

	function physics.GetGravity()
		ode.WorldGetGravity(physics.world, out)
		return Vec3(physics.Vec3FromEngine(out[0], out[1], out[2]))
	end

	function physics.SetGravity(vec)
		ode.WorldSetGravity(physics.world, physics.Vec3ToEngine(vec:Unpack()))
	end
end