window.Open() 

local data = {
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
			texture = "texture",
		},		
		-- when attributes is used outside of vertex they are simply sent from vertex shader
		-- as "__out_foo" and then grabbed from the other shader with a macro to turn its name 
		-- back to "foo" with #define
		attributes = {
			uv = "vec2",
		},			
		source = [[
			out vec4 frag_color;
			vec4 color = texture2D(texture, uv);
			
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
 
local shader = SuperShader("test", data)

-- this creates mesh from the attributes field
local mesh = shader:CreateVertexBuffer({
	{pos = {0, 0}, uv = {0, 1}},
	{pos = {0, 1}, uv = {0, 0}},
	{pos = {1, 1}, uv = {1, 0}},

	{pos = {1, 1}, uv = {1, 0}},
	{pos = {1, 0}, uv = {1, 1}},
	{pos = {0, 0}, uv = {0, 1}},
})

mesh.pwm_matrix = render.GetPVWMatrix2D
 
event.AddListener("OnDraw2D", "hm", function()
	surface.PushMatrix(0, 0, surface.GetScreenSize())
		mesh.global_color = HSVToColor(timer.GetTime())
		mesh.time = timer.GetTime()
		mesh.texture = tex	
		mesh:Draw()
	surface.PopMatrix()
end) 