local PASS = {}

PASS.Position, PASS.Name = FILE_NAME:match("(%d-)_(.+)")

PASS.Source = [[
out vec3 out_color;

void main(void)
{
	out_color = texture(self, uv).rgb + get_sky(uv, get_depth(uv));
}
]]

render.AddGBufferShader(PASS)