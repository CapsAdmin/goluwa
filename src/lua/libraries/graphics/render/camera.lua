local render = ... or _G.render

for _, info in ipairs(camera.GetVariables()) do
	if info.glsl then
		render.SetGlobalShaderVariable("g_" .. info.name .. "_2d", (info.glsl:gsub("%$", "g_"):gsub("%^", "_2d")), "mat4")
		render.SetGlobalShaderVariable("g_" .. info.name, (info.glsl:gsub("%$", "g_"):gsub("%^", "")), "mat4")
	else
		render.SetGlobalShaderVariable("g_" .. info.name .. "_2d", function() return camera.camera_2d:GetMatrices()[info.name] end, "mat4")
		render.SetGlobalShaderVariable("g_" .. info.name, function() return camera.camera_3d:GetMatrices()[info.name] end, "mat4")
	end
end

render.SetGlobalShaderVariable("g_cam_nearz", function() return camera.camera_3d.NearZ end, "float")
render.SetGlobalShaderVariable("g_cam_farz", function() return camera.camera_3d.FarZ end, "float")
render.SetGlobalShaderVariable("g_cam_fov", function() return camera.camera_3d.FOV end, "float")

render.SetGlobalShaderVariable("g_cam_pos", function() return camera.camera_3d:GetPosition() end, "vec3")
render.SetGlobalShaderVariable("g_cam_up", function() return camera.camera_3d:GetAngles():GetUp() end, "vec3")
render.SetGlobalShaderVariable("g_cam_forward", function() return camera.camera_3d:GetAngles():GetForward() end, "vec3")
render.SetGlobalShaderVariable("g_cam_right", function() return camera.camera_3d:GetAngles():GetRight() end, "vec3")

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


