window.Open(500, 500)
    
local fb = render.CreateFrameBuffer(500, 500, {
	{
		name = "diffuse",
		attach = e.GL_COLOR_ATTACHMENT0,
		internal_format = e.GL_RGBA,
		texture_format = {
			format_type = e.GL_UNSIGNED_BYTE,
		}
	},
	{
		name = "position",
		attach = e.GL_COLOR_ATTACHMENT1,
		internal_format = e.GL_RGBA32F,
		texture_format = {
			format_type = e.GL_FLOAT,
		}
	},
	{
		name = "normal",
		attach = e.GL_COLOR_ATTACHMENT2,
		internal_format = e.GL_RGBA16F,
		texture_format = {
			format_type = e.GL_FLOAT,
		}
	},
	{
		name = "depth",
		attach = e.GL_DEPTH_ATTACHMENT,
		internal_format = e.GL_DEPTH_COMPONENT24,
	}
})  

local gbuff_shader = SuperShader("deffered", {
	vertex = {
		uniform = {
			camera_matrix = "mat4",
			model_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = "gl_Position = camera_matrix * model_matrix * vec4(pos, 0.0, 1.0);"
	},
	fragment = {
		uniform = {
			tex_diffuse = "sampler2D",
			tex_position = "sampler2D",
			tex_normal = "sampler2D",
			cam_pos = "vec3",
		},
		attributes = {
			uv = "vec2",
		},
		source = [[
			out vec4 out_color;
		
			void main ()
			{
				vec4 image = texture2D(tex_diffuse, uv);
				vec4 position = texture2D(tex_position, uv);
				vec4 normal = texture2D(tex_normal, uv);
				
				vec3 light = vec3(50,100,50);
				vec3 light_dir = light - position.xyz ;

				normal = normalize(normal);
				light_dir = normalize(light_dir);

				vec3 eyeDir = normalize(cam_pos - position.xyz);
				vec3 half = normalize(light_dir.xyz + eyeDir);

				out_color = max(dot(normal.xyz, light_dir), 0) * image + pow(max(dot(normal.xyz, half),0.0), 100) * 1.5;
			}
		]]
	}
}) 
  
local screen_rect = gbuff_shader:CreateVertexBuffer({
	{pos = {0, 0}, uv = {0, 1}},
	{pos = {0, 1}, uv = {0, 0}},
	{pos = {1, 1}, uv = {1, 0}},

	{pos = {1, 1}, uv = {1, 0}},
	{pos = {1, 0}, uv = {1, 1}},
	{pos = {0, 0}, uv = {0, 1}},
})

screen_rect.model_matrix = render.GetModelMatrix
screen_rect.camera_matrix = render.GetCameraMatrix
screen_rect.cam_pos = render.GetCamPos

local tex = Texture(64,64):Fill(function() 
	return math.random(255), math.random(255), math.random(255), math.random(255) 
end)  

event.AddListener("OnDraw2D", "lol", function()
	
	render.PushMatrix()
		surface.Translate(5, 5)
		surface.Scale(500, 500)
		
		screen_rect.tex_diffuse = fb:GetTexture("diffuse")
		screen_rect.tex_normal = fb:GetTexture("normal")
		screen_rect.tex_position = fb:GetTexture("position") 
		
		screen_rect:Draw()
	render.PopMatrix()   
	
	fb:Begin()
		surface.Color(1,1,1,1)
		surface.SetTexture(tex)
		surface.DrawRect(90, 10, 100, 100)
	fb:End()
end)    