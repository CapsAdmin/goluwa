do
	local ffi = require("ffi")
	local gl = require("libopengl")

	local shader = render.CreateShader({
		name = "test",
		fragment = {
			source = [[
				#version 430

				out vec4 out_color;

				void main()
				{
					out_color = g_world[0];
				}
			]]
		}
	})


	local lol = ffi.new("struct {float a[3]; float b[3]; float c[3];}", {a = {1,2,3}, b = {1,0,1}, c = {7,8,9}})

	local val = render.CreateShaderStorageBuffer("dynamic_draw", lol, ffi.sizeof(lol))

	local block_index = shader.program:GetProperties().shader_storage_block.global_variables.block_index
	shader.program:BindShaderBlock(block_index, 2)
	table.print(shader.program:GetProperties().shader_storage_block.global_variables)

	event.AddListener("PreDrawGUI", "fb", function()
		local data = ffi.new("float[3]")
		data[1] = math.abs(math.sin(os.clock()))
		val:UpdateData(data, ffi.sizeof(data), ffi.sizeof("float") * 3)

		val:Bind(2)

		surface.PushMatrix(0, 0, surface.GetSize())
			render.SetShaderOverride(shader)
			surface.rect_mesh:Draw()
			render.SetShaderOverride()
		surface.PopMatrix()
	end)
end