render.AddGlobalShaderCode([[
vec3 gbuffer_compute_sky(vec3 ray, float depth)
{
	depth = depth < 1 ? 0 : 1;
	vec3 res = textureLatLon(lua[nightsky_tex = render.CreateTextureFromPath("textures/skybox/hdr/power_plant.hdr")], ray.xzy * vec3(1,-1,1)).rgb*depth;

	res = pow(res, vec3(0.5));
	res += res*vec3(length(pow(res, vec3(5))));

	return res;
}]])

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_specular(vec3 l, vec3 v, vec3 n, float attenuation, vec3 light_color)
{
	return attenuation*light_color;
}]])

do
	local PASS = {}

	PASS.Position = 1
	PASS.Name = "importance_sampling"

	PASS.Source = {}

	table.insert(PASS.Source, {
		buffer = {
			--max_size = Vec2() + 512,
			size_divider = 1,
			internal_format = "r11f_g11f_b10f",
		},
		source = [[

		float brdf(vec3 l, vec3 v, vec3 n)
		{
			n = -n;
			vec2 uv = get_screen_uv();

			float diffuseTerm = clamp(dot(n, l), 0, 1);
			float specularTerm = 0;

			if(dot(n, l) > 0)
			{
				vec3 h = normalize(l + v);
				specularTerm = pow(dot(n, h), pow(1/get_roughness(uv), 5));
			}

			return (diffuseTerm + specularTerm);
		}

		out vec3 out_color;

		void main()
		{
			if (get_depth(uv) == 1)
			{
				out_color = vec3(0,0,0);
			}
			else
			{
				float roughness = get_roughness(uv) * 0.5;
				vec3 lookup = -reflect(get_camera_dir(uv), get_world_normal(uv)).yxz*vec3(1,-1,1);
				vec3 samples = vec3(0);

				for (float i = 0; i < 16; i++)
				{
					vec3 noise = get_noise3(uv+i) * roughness;
					samples += texture(lua[sky_tex = render3d.GetSkyTexture()], noise + lookup).rgb;
				}

				samples /= 16;

				vec3 pos = get_view_pos(uv);
				vec3 light_view_pos = g_view_world[3].xyz;

				vec3 V = normalize(pos);
				vec3 N = get_view_normal(uv);
				vec3 L = normalize(reflect(N, V));

				 //* vec3(brdf(-L, V, N)+0.5)

				out_color = samples;
			}
		}
	]]
	})

	table.insert(PASS.Source, {
		source = [[
			out vec3 out_color;

			void main()
			{
				vec3 reflection = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;

				out_color = reflection;
				out_color += gbuffer_compute_sky(-get_camera_dir(uv).yzx, get_linearized_depth(uv));
			}
		]]
	})

	render3d.AddGBufferShader(PASS)
end

if RELOAD then
	RELOAD = nil
	render3d.Initialize()
end