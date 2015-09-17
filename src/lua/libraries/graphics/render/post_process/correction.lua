local PASS = {}

PASS.Name = FILE_NAME
PASS.Position = math.huge
PASS.Default = SRGB

PASS.Source = [[
	out vec3 out_color;
		
	void main()
	{		
		const float gamma = 0.8;
		const float exposure = 3;
				
		// Exposure tone mapping
		vec3 mapped = vec3(1.0) - exp(-texture(self, uv).rgb * exposure);
		// Gamma correction 
		mapped = pow(mapped, vec3(1.0 / gamma));
	  
		out_color = mapped;
	}
]]

render.AddGBufferShader(PASS)