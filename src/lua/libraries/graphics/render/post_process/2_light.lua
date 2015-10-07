local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
	out vec3 out_color;

	void main()
	{
		vec3 reflection = texture(self, uv).rgb;
		vec3 diffuse = get_diffuse(uv);
		vec3 specular = get_light(uv);
		float metallic = get_metallic(uv);

		specular = mix(specular, reflection, pow(metallic, 0.5));

		// self illumination
		specular += diffuse * get_self_illumination(uv)/200;

		out_color = diffuse * specular;
		//out_color = reflection;
	}
]]

render.AddGBufferShader(PASS)