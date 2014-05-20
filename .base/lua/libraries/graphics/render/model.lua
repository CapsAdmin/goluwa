local assimp = require("lj-assimp") -- model decoder


local render = (...) or _G.render

local default_texture_format = {
	mip_map_levels = 4,
	mag_filter = "linear",
	min_filter = "linear_mipmap_linear",
}

render.model_cache = render.model_cache or {}

do -- model meta
	local META = utilities.CreateBaseMeta("model")

	META.__index = META

	class.GetSet(META, "TextureOverride", NULL)

	function render.CreateModel(path, flags, ...)
		check(path, "string")

		if render.model_cache[path] then
			return render.model_cache[path]
		end

		flags = flags or bit.bor(e.aiProcess_CalcTangentSpace, e.aiProcess_GenSmoothNormals)

		local new_path = R(path)

		if not vfs.Exists(new_path) then
			return nil, path .. " not found"
		end

		local models, err = assimp.ImportFileEx(new_path, flags, ...)

		if not models then return nil, err end

		local self = setmetatable({}, META)
		self.sub_models = {}

		for i, model in pairs(models) do
			local sub_model = {mesh = render.CreateMesh3D(model.mesh_data), name = model.name}

			if model.material and model.material.path then
				sub_model.diffuse = render.CreateTexture(model.material.path, default_texture_format)

				do -- try to find normal map
					local path = render.FindTextureFromSuffix(model.material.path, "_n", "_ddn", "_nrm")

					if path then
						sub_model.bump = render.CreateTexture(path, default_texture_format)
					end
				end

				do -- try to find specular map
					local path = render.FindTextureFromSuffix(model.material.path, "_s", "_spec")

					if path then
						sub_model.specular = render.CreateTexture(path, default_texture_format)
					end
				end
			end
			
			if not sub_model.diffuse then
				sub_model.diffuse = render.GetErrorTexture()
			end
		
			--sub_model.diffuse:SetChannel(1)
			--sub_model.bump:SetChannel(2)
			--sub_model.specular:SetChannel(3)

			self.sub_models[i] = sub_model
		end

		render.model_cache[path] = self

		return self
	end

	function META:Remove()
		for _, model in pairs(self.sub_models) do
			model.mesh.diffuse:Remove()
			model.mesh.bump:Remove()
			model.mesh.specular:Remove()
			model.mesh:Remove()
		end
	end

	function META:Draw()
		for _, model in pairs(self.sub_models) do
			if self.TextureOverride:IsValid() then
				model.mesh.diffuse = self.TextureOverride
				model.mesh.bump = self.TextureOverride
				model.mesh.specular = self.TextureOverride
			else
				model.mesh.diffuse = model.diffuse
				model.mesh.bump = model.bump
				model.mesh.specular = model.specular
			end
			
			model.mesh:Draw()
		end
	end

	function META:IsValid()
		return true
	end
end