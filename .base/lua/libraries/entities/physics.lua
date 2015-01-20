local bullet = requirew("lj-bullet3")
if not bullet then return end

local physics = physics or {}

if not physics.bullet then
	bullet.Initialize()	
	physics.bullet = bullet
end

bullet.SetGravity(0,0,9.8)

event.AddListener("Update", "bullet", function(dt)
	bullet.Update(dt)
end)

function bullet.OnCollision(body_a, body_b)
	event.Call("PhysicsCollide", body_a.ent, body_b.ent)
end

function physics.RayCast(a, b)
	local res = bullet.RayCast(a.x, a.y, a.z, b.x, b.y, b.z)
	
	if res then 
		res.body = res.body and res.body.ent or NULL 
		res.hit_normal = Vec3(res.hit_normal[0], res.hit_normal[1], res.hit_normal[3])
		res.hit_pos = Vec3(res.hit_pos[0], res.hit_pos[1], res.hit_pos[3])
	end
	
	return res
end

function physics.SetGravity(vec)
	bullet.SetGravity(vec:Unpack())
end

local assimp = require("lj-assimp")

function physics.GetPhysicsModelsFromPath(path)
	local meshes = {}
	
	if vfs.Exists(path) then
		
		local scene = assimp.ImportFile(R(path), assimp.e.aiProcessPreset_TargetRealtime_Quality)
		
		for i = 0, scene.mNumMeshes - 1 do
			
			if scene.mMeshes[i].mNumVertices == 0 then
				warning("no vertices found in " .. path)
			else
									
				local vertices = ffi.new("float[?]", scene.mMeshes[i].mNumVertices  * 3)
				local triangles = ffi.new("unsigned int[?]", scene.mMeshes[i].mNumFaces * 3)
				
				ffi.copy(vertices, scene.mMeshes[i].mVertices, ffi.sizeof(vertices))

				local j = 0
				for k = 0, scene.mMeshes[i].mNumFaces - 1 do
					for l = 0, scene.mMeshes[i].mFaces[k].mNumIndices - 1 do
						triangles[j] = scene.mMeshes[i].mFaces[k].mIndices[l]
						j = j + 1 
					end
				end
							
				local mesh = {	
					triangles = {
						count = tonumber(scene.mMeshes[i].mNumFaces), 
						pointer = triangles, 
						stride = ffi.sizeof("unsigned int") * 3, 
					},					
					vertices = {
						count = tonumber(scene.mMeshes[i].mNumVertices),  
						pointer = vertices, 
						stride = ffi.sizeof("float") * 3,
					},
				}
				
				meshes[i + 1] = mesh
			end
		end
		
		assimp.ReleaseImport(scene)
		
		return meshes
	end
	
	return nil, "file does not exist"
end

return physics