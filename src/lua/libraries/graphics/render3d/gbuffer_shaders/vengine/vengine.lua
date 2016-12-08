editor.Open()
editor.Close()

local atmosphere_fbc = render3d.CreateFramebufferCubemap("r11f_g11f_b10f", Vec2() + 128)
local atmosphere_shader = render.CreateShader({
	name = "vengine_clouds_atmosphere",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		include_directories = {
			"shaders/include/",
		},
		source = [[
			#version 430 core
			uniform float MieScattCoeff;
			#include Constants.glsl
			#include PlanetDefinition.glsl
			#include ProceduralValueNoise.glsl
			#include AtmScattering.glsl

			out vec3 out_color;

			void main()
			{
				vec3 pos = g_cam_pos.yzx;
				vec3 dir = -get_camera_dir(uv).xzy;

				dir.y = abs(dir.y);

				out_color = getAtmosphereForDirectionReal(pos, dir, dayData.sunDir * vec3(-1,1,-1));
			}
		]],
	},
})

local cloud_coverage_fbc = render3d.CreateFramebufferCubemap("rg32f", Vec2() + 512)
local cloud_coverage_tex_odd = cloud_coverage_fbc.Texture
local cloud_coverage_tex_even = render3d.CreateFramebufferCubemap("rg32f", Vec2() + 512).Texture
local cloud_coverage_shader = render.CreateShader({
	name = "vengine_clouds_coverage",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		variables = {
			cloud_coverage_tex = cloud_coverage_fbc:GetTexture(),
		},
		include_directories = {
			"shaders/include/",
		},
		source = [[
			#version 430 core

			#define CLOUD_SAMPLES 2
			#define CLOUDCOVERAGE_DENSITY 90
			#define UV uv
			#define CAMERA g_cam_pos.yzx
			#include Atmosphere.glsl

			out vec2 out_color;

			void main()
			{
				vec3 dir = -get_camera_dir(uv).xzy;

				vec2 lastData = texture(cloud_coverage_tex, -dir*vec3(1,-1,1)).rg;
				vec2 val = raymarchCloudsRay(dir);
				vec2 retedg = vec2(max(val.r, lastData.r), min(val.g, lastData.g));
				vec2 retavg = vec2(mix(val.r, lastData.r, CloudsIntegrate), val.g);

				retavg.r = mix(retavg.r, retedg.r, 0.0);
				retavg.g = mix(retavg.g, retedg.g, 0.5);

				out_color = retavg;
			}
		]],
	},
})

local cloud_ao_fbc = render3d.CreateFramebufferCubemap("r11f_g11f_b10f", Vec2() + 512)
local cloud_ao_tex_odd = cloud_ao_fbc.Texture
local cloud_ao_tex_even = render3d.CreateFramebufferCubemap("r11f_g11f_b10f", Vec2() + 512).Texture
local cloud_ao_shader = render.CreateShader({
	name = "vengine_clouds_ao",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		variables = {
			cloud_coverage_tex = cloud_coverage_fbc:GetTexture(),
			cloud_ao_tex = cloud_ao_fbc:GetTexture(),
		},
		include_directories = {
			"shaders/include/",
		},
		source = [[
			#version 430 core

			#define CLOUD_SAMPLES 2
			#define CLOUDCOVERAGE_DENSITY 90
			#define UV uv
			#define CAMERA g_cam_pos.yzx
			#include Atmosphere.glsl

			out vec3 out_color;

			void main()
			{
				vec3 dir = -get_camera_dir(uv).xzy;

				vec3 retedg = vec3(0);
				vec3 retavg = vec3(0);

				vec3 lastData = texture(cloud_ao_tex, dir).rgb;

				float val = shadows(cloud_coverage_tex, dir);
				retedg.r = min(val, lastData.r);
				retavg.r = mix(val, lastData.r, CloudsIntegrate);
				float AOGround = getCloudsAO(cloud_coverage_tex, dir, 0.0);
				float AOSky = getCloudsAO(cloud_coverage_tex, dir, 1.0);
				retedg.g = min(AOGround, lastData.g);
				retavg.g = mix(AOGround, lastData.g, CloudsIntegrate);
				retedg.b = min(AOSky, lastData.b);
				retavg.b = mix(AOSky, lastData.b, CloudsIntegrate);

				retavg.r = mix(retavg.r, retedg.r, 0.4);
				retavg.g = mix(retavg.g, retedg.g, 0.4);
				retavg.b = mix(retavg.b, retedg.b, 0.4);

				out_color = retavg;
			}
		]],
	},
})

local sky_resolve_fbc = render3d.CreateFramebufferCubemap("r11f_g11f_b10f", Vec2() + 1024)
local sky_resolve_shader = render.CreateShader({
	name = "vengine_clouds_resolve",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		variables = {
			atmosphere_tex = atmosphere_fbc:GetTexture(),
			cloud_coverage_tex = cloud_coverage_fbc:GetTexture(),
			cloud_ao_tex = cloud_ao_fbc:GetTexture(),
		},
		include_directories = {
			"shaders/include/",
		},
		source = [[
			#version 430 core

			#define CAMERA g_cam_pos.yzx
			#define UV uv

			#define atmScattTex atmosphere_tex
			#define cloudsCloudsTex cloud_coverage_tex
			#define coverageDistTex cloud_coverage_tex
			#define shadowsTex cloud_ao_tex
			#define VPMatrix g_projection_view
			#define CameraPosition g_cam_pos.yzx
			#define Resolution g_gbuffer_size

			#include Atmosphere.glsl
			#include ResolveAtmosphere.glsl

			vec3 integrateStepsAndSun(vec3 dir){
				return sampleAtmosphere(dir, 0, 1.0, 23, lua[moon_tex = render.CreateTextureFromPath("textures/moon.png")], lua[stars_tex = render.CreateTextureFromPath("textures/stars.png")]);
			}

			out vec4 out_color;
			void main()
			{
				vec3 dir = -get_camera_dir(uv).xzy;
				out_color.rgb = integrateStepsAndSun(dir);
				//out_color.rgb = vec3(texture(cloud_coverage_tex, dir).r);
				//out_color.rgb = vec3(texture(cloud_ao_tex, dir).g);
				//out_color.rgb = dir;
			}
		]],
	},
})

local cubemap_view = render.CreateShader({
	name = "test_view",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		variables = {
			cubemap = sky_resolve_fbc:GetTexture(),
		},
		source = [[
			out vec4 out_color;
			void main()
			{
				out_color = texture(cubemap, -get_camera_dir(uv).xzy);
				out_color.rgb = gbuffer_compute_tonemap(out_color.rgb*0.15, vec3(0));
			}
		]],
	},
})


local water_shader = render.CreateShader({
	name = "vengine_water",
	fragment = {
		mesh_layout = {
			{uv = "vec2"},
		},
		variables = {
			cubemap = sky_resolve_fbc:GetTexture(),
		},
		include_directories = {
			"shaders/include/",
		},
		source = [[
			#version 430 core
			uniform float MieScattCoeff;
			#include Constants.glsl
			#include PlanetDefinition.glsl
			#include ProceduralValueNoise.glsl
			#include AtmScattering.glsl

			float hlower = -1;

			// this paste somewhere to be accessible
			float intersectPlane(vec3 origin, vec3 direction, vec3 point, vec3 normal){
				return dot(point - origin, normal) / dot(direction, normal);
			}

			float intersectWater(vec3 camera, vec3 dir, float level){
				return intersectPlane(camera, dir, vec3(0.0, level, 0.0), vec3(0.0, 1.0, 0.0));
			}

			float waterHeight(vec2 pos){
				return noise3d(vec3(-pos.x, -pos.y, Time)) * 0.66 +
					noise3d(vec3(-pos.x * 5.0, -pos.y * 4.0, -Time)) * 0.33 +
					noise3d(vec3(-pos.x * 9.0, pos.y * 8.0, Time)) * 0.16;
			}

			vec3 normalx(vec3 pos, float e, float roughness){
				vec2 ex = vec2(e, 0);
				vec3 a = vec3(pos.x, waterHeight(pos.xz), pos.z);
				vec3 b = vec3(pos.x - e, waterHeight(pos.xz - ex.xy), pos.z);
				vec3 c = vec3(pos.x, waterHeight(pos.xz + ex.yx), pos.z + e);
				vec3 normal = (cross(normalize(a-b), normalize(a-c)));
				return normalize(normal);
			}

			float raymarchwater3(vec3 start, vec3 end, int stepsI){
				float stepsize = 1.0 / stepsI;
				float iter = 0;
				vec3 pos = start;
				float h = 0.0;
				for(int i=0;i<stepsI + 1;i++){
					pos = mix(start, end, iter);
					h = hlower + waterHeight(pos.xz);
					if(h > pos.y) {
						return distance(pos, g_cam_pos.yzx);
					}
					iter += stepsize;
				}
				return -1.0;
			}
			float raymarchwater2(vec3 start, vec3 end, int stepsI){
				float stepsize = 1.0 / stepsI;
				float iter = 0;
				vec3 pos = start;
				float h = 0.0;
				for(int i=0;i<stepsI + 1;i++){
					pos = mix(start, end, iter);
					h = hlower + waterHeight(pos.xz);
					if(h > pos.y) {
						return raymarchwater3(mix(start, end, iter - stepsize), mix(start, end, iter + stepsize), 6);
					}
					iter += stepsize;
				}
				return -1.0;
			}
			float raymarchwater(vec3 start, vec3 end, int stepsI){
				float stepsize = 1.0 / stepsI;
				float iter = 0;
				vec3 pos = start;
				float h = 0.0;
				for(int i=0;i<stepsI + 1;i++){
					pos = mix(start, end, iter);
					h = hlower + waterHeight(pos.xz);
					if(h > pos.y) {
						return raymarchwater3(mix(start, end, iter - stepsize), mix(start, end, iter + stepsize), 16);
					}
					iter += stepsize;
				}
				return -1.0;
			}
			out vec3 out_color;

			void main()
			{
				vec3 pos = g_cam_pos.yzx;
				vec3 dir = -get_camera_dir(uv).xzy;

				float hitdist1 = intersectWater(pos, dir, 0.0);
				float hitdist2 = intersectWater(pos, dir, -1.0);

				if(hitdist1 > 0.0){
					vec3 hitpos1 = pos + hitdist1 * dir;
					vec3 hitpos2 = pos + hitdist2 * dir;
					float hit = raymarchwater(hitpos1, hitpos2, 16);
					vec3 hitpos = pos + hit * dir;
					vec3 n = normalx(hitpos, 0.1, 1);
					dir = reflect(dir, n);

					out_color = texture(cubemap, dir).rgb;
				}
				else
				{
					discard;
				}
			}
		]],
	},
})

