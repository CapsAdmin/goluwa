local PASS = {}

PASS.Name = "ssdo"
PASS.Default = false

PASS.Variables = {
	tex_ssdo = "texture",
}

function PASS:Initialize()
	self.fb = render.CreateFrameBuffer(render.GetWidth()/2, render.GetHeight()/2)
		
	self.extract = render.CreateShader([[		
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
		
		vec3 dssdo()
		{				
			vec2 noise_texture_size = vec2(512,512)*2;
			vec3 center_pos = get_view_pos(uv);

			float radius = occlusion_radius / center_pos.z;
						
			float max_distance_inv = 1.f / occlusion_max_distance;

			vec3 noise = texture(tex_noise, uv*g_screen_size.xy/noise_texture_size).xyz*2-1;
					
			vec3 center_normal = get_view_normal(uv);

			vec4 occlusion_sh2 = vec4(0);

			const float fudge_factor_l0 = 2.0;
			const float fudge_factor_l1 = 10.0;
			const float sh2_weight_l0 = fudge_factor_l0 * 0.28209; //0.5*sqrt(1.0/pi);
			const vec3 sh2_weight_l1 = vec3(fudge_factor_l1 * 0.48860); //0.5*sqrt(3.0/pi);

			vec4 sh2_weight = vec4(sh2_weight_l1, sh2_weight_l0) / float(num_samples);
		
			for( int i=0; i<num_samples; ++i )
			{
				vec2 textureOffset = reflect( points[ i ].xy, noise.xy ).xy * radius;
				vec3 sample_pos = get_view_pos(uv + textureOffset);
				vec3 center_to_sample = sample_pos - center_pos;
				float dist = length(center_to_sample);
				vec3 center_to_sample_normalized = center_to_sample / dist;
				float dp = dot(center_normal, center_to_sample_normalized);
				if (dp > angle_threshold)
				{
					float attenuation = 1-clamp(dist * max_distance_inv, 0, 1);
					attenuation = attenuation*attenuation * step(angle_threshold, dp);
					occlusion_sh2 += attenuation * sh2_weight*vec4(center_to_sample_normalized,1);
				}
			}

			return occlusion_sh2.xyz;
			
			/*float occlusion = 0;

			float weight = 50 / float(num_samples);
		
			for( int i = 0; i < num_samples; ++i)
			{
				vec3 sample_pos = get_view_pos(uv + reflect(points[i].xyz, noise.xyz).xy * radius);
				vec3 center_to_sample = sample_pos - center_pos;
				float dist = length(center_to_sample)*0.25;
				float dp = dot(center_normal, center_to_sample / dist);
				if (dp > angle_threshold)
				{
					float attenuation = 1-clamp(dist * max_distance_inv, 0, 1);
					attenuation = attenuation * step(angle_threshold, dp);
					occlusion += attenuation*weight*dist/2; 
				}
			}

			return clamp(-occlusion+1,0,1) * 0.5;*/
		}
		
		out vec4 out_color;
		
		void main() 
		{ 	
			out_color.rgb = dssdo();
			out_color.a = 1;
		}
	]], {
		self = self.fb:GetTexture(), 
		tex_noise =  {texture = render.GetNoiseTexture},
		num_samples = 32,
		occlusion_max_distance = 1,
		occlusion_radius = 0.25,
		angle_threshold = 0.75,
	})
	
	self.blur = render.CreateShader([[
		float weights[9] =
		float[](
			0.013519569015984728,
			0.047662179108871855,
			0.11723004402070096,
			0.20116755999375591,
			0.240841295721373,
			0.20116755999375591,
			0.11723004402070096,
			0.047662179108871855,
			0.013519569015984728
		);

		float indices[9] = float[](-4, -3, -2, -1, 0, +1, +2, +3, +4);

		vec2 step = blur_dir/blur_size;

		vec3 normal[9] =
		vec3[](
			get_view_normal(uv + indices[0]*step).xyz,
			get_view_normal(uv + indices[1]*step).xyz,
			get_view_normal(uv + indices[2]*step).xyz,
			get_view_normal(uv + indices[3]*step).xyz,
			get_view_normal(uv + indices[4]*step).xyz,
			get_view_normal(uv + indices[5]*step).xyz,
			get_view_normal(uv + indices[6]*step).xyz,
			get_view_normal(uv + indices[7]*step).xyz,
			get_view_normal(uv + indices[8]*step).xyz
		);

		float total_weight = 1;
		float discard_threshold = 0.85;

		for( int i=0; i<9; ++i )
		{
			if( dot(normal[i], normal[4]) < discard_threshold )
			{
				total_weight -= weights[i];
				weights[i] = 0;
			}
		}

		//

		vec4 res = vec4(0);

		for( int i=0; i<9; ++i )
		{
			res += texture(self, uv + indices[i]*step) * weights[i];
		}

		res /= total_weight;
		res.a = 1;

		return res;
	]], {
		self = self.fb:GetTexture(),
		blur_size = 666,
		blur_dir = Vec2(0,0),
	})
end

function PASS:Update()
	--self.fb:Copy(render.gbuffer_mixer_buffer)
	
	render.SetBlendMode("alpha")
	
	surface.PushMatrix(0, 0, self.fb.w, self.fb.h)		
		self.fb:Begin()
			self.extract:Bind()
			surface.rect_mesh:Draw()
		self.fb:End()
	
		self.blur.blur_dir = Vec3(1, 0) 
		self.fb:Begin()
			self.blur:Bind()
			surface.rect_mesh:Draw()
		self.fb:End()
		
		self.blur.blur_dir = Vec3(0, 1) 
		self.fb:Begin()
			self.blur:Bind()
			surface.rect_mesh:Draw()
		self.fb:End()
		
	surface.PopMatrix()
	
	self.shader.tex_ssdo = self.fb:GetTexture()
end


PASS.Source = [[
	out vec4 out_color;
		
	void main() 
	{ 	
		out_color.rgb = texture(self, uv).rgb;
		out_color.rgb = vec3(-length(texture(tex_ssdo, uv).rgb)+1);
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)