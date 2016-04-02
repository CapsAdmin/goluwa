local render = ... or _G.render

render.AddGlobalShaderCode([[
#define PI 3.141592
#define iSteps 16
#define jSteps 8

float rsi(vec3 r0, vec3 rd, float sr) {
    // Simplified ray-sphere intersection that assumes
    // the ray starts inside the sphere and that the
    // sphere is centered at the origin. Always intersects.
    float a = dot(rd, rd);
    float b = 2.0 * abs(dot(rd, r0));
    float c = dot(r0, r0) - (sr * sr);
    return (-b + sqrt((b*b) - 4.0*a*c))/(2.0*a);
}

vec3 atmosphere(vec3 r, vec3 r0, vec3 pSun, float iSun, float rPlanet, float rAtmos, vec3 kRlh, float kMie, float shRlh, float shMie, float g) {
    // Normalize the sun and view directions.
    pSun = normalize(pSun);
    r = normalize(r);

    // Calculate the step size of the primary ray.
    float iStepSize = rsi(r0, r, rAtmos) / float(iSteps);

    // Initialize the primary ray time.
    float iTime = 0.0;

    // Initialize accumulators for Rayleigh and Mie scattering.
    vec3 totalRlh = vec3(0,0,0);
    vec3 totalMie = vec3(0,0,0);

    // Initialize optical depth accumulators for the primary ray.
    float iOdRlh = 0.0;
    float iOdMie = 0.0;

    // Calculate the Rayleigh and Mie phases.
    float mu = dot(r, pSun);
    float mumu = mu * mu;
    float gg = g * g;
    float pRlh = 3.0 / (16.0 * PI) * (1.0 + mumu);
    float pMie = 3.0 / (8.0 * PI) * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

    // Sample the primary ray.
    for (int i = 0; i < iSteps; i++) {

        // Calculate the primary ray sample position.
        vec3 iPos = r0 + r * (iTime + iStepSize * 0.5);

        // Calculate the height of the sample.
        float iHeight = length(iPos) - rPlanet;

        // Calculate the optical depth of the Rayleigh and Mie scattering for this step.
        float odStepRlh = exp(-iHeight / shRlh) * iStepSize;
        float odStepMie = exp(-iHeight / shMie) * iStepSize;

        // Accumulate optical depth.
        iOdRlh += odStepRlh;
        iOdMie += odStepMie;

        // Calculate the step size of the secondary ray.
        float jStepSize = rsi(iPos, pSun, rAtmos) / float(jSteps);

        // Initialize the secondary ray time.
        float jTime = 0.0;

        // Initialize optical depth accumulators for the secondary ray.
        float jOdRlh = 0.0;
        float jOdMie = 0.0;

        // Sample the secondary ray.
        for (int j = 0; j < jSteps; j++) {

            // Calculate the secondary ray sample position.
            vec3 jPos = iPos + pSun * (jTime + jStepSize * 0.5);

            // Calculate the height of the sample.
            float jHeight = length(jPos) - rPlanet;

            // Accumulate the optical depth.
            jOdRlh += exp(-jHeight / shRlh) * jStepSize;
            jOdMie += exp(-jHeight / shMie) * jStepSize;

            // Increment the secondary ray time.
            jTime += jStepSize;
        }

        // Calculate attenuation.
        vec3 attn = exp(-(kMie * (iOdMie + jOdMie) + kRlh * (iOdRlh + jOdRlh)));

        // Accumulate scattering.
        totalRlh += odStepRlh * attn;
        totalMie += odStepMie * attn;

        // Increment the primary ray time.
        iTime += iStepSize;

    }

    // Calculate and return the final color.
    return iSun * (pRlh * kRlh * totalRlh + pMie * kMie * totalMie);
}

vec3 get_sky(vec3 ray, float depth)
{

	vec3 sun_direction = lua[(vec3)render.GetShaderSunDirection];
	float intensity = lua[world_sun_intensity = 1];
	vec3 sky_color = lua[world_sky_color = Vec3(0.18867780436772762, 0.4978442963618773, 0.6616065586417131)];

	//{return textureLatLon(lua[nightsky_tex = render.CreateTextureFromPath("textures/skybox/street.jpg")], reflect(ray, sun_direction)).rgb;};

	vec3 stars = textureLatLon(lua[nightsky_tex = render.CreateTextureFromPath("textures/skybox/milkyway.jpg")], reflect(ray, sun_direction)).rgb;
	stars += pow(stars*1.25, vec3(1.5));
	stars *= depth * 0.05;

	return depth*max(atmosphere(
		normalize(ray),         		// normalized ray direction
        g_cam_pos.xzy + vec3(0,6372e3,0),               // ray origin
        vec3(sun_direction.x, sun_direction.y, sun_direction.z),					// position of the sun
        22.0*intensity,                           // intensity of the sun
        6371e3,                         // radius of the planet in meters
        6471e3,                         // radius of the atmosphere in meters
        vec3(5.5e-6, 13.0e-6, 22.4e-6), // Rayleigh scattering coefficient
        21e-6,                          // Mie scattering coefficient
        8e3,                            // Rayleigh scale height
        1.2e3,                          // Mie scale height
        0.758                           // Mie preferred scattering direction
	), vec3(0))+stars;
}]], "get_sky")

