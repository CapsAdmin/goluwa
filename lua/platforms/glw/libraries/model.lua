local function parse_scene(scene, dir)

	print("PARSING SCENE")

	local out = {}
	
	out = {}
			
	for i = 0, scene.mNumMeshes-1 do
		local mesh = scene.mMeshes[i]
		
		local sub_model = {mesh_data = {}}
		
		for i = 0, scene.mMeshes[i].mNumVertices-1 do
			local data = {}
			
			if mesh.mVertices ~= nil then
				local val = mesh.mVertices[i]
				data.pos = {val.x, val.y, val.z}
			end

			if mesh.mNormals ~= nil then
				local val = mesh.mNormals[i]
				data.normal = {val.x, val.y, val.z}
			end

			if mesh.mTangents ~= nil then
				local val = mesh.mTangents[i]
				data.tangent = {val.x, val.y, val.z}
			end	
						
			if mesh.mTextureCoords ~= nil then
				local val = mesh.mTextureCoords[0] and mesh.mTextureCoords[0][i]
				data.uv = {val.x, val.y}
			end
			
			sub_model.mesh_data[#sub_model.mesh_data+1] = data
		end
				
		sub_model.name = ffi.string(mesh.mName.data, mesh.mName.length):trim()
		
		if mesh.mMaterialIndex > 0 then
			local mat = scene.mMaterials[mesh.mMaterialIndex]
			sub_model.material = {}
			for i = 0, mat.mNumProperties-1 do
				local property = mat.mProperties[i]
				local key = ffi.string(property.mKey.data, property.mKey.length)
				local val = ffi.string(property.mData, property.mDataLength)
				
				key = key:sub(2)
				val = val:sub(4) 
					
				val = val:gsub("(.)", function(char) if char:byte() == 0 then return "" end end) 
				
				if key == "mat.name" then
					sub_model.material.name = val
				end
				
				if key == "tex.file" and val then
					if val:sub(1,1) == "." then
						sub_model.material.path = vfs.FixPath(dir .. val:sub(2))
					else
						sub_model.material.path = vfs.FixPath(val)
					end
				end
			end
		end
				
		out[i] = sub_model
	end	
		
	print("DONE PARSING SCENE")
		
	return out
end

local META = {}
META.__index = META
META.Type = "model"

function META:Draw()
	for _, model in pairs(self.sub_models) do
		model.mesh.diffuse = model.diffuse
		model.mesh.bump = model.bump
		model.mesh:Draw()
	end
end

function META:IsValid()
	return true
end

function META:Remove()
	for _, model in pairs(self.sub_models) do
		model.mesh.diffuse:Remove()
		model.mesh.bump:Remove()
		model.mesh:Remove()
	end
	
	utilities.MakeNull(self)
end

function Model(path)
	check(path, "string")
	
	if false then
		local contents, err = vfs.Read(path, "b")
		if not contents then error(err, 2) end
		
		local models, err = utilities.ParseModel(contents)
		if not models then error(err, 2) end
	end
	
	local path = R(path)
	
	if not vfs.Exists(path) then
		error(path .. " not found", 2)
	end
	
	local scene = assimp.ImportFile(path, 0x1)

	if not scene then
		error(ffi.string(assimp.GetErrorString()), 2)
	end
	
	models = parse_scene(scene, path:match("(.+)/"))	
	
	assimp.ReleaseImport(scene)
	
	local self = setmetatable({}, META)
	
	self.sub_models = {}
	
	--[[local MAX = #models

	local co = coroutine.create(function()
			
		local I = 0
		local function yield()
			if wait(0.5) then
				logf("%i out of %i textures left", I, MAX, 3)
			end
			coroutine.yield()
		end]]
			
		for i, model in pairs(models) do
			local sub_model = {mesh = Mesh3D(model.mesh_data), name = model.name}
			
			if true then
				sub_model.bump = Image("textures/debug/brain_n.jpg")
			--	yield()
				sub_model.bump:SetChannel(1)
			end
			
			if model.material and model.material.path then
				sub_model.diffuse = Image(model.material.path)
			--	yield()
			else
				sub_model.diffuse = ERROR_TEXTURE
			end			
		
			self.sub_models[i] = sub_model
			
		--	I = i
		end
		
	--end)
	
	--[[logf("loading %i textures", MAX)
	
	timer.Thinker(function() 
		local ok , err = coroutine.resume(co) 
		
		if not ok then 
			print(err) 
			return false 
		end  
	end, 100)	]]
	
	return self 
end
