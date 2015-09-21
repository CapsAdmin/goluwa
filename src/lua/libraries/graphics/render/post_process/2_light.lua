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
		
		specular += reflection * metallic;		
		specular = mix(specular, reflection, metallic);
		
		specular += diffuse * texture(tex_reflection, uv).a;
		
		out_color = diffuse * specular;
	}
]]

render.AddGBufferShader(PASS)