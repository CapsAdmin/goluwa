local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
	out vec3 out_color;
		
	void main()
	{		
		out_color = get_light(uv);
	}
]]

render.AddGBufferShader(PASS)