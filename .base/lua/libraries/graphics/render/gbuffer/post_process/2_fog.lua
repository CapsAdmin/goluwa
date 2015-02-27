local PASS = {}

PASS.Name = "fog"
PASS.Position = FILE_NAME:sub(1, 1)

PASS.Variables = {
	fog_color = Color(0.18867780436772762, 0.4978442963618773, 0.6616065586417131, 1),
	fog_intensity = 256,
	fog_start = 0,
	fog_end = 0,
	inv_proj = {mat4 = function() return render.matrices.projection_3d_inverse.m end},
	inv_view_rot = {mat4 = function() return render.matrices.view_3d_inverse.m end},
	lightdir = {vec3 = function() 
		if SUN and SUN:IsValid() then
			local dir = SUN:GetTRPosition():GetNormalized()
			
			return Vec3(-dir.y, dir.z, -dir.x)
		end
		
		return Vec3()
	end},
	
	Kr = Vec3(0.18867780436772762, 0.4978442963618773, 0.6616065586417131),
	rayleigh_brightness = 3.3*1500,
	mie_brightness = 0.1,
	spot_brightness = 800,
	scatter_strength = 0.028,
	rayleigh_strength = 0.139,
	mie_strength = 0.264,
	rayleigh_collection_power = 0.81,
	mie_collection_power = 0.39,
	mie_distribution = 0.63,
}

PASS.Source = [[	    
    float surface_height = 0.99;
    float range = 0.01;
    float intensity = 1.8;
    const int step_count = 16;
    
    vec4 get_world_normal()
	{
        vec2 frag_coord = uv;
        frag_coord = (frag_coord-0.5)*2.0;
        vec4 device_normal = vec4(frag_coord, 0.0, 1.0);
        vec3 eye_normal = normalize((inv_proj * device_normal).xyz);
        vec3 world_normal = normalize(mat3(inv_view_rot)*eye_normal).xyz;
        return vec4(world_normal.x, -world_normal.z, world_normal.y, eye_normal.z);
    }
    
    float atmospheric_depth(vec3 position, vec3 dir){
        float a = dot(dir, dir);
        float b = 2.0*dot(dir, position);
        float c = dot(position, position)-1.0;
        float det = b*b-4.0*a*c;
        float detSqrt = sqrt(det);
        float q = (-b - detSqrt)/2.0;
        float t1 = c/q;
        return t1;
    }

    float phase(float alpha, float g){
        float a = 3.0*(1.0-g*g);
        float b = 2.0*(2.0+g*g);
        float c = 1.0+alpha*alpha;
        float d = pow(1.0+g*g-2.0*g*alpha, 1.5);
        return (a/b)*(c/d);
    }

    float horizon_extinction(vec3 position, vec3 dir, float radius){
        float u = dot(dir, -position);
        if(u<0.0){
            return 1.0;
        }
        vec3 near = position + u*dir;
        if(length(near) < radius){
            return 0.0;
        }
        else{
            vec3 v2 = normalize(near)*radius - position;
            float diff = acos(dot(normalize(v2), dir));
            return smoothstep(0.0, 1.0, pow(diff*2.0, 3.0));
        }
    }

    vec3 absorb(float dist, vec3 color, float factor){
        return color-color*pow(Kr, vec3(factor/dist));
    }
	
	float get_depth2(vec2 coord, float start, float end) 
	{
		return (2.0 * start) / (end + start - texture(tex_depth, coord).r * (end - start));
	} 
	
	vec3 mix_fog(vec3 color, vec4 fog_color)
	{
		if (fog_color.a == 0) return color;
	
		// THIS ISNT RIGHT
		if (fog_start > fog_end)
			color = mix(fog_color.rgb, color, clamp(get_depth2(uv, cam_nearz, fog_start) * fog_color.a, 0.0, 1.0));
		
		if (fog_start < fog_end)
			color = mix(fog_color.rgb, color, clamp((-pow(get_depth2(uv, cam_nearz, fog_end),8)*90+1) * fog_color.a, 0.0, 1.0));
		
		return color;
	}

	out vec4 out_color;
	
    void main(void)
	{
		vec4 data = get_world_normal();
		vec3 eyedir = data.rgb;
		float alpha = dot(eyedir, lightdir);
		
		float rayleigh_factor = phase(alpha, -0.01)*rayleigh_brightness;
		float mie_factor = phase(alpha, mie_distribution)*mie_brightness;
		float spot = smoothstep(0.0, 15.0, phase(alpha, 0.9995))*spot_brightness;

		vec3 eye_position = vec3(0.0, surface_height, 0.0);
		float eye_depth = atmospheric_depth(eye_position, eyedir);
		float step_length = eye_depth/float(step_count);
		float eye_extinction = horizon_extinction(eye_position, eyedir, surface_height-0.15);
		
		vec3 rayleigh_collected = vec3(0.0, 0.0, 0.0);
		vec3 mie_collected = vec3(0.0, 0.0, 0.0);

		for(int i=0; i<step_count; i++){
			float sample_distance = step_length*float(i);
			vec3 position = eye_position + eyedir*sample_distance;
			float extinction = horizon_extinction(position, lightdir, surface_height-0.35);
			float sample_depth = atmospheric_depth(position, lightdir);
			vec3 influx = absorb(sample_depth, vec3(intensity), scatter_strength)*extinction;
			rayleigh_collected += absorb(sample_distance, Kr*influx, rayleigh_strength);
			mie_collected += absorb(sample_distance, influx, mie_strength);
		}

		rayleigh_collected = (rayleigh_collected*eye_extinction*pow(eye_depth, rayleigh_collection_power))/float(step_count);
		mie_collected = (mie_collected*eye_extinction*pow(eye_depth, mie_collection_power))/float(step_count);
		
		if (texture(tex_depth, uv).r != 1)
		{
			out_color.rgb =  mix_fog(texture(self, uv).rgb, vec4(Kr, 1));
			out_color.a = fog_color.a;
		}
		else
		{
			vec3 color = vec3(spot*mie_collected + mie_factor*mie_collected + rayleigh_factor*rayleigh_collected)*abs(data.w);

			out_color = vec4(normalize(color)+vec3(0.3), sqrt(length(color))/16.0);
		}
    }
]]

render.AddGBufferShader(PASS)