local variables = {
	DayElapsed = 0.2,
	YearElapsed = 0.1,
	EquatorPoleMix = 0.5,

	NoiseOctave1 = 0,

	MieScattCoeff = 0.5,

	WindBigPower = 1,
	WindBigScale = 1,
	CloudsFloor = 3000,
	CloudsCeil = 10000,
	CloudsThresholdLow = 0.6,
	CloudsThresholdHigh = 0.30,
	CloudsDensityThresholdLow = 0.0,
	CloudsDensityThresholdHigh = 1.0,
	CloudsDensityScale = 0.6,
	CloudsWindSpeed = 0.4,
	CloudsIntegrate = 0.95,
	FBMSCALE = 1,
}

local function set_variables(shader)
	for k,v in pairs(variables) do
		if shader.variables[k] then
			shader[k] = v
		end
	end
end

event.AddListener("PreDrawGUI", "vengine", function()

	if true or wait(1/15) then
		variables.Time = system.GetElapsedTime()*1
		--variables.DayElapsed = (math.abs(math.sin(variables.Time/100)) * 0.5) + 0.25
		variables.DayElapsed = 0.5

		do -- update atmosphere
			set_variables(atmosphere_shader)
			atmosphere_fbc:Update(atmosphere_shader)
		end

		do -- update cloud coverage
			set_variables(cloud_coverage_shader)
			if cloud_coverage_fbc.use_odd then
				cloud_coverage_shader.cloud_coverage_tex = cloud_coverage_tex_odd
				cloud_coverage_fbc.Texture = cloud_coverage_tex_even
				cloud_coverage_fbc.use_odd = false
			else
				cloud_coverage_shader.cloud_coverage_tex = cloud_coverage_tex_even
				cloud_coverage_fbc.Texture = cloud_coverage_tex_odd
				cloud_coverage_fbc.use_odd = true
			end
			cloud_coverage_fbc:Update(cloud_coverage_shader)
		end

		do -- update cloud ao
			set_variables(cloud_ao_shader)

			if cloud_ao_fbc.use_odd then
				cloud_ao_shader.cloud_ao_tex = cloud_ao_tex_odd
				cloud_ao_fbc.Texture = cloud_ao_tex_even
				cloud_ao_fbc.use_odd = false
			else
				cloud_ao_shader.cloud_ao_tex = cloud_ao_tex_even
				cloud_ao_fbc.Texture = cloud_ao_tex_odd
				cloud_ao_fbc.use_odd = true
			end

			cloud_ao_fbc:Update(cloud_ao_shader)
		end

		do -- combine results to cubemap
			set_variables(sky_resolve_shader)
			sky_resolve_fbc:Update(sky_resolve_shader)
		end
	end

	do -- view cubemap
		render2d.PushMatrix(0, 0, render2d.GetSize())
			cubemap_view:Bind()
			render2d.rectangle:Draw()

			-- draw water
			--set_variables(water_shader)
			--water_shader:Bind()
			render2d.rectangle:Draw()
		render2d.PopMatrix()
	end
end)