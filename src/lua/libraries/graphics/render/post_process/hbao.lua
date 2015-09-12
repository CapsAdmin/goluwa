local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = false

PASS.Source = {
	{
		buffer = {
			size_divider = 2,
			internal_format = "r8",
			filter = "nearest",
		},
		source = [[
			// number of directions to sample in UV space
			#define NUM_SAMPLE_DIRECTIONS 7

			// number of sample steps when raymarching along a direction
			#define NUM_SAMPLE_STEPS 3

			const float uSampleRadius = 800;
			const float uAngleBias = 0.2;
			const float uIntensity = 10;
			const vec2 uNoiseScale = vec2(2);

			out float out_color;

			void main() 
			{
				const float PI = 3.14159265359;
				const float TWO_PI = 2.0 * PI;
				
				vec3 originVS = get_view_pos(uv)*0.996;
				
				vec3 normalVS = get_view_normal(uv);
				
				const float theta = TWO_PI / float(NUM_SAMPLE_DIRECTIONS);
				float cosTheta = cos(theta);
				float sinTheta = sin(theta);
				
				// matrix to create the sample directions
				mat2 deltaRotationMatrix = mat2(-cosTheta, -sinTheta, sinTheta, cosTheta);
				
				// step vector in view space
				vec2 deltaUV = vec2((uSampleRadius / (float(NUM_SAMPLE_DIRECTIONS * NUM_SAMPLE_STEPS) + 1.0)), 0.0);
				
				// we don't want to sample to the perimeter of R since those samples would be 
				// omitted by the distance attenuation (W(R) = 0 by definition)
				// Therefore we add a extra step and don't use the last sample.
				vec3 sampleNoise = normalize(get_noise(uv * uNoiseScale).xyz * 2 - 1);
				mat2 rotationMatrix = mat2(sampleNoise.xyxy);
				
				// apply a random rotation to the base step vector
				deltaUV = rotationMatrix * deltaUV;
				
				float jitter = sampleNoise.z*2;
				float occlusion = 0.0;
				
				for (int i = 0; i < NUM_SAMPLE_DIRECTIONS; ++i) 
				{
					// incrementally rotate sample direction
					deltaUV = deltaRotationMatrix * deltaUV;
					
					vec2 sampleDirUV = deltaUV / originVS.z;
					float oldAngle = uAngleBias;
					
					for (int j = 0; j < NUM_SAMPLE_STEPS; ++j) 
					{
						vec2 sampleUV = uv + (jitter + float(j)) * sampleDirUV;
						vec3 sampleVS = get_view_pos(sampleUV);
						vec3 sampleDirVS = (sampleVS - originVS);
						
						if (sampleDirVS.z < uSampleRadius * 0.05 && sampleDirVS.z > -50)
						{		
							// angle between fragment tangent and the sample
							float gamma = (PI / 2.0) - acos(dot(normalVS, normalize(sampleDirVS)));
							
							if (gamma > oldAngle) 
							{
								occlusion += sin(gamma) - sin(oldAngle);
								oldAngle = gamma;
							}
						}
					}
				}
			
			occlusion = 1.0 - occlusion / float(NUM_SAMPLE_DIRECTIONS);
			occlusion = pow(occlusion, 1.0 + uIntensity * uAngleBias);
			out_color = occlusion;
		}]]
	},
	{
		buffer = {
			size_divider = 1,
			internal_format = "r8",
		},
		source = [[
			out float out_color;
			
			float blur(sampler2D uInputTex)
			{
				int uBlurSize = 2;
				vec2 texelSize = 1.0 / vec2(textureSize(uInputTex, 0));
				
				//	ideally use a fixed size noise and blur so that this loop can be unrolled
				float fResult = 0;
				vec2 hlim = vec2(float(-uBlurSize) * 0.5 + 0.5);
				for (int x = 0; x < uBlurSize; ++x) {
					for (int y = 0; y < uBlurSize; ++y) {
						vec2 offset = vec2(float(x), float(y));
						offset += hlim;
						offset *= texelSize;
								
						fResult += texture(uInputTex, uv + offset).r;
					}
				}
				
				return fResult / (uBlurSize * uBlurSize);
			}
			
			void main()
			{					
				out_color = blur(tex_stage_1);
			}
		]]
	},
	{
		source = [[
			out vec4 out_color;
			
			void main()
			{
				out_color.rgb = texture(self, uv).rgb * vec3(texture(tex_stage_2, uv).r);
				out_color.a = 1;
			}
		]]
	}
}

render.AddGBufferShader(PASS)