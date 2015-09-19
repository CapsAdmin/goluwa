local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = false

PASS.Source = [[	
	float compare_depths(vec3 origin, vec3 pos) 
	{
		vec3 dir = origin-pos;
		
		if (dir.z < -0.5) return -dir.z/400;
		
		return clamp(dir.z, 0.0, 0.01);
	}
	
	float ssao()
	{

		vec3 origin = get_view_pos(uv)*0.996;
		
		vec2 p = vec2(1.0) / g_screen_size;

		float ao = 0.0;
		
		float aoscale = 1.125;
				
		for (int i = 1; i < 32; i++)
		{		
			ao += compare_depths(origin, get_view_pos(vec2(uv.x + p.x, uv.y + p.y)));
			ao += compare_depths(origin, get_view_pos(vec2(uv.x - p.x, uv.y + p.y)));
			ao += compare_depths(origin, get_view_pos(vec2(uv.x + p.x, uv.y - p.y)));
			ao += compare_depths(origin, get_view_pos(vec2(uv.x - p.x, uv.y - p.y)));
		 
			p *= aoscale;
		}			 
	 	
		 
		return clamp(pow(ao/2 + 0.68, 7), 0, 1);
	}
	out vec3 out_color;

	void main() 
	{ 
		out_color = 
			texture(self, uv).rgb * 
			vec3(ssao());
	}
]]

render.AddGBufferShader(PASS)