local PASS = {}

PASS.Name = "ssdo"
PASS.Position = 1

PASS.Variables = {
	ambient_lighting = Color(0.3, 0.3, 0.3, 1),
	tex_ssdo = "texture",
}

function PASS:Initialize()
	self.fb = render.CreateFrameBuffer(render.GetWidth(), render.GetHeight())
		
	self.extract = render.CreateShader([[						
		vec3 get_pos(vec2 uv)
		{
			float z = -texture(tex_depth, uv).r;
			vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
			sPos = inverse_projection * sPos;

			return (sPos.xyz / sPos.w);
		}
			
		float compare_depths( in float depth1, in float depth2 ) {
			float diff = (depth2)-(depth1-0.000005);
			diff = clamp(diff *= 30000, 0, 0.25);
							
			return diff;
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
		};
		
		vec4 dssdo()
		{		
			float g_occlusion_radius = 0.2;
			float g_occlusion_max_distance = 5;
		
			const int num_samples = 32;

			vec2 noise_texture_size = vec2(512,512)/10;
			vec3 center_pos = get_pos(uv);
			vec3 eye_pos = cam_eye.xyz;

			float center_depth = distance(eye_pos, center_pos);

			float radius = g_occlusion_radius / center_depth;
			float max_distance_inv = 1.f / g_occlusion_max_distance;
			float attenuation_angle_threshold = 0.3;

			vec3 noise = texture(tex_noise, uv*size.xy/noise_texture_size).xyz*2-1;
					
			vec3 center_normal = texture(tex_normal, uv).xyz;

			vec4 occlusion_sh2 = vec4(0);

			const float fudge_factor_l0 = 2.0;
			const float fudge_factor_l1 = 10.0;

			const float sh2_weight_l0 = fudge_factor_l0 * 0.28209; //0.5*sqrt(1.0/pi);
			const vec3 sh2_weight_l1 = vec3(fudge_factor_l1 * 0.48860); //0.5*sqrt(3.0/pi);

			vec4 sh2_weight = vec4(sh2_weight_l1, sh2_weight_l0) / float(num_samples);
		
			for( int i=0; i<num_samples; ++i )
			{
				vec2 textureOffset = reflect( points[ i ].xy, noise.xy ).xy * radius * (0.001+(float(i)/2.3333));
				vec2 sample_uv = uv + textureOffset;
				vec3 sample_pos = get_pos(sample_uv);
				vec3 center_to_sample = sample_pos - center_pos;
				float dist = length(center_to_sample);
				vec3 center_to_sample_normalized = center_to_sample / dist;
				float attenuation = 1-clamp(dist * max_distance_inv, 0, 1);
				float dp = dot(center_normal, center_to_sample_normalized);

				attenuation = attenuation*attenuation * step(attenuation_angle_threshold, dp);

				occlusion_sh2 += attenuation * sh2_weight*vec4(center_to_sample_normalized,1);
			}

			return (occlusion_sh2 * 0.5f + 0.5f);
		}
		
		out vec4 out_color;
			
		void main()
		{	
			out_color = dssdo();
			out_color.a = 1;
		}
	]], {
		self = self.fb:GetTexture(), 
		exposure = 1,
		tex_normal =  {texture = function() return render.gbuffer:GetTexture("normal") end},
		tex_depth =  {texture = function() return render.gbuffer:GetTexture("depth") end},
		tex_noise =  {texture = render.GetNoiseTexture},
		size = Vec2(render.GetWidth(), render.GetHeight()), 
		cam_eye = {vec3 = function() return render.GetCameraPosition() end},
		inverse_projection = {mat4 = function() return render.matrices.projection_3d_inverse.m end},
	})
	
	self.blur = render.CreateShader([[
		float dx = blur_size / size.x;
		float dy = blur_size / size.y;
		
		vec4 color = 4.0 * texture(self, uv);
		color += texture(self, uv + vec2(+dx, 0.0)) * 2.0;
		color += texture(self, uv + vec2(-dx, 0.0)) * 2.0;
		color += texture(self, uv + vec2(0.0, +dy)) * 2.0;
		color += texture(self, uv + vec2(0.0, -dy)) * 2.0;
		color += texture(self, uv + vec2(+dx, +dy));
		color += texture(self, uv + vec2(-dx, +dy));
		color += texture(self, uv + vec2(-dx, -dy));
		color += texture(self, uv + vec2(+dx, -dy)); 
		
		color.rgb /= 16;
		color.a = 1;
		
		return color;
	]], {
		self = self.fb:GetTexture(), 
		size = Vec2(render.GetWidth(), render.GetHeight()), 
		blur_size = 1,
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
		
		for i = 1, 0 do
			self.blur.blur_size = i
			self.fb:Begin()
				self.blur:Bind()
				surface.rect_mesh:Draw()
			self.fb:End()
		end
	surface.PopMatrix()
	
	self.shader.tex_ssdo = self.fb:GetTexture()
end


PASS.Source = [[
	out vec4 out_color;
		
	void main() 
	{ 	
		out_color.rgb = texture(self, uv).rgb * vec3(-length(texture(tex_ssdo, uv).xyz)/3+1);
		//out_color.rgb = vec3(-length(texture(tex_ssdo, uv).xyz)/3+1);
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)