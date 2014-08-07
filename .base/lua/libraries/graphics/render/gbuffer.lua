local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render
 
render.gbuffer = NULL

local SHADER = {
	name = "gbuffer",
	vertex = {
		uniform = {
			pvm_matrix = "mat4",
		},			
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = "gl_Position = pvm_matrix * vec4(pos, 0.0, 1.0);"
	},
	fragment = {
		uniform = {
			tex_diffuse = "sampler2D",
			tex_normal = "sampler2D",
			tex_position = "sampler2D", 
			tex_specular = "sampler2D",
			tex_depth = "sampler2D",
			rt_w = "float",
			rt_h = "float",
			time = "float",
			cam_pos = "vec3",
			cam_vec = "vec3",
			pv_matrix = "mat4",
		},  
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = [[			
			out vec4 out_color;
			
			//
			//SSAO
			//
			float aoMultiplier= 50000.0;
			float depthTolerance = 0.001;
			
			float readDepth( in vec2 coord ) {
				//return (2.0 * rt_w) / (rt_h + rt_w - texture2D( tex_position, coord ).x * (rt_h - rt_w));	
				return pow(texture(tex_depth, coord).a, 0.5);
			}
			 
			float compareDepths( in float depth1, in float depth2 ) {
				float aoCap = 1.2;
				float aoMultiplier=20000.0;
				float depthTolerance=0.000001;
				//float aorange = 10.0;// units in space the AO effect extends to (this gets divided by the camera far range
				float diff = sqrt( clamp(1.0-(depth1-depth2) / 0.01,0.0,0.3) );
				float ao = min(aoCap,max(0.0,depth1-depth2-depthTolerance) * aoMultiplier) * diff;
				return ao;
			}
			 
			float ssao(void)
			{	
				float depth = readDepth( uv );
				float d;
			 
				float pw = 1.0 / rt_w;
				float ph = 1.0 / rt_h;
			 
				float aoCap = 1.0;
			 
				float ao = 0.1;
			 
				float aoMultiplier=10000.0;
			 
				float depthTolerance = 0.001;
			 
				float aoscale=0.75;
			 
				d=readDepth( vec2(uv.x+pw,uv.y+ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x-pw,uv.y+ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x+pw,uv.y-ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x-pw,uv.y-ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				pw*=2.0;
				ph*=2.0;
				aoMultiplier/=2.0;
				aoscale*=1.2;
			 
				d=readDepth( vec2(uv.x+pw,uv.y+ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x-pw,uv.y+ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x+pw,uv.y-ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x-pw,uv.y-ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				pw*=2.0;
				ph*=2.0;
				aoMultiplier/=2.0;
				aoscale*=1.2;
			 
				d=readDepth( vec2(uv.x+pw,uv.y+ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x-pw,uv.y+ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x+pw,uv.y-ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x-pw,uv.y-ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				pw*=2.0;
				ph*=2.0;
				aoMultiplier/=2.0;
				aoscale*=1.2;
			 
				d=readDepth( vec2(uv.x+pw,uv.y+ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x-pw,uv.y+ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x+pw,uv.y-ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				d=readDepth( vec2(uv.x-pw,uv.y-ph));
				ao+=compareDepths(depth,d)/aoscale;
			 
				ao/=16.0;
			 
				return 1-ao;
			}
			
			//
			//FOG
			//
			vec3 mix_fog(vec3 color, float depth)
			{
				//blue
				//const vec3 ambient = vec3(0.30588236451149, 0.59607845544815, 0.88235300779343); 
				const vec3 ambient = vec3(245.0 / 255.0, 210.0 / 255.0, 144.0 / 255.0); 
				
				float fog_intensity = pow(depth, 255);
				fog_intensity = -fog_intensity + 1;

				color = mix(ambient * color, color, fog_intensity);
				
				return color;
			}
			
			
			//
			//LIGHTING
			//
			vec3 calc_light(vec3 light_pos, vec3 normal, vec3 position, vec3 diffuse, float specular_map, vec3 light_color)
			{			
				const float method = 1;
				float light_specular = 64;
				float light_shininess = 64;
				float light_radius = 1000; //light radius isnt working, its also not being used
				
				vec3 final_color = light_color;
				
				vec3 light_vec = light_pos - position;
				float light_dist = length(light_vec);
				
				if (light_dist > light_radius) {return final_color;}
				
				vec3 light_dir = normalize(light_vec);
				
				float lambertian = dot(light_dir, normal);
	
				if (lambertian > 0.0)
				{						
					vec3 R = reflect(-light_dir, normal);
					
					vec3 half_dir = normalize(light_dir + cam_vec);
					float spec_angle = max(dot(half_dir, normal), 0.0);
					float S = pow(spec_angle, 64.0);
					
					final_color = vec3(0,0,0) + lambertian * diffuse + S * specular_map;
				}
						
				return final_color / light_dist * 10;
			}
			
			//
			//DEPTH POSITION
			//
			vec3 get_pos(float z)
			{
				vec4 spos = vec4(uv, z, 1.0);
				spos = (pv_matrix) * spos;
				
				return spos.xyz / spos.w;
			}
			
			void main ()
			{	
				vec3 diffuse = texture(tex_diffuse, uv).rgb;
				float depth = texture(tex_depth, uv).a;			
			
				vec3 normal = texture(tex_normal, uv).yxz;				
				vec3 position = -texture(tex_position, uv).yxz;

				float specular = texture(tex_specular, uv).x;
		
				out_color.rgb = diffuse * 0.1;
				
				//out_color.rgb += calc_light(vec3(0, 0, 10) + vec3(sin(time) * 10, cos(time) * 10, 0), normal, position, diffuse, specular, vec3(0,0,0));				
				out_color.rgb += calc_light(cam_pos, normal, position, diffuse, specular, vec3(0,0,0));				
				out_color.rgb = mix_fog(out_color.rgb, depth);
				
				out_color.a = 1;
				out_color.rgb *=  vec3(ssao());
			}
		]]  
	}
} 

local PPSHADER = {
	name = "gbuffer_post_process",
	base = "gbuffer",
	fragment = {
		uniform = {
			tex_diffuse = "sampler2D",
			tex_depth = "sampler2D",
			tex_normal = "sampler2D",
			tex_position = "sampler2D",
			rt_w = "float",
			rt_h = "float",
		},
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = [[			
			out vec4 out_color;
					
			float FXAA_SPAN_MAX = 8.0;
			float FXAA_REDUCE_MUL = 1.0/8.0;
			float FXAA_SUBPIX_SHIFT = 1.0/4.0;

			#define FxaaInt2 ivec2
			#define FxaaFloat2 vec2
			#define FxaaTexLod0(t, p) textureLod(t, p, 0.0)
			#define FxaaTexOff(t, p, o, r) textureLodOffset(t, p, 0.0, o)
			
			vec2 rcpFrame = vec2(1.0/rt_w, 1.0/rt_h);
			vec4 posPos = vec4(uv, uv - (rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT)));

			vec3 FxaaPixelShader(vec4 posPos, sampler2D tex)
			{   

				#define FXAA_REDUCE_MIN   (1.0/128.0)
				//#define FXAA_REDUCE_MUL   (1.0/8.0)
				//#define FXAA_SPAN_MAX     8.0
				

				vec3 rgbNW = FxaaTexLod0(tex, posPos.zw).xyz;
				vec3 rgbNE = FxaaTexOff(tex, posPos.zw, FxaaInt2(1,0), rcpFrame.xy).xyz;
				vec3 rgbSW = FxaaTexOff(tex, posPos.zw, FxaaInt2(0,1), rcpFrame.xy).xyz;
				vec3 rgbSE = FxaaTexOff(tex, posPos.zw, FxaaInt2(1,1), rcpFrame.xy).xyz;
				vec3 rgbM  = FxaaTexLod0(tex, posPos.xy).xyz;
				

				vec3 luma = vec3(0.299, 0.587, 0.114);
				float lumaNW = dot(rgbNW, luma);
				float lumaNE = dot(rgbNE, luma);
				float lumaSW = dot(rgbSW, luma);
				float lumaSE = dot(rgbSE, luma);
				float lumaM  = dot(rgbM,  luma);
				
				float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
				float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

				
				vec2 dir; 
				dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
				dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));


				float dirReduce = max(
					(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
					FXAA_REDUCE_MIN);
				float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
				dir = min(FxaaFloat2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX), 
					  max(FxaaFloat2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), 
					  dir * rcpDirMin)) * rcpFrame.xy;


				vec3 rgbA = (1.0/2.0) * (
					FxaaTexLod0(tex, posPos.xy + dir * (1.0/3.0 - 0.5)).xyz +
					FxaaTexLod0(tex, posPos.xy + dir * (2.0/3.0 - 0.5)).xyz);
					
				vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
					FxaaTexLod0(tex, posPos.xy + dir * (0.0/3.0 - 0.5)).xyz +
					FxaaTexLod0(tex, posPos.xy + dir * (3.0/3.0 - 0.5)).xyz);
					
				float lumaB = dot(rgbB, luma);

				if ((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;

				return rgbB; 
			}
				
			void main() 
			{ 
			  out_color = texture(tex_diffuse, uv);
			  //out_color.rgb = vec3(pow(ssao(), 4));
			  out_color.rgb = FxaaPixelShader(posPos, tex_diffuse);
			 // out_color.rgb *= vec3(ssao());
			  out_color.a = 1;
			}
		]]  
	}
}

 
local sphere = NULL

function render.InitializeGBuffer(width, height)
	width = width or render.GetWidth()
	height = height or render.GetHeight()
	
	if width == 0 or height == 0 then return end
	
	logn("[render] initializing gbuffer: ", width, " ", height)
	
	render.gbuffer_config = {
		{
			name = "diffuse",
			attach = "color",
			texture_format = {
				internal_format = "RGB8",
			}
		},
		{
			name = "normal",
			attach = "color",
			texture_format = {
				internal_format = "RGB16F",
			}
		},
		{
			name = "position",
			attach = "color",
			texture_format = {
				internal_format = "RGB16F",
			}
		},
		{
			name = "specular",
			attach = "color",
			texture_format = {
				internal_format = "R8",
			}
		},
		--[[{{
			name = "light",
			attach = "color",
			texture_format = {
				internal_format = "RGB16F",
			}
		},]]
		{
			name = "depth",
			attach = "depth",
			draw_manual = true,
			texture_format = {
				internal_format = "DEPTH_COMPONENT32F",	 
				depth_texture_mode = gl.e.GL_ALPHA,
				
			} 
		} 
	} 
  
	render.gbuffer = render.CreateFrameBuffer(width, height, render.gbuffer_config)  
	
	if not render.gbuffer:IsValid() then
		logn("[render] failed to initialize gbuffer")
		return
	end

	local shader = render.CreateShader(SHADER)
	
	shader.pvm_matrix = render.GetPVWMatrix2D
	shader.pv_matrix = function() return (render.matrices.projection_3d*render.matrices.view_3d).m end
	shader.cam_pos = function() 
	return  render.GetCamPos() end
	shader.cam_vec = function() return render.GetCamAng():GetRad():GetForward() end
	shader.time = function() return tonumber(timer.GetSystemTime()) end
	 
	shader.tex_diffuse = render.gbuffer:GetTexture("diffuse")
	shader.tex_position = render.gbuffer:GetTexture("position") 
	shader.tex_normal = render.gbuffer:GetTexture("normal")
	shader.tex_specular = render.gbuffer:GetTexture("specular")
	shader.tex_depth = render.gbuffer:GetTexture("depth")
	shader.rt_w = width
	shader.rt_h = height

	local vbo = shader:CreateVertexBuffer({
		{pos = {0, 0}, uv = {0, 1}},
		{pos = {0, 1}, uv = {0, 0}},
		{pos = {1, 1}, uv = {1, 0}},

		{pos = {1, 1}, uv = {1, 0}},
		{pos = {1, 0}, uv = {1, 1}},
		{pos = {0, 0}, uv = {0, 1}},
	})
	
	render.gbuffer_shader = shader
	render.gbuffer_screen_quad = vbo
	
	render.pp_buffer = render.CreateFrameBuffer(width, height, {
		{
			name = "diffuse",
			attach = "color",
			texture_format = {
				internal_format = "RGBA8",
			}
		},
	}) 

	local shader = render.CreateShader(PPSHADER)
	shader.pvm_matrix = render.GetPVWMatrix2D

	shader.cam_pos = render.GetCamPos
	shader.tex_diffuse = render.pp_buffer:GetTexture("diffuse")
	shader.tex_depth = render.gbuffer:GetTexture("depth")
	shader.tex_position = render.gbuffer:GetTexture("position") 
	shader.tex_normal = render.gbuffer:GetTexture("normal")
	shader.rt_w = width
	shader.rt_h = height
	
	local vbo = shader:CreateVertexBuffer({
		{pos = {0, 0}, uv = {0, 1}},
		{pos = {0, 1}, uv = {0, 0}},
		{pos = {1, 1}, uv = {1, 0}},

		{pos = {1, 1}, uv = {1, 0}},
		{pos = {1, 0}, uv = {1, 1}},
		{pos = {0, 0}, uv = {0, 1}},
	})
	
	render.pp_screen_shader = shader
	render.pp_screen_quad = vbo
	
	event.AddListener("PreDisplay", "gbuffer", function()
		render.gbuffer:Begin()
		render.gbuffer:Clear()
	end)	
	
	event.AddListener("PostDisplay", "gbuffer", function()
		render.gbuffer:End()
		render.DrawGBuffer(render.GetWidth(), render.GetHeight())
	end)	

	event.AddListener("WindowFramebufferResized", "gbuffer", function(window, w, h)
		render.InitializeGBuffer(w, h)
	end)
	
	
	event.AddListener("Draw2D", "gbuffer_debug", function()
		local size = 4
		local w, h = surface.GetScreenSize()
		if render.debug then
			w = w / size
			h = h / size
			
			local x = 0
			local y = 0
			
			surface.SetColor(1,1,1,1)
			
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
	end)
end

function render.ShutdownGBuffer()
	event.RemoveListener("PreDisplay", "gbuffer")
	event.RemoveListener("PostDisplay", "gbuffer")
	event.RemoveListener("WindowFramebufferResized", "gbuffer")
	
	if render.gbuffer:IsValid() then
		render.gbuffer:Remove()
	end
	
	if render.gbuffer_shader:IsValid() then
		render.gbuffer_shader:Remove()
	end
	
	if render.gbuffer_screen_quad:IsValid() then
		render.gbuffer_screen_quad:Remove()
	end
	
	logn("[render] gbuffer shutdown")
end

local size = 4

function render.DrawGBuffer(w, h)
	render.Start3D()
	
	render.gbuffer:Begin()
	
	--gl.ActiveTextureARB(gl.e.GL_TEXTURE4)
	gl.Disable(gl.e.GL_DEPTH_TEST)
	gl.Disable(gl.e.GL_CULL_FACE)	
	
	if sphere:IsValid() then 
		gl.DrawBuffers(1, render.gbuffer.buffers.light.draw_enum)
		sphere:Draw()   
	end
	
	gl.Enable(gl.e.GL_DEPTH_TEST)
	gl.Enable(gl.e.GL_CULL_FACE)
	
	render.gbuffer:End()
		
	render.Start2D()
		-- draw to the pp buffer
		render.pp_buffer:Begin()
			render.PushWorldMatrix()
				surface.Scale(w, h)
				render.gbuffer_shader:Bind()
				render.gbuffer_screen_quad:Draw()
			render.PopWorldMatrix()		
		render.pp_buffer:End()
		
		-- draw the pp texture as quad
		render.PushWorldMatrix()
			surface.Scale(w, h)
			render.pp_screen_shader:Bind()
			render.pp_screen_quad:Draw()
		render.PopWorldMatrix()
		
		
	render.End2D()
end

local gbuffer_enabled = true

function render.EnableGBuffer(b)
	gbuffer_enabled = b
	if b then 
		render.InitializeGBuffer()
	else
		render.ShutdownGBuffer()
	end
end

if render.gbuffer_shader then
	render.InitializeGBuffer()
end

event.AddListener("RenderContextInitialized", nil, function() 
	local ok, err = xpcall(render.InitializeGBuffer, system.OnError)
	
	if not ok then
		logn("[render] failed to initialize gbuffer: ", err)
		render.ShutdownGBuffer()
	end
end)
