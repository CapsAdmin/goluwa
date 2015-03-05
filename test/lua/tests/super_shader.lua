local data = {
	name = "test",
	
	-- these are declared as uniform on all shaders
	shared = {
		uniform = {
			time = 0,
		},
	},
	
	vertex = {
		uniform = {
			pwm_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},	
		-- if main is not defined it will wrap void main() { *line here* } around the line
		source = "gl_Position = pwm_matrix * vec4(pos, 0, 1);"
	},
	
	fragment = { 
		uniform = {
			global_color = Color(1,1,1,1),
			tex = "texture",
		},		
		-- when attributes is used outside of vertex they are simply sent from vertex shader
		-- as "__out_foo" and then grabbed from the other shader with a macro to turn its name 
		-- back to "foo" with #define
		attributes = {
			{uv = "vec2"},
		},			
		source = [[
			out vec4 frag_color;
			vec4 color = texture(tex, uv);
			
			// 0 to 1
			float x = uv.x;
			float y = uv.y;

			void main()
			{
				frag_color = color * global_color;
				
				frag_color.r = sin(x*100);
				frag_color.g = cos(time+x*100);
			}
		]]
	} 
} 
 
local shader = render.CreateShader(data)

shader.pwm_matrix = render.GetProjectionViewWorldMatrix

-- this creates mesh from the attributes field
local mesh = shader:CreateVertexBuffer{
	{pos = {0, 0}, uv = {0, 1}},
	{pos = {0, 1}, uv = {0, 0}},
	{pos = {1, 1}, uv = {1, 0}},

	{pos = {1, 1}, uv = {1, 0}},
	{pos = {1, 0}, uv = {1, 1}},
	{pos = {0, 0}, uv = {0, 1}},
}
 
event.AddListener("Draw2D", "hm", function()
	surface.PushMatrix(0, 0, surface.GetSize())
		shader.global_color = HSVToColor(system.GetTime())
		shader.time = system.GetTime()
		shader.tex = render.GetWhiteTexture()
		shader:Bind()
		mesh:Draw()
	surface.PopMatrix()
end)  