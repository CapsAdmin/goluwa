commands.Add("whitemat", function()
	local mat = render.CreateMaterial("model")
	mat:SetAlbedoTexture(render.GetWhiteTexture())
	mat:SetRoughnessTexture(render.GetWhiteTexture())
	mat:SetMetallicTexture(render.GetWhiteTexture())
	mat:SetRoughnessMultiplier(0)
	mat:SetMetallicMultiplier(1)

	for k, v in ipairs(entities.GetAll()) do
		if v.model then
			v:SetMaterialOverride(mat)
		end
	end
end)
commands.Add("cubemodels", function()
	render3d.LoadModel("models/cube.obj", function(meshes)
		local vtx = meshes[1].vertex_buffer
		local idx = meshes[1].indices[1].index_buffer

		for k, v in ipairs(entities.GetAll()) do
			if v.model then
				for _,sub_model in ipairs(v.model:GetSubModels()) do
					sub_model.vertex_buffer = vtx
					for _, data in ipairs(sub_model:GetSubMeshes()) do
						data.index_buffer = idx
					end
				end
			end
		end
	end)
end)