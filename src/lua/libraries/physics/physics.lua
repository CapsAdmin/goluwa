local ffi = require("ffi")
local physics = physics or {}

physics.bullet = desire("physics.ffi.bullet3")
physics.bodies = physics.bodies or {}

local function vec3_to_bullet(x, y, z)
	return -y, -x, -z
end

local function vec3_from_bullet(x, y, z)
	return -y, -x, -z
end

physics.Vec3ToBullet = vec3_to_bullet
physics.Vec3FromBullet = vec3_from_bullet

function physics.BodyToLua(ptr)
	local udata = ffi.cast("uint32_t *", physics.bullet.RigidBodyGetUserData(ptr))

	return physics.body_lookup[udata[0]]
end

function physics.StoreBodyPointer(ptr, obj)
	local idx = ffi.new("uint32_t[1]", tonumber(("%p"):format(obj)))
	physics.bullet.RigidBodySetUserData(ptr, idx)
	physics.body_lookup[idx[0]] = obj
end

include("physics_body.lua", physics)

function physics.Initialize()
	if LINUX then return end

	if not RELOAD then
		for k,v in pairs(physics.bodies) do
			if v:IsValid() then
				v:Remove()
			end
		end
		physics.bullet.Initialize()
		physics.bodies = {}
		physics.body_lookup = utility.CreateWeakTable()
	end

	do
		local out = ffi.new("bullet_collision_value[1]")
		event.AddListener("Update", "bullet", function(dt)
			physics.bullet.StepSimulation(dt, physics.sub_steps, physics.fixed_time_step)

			while physics.bullet.ReadCollision(out) do
				local a = physics.BodyToLua(out[0].a)
				local b = physics.BodyToLua(out[0].b)

				if a and b then
					event.Call("PhysicsCollide", a.ent, b.ent)
				end
			end
		end)
	end

	physics.SetGravity(Vec3(0, 0, -9.8))
	physics.sub_steps = 1
	physics.fixed_time_step = 1/120
	physics.init = true
end

function physics.EnableDebug(draw_line, contact_point, _3d_text, report_error_warning)
	physics.bullet.EnableDebug(draw_line, contact_point, _3d_text, report_error_warning)
end

function physics.DisableDebug()
	physics.bullet.DisableDebug()
end

function physics.DrawDebugWorld()
	physics.bullet.DrawDebugWorld()
end

function physics.GetBodies()
	return physics.bodies
end

do
	local out = ffi.new("bullet_raycast_result[1]")

	function physics.RayCast(from, to)
		if physics.bullet.RayCast(from.x, from.y, from.z, to.x, to.y, to.z, out) then
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

		end
	end
end

do
	local out = ffi.new("float[3]")

	function physics.GetGravity()
		physics.bullet.GetWorldGravity(out)
		return Vec3(vec3_from_bullet(out[0], out[1], out[2]))
	end

	function physics.SetGravity(vec)
		physics.bullet.SetWorldGravity(vec3_to_bullet(vec:Unpack()))
	end
end

do -- physcs models

	local assimp = desire("ffi.assimp")

	physics.model_cache = {}

	local cb = utility.CreateCallbackThing(physics.model_cache)

	function physics.LoadModel(path, callback, on_fail)
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
					local scene = assimp.ImportFile(full_path, assimp.e.aiProcessPreset_TargetRealtime_Quality)

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

physics.Initialize()

return physics
