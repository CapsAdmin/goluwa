local PASS = {}

PASS.Name = "lens_flare"
PASS.Position = FILE_NAME:sub(1, 1)

PASS.Variables = {
	lens_flare_intensity = 1,
}

PASS.Source = [[
	out vec4 out_color;

	void main()
	{
		out_color.rgb = texture(self, uv).rgb + texture(tex_lens_flare, uv).rgb * lens_flare_intensity;
		out_color.a = 1;
	}
]]

render.AddGBufferShader(PASS) 