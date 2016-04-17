local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = false
PASS.Position = 3

PASS.Source = {}

local FAST_BLUR = false

table.insert(PASS.Source, {
	buffer = {
		--max_size = Vec2() + 512,
		size_divider = 1,
		internal_format = "rgb16f",
	},
	source = [[
	out vec3 out_color;

	#define USE_MIPMAP

	// The Golden Angle is (3.-sqrt(5.0))*PI radians, which doesn't precompiled for some reason.
	// The compiler is a dunce I tells-ya!!
	#define GOLDEN_ANGLE 2.39996323

	#define ITERATIONS 140

	mat2 rot = mat2(cos(GOLDEN_ANGLE), sin(GOLDEN_ANGLE), -sin(GOLDEN_ANGLE), cos(GOLDEN_ANGLE));

	//-------------------------------------------------------------------------------------------
	vec3 Bokeh(sampler2D tex, vec2 uv, float radius, float amount)
	{
		vec3 acc = vec3(0.0);
		vec3 div = vec3(0.0);
		vec2 pixel = 1.0 / g_gbuffer_size.xy;
		float r = 1.0;
		vec2 vangle = vec2(0.0,radius); // Start angle
		amount += radius*1000.0;

		for (int j = 0; j < ITERATIONS; j++)
		{
			r += 1. / r;
			vangle = rot * vangle;
			// (r-1.0) here is the equivalent to sqrt(0, 1, 2, 3...)
			vec3 col = texture2D(tex, uv + pixel * (r-1.) * vangle).xyz;
			col = col * col * 1.5; // ...contrast it for better highlights - leave this out elsewhere.
			vec3 bokeh = pow(col, vec3(9.0)) * amount+.4;
			acc += col * bokeh;
			div += bokeh;
		}
		return acc / div;
	}


	void main()
	{
		float z = pow((-texture(tex_depth, uv).r+1)*15, 1.25);

		out_color = Bokeh(tex_mixer, uv, z, 1);
	}
]]
})

table.insert(PASS.Source, {
	source = [[
		out vec3 out_color;

		void main()
		{
			vec3 color = texture(tex_stage_]]..(#PASS.Source)..[[, uv).rgb;
			out_color = pow(color, vec3(0.5));
		}
	]]
})

render.AddGBufferShader(PASS)