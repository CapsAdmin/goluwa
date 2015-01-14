local PASS = {}

PASS.Name = "fog"
PASS.Position = 2

PASS.Variables = {
	fog_color = Color(0.9,0.9,0.9),
	fog_intensity = 256,
	fog_start = 0,
	fog_end = 32,
}

PASS.Source = [[	
	float get_depth2(vec2 coord, float start, float end) 
	{
		return (2.0 * start) / (end + start - texture(tex_depth, coord).r * (end - start));
	}
		
	vec3 mix_fog(vec3 color)
	{
		if (fog_color.a == 0) return color;
	
		// THIS ISNT RIGHT
		if (fog_start > fog_end)
			color = mix(fog_color.rgb, color, clamp(get_depth2(uv, cam_nearz, fog_start) * fog_color.a, 0.0, 1.0));
		
		if (fog_start < fog_end)
			color = mix(fog_color.rgb, color, clamp((-pow(get_depth2(uv, cam_nearz, fog_end),5)*6.5+1) * fog_color.a, 0.0, 1.0));
		
		
		return color;
	}
	
	out vec4 out_color;

	void main()
	{
		out_color.rgb = mix_fog(texture(self, uv).rgb);
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)