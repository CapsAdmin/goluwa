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
			tex_normal = "sampler2D",
			tex_position = "sampler2D", 
			tex_specular = "sampler2D",
			tex_depth = "sampler2D",
			cam_pos = "vec3",
			time = "float",
		},  
		attributes = {
			uv = "vec2",
		},
		source = [[
			out vec4 out_color;
			
			vec3 mix_fog(vec3 color, float depth)
			{
				const vec3 ambient = vec3(0.30588236451149, 0.59607845544815, 0.88235300779343); 
				
				float fog_intensity = pow(depth, 30000);
				fog_intensity = -fog_intensity + 1;

				color = mix(ambient, color, fog_intensity);
				
				return color;
			}
			
			vec3 calc_light(vec3 normal, vec3 position, vec3 diffuse, float specular)
			{
				float light_specular = 0.5;
				float light_shininess = 1.25;
				vec3 light_color = vec3(1,1,1);
				
				vec3 light_pos = vec3(100, 100, -200);
				vec3 light_dir = light_pos - position;
				
				vec3 final_color = vec3(0, 0, 0);
				vec3 N = normalize(normal);
				vec3 L = normalize(light_dir);
	
				float lambert_term = dot(N, L);
	
				if (lambert_term > 0.0)
				{
					final_color += light_color * diffuse * lambert_term;	
					
					vec3 E = normalize(-position);
					vec3 R = reflect(-L, N);
					
					final_color += light_specular * specular * pow(max(dot(R, E), 0.0), light_shininess);
				}
				
				return final_color;
			}
			
			void main ()
			{	
				vec3 diffuse = texture2D(tex_diffuse, uv).rgb;
				vec3 normal = texture2D(tex_normal, uv).rgb;
				vec3 position = texture2D(tex_position, uv).xyz;
				
				float specular = texture2D(tex_specular, uv).r;
				float depth = texture2D(tex_depth, uv).a;

				out_color.rgb += calc_light(normal, position, diffuse, specular);				
				out_color.rgb = mix_fog(out_color.rgb, depth);
				
				out_color.a = 1;
			}
		]]  
	}
} 

local PPSHADER = {
	vertex = SHADER.vertex,
	fragment = {
		uniform = {
			tex_diffuse = "sampler2D",
			tex_depth = "sampler2D",
		},
		attributes = {
			uv = "vec2",
		},
		source = [[
			out vec4 out_color;
			
			void main ()
			{				
				out_color = texture2D(tex_diffuse, uv);				
			}
		]]  
	}
}

 
local sphere = NULL

function render.InitializeDeffered()

	render.gbuffer_config = {
		{
			name = "diffuse",
			attach = e.GL_COLOR_ATTACHMENT0,
			texture_format = {
				internal_format = e.GL_RGBA32F,
			}
		},
		{
			name = "normal",
			attach = e.GL_COLOR_ATTACHMENT1,
			texture_format = {
				internal_format = e.GL_RGB32F,
			}
		},
		{
			name = "position",
			attach = e.GL_COLOR_ATTACHMENT2,
			texture_format = {
				internal_format = e.GL_RGB32F,
			}
		},
		{
			name = "specular",
			attach = e.GL_COLOR_ATTACHMENT3,
			texture_format = {
				internal_format = e.GL_RGB32F,
			}
		},
		{
			name = "depth",
			attach = e.GL_DEPTH_ATTACHMENT,
			draw_manual = true,
			texture_format = {
				internal_format = e.GL_DEPTH_COMPONENT32F,	 
				[e.GL_DEPTH_TEXTURE_MODE] = e.GL_ALPHA,
				
			}
		}
	} 
	render.gbuffer = render.CreateFrameBuffer(render.w, render.h, render.gbuffer_config)  

	local shader = render.CreateSuperShader("deferred", SHADER)
	
	shader.model_matrix = render.GetModelMatrix
	shader.camera_matrix = render.GetCameraMatrix
	shader.cam_pos = render.GetCamPos
	shader.time = function() return tonumber(glfw.GetTime()) end
	
	shader.tex_diffuse = render.gbuffer:GetTexture("diffuse")
	shader.tex_position = render.gbuffer:GetTexture("position") 
	shader.tex_normal = render.gbuffer:GetTexture("normal")
	shader.tex_specular = render.gbuffer:GetTexture("specular")
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
	
	
	render.pp_buffer = render.CreateFrameBuffer(render.w, render.h, {
		{
			name = "diffuse",
			attach = e.GL_COLOR_ATTACHMENT0,
			texture_format = {
				internal_format = e.GL_RGBA32F,
				format = {mip_map_levels = 4, mag_filter = e.GL_LINEAR_MIPMAP_LINEAR, min_filter = e.GL_LINEAR_MIPMAP_LINEAR,},
			}
		},
	}) 
	
	local shader = render.CreateSuperShader("post_process", PPSHADER)
	shader.model_matrix = render.GetModelMatrix
	shader.camera_matrix = render.GetCameraMatrix
	shader.cam_pos = render.GetCamPos
	shader.tex_diffuse = render.pp_buffer:GetTexture("diffuse")
	shader.tex_depth = render.gbuffer:GetTexture("depth")
	
	local screen_quad = shader:CreateVertexBuffer({
		{pos = {0, 0}, uv = {0, 1}},
		{pos = {0, 1}, uv = {0, 0}},
		{pos = {1, 1}, uv = {1, 0}},

		{pos = {1, 1}, uv = {1, 0}},
		{pos = {1, 0}, uv = {1, 1}},
		{pos = {0, 0}, uv = {0, 1}},
	})
	
	render.pp_screen_quad = screen_quad
	
end

local size = 6

function render.DrawDeffered(w, h)
	render.Start3D()
	
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, render.gbuffer.id)
	
	gl.ActiveTextureARB(e.GL_TEXTURE4)
	gl.Enable(e.GL_TEXTURE_2D)
	gl.Disable(e.GL_DEPTH_TEST)
	gl.Disable(e.GL_CULL_FACE)
	
	
	if sphere:IsValid() then 
		gl.DrawBuffers(1, render.gbuffer.buffers.light.draw_enum)
		sphere:Draw()   
	end
	
	gl.Enable(e.GL_DEPTH_TEST)
	gl.Enable(e.GL_CULL_FACE)
		
	render.Start2D()

	-- draw to the pp buffer
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, render.pp_buffer.id)		
		render.PushMatrix()
			surface.Scale(w, h)
			render.deferred_screen_quad:Draw()
		render.PopMatrix()		
	gl.BindFramebuffer(e.GL_FRAMEBUFFER, 0)

	-- draw the pp texture as quad
	render.PushMatrix()
		surface.Scale(w, h)
		render.pp_screen_quad:Draw()
	render.PopMatrix()
	
	
	if render.debug then
		w = w / size
		h = h / size
		
		local x = 0
		local y = 0
		
		surface.Color(1,1,1,1)
		
		for i, data in pairs(render.gbuffer_config) do
			surface.SetTexture(render.gbuffer:GetTexture(data.name))
			surface.DrawRect(x, y, w, h)
			
			surface.SetTextPos(x, y + 5)
			surface.DrawText(data.name)
			
			if i%size == 0 then
				y = y + h
				x = 0
			else
				x = x + w
			end
		end
	end
end

if render.deferred_shader then
	render.InitializeDeffered()
end
