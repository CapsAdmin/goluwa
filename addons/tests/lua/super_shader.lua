glw.OpenWindow()

local data = {
	-- these are declared as uniform on all shaders
	shared = {
		uniform = {
			time = 0,
		},
	},
	
	vertex = {
		uniform = {
			camera_matrix = "mat4",
			model_matrix = "mat4",
		},			
		attributes = {
			position = "vec2",
		},
		vertex_attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
			{color = "vec4"},
		},	
		-- if main is not defined it will wrap void main() { *line here* } around the line
		source = "gl_Position = camera_matrix * model_matrix * vec4(position, 0.0, 1.0);"
	},
	
	fragment = { 
		uniform = {
			add_color = 0, -- guess the type and use passed var as default if not passed
			global_color = Color(1,1,1,1), 
			texture = Texture(16,16):Fill(function() 
				return 255, 255, 255, 255
			end),
		},		
		-- when attributes is used outside of vertex they are simply sent from vertex shader
		-- as "__out_foo" and then grabbed from the other shader with a macro to turn its name 
		-- back to "foo" with #define
		attributes = {
			uv = "vec2",
			color = "vec4",
		},			
		source = [[
			out vec4 frag_color;

			vec4 texel = texture2D(texture, uv);

			void main()
			{	
				if (add_color > 0.5)
				{
					frag_color = texel * color;
					frag_color.xyz = frag_color.xyz + global_color.xyz;
					frag_color.w = frag_color.w * global_color.w;
				}
				else
				{	
					frag_color = texel * color * global_color;
				}
			}
		]]
	} 
} 
 
local mat = SuperShader("2d_rect", data)

-- this creates buffer from the vertex_attributes field in our material
local buffer = mat:CreateVertexBuffer({
	{pos = {0, 0}, uv = {0, 1}, color = {1,1,1,1}},
	{pos = {0, 1}, uv = {0, 0}, color = {1,1,1,1}},
	{pos = {1, 1}, uv = {1, 0}, color = {1,1,1,1}},

	{pos = {1, 1}, uv = {1, 0}, color = {1,1,1,1}},
	{pos = {1, 0}, uv = {1, 1}, color = {1,1,1,1}},
	{pos = {0, 0}, uv = {0, 1}, color = {1,1,1,1}},
})

event.AddListener("OnDraw2D", "hm", function()

	-- use the built in matrices cause we dont have our own (yet!)
	gl.Translatef(50, 50, 0)
	gl.Scalef(100, 100, 0)
	
	gl.GetFloatv(e.GL_MODELVIEW_MATRIX, render.model_matrix)
	gl.GetFloatv(e.GL_PROJECTION_MATRIX, render.camera_matrix)
	
	--set the uniform fields
	mat.model_matrix = render.model_matrix
	mat.camera_matrix = render.camera_matrix
	mat.global_color = HSVToColor(glfw.GetTime()) 

	buffer:Draw(mat)
end)