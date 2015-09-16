local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")
PASS.Default = true

PASS.Source = {}

table.insert(PASS.Source, {
	buffer = {
		size_divider = 2,
		internal_format = "rgb8",
	},
	source = [[	 
	const float rayStep = 0.33;
	const float minRayStep = 0.1;
	const float maxSteps = 30;
	
	const float searchDist = 200;
	const float searchDistInv = 0.2;	 
	
	vec2 project(vec3 coord)
	{
		vec4 res = g_projection * vec4(coord, 1.0);
		return (res.xy / res.w) * 0.5 + 0.5;
	}
	 
	vec4 ray_cast(vec3 dir, inout vec3 hitCoord)
	{
		dir *= rayStep * pow(1/texture(tex_depth, uv).x/10, 1.23);
	  	 
		for(int i = 0; i < maxSteps; i++)
		{
			hitCoord += dir;
				  
			float depth = hitCoord.z - get_view_pos(project(hitCoord)).z + (random(uv) * get_roughness(uv));
			 	 
			if(depth < 0.0 && depth > -1)
			{
				dir *= 0.5;
				hitCoord -= dir;
				
				return vec4(project(hitCoord).xy, depth, 1);
			}
		}
	 
		return vec4(0.0, 0.0, 0.0, 0.0);
	}

	out vec3 out_color;
	 
	void main()
	{
		vec3 viewNormal = get_view_normal(uv);
		vec3 viewPos = get_view_pos(uv);
		vec3 reflected = normalize(reflect(normalize(viewPos), normalize(viewNormal)));
		
		vec3 hitPos = viewPos;
		vec4 coords = ray_cast(reflected * max(minRayStep, -viewPos.z), hitPos);
		
		vec2 dCoords = abs(vec2(0.5, 0.5) - coords.xy);
		float screenEdgefactor = clamp(1.0 - (dCoords.x + dCoords.y), 0.0, 1.0);
		
		float fade = screenEdgefactor *  clamp((searchDist - length(viewPos - hitPos)) * searchDistInv, 0.0, 1.0) * coords.w;
	 	
		vec3 reflection = mix(texture(tex_reflection, uv).rgb, texture(tex_diffuse, coords.xy).rgb * pow(get_light(uv), vec3(1)), pow(fade, 0.15));
	 
		out_color =	reflection;
	}
]]
})

table.insert(PASS.Source, {
	source = [[
		out vec3 out_color;
		
		void main()
		{			
			out_color = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;
		}
	]]
})


render.AddGBufferShader(PASS)