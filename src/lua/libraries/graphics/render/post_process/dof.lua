local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = false

PASS.Source = [[
	out vec4 out_color;
	
	void main()
	{					
		int uBlurSize = 4;
		vec2 texelSize = 1.0 / vec2(textureSize(self, 0));
		float z = pow((-texture(tex_depth, uv).r+1)*10, 1.25);
		//	ideally use a fixed size noise and blur so that this loop can be unrolled
		vec3 fResult = vec3(0);
		vec2 hlim = vec2(float(-uBlurSize) * 0.5 + 0.5);
		for (int x = 0; x < uBlurSize; ++x) {
			for (int y = 0; y < uBlurSize; ++y) {
				vec2 offset = vec2(float(x), float(y));
				offset += hlim;
				offset *= texelSize * z;
						
				fResult += texture(self, uv + offset).rgb;
			}
		}
		
		out_color.rgb = fResult / (uBlurSize * uBlurSize);
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)