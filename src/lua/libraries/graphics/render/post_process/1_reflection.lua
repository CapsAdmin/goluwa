local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")
PASS.Default = true

PASS.Source = {}

local FAST_BLUR = false

table.insert(PASS.Source, {
	buffer = {
		max_size = Vec2() + 1024,
		internal_format = "rgb8",
	},
	source = [[	 
	const float rayStep = 0.002;
	const float minRayStep = 50;
	const float maxSteps = 50;
		
	vec2 project(vec3 coord)
	{
		vec4 res = g_projection * vec4(coord, 1.0);
		return (res.xy / res.w) * 0.5 + 0.5;
	}
	 
	vec4 ray_cast(vec3 dir, inout vec3 hitCoord)
	{
		dir *= rayStep;
	  	 
		for(int i = 0; i < maxSteps; i++)
		{
			hitCoord += dir;
				  
			float depth = hitCoord.z - get_view_pos(project(hitCoord)).z;
			 	 
			if(depth < 0.0 && depth > -0.3)
			{				
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
		vec4 coords = ray_cast(reflected * max(minRayStep, viewPos.z), hitPos);
		
		vec2 dCoords = abs(vec2(0.5, 0.5) - coords.xy);
		float screenEdgefactor = clamp(1.0 - (dCoords.x + dCoords.y), 0.0, 1.0);
		
		float dist = texture(tex_depth, uv).r*20;
		
		float fade = screenEdgefactor * pow(clamp((dist - length(viewPos - hitPos)) * 1/dist, 0.0, 1.0) * coords.w * 1.025, 5);
		
		vec4 sky = texture(tex_reflection, uv);
		vec3 diffuse = texture(tex_diffuse, coords.xy).rgb;
		vec3 light = diffuse * (get_light(coords.xy) + (sky.rgb * get_metallic(uv)) + (diffuse * diffuse * diffuse * texture(tex_reflection, coords.xy).a * 10));
		
		vec3 reflection = mix(sky.rgb, light, fade);
	 
		out_color =	reflection;
	}
]]
})

if FAST_BLUR then

	for x = -1, 1 do
		for y = -1, 1 do
			if x == 0 and y == 0 then goto continue end
			
			local weights = {}
			
			for i,v in ipairs({-0.028, -0.024, -0.020, -0.016, -0.012, -0.008, -0.004, 0.004, 0.008, 0.012, 0.016, 0.020, 0.024, 0.028}) do
				weights[i] = Vec2(v*x, v*y)
			end
			
			table.insert(PASS.Source, {
				buffer = {
					size_divider = 4,
					internal_format = "rgb8",
				},
				source = [[
					out vec3 out_color;
					
					void main()
					{			
						float roughness = get_roughness(uv);
						out_color = vec3(0.0);
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[1].x..[[,]]..weights[1].y..[[)*roughness).rgb*0.0044299121055113265;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[2].x..[[,]]..weights[2].y..[[)*roughness).rgb*0.00895781211794;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[3].x..[[,]]..weights[3].y..[[)*roughness).rgb*0.0215963866053;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[4].x..[[,]]..weights[4].y..[[)*roughness).rgb*0.0443683338718;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[5].x..[[,]]..weights[5].y..[[)*roughness).rgb*0.0776744219933;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[6].x..[[,]]..weights[6].y..[[)*roughness).rgb*0.115876621105;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[7].x..[[,]]..weights[7].y..[[)*roughness).rgb*0.147308056121;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv).rgb*0.159576912161;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[8].x..[[,]]..weights[8].y..[[)*roughness).rgb*0.147308056121;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[9].x..[[,]]..weights[9].y..[[)*roughness).rgb*0.115876621105;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[10].x..[[,]]..weights[10].y..[[)*roughness).rgb*0.0776744219933;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[11].x..[[,]]..weights[11].y..[[)*roughness).rgb*0.0443683338718;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[12].x..[[,]]..weights[12].y..[[)*roughness).rgb*0.0215963866053;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[13].x..[[,]]..weights[13].y..[[)*roughness).rgb*0.00895781211794;
						out_color += texture(tex_stage_]]..#PASS.Source..[[, uv + vec2(]]..weights[14].x..[[,]]..weights[14].y..[[)*roughness).rgb*0.0044299121055113265;
					}
				]]
			})
			::continue::
		end
	end 
else	
	for x = -1, 1 do
		for y = -1, 1 do
			if x == 0 and y == 0 then goto continue end
			table.insert(PASS.Source, {
				buffer = {
					max_size = Vec2() + 512,
					internal_format = "rgb8",
				},
				source = [[
					out vec3 out_color;
					
					vec3 blur(vec2 tex, vec2 dir)
					{
						if (get_view_normal(tex) == vec3(0,0,0))
							return vec3(0);
					
						float weights[9] =
						{
							0.013519569015984728,
							0.047662179108871855,
							0.11723004402070096,
							0.20116755999375591,
							0.240841295721373,
							0.20116755999375591,
							0.11723004402070096,
							0.047662179108871855,
							0.013519569015984728
						};
	
						const float indices[9] = {-4, -3, -2, -1, 0, +1, +2, +3, +4};
	
						vec2 step = dir/g_screen_size.xy;
	
						vec3 normal[9];
	
						]] ..(function()
							local str = ""
							for i = 0, 8 do
								str = str .. "normal["..i.."] = get_view_normal(tex + indices["..i.."]*step).xyz;\n"
							end
							return str
						end)()..[[
	
						float total_weight = 1.0;
						float discard_threshold = 0.2;
	
						int i;
	
						for( i=0; i<9; ++i )
						{
							if( dot(normal[i].xyz, normal[4].xyz) < discard_threshold)
							{
								total_weight -= weights[i];
								weights[i] = 0;
							}
						}
	
						//
	
						vec3 res = vec3(0);
	
						for( i = 0; i < 9; ++i )
						{
							res += texture(tex_stage_]]..#PASS.Source..[[, tex + indices[i]*step).rgb * weights[i];
						}
	
						res /= total_weight;
	
						return res;
					}
					
					void main()
					{					 
						out_color = blur(uv, vec2(]]..x..","..y..[[) * pow(get_roughness(uv) * 1.75, 4));
					}
				]]
			})
			::continue::
		end
	end 	
end

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