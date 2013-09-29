local SHADER = {
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
				vec4 diffuse = texture2D(tex_diffuse, uv);
				vec4 position = texture2D(tex_normal, uv);
				vec4 normal = texture2D(tex_position, uv);
				
				vec3 light = vec3(50,100,50);
				vec3 lightDir = light - position.xyz;

				normal = normalize(normal);
				lightDir = normalize(lightDir);

				vec3 eyeDir = normalize(cam_pos-position.xyz);
				vec3 vHalfVector = normalize(lightDir.xyz+eyeDir);

				out_color = max(dot(normal.xyz,lightDir),0) * diffuse + 
				pow(max(dot(normal.xyz,vHalfVector),0.0), 100) * 1.5;
				
				out_color.a = 1; 
			}
		]]
	}
}

function render.InitializeDeffered()
	render.gbuffer = render.CreateFrameBuffer(
		render.w, 
		render.h, 
		{
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
		}
	)
	
		
	local noise = Texture(64,64):Fill(function() 
		return math.random(255), math.random(255), math.random(255), math.random(255) 
	end)  


	local shader = render.CreateSuperShader("deffered", SHADER)
	
	shader.model_matrix = render.GetModelMatrix
	shader.camera_matrix = render.GetCameraMatrix
	shader.cam_pos = render.GetCamPos
	shader.tex_diffuse = render.gbuffer:GetTexture("diffuse")
	shader.tex_position = render.gbuffer:GetTexture("position") 
	shader.tex_normal = render.gbuffer:GetTexture("normal")
	
	local screen_quad = shader:CreateVertexBuffer({
		{pos = {0, 0}, uv = {0, 1}},
		{pos = {0, 1}, uv = {0, 0}},
		{pos = {1, 1}, uv = {1, 0}},

		{pos = {1, 1}, uv = {1, 0}},
		{pos = {1, 0}, uv = {1, 1}},
		{pos = {0, 0}, uv = {0, 1}},
	})
	
	render.deffered_shader = shader
	render.deffered_screen_quad = screen_quad	
end

function render.DrawDeffered(w, h)
	render.PushMatrix()
		surface.Scale(w, h)		
		render.deffered_screen_quad:Draw()
	render.PopMatrix()     
end

if render.deffered_shader then
	render.InitializeDeffered()
end