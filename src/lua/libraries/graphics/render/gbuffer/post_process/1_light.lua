local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
	out vec4 out_color;
		
	void main()
	{		
		out_color = vec4(get_diffuse(uv) * get_light(uv), 1);
	}
]]

render.AddGBufferShader(PASS)