local render = ... or _G.render

for _, info in ipairs(camera.GetVariables()) do
	if info.glsl then
		render.SetGlobalShaderVariable("g_" .. info.name .. "_2d", (info.glsl:gsub("%$", "g_"):gsub("%^", "_2d")), "mat4")
		render.SetGlobalShaderVariable("g_" .. info.name, (info.glsl:gsub("%$", "g_"):gsub("%^", "")), "mat4")
	else
		render.SetGlobalShaderVariable("g_" .. info.name .. "_2d", function() return render2d.camera:GetMatrices()[info.name] end, "mat4")
		render.SetGlobalShaderVariable("g_" .. info.name, function() return render3d.camera:GetMatrices()[info.name] end, "mat4")
	end
end

render.SetGlobalShaderVariable("g_cam_nearz", function() return render3d.camera.NearZ end, "float")
render.SetGlobalShaderVariable("g_cam_farz", function() return render3d.camera.FarZ end, "float")
render.SetGlobalShaderVariable("g_cam_fov", function() return render3d.camera.FOV end, "float")

render.SetGlobalShaderVariable("g_cam_pos", function() return render3d.camera:GetPosition() end, "vec3")
render.SetGlobalShaderVariable("g_cam_up", function() return render3d.camera:GetAngles():GetUp() end, "vec3")
render.SetGlobalShaderVariable("g_cam_forward", function() return render3d.camera:GetAngles():GetForward() end, "vec3")
render.SetGlobalShaderVariable("g_cam_right", function() return render3d.camera:GetAngles():GetRight() end, "vec3")

render.AddGlobalShaderCode([[
float get_depth(vec2 uv)
{
	return texture(tex_depth, uv).r;
}]])

render.AddGlobalShaderCode([[
float linearize_depth(float depth)
{
	return (2.0 * g_cam_nearz) / (g_cam_farz + g_cam_nearz - depth * (g_cam_farz - g_cam_nearz));
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
    vec3 eye_normal = normalize((g_projection_inverse * device_normal).xyz);
    vec3 world_normal = normalize(mat3(g_view_inverse)*eye_normal);
    return world_normal;
}]])


