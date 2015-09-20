local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
	out vec3 out_color;
		
	void main()
	{	
		
		vec3 reflection = texture(self, uv).rgb;
		vec3 diffuse = texture(tex_diffuse, uv).rgb;
		vec3 specular = get_light(uv);
		float metallic = get_metallic(uv);
		float roughness = get_metallic(uv);
		
		specular += vec3(0.01) + normalize(reflection) * pow(length(reflection), metallic*roughness) / 5;
		
		out_color = diffuse * specular;
	}
]]

render.AddGBufferShader(PASS)