local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render

function render.GetGBufferSize()
	return Vec2(render.gbuffer_width or render.GetWidth(), render.gbuffer_height or render.GetHeight())
end

function render.CreateMesh(vertices, indices, is_valid_table)		
	return vertices and render.gbuffer_model_shader:CreateVertexBuffer(vertices, indices, is_valid_table) or NULL
end

local GBUFFER = {
	name = "gbuffer",
	vertex = {
		uniform = {
			pvm_matrix = {mat4 = render.GetPVWMatrix2D},
		},			
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = "gl_Position = pvm_matrix * vec4(pos, 0.0, 1.0);"
	},
	fragment = {
		uniform = {			
			screen_size = {vec2 = render.GetGBufferSize},			
			cam_nearz = {float = function() return render.camera.nearz end},
			cam_farz = {float = function() return render.camera.farz end},
			cam_fov = {float = function() return render.camera.fov end},
			inv_proj = {mat4 = function() return (render.matrices.projection_3d_inverse).m end},
			inv_proj_mat = {mat4 = function() return (render.matrices.view_3d * render.matrices.projection_3d).m end},
			inv_view_mat = {mat4 = function() return render.matrices.view_3d_inverse.m end},
			tex_noise = {sampler2D = render.GetNoiseTexture},
			
			fog_color = Color(0.9,0.9,0.9),
			fog_intensity = 256,
			fog_start = 0,
			fog_end = 32,
			 
			ao_amount = 1.0,
			ao_cap = 0.3,
			ao_multiplier = 1,
			ao_depthtolerance = -0.00001,
			ao_range = 100000.0,
			ao_scale = 0.6,
			
			gamma = 1.2;
			
			ambient_lighting = Color(0.3, 0.3, 0.3),
		},  
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = [[
			out vec4 out_color;
			
			vec3 get_pos(vec2 uv)
			{
				float z = -texture(tex_depth, uv).r;
				vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
				sPos = inv_proj * sPos;

				return sPos.xyz / sPos.w;
			}		
			
			float get_depth(vec2 coord) 
			{
				return (2.0 * cam_nearz) / (cam_farz + cam_nearz - texture(tex_depth, coord).r * (cam_farz - cam_nearz));
			}
			
			float get_depth2(vec2 coord, float start, float end) 
			{
				return (2.0 * start) / (end + start - texture(tex_depth, coord).r * (end - start));
			}
			
			//
			//SSAO
			//
			float compareDepths( in float depth1, in float depth2 ) {
				float diff = (depth2)-(depth1-0.000005);
				diff = clamp(diff *= 30000, 0, 0.25);
								
				return diff;
			}
			
			vec3 get_pos2(vec2 uv)
			{
				float z = -texture(tex_depth, uv).r;
				vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
				sPos = inv_proj_mat * sPos; 

				return (sPos.xyz / sPos.w);
			}

			float ssao()
			{

				float depth = get_depth(uv);
				
				if (depth > 0.05) return 1;
				
				float pw = 1.0 / screen_size.x;
				float ph = 1.0 / screen_size.y;

				float ao = 0;
				
				float aoscale = 2.2;
				
				pw /= aoscale;
				ph /= aoscale;
				
				for (int i = 1; i < 5; i++)
				{					
					ao += compareDepths(depth, get_depth(vec2(uv.x+pw,uv.y+ph)));
					ao += compareDepths(depth, get_depth(vec2(uv.x-pw,uv.y+ph)));
					ao += compareDepths(depth, get_depth(vec2(uv.x+pw,uv.y-ph)));
					ao += compareDepths(depth, get_depth(vec2(uv.x-pw,uv.y-ph)));
				 
					pw *= aoscale;
					ph *= aoscale;
				}			 
			 
				ao/=4.0;
			 
				return 0.5+clamp(ao*1.9, 0, 1)*0.5;
			}
			
			vec3 hbao() 
			{
				const float PI = 3.141592653589793238462643383279502884197169399375105820974944592;
				const float TWO_PI = 2.0 * PI;
				const int NUM_SAMPLE_DIRECTIONS = 5;
				const int NUM_SAMPLE_STEPS = 3;
				const float uIntensity = 1;
				const float uAngleBias = 0.5;
				const float radiusSS = 2;
				
				vec3 originVS = get_pos(uv);
				vec3 normalVS = texture(tex_normal, uv).xyz;
								
				float radiusWS = 1;
																
				const float theta = TWO_PI / float(NUM_SAMPLE_DIRECTIONS);
				float cosTheta = cos(theta);
				float sinTheta = sin(theta);
				
				mat2 deltaRotationMatrix = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
				
				vec2 deltaUV = vec2(1.0, 0.0) * (radiusSS / (float(NUM_SAMPLE_DIRECTIONS * NUM_SAMPLE_STEPS) + 1.0));
				vec4 sampleNoise = texture(tex_noise, uv*10);
				sampleNoise = sampleNoise * 2 - vec4(1);
				deltaUV = sampleNoise.xy * deltaUV;
				
				float jitter = sampleNoise.a;
				vec3 occlusion = vec3(1);
				
				for (int i = 0; i < NUM_SAMPLE_DIRECTIONS; ++i) {
					deltaUV = deltaRotationMatrix * deltaUV;
					
					vec2 sampleDirUV = deltaUV;
					float oldAngle = uAngleBias;
					
					for (int j = 0; j < NUM_SAMPLE_STEPS; ++j) {
						vec2 sampleUV = uv + (jitter + float(j)) * sampleDirUV;
						vec3 sampleVS = get_pos(sampleUV);
						vec3 sampleDirVS = -(originVS - sampleVS);
						
						if (sampleDirVS.z < radiusSS/4)
						{
											
							float gamma = (PI / 2.0) - acos(dot(normalVS, normalize(sampleDirVS)));
							
							if (gamma > oldAngle) 
							{
								float value = sin(gamma) - sin(oldAngle);
								
								occlusion -= value;

								oldAngle = gamma;
							}
						}
					}
				}
				
				//occlusion = occlusion / float(NUM_SAMPLE_DIRECTIONS);
				//occlusion = clamp(pow(occlusion, vec3(1.0 + uIntensity)), vec3(0.0), vec3(1.0));
				return 0.75+occlusion*0.25;
			}
			
			vec3 huh()
			{
				vec3 color = vec3(0,0,0);
				
				for (int i = 0; i < 8; i++)
				{
					vec3 a = get_pos(uv);
				}
				return color;
			}
			
			//
			//FOG
			//
			vec3 mix_fog(vec3 color)
			{
				if (fog_color.a == 0) return color;
			
				// THIS ISNT RIGHT
				if (fog_start > fog_end)
					color = mix(fog_color.rgb, color, clamp(get_depth2(uv, cam_nearz, fog_start) * fog_color.a, 0.0, 1.0));
				
				if (fog_start < fog_end)
					color = mix(fog_color.rgb, color, clamp((-get_depth2(uv, cam_nearz, fog_end)+1) * fog_color.a, 0.0, 1.0));
				
				
				return color;
			}
									
			void main ()
			{							
				out_color.rgb = texture(tex_diffuse, uv).rgb;
				out_color.a = 1;
								
				vec3 light = texture(tex_light, uv).rgb;
				if (out_color.rgb != vec3(0,0,0)) light *= ssao();
				//light *= ssao()
				light = max(light, ambient_lighting.rgb);
				
				out_color.rgb *= light;
				
				out_color.rgb = mix_fog(out_color.rgb);
				//out_color.rgb += texture(tex_lens_flare, uv).rgb;
				
				out_color.rgb = pow(out_color.rgb, vec3(gamma));
			}
		]]  
	} 
}  

