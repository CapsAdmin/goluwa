render.AddGlobalShaderCode([[
float handle_roughness(float x)
{
	return x;
}
]])

render.AddGlobalShaderCode([[
float handle_metallic(float x)
{
	return x;
}
]])

render.AddGlobalShaderCode([[
float random(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}]])

render.AddGlobalShaderCode([[
vec2 get_noise2(vec2 uv)
{
	float x = random(uv);
	float y = random(uv*x);

	return vec2(x,y) * 2 - 1;
}]])

render.AddGlobalShaderCode([[
vec3 get_noise3(vec2 uv)
{
	float x = random(uv);
	float y = random(uv*x);
	float z = random(uv*y);

	return vec3(x,y,z) * 2 - 1;
}]])


render.AddGlobalShaderCode([[
vec4 get_noise(vec2 uv)
{
	return texture(g_noise_texture, uv);
}]])

render.AddGlobalShaderCode([[
vec3 gbuffer_compute_tonemap(vec3 color, vec3 bloom)
{
	const float gamma = 1.2;
	const float exposure = 0.2;
	const float bloomFactor = 0.03;

	color = color + bloom * bloomFactor;
	color *= exposure * (exposure + 1.0);
	color = exp( -1.0 / ( 2.72*color + 0.15 ) );
	color = pow(color, vec3(1. / gamma));
	color = max(vec3(0.), color - vec3(0.004));
	color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);

	return color;
}]])

render.AddGlobalShaderCode([[
float gbuffer_compute_light_attenuation(vec3 pos, vec3 light_pos, float radius, vec3 normal)
{
	const float cutoff = 0.175;

	vec3 L = light_pos - pos;
	float distance = length(L);
	L /= distance;

	float dot = max(dot(L, normal), 0);

	float r = radius/10;
	float d = max(distance - r, 0);

	float denom = d/r + 1;
	float attenuation = 1 / (denom*denom);
	attenuation = (attenuation - cutoff) / (1 - cutoff);
	attenuation = max(attenuation, 0);
	attenuation *= dot;

	return attenuation;
}
]])

render.AddGlobalShaderCode([[
vec2 _raycast_project(vec3 coord)
{
	vec4 res = g_projection * vec4(coord, 1.0);
	return (res.xy / res.w) * 0.5 + 0.5;
}

vec2 g_raycast(vec2 uv, const float step_size, const float max_steps)
{
	vec3 viewPos = get_view_pos(uv);

	vec3 dir = reflect(normalize(viewPos), get_view_normal(uv)) * 125;
	dir *= step_size + get_linearized_depth(uv);

	for(int i = 0; i < max_steps; i++)
	{
		viewPos += dir;
		viewPos += get_noise3(viewPos.xy).xyz * pow(get_roughness(uv), 3)*2;

		float depth = viewPos.z - get_view_pos(_raycast_project(viewPos)).z;

		if(depth > -5 && depth < 0)
		{
			return _raycast_project(viewPos).xy;
		}
	}

	return vec2(0.0, 0.0);
}
]])

render.AddGlobalShaderCode([[
float g_ssao(vec2 uv) {
	const vec2 KERNEL[16] = vec2[](vec2(0.53812504, 0.18565957), vec2(0.13790712, 0.24864247), vec2(0.33715037, 0.56794053), vec2(-0.6999805, -0.04511441), vec2(0.06896307, -0.15983082), vec2(0.056099437, 0.006954967), vec2(-0.014653638, 0.14027752), vec2(0.010019933, -0.1924225), vec2(-0.35775623, -0.5301969), vec2(-0.3169221, 0.106360726), vec2(0.010350345, -0.58698344), vec2(-0.08972908, -0.49408212), vec2(0.7119986, -0.0154690035), vec2(-0.053382345, 0.059675813), vec2(0.035267662, -0.063188605), vec2(-0.47761092, 0.2847911));
	const float SAMPLE_RAD = 5;
	const float INTENSITY = 1;
	const float ITERATIONS = 16;

	vec3 p = get_view_pos(uv)*0.99;

	vec3 n = get_view_normal(uv);
	vec2 offset = uv;
	float occlusion = 0;
	float weight = 1;

	for(float j = 0; j < ITERATIONS; ++j)
	{
		vec2 rand = get_noise2(offset).xy;

		offset = uv + (reflect(KERNEL[int(mod(j, 16))], rand) / (get_linearized_depth(uv)*g_cam_farz)) * SAMPLE_RAD;

		vec3 diff = get_view_pos(offset) - p;
		float d = length(diff);

		if (d < 3 && d > 0.01)
		{
			occlusion += max(0.0, dot(n, normalize(diff))) * ((INTENSITY) / (1.0 + d));
			weight += 1;
		}
	}

	return pow(max((1.0 - (occlusion / weight)), 0), 10);
}
]])

