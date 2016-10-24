do
	local ffi = require("ffi")
	local gl = require("opengl")

	local shader = render.CreateShader({
		name = "test",
		fragment = {
			source = [[
				#version 430

				layout(std430, binding = 0) buffer lol
				{
					vec3 pos2;
					float num2;
					float num3;
					vec3 pos;
					vec4 color;
					float num;
					vec4 color2;
					//uint64_t wow;
				};

				out vec4 out_color;

				void main()
				{
					out_color = color+color2+vec4(pos+pos2,num+num2+num3);
				}
			]]
		}
	})

	shader.program:SetupStorageBlock("lol", 1)
	shader.program:BindStorageBlock("lol")

	event.AddListener("PreDrawGUI", "fb", function()
		shader.program:SetStorageBlockVariable("lol", "color", Color(1, math.abs(math.sin(os.clock())), 1, 1))

		render2d.PushMatrix(0, 0, render2d.GetSize())
			render.SetShaderOverride(shader)
			render2d.rectangle:Draw()
			render.SetShaderOverride()
		render2d.PopMatrix()
	end)
end