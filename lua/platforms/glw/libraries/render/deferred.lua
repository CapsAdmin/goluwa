gl.debug = true

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
			tex_light = "sampler2D",
			tex_depth = "sampler2D",
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
				vec4 normal = texture2D(tex_normal, uv);
				vec4 position = texture2D(tex_position, uv);
				vec4 light = texture2D(tex_light, uv);
				vec4 depth = texture2D(tex_depth, uv);
	
				vec3 light_pos = vec3(0,100,100);
				vec3 light_direction = light_pos - position.xyz;

				normal = normalize(normal);
				light_direction = normalize(light_direction);

				vec3 viewer_direction = normalize(cam_pos - position.xyz);
				
				float mult = clamp(dot(reflect(light_direction, normal.xyz), viewer_direction) * 0.96, 0.0, 1.0);
				mult = pow(mult, 32.0);

				vec3 half = normalize(light_direction.xyz + viewer_direction);
				
				out_color = 
				dot(normal.xyz, light_direction) * 
				diffuse + 
				pow(max(dot(normal.xyz, half), 0.0), 100);
								
				
				float fog_amount = pow(depth.a, 15000);
				vec3 fog_color = vec3(0.0, 0.25, 0.5);
				
				out_color.a = 1; 
				
				out_color.rgb = mix(out_color.rgb, fog_color, 0.5);
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
				texture_format = {
					internal_format = e.GL_RGBA32F,
				}
			},
			{
				name = "normal",
				attach = e.GL_COLOR_ATTACHMENT2,
				texture_format = {
					internal_format = e.GL_RGBA32F,
				}
			},
			{
				name = "position",
				attach = e.GL_COLOR_ATTACHMENT1,
				texture_format = {
					internal_format = e.GL_RGBA32F,
				}
			},
			{
				name = "light",
				attach = e.GL_COLOR_ATTACHMENT3,
				texture_format = {
					internal_format = e.GL_RGBA32F,
				}
			},
			{
				name = "depth",
				attach = e.GL_DEPTH_ATTACHMENT,
				texture_format = {
					internal_format = e.GL_DEPTH_COMPONENT32F,
					
				--	compare_mode = e.GL_COMPARE_R_TO_TEXTURE,
				--	compare_func = e.GL_EQUAL,					 
					[e.GL_DEPTH_TEXTURE_MODE] = e.GL_ALPHA,
					
				}
			}
		}
	)  

	local shader = render.CreateSuperShader("deferred", SHADER)
	
	shader.model_matrix = render.GetModelMatrix
	shader.camera_matrix = render.GetCameraMatrix
	shader.cam_pos = render.GetCamPos
	
	shader.tex_diffuse = render.gbuffer:GetTexture("diffuse")
	shader.tex_position = render.gbuffer:GetTexture("position") 
	shader.tex_normal = render.gbuffer:GetTexture("normal")
	shader.tex_light = render.gbuffer:GetTexture("light")
	shader.tex_depth = render.gbuffer:GetTexture("depth")

	local screen_quad = shader:CreateVertexBuffer({
		{pos = {0, 0}, uv = {0, 1}},
		{pos = {0, 1}, uv = {0, 0}},
		{pos = {1, 1}, uv = {1, 0}},

		{pos = {1, 1}, uv = {1, 0}},
		{pos = {1, 0}, uv = {1, 1}},
		{pos = {0, 0}, uv = {0, 1}},
	})
	
	render.deferred_shader = shader
	render.deferred_screen_quad = screen_quad	
	--debug.logcalls(true)
end

function render.DrawDeffered(w, h)
	render.PushMatrix()
		surface.Scale(w, h)		
		render.deferred_screen_quad:Draw()
	render.PopMatrix()     
end

if render.deferred_shader then
	render.InitializeDeffered()
end
