local PASS = {}

PASS.Name = "light"
PASS.Position = FILE_NAME:sub(1, 1)

PASS.Variables = {
	ambient_lighting = Color(0.3, 0.3, 0.3, 1),
}
PASS.Source = [[
	out vec4 out_color;
		
	void main()
	{		
		out_color = texture(tex_diffuse, uv);
						
		vec3 light = texture(tex_light, uv).rgb;
		light = max(light, ambient_lighting.rgb);

		out_color.rgb *= light/2;
		out_color.rgb += texture(tex_illumination, uv).rgb*2;
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)