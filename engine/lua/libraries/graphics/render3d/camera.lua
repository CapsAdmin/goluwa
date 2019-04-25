local render3d = ... or _G.render3d

for _, info in ipairs(camera.GetVariables()) do
	local type = "mat4"

	if info.name == "normal_matrix" then
		type = "mat3"
	end

	if info.name:find("world") or info.name == "normal_matrix" then
		if info.glsl then
			render.SetGlobalShaderVariable("g_" .. info.name, (info.glsl:gsub("%$", "g_"):gsub("%^", "")), type)
		else
			render.SetGlobalShaderVariable("g_" .. info.name, function() return render3d.camera:GetMatrices()[info.name] end, type)
		end
	else
		if info.glsl then
			render.SetGlobalShaderVariable2(info.name, (info.glsl:gsub("%$", "g_"):gsub("%^", "")), type)
		else
			render.SetGlobalShaderVariable2(info.name, function() return render3d.camera:GetMatrices()[info.name] end, type)
		end
	end
end

render.SetGlobalShaderVariable2("cam_nearz", function() return render3d.camera.NearZ end, "float")
render.SetGlobalShaderVariable2("cam_farz", function() return render3d.camera.FarZ end, "float")
render.SetGlobalShaderVariable2("cam_fov", function() return render3d.camera.FOV end, "float")

render.SetGlobalShaderVariable2("cam_pos", function() return render3d.camera:GetPosition() end, "vec3")
render.SetGlobalShaderVariable2("cam_up", function() return render3d.camera:GetAngles():GetUp() end, "vec3")
render.SetGlobalShaderVariable2("cam_forward", function() return render3d.camera:GetAngles():GetForward() end, "vec3")
render.SetGlobalShaderVariable2("cam_right", function() return render3d.camera:GetAngles():GetRight() end, "vec3")

render.AddGlobalShaderCode([[
float get_depth(vec2 uv)
{
	return texture(tex_depth, uv).r;
}]])

render.AddGlobalShaderCode([[
float linearize_depth(float depth)
{
	return (2.0 * _G.cam_nearz) / (_G.cam_farz + _G.cam_nearz - depth * (_G.cam_farz - _G.cam_nearz));
}]])

render.AddGlobalShaderCode([[
float get_linearized_depth(vec2 uv)
{
	return linearize_depth(get_depth(uv));
}]])

render.AddGlobalShaderCode([[
vec3 get_camera_dir(vec2 uv)
{
    vec4 device_normal = vec4(uv * 2 - 1, 0.0, 1.0);
    vec3 eye_normal = normalize((_G.projection_inverse * device_normal).xyz);
    vec3 world_normal = normalize(mat3(_G.view_inverse)*eye_normal);
    return world_normal;
}]])


