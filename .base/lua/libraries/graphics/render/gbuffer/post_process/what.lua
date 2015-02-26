local PASS = {}

PASS.Name = "what"
PASS.Default = false

PASS.Variables = {
	inverse_projection = {mat4 = function() return render.matrices.projection_3d_inverse.m end},
	inverse_view = {mat4 = function() return render.matrices.view_3d_inverse.m end},
}

PASS.Source = [[
	float get_depth(vec2 uv) 
	{
		return -(2.0 * cam_nearz) / (cam_farz + cam_nearz - texture2D(tex_depth, uv).r * (cam_farz - cam_nearz));
	}
	

	vec3 get_pos(vec2 uv)
	{
		vec4 pos = inverse_view * inverse_projection * vec4(uv * 2 - 1, texture2D(tex_depth, uv).r * 2 - 1, 1);
		return pos.xyz / pos.w;
	}
	
	out vec4 out_color;

	void main() 
	{ 
		out_color.rgb = get_pos(uv);
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)