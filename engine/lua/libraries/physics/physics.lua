local physics = _G.physics or {}
local ffi = require("ffi")

runfile("ode/physics.lua", physics)

physics.bodies = physics.bodies or {}

runfile("physics_body.lua", physics)

function physics.Initialize()
	if not PHYSICS then return end

	if not RELOAD then
		for k,v in pairs(physics.bodies) do
			if v:IsValid() then
				v:Remove()
			end
		end

		physics._Initialize()
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

do -- physcs models

	local assimp = desire("assimp")

	physics.model_cache = {}

	local cb = utility.CreateCallbackThing(physics.model_cache)

	function physics.LoadModel(path, callback, on_fail)
		if not physics.IsReady() then if on_fail then on_fail("physics is not initialized") end return end
		if cb:check(path, callback, {on_fail = on_fail}) then return true end

		steam.MountGamesFromMapPath(path)

		local data = cb:get(path)

		if data then
			callback(data)
			return true
		end

		cb:start(path, callback, {on_fail = on_fail})

		resource.Download(path):Then(function(full_path)
			local thread = tasks.CreateTask()
			thread.debug = true

			function thread:OnStart()
				if steam.LoadMap and path:endswith(".bsp") then

					-- :(
					if GRAPHICS and gfx.model_loader_cb and gfx.model_loader_cb:get(path) and gfx.model_loader_cb:get(path).callback then
						tasks.Report("waiting for render mesh to finish loading")
						repeat
							tasks.Wait()
						until not gfx.model_loader_cb:get(path) or not gfx.model_loader_cb:get(path).callback
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
		end):Catch(function(reason)
			cb:callextra(path, "on_fail", reason)
		end)

		return true
	end
end

return physics