render.AddGlobalShaderCode([[
float g_ssao2(vec2 uv)
{
	float SampleRadius = 1.0;
	float ShadowScalar = 1.3;
	float DepthThreshold = 0.0025;
	float ShadowContrast = 0.5;
	uint NumSamples = 20u;


	float visibility = 0.0;
	vec3 P = get_view_pos(uv);
	vec3 N = get_view_normal(uv);
	float PerspectiveRadius = (SampleRadius / P.z);

	// Main sample loop, this is where we will preform our random
	// sampling and estimate the ambient occlusion for the current fragment.
	for (uint i = 0u; i < NumSamples; ++i)
	{
		// Generate Sample Position
		vec2 E = hammersley_2d(i, NumSamples) * vec2(PI, PI*2);
		E.y += random_angle(); // Apply random angle rotation
		vec2 sE= vec2(cos(E.y), sin(E.y)) * PerspectiveRadius * cos(E.x);
		vec2 Sample = gl_FragCoord.xy / g_gbuffer_size + sE;

		// Create Alchemy helper variables
		vec3 Pi         = get_view_pos(Sample);
		vec3 V          = Pi - P;
		float sqrLen    = dot(V, V);
		float Heaveside = step(sqrt(sqrLen), SampleRadius);
		float dD        = DepthThreshold * P.z;

		// For arithmetically removing edge-bleeding error
		// introduced by clamping the ambient occlusion map.
		float EdgeError = step(0.0, Sample.x) * step(0.0, 1.0 - Sample.x) *
						  step(0.0, Sample.y) * step(0.0, 1.0 - Sample.y);

		// Summation of Obscurance Factor
		visibility += (max(0.0, dot(N, V) + dD) * Heaveside * EdgeError) / (sqrLen + 0.0001);
	}

	// Final scalar multiplications for averaging and intensifying shadows
	visibility *= (2 * ShadowScalar) / NumSamples;
	visibility = max(0.0, 1.0 - pow(visibility, ShadowContrast));
	return visibility;
}
]])

