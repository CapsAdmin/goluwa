local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
	out vec4 out_color;
		
	void main()
	{		
		out_color = texture(tex_diffuse, uv);
						
		vec3 light = texture(tex_light, uv).rgb;
		
		out_color.rgb *= light;
		//out_color.rgb += vec3(texture(tex_illumination, uv).r)*2;
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)