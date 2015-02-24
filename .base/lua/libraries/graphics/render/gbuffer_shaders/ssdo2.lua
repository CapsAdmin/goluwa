local PASS = {}

PASS.Name = "ssdo2"
PASS.Position = 1

PASS.Variables = {
	inverse_projection = {mat4 = function() return render.matrices.projection_3d_inverse.m end},
	num_samples = 16,
	occlusion_max_distance = 0.2,
	occlusion_radius = 0.25,
	angle_threshold = 2,
	tex_noise =  {texture = render.GetNoiseTexture},
}

PASS.Source = [[
	vec3 get_pos(vec2 uv)
	{
		float z = -texture(tex_depth, uv).r;
		vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
		sPos = inverse_projection * sPos;

		return (sPos.xyz / sPos.w);
	}
	
	uniform vec3 points[] =
	{
		vec3(-0.134, 0.044, -0.825),
		vec3(0.045, -0.431, -0.529),
		vec3(-0.537, 0.195, -0.371),
		vec3(0.525, -0.397, 0.713),
		vec3(0.895, 0.302, 0.139),
		vec3(-0.613, -0.408, -0.141),
		vec3(0.307, 0.822, 0.169),
		vec3(-0.819, 0.037, -0.388),
		vec3(0.376, 0.009, 0.193),
		vec3(-0.006, -0.103, -0.035),
		vec3(0.098, 0.393, 0.019),
		vec3(0.542, -0.218, -0.593),
		vec3(0.526, -0.183, 0.424),
		vec3(-0.529, -0.178, 0.684),
		vec3(0.066, -0.657, -0.570),
		vec3(-0.214, 0.288, 0.188),
		vec3(-0.689, -0.222, -0.192),
		vec3(-0.008, -0.212, -0.721),
		vec3(0.053, -0.863, 0.054),
		vec3(0.639, -0.558, 0.289),
		vec3(-0.255, 0.958, 0.099),
		vec3(-0.488, 0.473, -0.381),
		vec3(-0.592, -0.332, 0.137),
		vec3(0.080, 0.756, -0.494), 
		vec3(-0.638, 0.319, 0.686),
		vec3(-0.663, 0.230, -0.634),
		vec3(0.235, -0.547, 0.664),
		vec3(0.164, -0.710, 0.086),
		vec3(-0.009, 0.493, -0.038),
		vec3(-0.322, 0.147, -0.105),
		vec3(-0.554, -0.725, 0.289),
		vec3(0.534, 0.157, -0.250),
	
		/*vec3(-0.134, 0.044, -0.825),			
		vec3(0.895, 0.302, 0.139),					
		vec3(0.376, 0.009, 0.193),
		vec3(0.526, -0.183, 0.424),			
		vec3(-0.689, -0.222, -0.192),			
		vec3(-0.255, 0.958, 0.099),			
		vec3(-0.663, 0.230, -0.634),			
		vec3(-0.322, 0.147, -0.105),*/
	};
	
	float dssdo()
	{				
		vec2 noise_texture_size = vec2(512,512);
		vec3 center_pos = get_pos(uv);

		float radius = occlusion_radius / center_pos.z;
					
		float max_distance_inv = 1.f / occlusion_max_distance;

		vec3 noise = texture(tex_noise, uv*size.xy/noise_texture_size).xyz*2-1;
				
		vec3 center_normal = texture(tex_normal, uv).xyz;
		
		float occlusion = 0;

		float weight = 2 / float(num_samples);
	
		for( int i = 0; i < num_samples; ++i)
		{
			vec3 sample_pos = get_pos(uv + reflect(points[i].xyz, noise.xyz).xy * radius);
			vec3 center_to_sample = sample_pos - center_pos;
			float dist = length(center_to_sample)*0.25;
			float dp = dot(center_normal, center_to_sample / dist);
			if (dp > angle_threshold)
			{
				float attenuation = 1-clamp(dist * max_distance_inv, 0, 1);
				attenuation = attenuation * step(angle_threshold, dp);
				occlusion += attenuation*weight; 
			}
		}

		return clamp(-occlusion+1,0,1);
	}
	
	out vec4 out_color;
	
	void main() 
	{ 	
		out_color.rgb = texture(self, uv).rgb;
		out_color.rgb *= vec3(dssdo());
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)