render.gbuffer = render.gbuffer or NULL
render.gbuffer_passes = render.gbuffer_passes or {}

do -- post process
	render.pp_shaders = render.pp_shaders or {}
	render.pp_disabled_shaders = render.pp_disabled_shaders or {}
	
	local function solve_tex_last()
		for i, effect in ipairs(render.pp_shaders) do
			if i == 1 then 
				effect.shader.tex_last = render.screen_buffer:GetTexture("screen_buffer")
			else
				effect.shader.tex_last = render.pp_shaders[i - 1].buffer:GetTexture("tex_last")
			end
		end
	end
	function render.AddPostProcessShader(name, source, priority, down_sample, global_id)
		if type(source) == "table" then
			for i, v in ipairs(source) do
				v.priority = v.priority or #render.pp_shaders
				render.AddPostProcessShader(name .. "_" .. i, v.source, v.priority + i, v.down_sample, name)
			end
			return
		end

		priority = priority or #render.pp_shaders
		down_sample = down_sample or 1
		
		local width = render.gbuffer_width / down_sample
		local height = render.gbuffer_height / down_sample  
		
		local shader = {
			name = "gbuffer_post_process_" .. name,
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
					screen_size = "vec2",
					tex_gbuffer = "sampler2D",
					tex_last = "sampler2D",

					cam_nearz = {float = function() return render.camera.nearz end},
					cam_farz = {float = function() return render.camera.farz end},
					cam_fov = {float = function() return render.camera.fov end},
					inv_proj_mat = {mat4 = function() return (render.matrices.view_3d * render.matrices.projection_3d).m end},
					inv_view_mat = {mat4 = function() return render.matrices.view_3d_inverse.m end},
				},
				attributes = {
					{pos = "vec2"},
					{uv = "vec2"},
				},
				source = source
			}
		}
		for i, info in ipairs(render.gbuffer_buffers) do
			shader.fragment.uniform["tex_" .. info.name] = "sampler2D"
		end
		shader = render.CreateShader(shader)
		
		local buffer = render.CreateFrameBuffer(width, height, {
			{
				name = "tex_last",
				attach = "color",
				texture_format = {
					internal_format = "RGBA8",
					--mag_filter = "nearest",
					--min_filter = "nearest",
				}
			},
		})
		
		shader.pvm_matrix = render.GetPVWMatrix2D
		shader.tex_gbuffer = render.screen_buffer:GetTexture("screen_buffer")
		shader.screen_size = Vec2(width, height)
		
		for i, info in ipairs(render.gbuffer_buffers) do
			shader["tex_" .. info.name] = render.gbuffer:GetTexture(info.name)
		end
		
		shader.p_matrix_inverse = function() return ((render.matrices.view_3d * render.matrices.projection_3d):GetInverse()).m end
			
		local quad = shader:CreateVertexBuffer({
			{pos = {0, 0}, uv = {0, 1}},
			{pos = {0, 1}, uv = {0, 0}},
			{pos = {1, 1}, uv = {1, 0}},

			{pos = {1, 1}, uv = {1, 0}},
			{pos = {1, 0}, uv = {1, 1}},
			{pos = {0, 0}, uv = {0, 1}},
		})

		for k, v in pairs(render.pp_shaders) do
			if v.name == name then
				render.pp_shaders[k] = nil
			end
		end
		table.fixindices(render.pp_shaders)
		
		global_id = global_id or name
		
		table.insert(render.pp_shaders, {
			shader = shader, 
			quad = quad, 
			buffer = buffer, 
			name = name, 
			priority = priority, 
			w = width, 
			h = height, 
			down_sample = down_sample,
			global_id = global_id,
			cvar = console.CreateVariable("render_pp_" .. global_id, true, function(val)
				if val then
					for k, v in pairs(render.pp_disabled_shaders) do
						if v.global_id == global_id then
							table.insert(render.pp_shaders, v)
							render.pp_disabled_shaders[k] = nil
						end
					end
				else
					for k, v in pairs(render.pp_shaders) do
						if v.global_id == global_id then
							render.pp_disabled_shaders[v.name] = v
							render.pp_shaders[k] = nil
						end
					end
					
					table.fixindices(render.pp_shaders)
				end
				
				table.sort(render.pp_shaders, function(a, b) return a.priority < b.priority end)
				
				solve_tex_last()
			end),
		})
		
		table.sort(render.pp_shaders, function(a, b) return a.priority < b.priority end)		
		
		solve_tex_last()
	end
