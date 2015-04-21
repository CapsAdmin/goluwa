local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = true

PASS.Source = [[	
	float compare_depths( in float depth1, in float depth2 ) {
		float diff = (depth2)-(depth1-0.000001);
		diff = clamp(diff *= 2048.0, 0, 0.25);
						
		return diff;
	}
	
	float ssao()
	{

		float depth = get_depth(uv);
		
		if (depth > 1.0) return 1;
		
		float pw = 1.0 / g_screen_size.x;
		float ph = 1.0 / g_screen_size.y;

		float ao = 8.0;
		
		float aoscale = 1.1;
		
		pw /= aoscale;
		ph /= aoscale;
		
		for (int i = 1; i < 48; i++)
		{					
			ao += compare_depths(depth, get_depth(vec2(uv.x+pw,uv.y+ph)));
			ao += compare_depths(depth, get_depth(vec2(uv.x-pw,uv.y+ph)));
			ao += compare_depths(depth, get_depth(vec2(uv.x+pw,uv.y-ph)));
			ao += compare_depths(depth, get_depth(vec2(uv.x-pw,uv.y-ph)));
		 
			pw *= aoscale;
			ph *= aoscale;
		}			 
	 
		ao/=48.0;
	 
		return 0.5+clamp(ao, 0.0, 1.0)*0.5;
	}
	out vec4 out_color;

	void main() 
	{ 
		out_color.rgb = texture(self, uv).rgb * vec3(ssao());
		out_color.a = 1; 
	}
]]

render.AddGBufferShader(PASS)