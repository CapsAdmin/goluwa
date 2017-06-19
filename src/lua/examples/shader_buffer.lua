do
	local ffi = require("ffi")
	local gl = require("opengl")

	local shader = render.CreateShader({
		name = "test",
		fragment = {
			source = [[
				#version 430
				#extension GL_ARB_gpu_shader5 : require

				uniform uniform_test_
				{
					vec3 pos2;
					float num2;
					float num3;
					vec3 pos;
					vec4 colors[2];
					float num;
					vec4 color2;
				} uniform_test;

				buffer shader_storage_test_
				{
					mat4 asdf;
					vec4 color_array[];
				} shader_storage_test;

				out vec4 out_color;

				void main()
				{
					out_color = uniform_test.colors[1] * shader_storage_test.color_array[32];
					out_color.r = uniform_test.num;
				}
			]]
		}
	})

	local ubo = render.CreateShaderVariables("uniform", shader, "uniform_test_")
	ubo:SetBindLocation(shader, 1)

	local array_size = (ffi.sizeof("float") * 4) * 50
	local ssbo = render.CreateShaderVariables("shader_storage", shader, "shader_storage_test_", array_size)
	ssbo:SetBindLocation(shader, 2)

	function goluwa.PreDrawGUI()
		ubo:UpdateVariable("colors", Color(1, math.abs(math.sin(os.clock())), 1, 1), 1)
		ubo:UpdateVariable("num", math.abs(math.cos(os.clock()*10)))
		ubo:Bind(1)

		ssbo:UpdateVariable("color_array", Color(1, math.abs(math.sin(os.clock()*20)), 1, 1), 32)
		ssbo:Bind(2)

		render2d.PushMatrix(0, 0, render2d.GetSize())
			shader:Bind()
			render2d.rectangle:Draw()
		render2d.PopMatrix()
	end
end