local directions = {
	QuatDeg3(0,-90,-90), -- back
	QuatDeg3(0,90,90), -- front

	QuatDeg3(0,0,0), -- up
	QuatDeg3(180,0,0), -- down

	QuatDeg3(90,0,0), -- left
	QuatDeg3(-90,180,0), -- right
}

local fb
local tex
local shader

local function init()
	tex = render.CreateTexture("cube_map")
	tex:SetInternalFormat("rgb16f")

	--tex:SetMipMapLevels(16)
	tex:SetSize(Vec2() + 1024)
	tex:SetupStorage()

	shader = render.CreateShader({
		name = "sky",
		fragment = {
			mesh_layout = {
				{pos = "vec3"},
				{uv = "vec2"},
			},
			source = [[
				out vec3 out_color;

				void main()
				{
					out_color = get_sky(get_camera_dir(uv), 1);
				}
			]]
		}
	})

	fb = render.CreateFrameBuffer()
	fb:SetTexture(1, tex, "write", nil, 1)
	fb:CheckCompletness()
	fb:WriteThese(1)
end

function render.UpdateSky()
	if not fb then return end
	if not tex then init() end

	render.SetDepth(false)
	render.SetBlendMode()

	for k,v in pairs(render.gbuffer_values) do
		shader[k] = v
	end

	render.SetShaderOverride(shader)
	local old_view = render.camera_3d:GetView()
	local old_projection = render.camera_3d:GetProjection()

	local projection = Matrix44()
	projection:Perspective(math.rad(90), render.camera_3d.FarZ, render.camera_3d.NearZ, tex:GetSize().x / tex:GetSize().y)

	fb:Begin()
		for i, rot in ipairs(directions) do
			fb:SetTexture(1, tex, nil, nil, i)
			--fb:Clear()

			local view = Matrix44()
			view:SetRotation(rot)
			render.camera_3d:SetView(view)
			render.camera_3d:SetProjection(projection)

			surface.DrawRect(0,0,surface.GetSize())
		end
	fb:End()

	render.camera_3d:SetView(old_view)
	render.camera_3d:SetProjection(old_projection)

	tex:GenerateMipMap()


	render.SetShaderOverride()
end

function render.GetSkyTexture()
	if not tex then init() end
	return tex
end

function render.GetShaderSunDirection()
	local sun = entities.world and entities.world.sun

	if sun and sun:IsValid() then
		local dir = sun:GetTRPosition():GetNormalized()

		return Vec3(dir.y, dir.z, -dir.x)
	end

	return Vec3()
end

if RELOAD then
	init()
	event.Delay(0.1, function()
	render.InitializeGBuffer()
	end)
end