do
	local ffi = require("ffi")
	local gl = require("opengl")

	local shader = render.CreateShader({
		name = "test",
		fragment = {
			source = [[
				#version 430
				#extension GL_ARB_gpu_shader5 : require

				uniform lol
				{
					vec3 pos2;
					float num2;
					float num3;
					vec3 pos;
					vec4 color;
					float num;
					vec4 color2;
				};

				out vec4 out_color;

				void main()
				{
					out_color = color;
					out_color.r = num;
				}
			]]
		}
	})

	local sb = render.CreateShaderVariables("uniform", shader, "lol")
	sb:SetBindLocation(shader, 1)

	event.AddListener("PreDrawGUI", "fb", function()
		sb:UpdateVariable("color", Color(1, math.abs(math.sin(os.clock())), 1, 1))
		sb:UpdateVariable("num", math.abs(math.cos(os.clock()*10)))
		sb:Bind(1)

		render2d.PushMatrix(0, 0, render2d.GetSize())
			render.SetShaderOverride(shader)
			render2d.rectangle:Draw()
			render.SetShaderOverride()
		render2d.PopMatrix()
	end)
end