function render3d.AddBilateralBlurPass(PASS, amount, discard_threshold, format, size_divider, depth_check)
	discard_threshold = discard_threshold or 0.85
	format = format or "r11f_g11f_b10f"
	size_divider = size_divider or 1

	if depth_check then
		depth_check = "&& abs(depth - get_linearized_depth(offset)) < " .. depth_check
	else
		depth_check = ""
	end

	for x = -1, 1 do
		for y = -1, 1 do
			if x == y or (y == 0 and x == 0) then goto continue end

			local weights = {
				Vec2(0.53812504, 0.18565957),
				Vec2(0.13790712, 0.24864247),
				Vec2(0.33715037, 0.56794053),
				Vec2(-0.6999805, -0.04511441),
				Vec2(0.06896307, -0.15983082),
				Vec2(0.056099437, 0.006954967),
				Vec2(-0.014653638, 0.14027752),
				Vec2(0.010019933, -0.1924225),
				Vec2(-0.35775623, -0.5301969),
				Vec2(-0.3169221, 0.106360726),
				Vec2(0.010350345, -0.58698344),
				Vec2(-0.08972908, -0.49408212),
				Vec2(0.7119986, -0.0154690035),
				Vec2(-0.053382345, 0.059675813),
				Vec2(0.035267662, -0.063188605),
				Vec2(-0.47761092, 0.2847911)
			}

			for i,v in ipairs(weights) do
				weights[i] = {
					dir = ("vec2(%s, %s)"):format(v.x, v.y),
					weight = math.lerp(math.sin((i / #weights) * math.pi), 0, 0.25),
				}
			end

			table.insert(PASS.Source, {
				buffer = {
					size_divider = size_divider,
					internal_format = format,
					filter = "nearest",
				},
				source = [[
					out vec3 out_color;

					vec3 blur(vec2 dir, float amount)
					{
						vec2 step = dir * amount;
						vec3 normal = get_view_normal(uv);
						float depth = get_linearized_depth(uv);
						float total_weight = 1;
						vec3 res = vec3(0);
						vec2 offset;
						vec2 jitter;

						]] ..(function()
							local str = ""
							for i, weight in ipairs(weights) do
								str = str .. "jitter = get_noise2(offset)*0.0025*amount;\n"
								str = str .. "offset = uv + " ..weight.dir.." * step + jitter;\n"
								str = str .. "if(dot(get_view_normal(offset), normal) > " .. discard_threshold .. depth_check .. ") {\n"
								str = str .."total_weight += 1;\n"
								str = str .. "res += texture(tex_stage_"..#PASS.Source..", offset).rgb;\n"
								str = str .. "}"
							end
							return str
						end)()..[[

						res /= total_weight;
						res *= 1.125;

						res = max(res, texture(tex_stage_]]..#PASS.Source..[[, uv).rgb/1.25);

						return res;
					}

					void main()
					{
						out_color = blur(vec2(]]..x..","..y..[[), ]]..amount..[[);
					}
				]]
			})
			::continue::
		end
	end
end

--https://www.shadertoy.com/view/MdyXRt
function render3d.AddDenoisePass(PASS)
	table.insert(PASS.Source, {
		buffer = {
			size_divider = 1,
			internal_format = "rgba8",
		},
		source = [[
			float vec3_float_flat( in vec3 t )
			{
				const vec3 coeffs = vec3( 1.0/3.0, 1.0/3.0, 1.0/3.0 );
				t *= coeffs;
				return t.r + t.g + t.b;
			}

			out vec4 out_color;

			void main()
			{
				const int kernel_size = 2;
				const float kernel_sq = float( kernel_size * kernel_size);

				out_color = vec4(0.0,0.0,1.0,1.0);

				vec3 means = vec3(0.0);
				vec3 deviations = vec3(0.0);
				vec2 res = textureSize(tex_stage_]]..(#PASS.Source)..[[, 0).xy;

				for( int i = 0; i < kernel_size; i++ )
				{
					for( int j = 0; j < kernel_size; j++ )
					{
						vec2 uv = uv * res;
						uv += vec2( i,j);
						uv += vec2( -1.0, -1.0 );
						uv /= res;
						vec3 sample = texture2D(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;
						means += sample / kernel_sq;

						deviations += sample*sample / kernel_sq;
					}
				}
				deviations -= ( means * means);



				float deviation = vec3_float_flat( deviations );
				out_color.a = deviation;

				out_color.rgb = means;
				//deviations *= 10.0;
				//out_color.rgb = deviations;

			}
		]]
	})

	table.insert(PASS.Source, {
		buffer = {
			size_divider = 1,
			internal_format = "rgba8",
		},
		source = [[
			#define denoise0(tex, pix, res)  texture2D( tex, (pix) / res )

			vec4 denoise1(sampler2D tex, vec2 pix, vec2 res)
			{
				vec4 accum = vec4(0);
				for( int i = -1; i <= 1; i++ )
					for( int j = -1; j <= 1; j++ )
					{
						vec2 uv = vec2( i,j), p = 2.-abs(uv);
						accum += texture2D( tex, (uv+pix) / res ) * p.x*p.y;
					}

				return accum/16.;
			}

			vec4 denoise2(sampler2D tex, vec2 pix, vec2 res)
			{
				const float size = 1.;

				vec2 offset = vec2(-1) * size;
				offset /= res;
				float cur_dev = 1e30;
				vec4 result = vec4(.5,.5,.5,1);

				for( int quad = 0; quad < 4; quad++)
				{
					vec4 sample = texture(tex_stage_]]..(#PASS.Source)..[[, (pix+offset));
					offset = vec2(-offset.y,offset);

					if( sample.a < cur_dev )
					{
						cur_dev = sample.a;
						result.rgb = sample.rgb;
					}
				}

				return result;
			}

			out vec4 out_color;

			void main()
			{
				out_color = denoise2(tex_stage_]]..(#PASS.Source)..[[, uv, textureSize(tex_stage_]]..(#PASS.Source)..[[, 0));
			}
		]]
	})
end

if RELOAD then
	RELOAD = nil
	render3d.InitializeGBuffer()
end