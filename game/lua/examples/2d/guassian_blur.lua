local w = 512
local h = 512

local shader = render.CreateShader({
	name = "guassian_blur",
	fragment = {
		variables = {
			image = render.GetWhiteTexture(),
			resolution = Vec2(w, h),
			direction = Vec2(0, 0),
			stage = 0,
		},
		mesh_layout = {
			{uv = "vec2"},
		},
		source = [[
			out vec4 out_color;

			vec4 blur5() {
				vec4 color = vec4(0.0);
				vec2 off1 = vec2(1.3333333333333333) * direction;
				color += texture2D(image, uv) * 0.29411764705882354;
				color += texture2D(image, uv + (off1 / resolution)) * 0.35294117647058826;
				color += texture2D(image, uv - (off1 / resolution)) * 0.35294117647058826;
				return color;
			}

			vec4 blur9() {
				vec4 color = vec4(0.0);
				vec2 off1 = vec2(1.3846153846) * direction;
				vec2 off2 = vec2(3.2307692308) * direction;
				color += texture2D(image, uv) * 0.2270270270;
				color += texture2D(image, uv + (off1 / resolution)) * 0.3162162162;
				color += texture2D(image, uv - (off1 / resolution)) * 0.3162162162;
				color += texture2D(image, uv + (off2 / resolution)) * 0.0702702703;
				color += texture2D(image, uv - (off2 / resolution)) * 0.0702702703;
				return color;
			}

			vec4 blur13() {
				vec4 color = vec4(0.0);
				vec2 off1 = vec2(1.411764705882353) * direction;
				vec2 off2 = vec2(3.2941176470588234) * direction;
				vec2 off3 = vec2(5.176470588235294) * direction;
				color += texture2D(image, uv) * 0.1964825501511404;
				color += texture2D(image, uv + (off1 / resolution)) * 0.2969069646728344;
				color += texture2D(image, uv - (off1 / resolution)) * 0.2969069646728344;
				color += texture2D(image, uv + (off2 / resolution)) * 0.09447039785044732;
				color += texture2D(image, uv - (off2 / resolution)) * 0.09447039785044732;
				color += texture2D(image, uv + (off3 / resolution)) * 0.010381362401148057;
				color += texture2D(image, uv - (off3 / resolution)) * 0.010381362401148057;
				return color;
			}

			void main()
			{
				if (stage == 0)
					out_color = blur5();

				if (stage == 1)
					out_color = blur9();

				if (stage == 3)
					out_color = blur13();

				out_color.rgb = vec3(1,0,0);
				out_color.a = 1;
			}
		]],
	}
})

local tex = render.CreateTextureFromPath("https://raw.githubusercontent.com/mikolalysenko/baboon-image/master/baboon.png")
tex:SetMinFilter("linear")
tex:SetMagFilter("linear")
tex:SetWrapS("repeat")

local fboA = render.CreateFrameBuffer(Vec2(512, 512))
fboA:GetTexture(1):SetMipMapLevels(1)
fboA:GetTexture(1):SetMinFilter("linear")
fboA:GetTexture(1):SetMagFilter("linear")
fboA:GetTexture(1):SetWrapS("repeat")
fboA:WriteThese("1")

local fboB = render.CreateFrameBuffer(Vec2(512, 512))
fboB:GetTexture(1):SetMipMapLevels(1)
fboB:GetTexture(1):SetMinFilter("linear")
fboB:GetTexture(1):SetMagFilter("linear")
fboB:GetTexture(1):SetWrapS("repeat")
fboB:WriteThese("1")

function goluwa.PostDrawGUI()

	local writeBuffer = fboA
	local readBuffer = fboB

	local iterations = 8
	local anim = (math.sin(os.clock()) * 0.5 + 0.5)

	for i = 0, iterations - 1 do
		local radius = (iterations - i - 1) * anim

		writeBuffer:Begin()
		writeBuffer:ClearColor(0, 0, 0, 1)

		if i == 0 then
			shader.image = tex
		else
			shader.image = readBuffer:GetTexture(1)
		end

		shader.flip = true
		shader.direction = i % 2 == 0 and Vec2(radius, 0) or Vec2(0, radius)
		shader:Bind()

		render2d.PushMatrix(0,0,w,h)
			render2d.rectangle:Draw(render2d.rectangle_indices)
		render2d.PopMatrix()

		writeBuffer:End()

		local t = writeBuffer
		writeBuffer = readBuffer
		readBuffer = t
	end


	writeBuffer:Begin()
	writeBuffer:ClearColor(0, 0, 0, 1)
		shader:Bind()

		render2d.PushMatrix()
		render2d.Scale(w, h)
			render2d.rectangle:Draw(render2d.rectangle_indices)
		render2d.PopMatrix()
	writeBuffer:End()

	gfx.DrawRect(0,0,w,h,writeBuffer:GetTexture(1))
end