local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
	out vec3 out_color;
		
	void main()
	{	
		
		vec3 reflection = texture(self, uv).rgb;
		vec3 diffuse = texture(tex_diffuse, uv).rgb;
		vec3 specular = get_light(uv);
		
		out_color = diffuse * mix(vec3(1), reflection, min(get_metallic(uv), 1)) * specular;
		//out_color = reflection;
	}
]]

render.AddGBufferShader(PASS)