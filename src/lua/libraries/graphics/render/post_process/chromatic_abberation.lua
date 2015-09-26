local PASS = {}

PASS.Name = FILE_NAME
PASS.Default = false

PASS.Source = [[
out vec3 fragColor;

void main()
{
    // maximum aberration in number of pixels at uv.x == 0 or 1 (left or right edge)
    const float redAberration = 10.0;
    const float greenAberration =0.0;
    const float blueAberration = -10.0;

    float pctEffect = (uv.x - 0.5) * 0.5;

    vec3 aberration = vec3(redAberration / g_screen_size.x, greenAberration / g_screen_size.x, blueAberration / g_screen_size.x);
    aberration *= pctEffect;

    vec3 col;

    col.r = texture(self, vec2(uv.x+aberration.x,uv.y)).x;
    col.g = texture(self, vec2(uv.x+aberration.y,uv.y)).y;
    col.b = texture(self, vec2(uv.x+aberration.z,uv.y)).z;

    fragColor = col;
}
]]

render.AddGBufferShader(PASS)