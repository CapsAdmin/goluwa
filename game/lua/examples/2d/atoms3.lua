local fb = render.CreateFrameBuffer(window.GetSize(), {
	internal_format = "rgba32f",
	filter = "linear",
})
fb:GetTexture():SetWrapS("repeat")
fb:GetTexture():SetWrapT("repeat")
local shader = render.CreateShader({
	name = "test",
	fragment = {
		variables = {
			texture_size = {vec2 = function() return fb:GetTexture():GetSize() end},
			self = {texture = function() return fb:GetTexture() end},
			i = 0,
			generate_random = 1,
		},
		mesh_layout = {
			{uv = "vec2"},
		},
		source = [[
			out vec4 out_val;

			vec2 Circle(float Start, float Points, float Point)
			{
				float Rad = (3.141592 * 2.0 * (1.0 / Points)) * (Point + Start);
				return vec2(sin(Rad), cos(Rad));
			}

			float GetAverage(vec2 uv, float unit)
			{
				vec2 PixelOffset = unit / texture_size;

				float Start = 2.0 / 14.0;
				vec2 Scale = 0.66 * 4.0 * 2.0 * PixelOffset.xy;

				vec3 N0 = texture(self, uv + Circle(Start, 14.0, 0.0) * Scale).rgb;
				vec3 N1 = texture(self, uv + Circle(Start, 14.0, 1.0) * Scale).rgb;
				vec3 N2 = texture(self, uv + Circle(Start, 14.0, 2.0) * Scale).rgb;
				vec3 N3 = texture(self, uv + Circle(Start, 14.0, 3.0) * Scale).rgb;
				vec3 N4 = texture(self, uv + Circle(Start, 14.0, 4.0) * Scale).rgb;
				vec3 N5 = texture(self, uv + Circle(Start, 14.0, 5.0) * Scale).rgb;
				vec3 N6 = texture(self, uv + Circle(Start, 14.0, 6.0) * Scale).rgb;
				vec3 N7 = texture(self, uv + Circle(Start, 14.0, 7.0) * Scale).rgb;
				vec3 N8 = texture(self, uv + Circle(Start, 14.0, 8.0) * Scale).rgb;
				vec3 N9 = texture(self, uv + Circle(Start, 14.0, 9.0) * Scale).rgb;
				vec3 N10 = texture(self, uv + Circle(Start, 14.0, 10.0) * Scale).rgb;
				vec3 N11 = texture(self, uv + Circle(Start, 14.0, 11.0) * Scale).rgb;
				vec3 N12 = texture(self, uv + Circle(Start, 14.0, 12.0) * Scale).rgb;
				vec3 N13 = texture(self, uv + Circle(Start, 14.0, 13.0) * Scale).rgb;
				vec3 N14 = texture(self, uv).rgb;

				float W = 1.0 / 15.0;

				vec3 color = vec3(0,0,0);

				color.rgb =
					(N0 * W) +
					(N1 * W) +
					(N2 * W) +
					(N3 * W) +
					(N4 * W) +
					(N5 * W) +
					(N6 * W) +
					(N7 * W) +
					(N8 * W) +
					(N9 * W) +
					(N10 * W) +
					(N11 * W) +
					(N12 * W) +
					(N13 * W) +
					(N14 * W);

				return color.r;
			}

			float GetAverage2(vec2 uv, float unit)
			{
				float neighbours = 0;

				vec2 uv_unit = unit / texture_size;

				for (float y = -1; y <= 1; y++)
				{
					for (float x = -1; x <= 1; x++)
					{
						neighbours += texture(self, uv + (uv_unit * vec2(x, y))).x;
					}
				}

				return neighbours / 9;
			}

			float normpdf(in float x, in float sigma)
			{
				return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
			}


			float GetAverage3(vec2 uv, float unit)
			{
				//declare stuff
				const int mSize = 11;
				const int kSize = (mSize-1)/2;
				float kernel[mSize];
				vec3 final_colour = vec3(0.0);

				//create the 1-D kernel
				float sigma = 7.0;
				float Z = 0.0;
				for (int j = 0; j <= kSize; ++j)
				{
					kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
				}

				//get the normalization factor (as the gaussian has been clamped)
				for (int j = 0; j < mSize; ++j)
				{
					Z += kernel[j];
				}

				//read out the texels
				for (int i=-kSize; i <= kSize; ++i)
				{
					for (int j=-kSize; j <= kSize; ++j)
					{
						final_colour += kernel[kSize+j]*kernel[kSize+i]*texture(self, ((uv*texture_size)+vec2(float(i),float(j))) / texture_size).rgb;

					}
				}

				return final_colour/(Z*Z).x;
			}

			float GetAverage4(vec2 uv, float unit)
			{
				float neighbours = 0;

				vec2 uv_unit = unit / texture_size;

				for (float i = 0; i <= 16; i++)
				{
					neighbours += texture(self, uv + (uv_unit * get_noise(uv*i/16).xy*2-1)).x;
				}

				return neighbours / 16;
			}

			vec2 hash( vec2 x )  // replace this by something better
			{
				const vec2 k = vec2( 0.3183099, 0.3678794 );
				x = x*k + k.yx;
				return -1.0 + 2.0*fract( 16.0 * k*fract( x.x*x.y*(x.x+x.y)) );
			}

			float smoothnoise( in vec2 p )
			{
				vec2 i = floor( p );
				vec2 f = fract( p );

				vec2 u = f*f*(3.0-2.0*f);

				return mix( mix( dot( hash( i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
								 dot( hash( i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
							mix( dot( hash( i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
								 dot( hash( i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
			}


			void main()
			{
				if (generate_random == 1)
				{
					out_val = get_noise(uv);
					return;
				}

				float prev = texture(self, uv).x;

				vec2 uv = uv;
				//uv = -uv+1;
				//uv.x = -uv.x+1;
				//uv.y = -uv.y+1;

				//uv.x += smoothnoise(uv)/160;
				//uv.y += smoothnoise(-uv)/160;

				//uv.x += random(uv)*0.0015;
				//uv.y += random(uv)*0.0015;
				//uv.y += 0.1;


				/*float val = texture(self, uv).x;
				float avg = GetAverage(uv, (1 + cos(val*1.1)));
				float s = sin(pow(avg, 1.57) * PI) / val * 1.5;
				out_val.x = clamp(s, 0, 1);*/

				vec4 c = texture(self, uv);
				float avg = GetAverage(uv, 1);
				out_val.r = sin(avg * 4) + sin(c.r);
				out_val.g = out_val.r*0.5+0.5 * 1.5;
				out_val.b = c.r/10;
				out_val.a = 1;

			}
		]]
	}
})

local brush = render.CreateBlankTexture(Vec2() + 128):Fill(function(x, y)
	x = x / 128
	y = y / 128

	x = x - 1
	y = y - 1.5

	x = x * math.pi
	y = y * math.pi

	local a = math.sin(x) * math.cos(y)

	a = a ^ 32

	return a * 128
end)

local brush_size = 4

function goluwa.PreDrawGUI()

	if true or wait(1/5) then
		fb:Begin()

			if input.IsMouseDown("button_1") or input.IsMouseDown("button_2") then
				if input.IsMouseDown("button_1") then
					render.SetPresetBlendMode("additive")
					render2d.SetColor(1,1,1,1)
				else
					render.SetBlendMode("src_color","one_minus_src_color","sub")
					render2d.SetColor(1,1,1,1)
				end
				render2d.SetTexture(brush)
				local x,y = gfx.GetMousePosition()
				render2d.DrawRect(x, y, brush:GetSize().x*brush_size, brush:GetSize().y*brush_size, 0, brush:GetSize().x/2*brush_size, brush:GetSize().y/2*brush_size)
			end



			render.SetBlendMode("src_color", "one_minus_dst_color", "add", "src_color")
			render.SetPresetBlendMode("none")

			render2d.PushMatrix(0, 0, fb:GetTexture():GetSize():Unpack())
				shader.i = ((shader.i or 0) + 1)%2
				shader:Bind()
				render2d.rectangle:Draw(render2d.rectangle_indices)
			render2d.PopMatrix()

		fb:End()
		shader.generate_random = 0
	end

	render.GetScreenFrameBuffer():ClearAll()

	render.SetPresetBlendMode("alpha")

	render2d.SetColor(1,1,1, 1)
	render2d.SetTexture(fb:GetTexture())
	local w,h = render2d.GetSize()
	render2d.SetRectUV(0,0,w,h,w,h)
	render2d.DrawRect(0, 0, w,h)
end