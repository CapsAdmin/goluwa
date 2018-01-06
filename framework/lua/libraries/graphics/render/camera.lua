local render = ... or _G.render

for _, info in ipairs(camera.GetVariables()) do
	local type = "mat4"

	if info.name == "normal_matrix" then
		type = "mat3"
	end

	if info.name:find("world") or info.name == "normal_matrix" then
		if info.glsl then
			render.SetGlobalShaderVariable("g_" .. info.name .. "_2d", (info.glsl:gsub("%$", "g_"):gsub("%^", "_2d")), type)
		else
			render.SetGlobalShaderVariable("g_" .. info.name .. "_2d", function() return render2d.camera:GetMatrices()[info.name] end, type)
		end
	else
		if info.glsl then
			render.SetGlobalShaderVariable2(info.name .. "_2d", (info.glsl:gsub("%$", "g_"):gsub("%^", "_2d")), type)
		else
			render.SetGlobalShaderVariable2(info.name .. "_2d", function() return render2d.camera:GetMatrices()[info.name] end, type)
		end
	end
end