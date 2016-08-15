local ode = desire("libode")

local ffi = require("ffi")
local physics = physics or {}

physics.ode = ode
physics.bodies = physics.bodies or {}

function physics.Vec3ToODE(x, y, z)
	return -y, -x, -z
end

function physics.Vec3FromODE(x, y, z)
	return -y, -x, -z
end

function physics.BodyToLua(ptr)
	local udata = ffi.cast("uint32_t *", physics.ode.BodyGetData(ptr))

	return physics.body_lookup[udata[0]]
end

function physics.StoreBodyPointer(ptr, obj)
	local idx = ffi.new("uint32_t[1]", tonumber(("%p"):format(obj)))
	physics.ode.BodySetData(ptr, idx)
	physics.body_lookup[idx[0]] = obj
end

include("physics_body.lua", physics)

function physics.Initialize()
	if not RELOAD then
		for k,v in pairs(physics.bodies) do
			if v:IsValid() then
				v:Remove()
			end
		end
		physics.ode.InitODE()

		physics.world = ode.WorldCreate()
		ode.WorldSetGravity(physics.world, 0, 0, -0.001)

		physics.hash_space = ode.HashSpaceCreate(nil)

		physics.bodies = {}
		physics.body_lookup = utility.CreateWeakTable()
	end

	do
		event.AddListener("Update", "ode", function(dt)
			physics.ode.WorldStep(physics.world, dt)

			--[[while physics.ode.ReadCollision(out) do
				local a = physics.BodyToLua(out[0].a)
				local b = physics.BodyToLua(out[0].b)

				if a and b then
					event.Call("PhysicsCollide", a.ent, b.ent)
				end
			end]]
		end)
	end

	physics.SetGravity(Vec3(0, 0, -9.8))
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
		--[[if physics.ode.RayCast(from.x, from.y, from.z, to.x, to.y, to.z, out) then
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
	local out = ffi.new("float[3]")

	function physics.GetGravity()
		physics.ode.WorldGetGravity(physics.world, out)
		return Vec3(physics.Vec3FromODE(out[0], out[1], out[2]))
	end

	function physics.SetGravity(vec)
		physics.ode.WorldSetGravity(physics.world, physics.Vec3ToODE(vec:Unpack()))
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
					local triangles = ffi.new("uint32_t[?]", scene.mMeshes[0].mNumFaces * 3)

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
							stride = ffi.sizeof("uint32_t") * 3,
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
