local render = ... or _G.render

local gl = require("lj-opengl") -- OpenGL

local PASS = {}

PASS.Name = "model"
PASS.Stage = FILE_NAME:sub(1,1)

PASS.Buffers = {
	{"diffuse", "RGBA8"},
	{"normal", "RGB16f"},
	{"illumination", "RGBA8"},
}

local gl = require("lj-opengl") -- OpenGL

function PASS:Draw3D()
	--gl.DepthMask(gl.e.GL_TRUE)
	--gl.Enable(gl.e.GL_DEPTH_TEST)
	--gl.Disable(gl.e.GL_BLEND)
	--gl.Disable(gl.e.GL_BLEND)

	render.gbuffer:Begin()
		render.gbuffer:Clear()
		
		--gl.Clear(gl.e.GL_DEPTH_BUFFER_BIT)
		event.Call("Draw3DGeometry", render.gbuffer_model_shader)
		
		--skybox?				
		
		--local scale = 16
		--local view = Matrix44()
		--view = render.SetupView3D(Vec3(234.1, -234.1, 361.967)*scale + render.GetCameraPosition(), render.GetCameraAngles(), render.GetCameraFOV(), view)
		--view:Scale(scale,scale,scale)
		--event.Call("Draw3DGeometry", render.gbuffer_model_shader, view * render.matrices.projection_3d, true)			
	render.gbuffer:End()
end

PASS.Shader = {
	vertex = {
		uniform = {
			pvm_matrix = "mat4",
		},
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},
		source = "gl_Position = pvm_matrix * vec4(pos, 1.0);"
	},
	fragment = {
		uniform = {
			color = Color(1,1,1,1),
			diffuse = "sampler2D",
			diffuse2 = "sampler2D",
			vm_matrix = "mat4",
			
			detail = "sampler2D",
			--detail_scale = 1,
			--detail_blend_factor = 0,
			alpha_test = 0,

			bump = "sampler2D",
			bump2 = "sampler2D",
			specular = "sampler2D",
			illumination = "sampler2D",
			illumination_color = Color(1,1,1,1),
		},
		attributes = {
			{pos = "vec3"},
			{normal = "vec3"},
			{uv = "vec2"},
			{texture_blend = "float"},
		},
		source = [[
			out vec4 out_color[3];

			float rand(vec2 co){
				return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
			}
			
			void main()
			{				
				// diffuse
				out_color[0] = mix(texture(diffuse, uv), texture(diffuse2, uv), texture_blend) * color;
				
				if (alpha_test == 1)
				{
					//if (out_color[0].a < pow(rand(uv), 0.5))
					//if (pow(out_color[0].a+0.5, 4) < 0.5)
					if (out_color[0].a < 0.25)
						discard;
				}
				else
				{
					out_color[0].a = 1;
				}
				
				//if (detail_blend_factor > 0)
					//out_color[0].rgb = (out_color[0].rgb - texture(detail, uv * detail_scale*10).rgb);
				
				// specular
				out_color[1].a = texture(specular, uv).r;

				// normals
				{
					out_color[1].rgb = mat3(vm_matrix) * normal;
					
					vec3 bump_detail = mix(texture(bump, uv).rgb, texture(bump2, uv).rgb, texture_blend);
				
					if (bump_detail != vec3(0,0,0))
					{
						//bump_detail = normalize(bump_detail);
						out_color[1].rgb += (mat3(vm_matrix)) * -(normalize(bump_detail.grb) - vec3(0.5));
						out_color[1].rgb = normalize(out_color[1].rgb);
					}
					
				}

				out_color[2] = texture(illumination, uv)*illumination_color;
			}
		]]
	}
}

render.RegisterGBufferPass(PASS)