end

function render.CreateGBufferPass(name, stage) 
	for i, pass in pairs(render.gbuffer_passes) do 
		if pass.name == name then 
			table.remove(render.gbuffer_passes, i) 
			break 
		end
	end
	
	local PASS = {}
	
	PASS.name = name
	PASS.stage = stage or math.huge
	PASS.shader = {}
	PASS.shader.name = "gbuffer_" .. name
	PASS.buffers = {}
	
	function PASS:ShaderStage(name, stage)
		self.shader[name] = stage
	end
	
	function PASS:AddBuffer(name, format, attach)
		table.insert(self.buffers, {name = name, format = format, attach = attach})
	end
	
	table.insert(render.gbuffer_passes, PASS)
		
	table.sort(render.gbuffer_passes, function(a, b) return a.stage < b.stage end)
	
	return PASS
end
 
local w_cvar = console.CreateVariable("render_width", 0, function() render.InitializeGBuffer() end)
local h_cvar = console.CreateVariable("render_height", 0, function() render.InitializeGBuffer() end)
 
function render.InitializeGBuffer(width, height)
	width = width or render.GetWidth()
	height = height or render.GetHeight()
	
	if w_cvar:Get() > 0 then width = w_cvar:Get() end
	if h_cvar:Get() > 0 then height = h_cvar:Get() end
	
	if width == 0 or height == 0 then return end
		
	render.gbuffer_width = width
	render.gbuffer_height = height
	
	if render.debug then
		warning("initializing gbuffer: ", width, " ", height)
	end 
	
	do -- gbuffer	  
		render.gbuffer_buffers = {
			{
				name = "depth",
				attach = "depth",
				draw_manual = true,
				texture_format = {
					internal_format = "DEPTH_COMPONENT32F",	 
					depth_texture_mode = gl.e.GL_RED,
				} 
			} 
		}
	
		for _, pass in pairs(render.gbuffer_passes) do
			for _, buffer in pairs(pass.buffers) do
				table.insert(render.gbuffer_buffers, #render.gbuffer_buffers, {
					name = buffer.name,
					attach = buffer.attach or "color",
					texture_format = {
						internal_format = buffer.format or "RGB16F",
						--mag_filter = "nearest",
						--min_filter = "nearest",
					},
				})
			end
		end
	
		render.gbuffer = render.CreateFrameBuffer(width, height, render.gbuffer_buffers)  
		
		if not render.gbuffer:IsValid() then
			warning("failed to initialize gbuffer")
			return
		end
		
		for i, info in ipairs(render.gbuffer_buffers) do
			GBUFFER.fragment.uniform["tex_" .. info.name] = "sampler2D"
		end

		local shader = render.CreateShader(GBUFFER)
				 
		for i, info in ipairs(render.gbuffer_buffers) do
			shader["tex_" .. info.name] = render.gbuffer:GetTexture(info.name)
		end

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
	end
	
	do -- post process
		render.screen_buffer = render.CreateFrameBuffer(width, height, {
			{
				name = "screen_buffer",
				attach = "color",
				texture_format = {
					internal_format = "RGBA8",
					--mag_filter = "nearest",
					--min_filter = "nearest",
				}
			},
		})

		include("libraries/graphics/render/post_process/*")
	end
		
	for _, pass in pairs(render.gbuffer_passes) do
		local shader = render.CreateShader(pass.shader)
		for i, info in ipairs(render.gbuffer_buffers) do
			shader["tex_" .. info.name] = render.gbuffer:GetTexture(info.name)
		end
		render["gbuffer_" .. pass.name .. "_shader"] = shader
	end
				
	event.AddListener("WindowFramebufferResized", "gbuffer", function(window, w, h)
		render.InitializeGBuffer(w, h)
	end)
	
	event.AddListener("Draw2D", "gbuffer_debug", function()
		local size = 4
		local w, h = surface.GetSize()
		if render.debug then
			w = w / size
			h = h / size
			
			local x = 0
			local y = 0
						
			local grey = 0.5 + math.sin(os.clock() * 10) / 10
			surface.SetFont("default")
			
			for i, data in pairs(render.gbuffer_buffers) do
				surface.SetWhiteTexture()
				surface.SetColor(grey, grey, grey, 1)
				surface.DrawRect(x, y, w, h)
				surface.SetRectUV(0,0,1,1)
				
				surface.SetColor(1,1,1,1)
				surface.SetTexture(render.gbuffer:GetTexture(data.name))
				surface.DrawRect(x, y, w, h)
				
				surface.SetTextPosition(x, y + 5)
				surface.DrawText(data.name)
				
				if i%size == 0 then
					y = y + h
					x = 0
				else
					x = x + w
				end
			end
			
			local i = 1
			
			for _, pass in ipairs(render.gbuffer_passes) do
				if pass.DrawDebug then 
					i,x,y,w,h = pass:DrawDebug(i,x,y,w,h,size) 
				end
			end
		end
	end)
	
	event.Call("GBufferInitialized")
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
	
	warning("gbuffer shutdown")
