local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
	out vec4 out_color;
		
	void main()
	{		
		const float gamma = 0.5;
		const float exposure = 2;
				
		// Exposure tone mapping
		vec3 mapped = vec3(1.0) - exp(-texture(self, uv).rgb * exposure);
		// Gamma correction 
		mapped = pow(mapped, vec3(1.0 / gamma));
	  
		out_color = vec4(mapped, 1.0);
	}
]]

render.AddGBufferShader(PASS)