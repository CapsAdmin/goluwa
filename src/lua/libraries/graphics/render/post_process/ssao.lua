local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = true

PASS.Source = [[	
	float compare_depths( in float depth1, in float depth2 ) 
	{
		float diff = (depth2-(depth1-0.000001)) * 55000;
		
		return clamp(diff, 0.025, 0.1);
	}
	
	float ssao()
	{

		float depth = get_depth(uv);
		
		if (depth > 1.0) return 1.0;
		
		float pw = 1.0 / g_screen_size.x;
		float ph = 1.0 / g_screen_size.y;

		float ao = 0.0;
		
		float aoscale = 1.25;
				
		for (int i = 1; i < 16; i++)
		{					
			ao += compare_depths(depth, get_depth(vec2(uv.x + pw, uv.y + ph)));
			ao += compare_depths(depth, get_depth(vec2(uv.x - pw, uv.y + ph)));
			ao += compare_depths(depth, get_depth(vec2(uv.x + pw, uv.y - ph)));
			ao += compare_depths(depth, get_depth(vec2(uv.x - pw, uv.y - ph)));
		 
			pw *= aoscale;
			ph *= aoscale;
		}			 
	 
		ao/=4.0;
	 
		return clamp(pow(ao+0.1, 2), 0, 1);
	}
	out vec3 out_color;

	void main() 
	{ 
		out_color = texture(self, uv).rgb * vec3(ssao());
	}
]]

render.AddGBufferShader(PASS)