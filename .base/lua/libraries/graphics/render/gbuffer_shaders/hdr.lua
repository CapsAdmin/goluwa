do return end
render.AddPostProcessShader("hdr", { 
	{
		source = [[
			out vec4 out_color;
			
			float brightThreshold = 0.1;
			
			void main() 
			{ 
				// Calculate luminance
				float lum = dot(vec4(0.30, 0.59, 0.11, 0.0), texture(tex_last, uv)); //MUST EXTRACT FROM LAST BUFFER AND STORE IN A NEW BUFFER
				
				// Extract very bright areas of the map
				if (lum > brightThreshold)
				{
					out_color = texture(tex_last, uv);
				}
				else
				{
					out_color = vec4(0.0, 0.0, 0.0, 1.0);
				}
			}
		]],
	},
	{
		source = [[
			out vec4 out_color;

			vec4 blur(sampler2D tex, vec2 uv)
			{			
				float dx = 4 / screen_size.x;
				float dy = 4 / screen_size.y;
				
				// Apply 3x3 gaussian filter
				vec4 color = 4.0 * texture(tex, uv);
				color += texture(tex, uv + vec2(+dx, 0.0)) * 2.0;
				color += texture(tex, uv + vec2(-dx, 0.0)) * 2.0;
				color += texture(tex, uv + vec2(0.0, +dy)) * 2.0;
				color += texture(tex, uv + vec2(0.0, -dy)) * 2.0;
				color += texture(tex, uv + vec2(+dx, +dy));
				color += texture(tex, uv + vec2(-dx, +dy));
				color += texture(tex, uv + vec2(-dx, -dy));
				color += texture(tex, uv + vec2(+dx, -dy));
				
				return color / 16.0;
			}

			void main() 
			{ 
				out_color = blur(tex_last, uv);
			}
		]],
	},
	
	{		
		source = [[
			out vec4 out_color;
			
			float exposure = 1;
			float bloomFactor = 1;
			float brightMax = 2;
			
			void main() 
			{ 
				vec4 original_image = texture(tex_gbuffer, uv); 
				vec4 downsampled_extracted_bloom = texture(tex_last, uv);
				
				vec4 color = original_image + downsampled_extracted_bloom * bloomFactor;
				
				// Perform tone-mapping
				float Y = dot(vec4(0.30, 0.59, 0.11, 0.0), color);
				float YD = exposure * (exposure/brightMax + 1.0) / (exposure + 1.0);
				color *= YD;
				
				color.a = 1;
				
				out_color = color;
			}
		]],
	}, 
}) 