local fb = render.CreateFrameBuffer()
local tex = render.CreateBlankTexture(window.GetSize():Copy())
tex:SetInternalFormat("rgba32f")
tex:SetupStorage()
tex:SetMinFilter("nearest")
tex:SetMagFilter("nearest")
fb:SetTexture(1, tex)
local shader = render.CreateShader(
	{
		name = "test",
		shared = {
			variables = {
				time = {number = system.GetTime},
			},
		},
		fragment = {
			variables = {
				size = {
					vec2 = function()
						return fb:GetTexture():GetSize()
					end,
				},
				self = {
					texture = function()
						return fb:GetTexture()
					end,
				},
				generate_random = 1,
			},
			mesh_layout = {
				{uv = "vec2"},
			},
			source = [[
			out vec4 frag_color;
			vec4 color = texture(self, uv);

			void main()
			{
				if (generate_random == 1)
				{

					frag_color.rgb = vec3(1, 1, 1);
					frag_color.a = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453) > 0.5 ? 1 : 0;

					return;
				}

				vec4 color = texture(self, uv);

				vec2 uv2 = uv / size;
				vec2 uv_unit = 1.0 / size;

				int neighbours = 0;

				for (float y = -1; y <= 1; y++)
				{
					for (float x = -1; x <= 1; x++)
					{
						if (texture(self, uv + (uv_unit * vec2(x, y))).a > 0)
						{
							neighbours++;
						}
					}
				}

				if (color.a > 0 && (neighbours-1 < 2 || neighbours-1 > 3))
				{
					color.a = 0;
				}
				else if (neighbours == 3)
				{
					color.a = 1;
				}

				frag_color = color;
			}
		]],
		},
	}
)

event.Timer(
	"fb_update",
	0,
	0,
	function()
		fb:Begin()
		render.SetBlendMode("src_color", "one_minus_dst_alpha", "add")
		render2d.PushMatrix(0, 0, fb:GetTexture(1):GetSize():Unpack())
		shader:Bind()
		render2d.rectangle:Draw(render2d.rectangle_indices)
		render2d.PopMatrix()

		if input.IsMouseDown("button_left") then  end

		fb:End()
		shader.generate_random = 0
	end
)

function goluwa.PreDrawGUI()
	render2d.SetTexture(fb:GetTexture())
	render2d.SetColor(1, 1, 1, 1)
	render2d.DrawRect(0, 0, render2d.GetSize())
end