local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")
PASS.Default = SRGB

PASS.Source = [[
	out vec3 out_color;
		
	void main()
	{		
		const float gamma = 0.75;
		const float exposure = 2.5;
				
		// Exposure tone mapping
		vec3 mapped = vec3(1.0) - exp(-texture(self, uv).rgb * exposure);
		// Gamma correction 
		mapped = pow(mapped, vec3(1.0 / gamma));
	  
		out_color = mapped;
	}
]]

render.AddGBufferShader(PASS)