end

local size = 4
local deferred = console.CreateVariable("render_deferred", true, "whether or not deferred rendering is enabled.")
local gbuffer_enabled = true

function render.DrawDeferred(dt, w, h)

	if not gbuffer_enabled or not deferred:Get() then
		render.Clear(1,1,1,1)
		gl.DepthMask(gl.e.GL_TRUE)
		gl.Enable(gl.e.GL_DEPTH_TEST)
		gl.Disable(gl.e.GL_BLEND)
		event.Call("Draw3DGeometry", render.gbuffer_model_shader)
		
		gl.Disable(gl.e.GL_DEPTH_TEST)	
		gl.Enable(gl.e.GL_BLEND)
		render.SetBlendMode("alpha")	
		render.SetCullMode("back")
		gl.Disable(gl.e.GL_DEPTH_TEST)
		render.Start2D()
			event.Call("Draw2D", dt)
		render.End2D()
	return end
	
	render.Start3D()
		for i, pass in ipairs(render.gbuffer_passes) do
			if pass.Draw3D then 
				pass:Draw3D() 
			end
		end
	render.End3D()
			
	-- gbuffer
	render.SetBlendMode("alpha")	
	render.SetCullMode("back")
	render.Start2D()
	
		for i, pass in ipairs(render.gbuffer_passes) do
			if pass.Draw2D then 
				pass:Draw2D() 
			end
		end
	
		if render.pp_shaders[1] and false then		
		
			-- copy the gbuffer to the screen buffer
			surface.PushMatrix(0,0,w,h)
				render.screen_buffer:Begin()
					render.gbuffer_shader:Bind()
					render.gbuffer_screen_quad:Draw()
				render.screen_buffer:End()
			surface.PopMatrix()
			
			for i, effect in ipairs(render.pp_shaders) do
				local next = render.pp_shaders[i + 1]
				
				if next then
					-- render this effect onto the next effects tex_last buffer
					
					surface.PushMatrix()
					surface.Scale(effect.w, effect.h)	
						next.buffer:Begin()
							effect.shader:Bind()
							effect.quad:Draw()
						next.buffer:End()
					surface.PopMatrix()
				else
					-- if this is the last effectr then draw it onto the main window's buffer
					
					surface.PushMatrix()
					surface.Scale(w, h)
						effect.shader:Bind()
						effect.quad:Draw()
					surface.PopMatrix()
				end
			end
		else		
			surface.PushMatrix()
				surface.Scale(w, h)
				render.gbuffer_shader:Bind()
				render.gbuffer_screen_quad:Draw()
			surface.PopMatrix()
		end	
						
		event.Call("Draw2D", dt)
	render.End2D()
end

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
		warning("failed to initialize gbuffer: ", err)
		render.EnableGBuffer(false)
	end
end)
