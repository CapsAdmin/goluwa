local ode = desire("libode")

local ffi = require("ffi")
local physics = physics or {}

physics.ode = ode
physics.bodies = physics.bodies or {}

function physics.Vec3ToODE(x, y, z)
--	return -y, -x, -z
	return x,y,z
end

function physics.Vec3FromODE(x, y, z)
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

include("physics_body.lua", physics)

function physics.Initialize()
	if not ode then return end

	if not PHYSICS then return end

	if not RELOAD then
		for k,v in pairs(physics.bodies) do
			if v:IsValid() then
				v:Remove()
			end
		end

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
		physics.body_lookup = utility.CreateWeakTable()
	end

	do
		local function nearCallback (data, o1, o2)
			local b1 = ode.GeomGetBody(o1)
			local b2 = ode.GeomGetBody(o2)

			local MAX_CONTACTS = 8;
			local contact = ffi.new("struct dContact[?]",MAX_CONTACTS);

			local numc = ode.Collide( o1, o2, MAX_CONTACTS, contact[0].geom, ffi.sizeof("struct dContact"))

			for i = 0, numc - 1 do
				contact[i].surface.mode = ode.e.ContactApprox1;
				contact[i].surface.mu = 5;

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

	physics.SetGravity(Vec3(0, 0, 9.8))
	physics.sub_steps = 1
	physics.fixed_time_step = 1/120
	physics.init = true
end

function physics.IsReady()
	return physics.init
end

function physics.GetBodies()
	return physics.bodies
end

do
	function physics.RayCast(from, to)
		warning("NYI")
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
		return Vec3(physics.Vec3FromODE(out[0], out[1], out[2]))
	end

	function physics.SetGravity(vec)
		ode.WorldSetGravity(physics.world, physics.Vec3ToODE(vec:Unpack()))
	end
end

do -- physcs models

	local assimp = desire("libassimp")

	physics.model_cache = {}

	local cb = utility.CreateCallbackThing(physics.model_cache)

	function physics.LoadModel(path, callback, on_fail)
		if not physics.IsReady() then if on_fail then on_fail("physics is not initialized") end return end
		if cb:check(path, callback, {on_fail = on_fail}) then return true end

		steam.MountGamesFromPath(path)

		local data = cb:get(path)

		if data then
			callback(data)
			return true
		end

		cb:start(path, callback, {on_fail = on_fail})

		resource.Download(path, function(full_path)
			local thread = tasks.CreateTask()
			thread.debug = true

			function thread:OnStart()
				if steam.LoadMap and path:endswith(".bsp") then

					-- :(
					if GRAPHICS and render.model_loader_cb and render.model_loader_cb:get(path) and render.model_loader_cb:get(path).callback then
						tasks.Report("waiting for render mesh to finish loading")
						repeat
							tasks.Wait()
						until not render.model_loader_cb:get(path) or not render.model_loader_cb:get(path).callback
					end
					-- :(
					cb:stop(path, steam.LoadMap(full_path).physics_meshes)
				elseif assimp then
					local scene = assimp.ImportFile(full_path, assimp.e.TargetRealtime_Quality)

					if scene.mMeshes[0].mNumVertices == 0 then
						return nil, "no vertices found in " .. path
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

					cb:stop(path, {mesh})

					assimp.ReleaseImport(scene)
				else
					cb:callextra(path, "on_fail", "unknown format " .. path)
				end
			end

			thread:Start()
		end, function(reason)
			cb:callextra(path, "on_fail", reason)
		end)

		return true
	end
end

return physics
