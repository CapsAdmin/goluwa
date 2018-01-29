local assimp = system.GetFFIBuildLibrary("assimp")

if not assimp then return end

local function fix_path(path)
	return (path:gsub("\\", "/"):gsub("(/+)", "/"))
end

local function parse_scene(scene, path, callback)
	if not scene then
		return nil, ffi.string(assimp.GetErrorString())
	end

	local dir = path:match("(.+)/")

	local out = {}

	for i = 0, scene.mNumMeshes - 1 do
		local mesh = scene.mMeshes[i]

		local sub_model = {vertices = {}, indices = {}}

		for i = 0, mesh.mNumVertices - 1 do
			local data = {}

			local val = mesh.mVertices[i]
			data.pos = Vec3(val.x, -val.y, val.z)

			if mesh.mNormals ~= nil then
				local val = mesh.mNormals[i]
				data.normal = Vec3(val.x, -val.y, val.z)
			end

			if mesh.mTangents ~= nil then
				local val = mesh.mTangents[i]
				data.tangent = Vec3(val.x, -val.y, val.z)
			end

			if mesh.mTextureCoords ~= nil and mesh.mTextureCoords[0] ~= nil then
				local val = mesh.mTextureCoords[0][i]
				data.uv = Vec2(val.x, -val.y)
			end

			table.insert(sub_model.vertices, data)

			if callback then
				tasks.Wait()
			end
		end

		for i = 0, mesh.mNumFaces - 1 do
			local face = mesh.mFaces[i]

			for i = 0, face.mNumIndices - 1 do
				local i = face.mIndices[i]

				table.insert(sub_model.indices, i)
			end
		end

		-- sub_model.name = ffi.string(mesh.mName.data, mesh.mName.length):trim()

		if mesh.mMaterialIndex > 0 then
			local mat = scene.mMaterials[mesh.mMaterialIndex]
			sub_model.material = {}
			local tex_i = 1
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
					local path = val
					if path:sub(1, 1) == "." then
						path = fix_path(dir .. val:sub(2))
					else
						path = fix_path(val)
					end

					if tex_i == 1 then
						sub_model.material.path = path
						sub_model.material.diffuse = path
					elseif tex_i == 2 then
						sub_model.material.metallic = path
					elseif tex_i == 3 then
						sub_model.material.normal = path
					elseif tex_i == 4 then
						sub_model.material.roughness = path
					end

					tex_i = tex_i + 1
				end
			end
		end

		out[i] = sub_model

		if callback then
			callback(sub_model, i+1, scene.mNumMeshes)
			tasks.Wait()
		end
	end

	assimp.ReleaseImport(scene)

	return out
end

function assimp.ImportFileMemory(data, flags, hint, callback)
	local scene = assimp.ImportFileFromMemory(data, #data, flags, hint)
	return parse_scene(scene, hint, callback)
end

function assimp.ImportFileEx(path, flags, callback, custom_io)
	local scene

	if custom_io then
		local file_io_data = ffi.new("struct aiFileIO", {
			OpenProc = function(self, path, mode)
				path = ffi.string(path)
				path = vfs.FixPath(path)
				path = path:gsub("/./", "/")

				local file, err = vfs.Open(path, "read")
				--print("file open", file, err, path)

				if not file then return nil end

				local proxy_data = ffi.new("struct aiFile", {
					ReadProc = function(proxy, buffer_out, size, count)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						local length = size * count
						--print("read", file, buffer_out, size)

						local str = file:ReadBytes(tonumber(length))

						local temp = ffi.cast("char *", str)
						ffi.copy(buffer_out, temp, #str)

						--print(#str, length, ffi.string(buffer_out, #str) == str)

						return #str
					end,
					WriteProc = function(proxy, buffer_in, buffer_length, length)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("write", file, buffer_in, buffer_length, length)

						file:WriteBytes(ffi.string(buffer_in, buffer_length))

						return buffer_length
					end,
					TellProc = function(proxy)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("tell", file)

						return file:GetPosition()
					end,
					FileSizeProc = function(proxy)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("file size", file)

						return file:GetSize()
					end,
					SeekProc = function(proxy, pos, current_pos)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("seek", file)

						file:SetPosition(pos)
						return 0 -- 0 = success, -1 = failure, -3 = out of memory
					end,
					FlushProc = function(proxy)
						local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
						--print("flush", file)

					end,
				})
				--ffi.gc(proxy_data, print)
				local proxy = ffi.new("struct aiFile[1]", proxy_data)

				vfs.proxies = vfs.proxies or {}
				vfs.proxies[tostring(proxy):match(".+: (.+)")] = file

				return ffi.cast("struct aiFile_*", proxy)
			end,
			CloseProc = function(self, proxy)
				local file = vfs.proxies[tostring(proxy):match(".+: (.+)")]
				--print("file close", file)

				file:Close()
			end,
		})
		--ffi.gc(file_io_data, print)
		local file_io = ffi.new("struct aiFileIO[1]", file_io_data)

		assimp.file_ios = assimp.file_ios or {}
		assimp.file_ios[path] = file_io

		scene = lib.aiImportFileEx(path, flags, file_io)
	else
		scene = assimp.ImportFile(path, flags)
	end

	return parse_scene(scene, path, callback)
end