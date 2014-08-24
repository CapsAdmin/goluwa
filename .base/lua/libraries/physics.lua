physics = physics or {}

do
	local bullet = require("lj-bullet3")
	bullet.Initialize()
	bullet.SetGravity(0,0,9.8) 		 

	event.AddListener("Update", "bullet", function(dt)
		bullet.Update(dt)
	end)

	physics.bullet = bullet
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
				logn("no vertices found in " .. path, 2)
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