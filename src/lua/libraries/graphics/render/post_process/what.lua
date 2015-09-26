local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = false

PASS.Source = [[
	out vec3 out_color;

	void main()
	{
		out_color.rgb = texture(self, uv).rgb;
		out_color.r = sin(out_color.g*10);
	}
]]

render.AddGBufferShader(PASS)