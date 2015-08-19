local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
	out vec4 out_color;
		
	void main()
	{		
		out_color.rgb = get_light(uv);
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS)