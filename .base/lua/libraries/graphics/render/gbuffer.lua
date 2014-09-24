local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render

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
			screen_size = {vec2 = render.GetScreenSize},			
			cam_nearz = {float = function() return render.camera.nearz end},
			cam_farz = {float = function() return render.camera.farz end},
			cam_fov = {float = function() return math.rad(render.camera.fov) end},
			inv_proj = {mat4 = function() return (render.matrices.projection_3d_inverse).m end},
			inv_proj_mat = {mat4 = function() return (render.matrices.view_3d * render.matrices.projection_3d).m end},
			inv_view_mat = {mat4 = function() return render.matrices.view_3d_inverse.m end},
			tex_noise = {sampler2D = render.GetNoiseTexture},
		},  
		attributes = {
			{pos = "vec2"},
			{uv = "vec2"},
		},
		source = [[
			out vec4 out_color;
			
			vec3 get_pos(vec2 uv)
			{
				float z = -texture2D(tex_depth, uv).r;
				vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
				sPos = inv_proj * sPos;

				return sPos.xyz / sPos.w;
			}		
			
			float get_depth(vec2 coord) 
			{
				return (2.0 * cam_nearz) / (cam_farz + cam_nearz - texture2D(tex_depth, coord).r * (cam_farz - cam_nearz));
			}
			
			//
			//SSAO
			//
			float compareDepths( in float depth1, in float depth2 ) {
				float aoCap = 0.25;
				float aoMultiplier=1500.0;
				float depthTolerance=0.0000;
				float aorange = 100000.0;// units in space the AO effect extends to (this gets divided by the camera far range
				float diff = sqrt( clamp(1.0-(depth1-depth2) / (aorange/(cam_farz-cam_nearz)),0.0,1.0) );
				float ao = min(aoCap,max(0.0,depth1-depth2-depthTolerance) * aoMultiplier) * diff;
				return ao;
			}
			
			vec3 reconstruct_pos(vec2 uv)
			{
				float z = texture(tex_depth, uv).r;
				vec4 sPos = vec4(uv * 2.0 - 1.0, z, 1.0);
				sPos = inv_proj_mat * sPos;

				return (sPos.xyz / sPos.w);
			}

			float ssao()
			{

				float depth = get_depth(uv);
				float d;

				float pw = 1.0 / screen_size.x;
				float ph = 1.0 / screen_size.y;

				float ao = 2;
				
				float aoscale=0.4;

				for (int i = 1; i < 5; i++)
				{					
					ao += compareDepths(depth, get_depth(vec2(uv.x+pw,uv.y+ph))) / aoscale;
					ao += compareDepths(depth, get_depth(vec2(uv.x-pw,uv.y+ph))) / aoscale;
					ao += compareDepths(depth, get_depth(vec2(uv.x+pw,uv.y-ph))) / aoscale;
					ao += compareDepths(depth, get_depth(vec2(uv.x-pw,uv.y-ph))) / aoscale;
				 
					pw *= 2.0;
					ph *= 2.0;
					aoscale *= 1.2;
				}			 
			 
				ao/=16.0;
			 
				return 1-ao;
			}
			
			float hbao() 
			{
				const float PI = 3.141592653589793238462643383279502884197169399375105820974944592;
				const float TWO_PI = 2.0 * PI;
				const int NUM_SAMPLE_DIRECTIONS = 3;
				const int NUM_SAMPLE_STEPS = 2;
				const float uIntensity = 1;
				const float uAngleBias = 0.5;
				const float radiusSS = 1;
				
				vec3 originVS = reconstruct_pos(uv);
				vec3 normalVS = texture(tex_normal, uv).yxz;
								
				float radiusWS = (-get_depth(uv)+1)*4; 
								
				// early exit if the radius of influence is smaller than one fragment
				// since all samples would hit the current fragment.
								
				const float theta = TWO_PI / float(NUM_SAMPLE_DIRECTIONS);
				float cosTheta = cos(theta);
				float sinTheta = sin(theta);
				
				// matrix to create the sample directions
				mat2 deltaRotationMatrix = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
				
				// step vector in view space
				vec2 deltaUV = vec2(1.0, 0.0) * (radiusSS / (float(NUM_SAMPLE_DIRECTIONS * NUM_SAMPLE_STEPS) + 1.0));
				
				// we don't want to sample to the perimeter of R since those samples would be 
				// omitted by the distance attenuation (W(R) = 0 by definition)
				// Therefore we add a extra step and don't use the last sample.
				vec4 sampleNoise = texture2D(tex_noise, uv * 4);
				sampleNoise = sampleNoise * 2.0 - vec4(1.0);
				//mat2 rotationMatrix = mat2(sampleNoise.x, -sampleNoise.y, sampleNoise.y, sampleNoise.x);
				
				// apply a random rotation to the base step vector
				deltaUV = sampleNoise.xy * deltaUV;
				
				float jitter = sampleNoise.a;
				float occlusion = 0;
				
				for (int i = 0; i < NUM_SAMPLE_DIRECTIONS; ++i) {
					// incrementally rotate sample direction
					deltaUV = deltaRotationMatrix * deltaUV;
					
					vec2 sampleDirUV = deltaUV;
					float oldAngle = uAngleBias;
					
					for (int j = 0; j < NUM_SAMPLE_STEPS; ++j) {
						vec2 sampleUV = uv + (jitter + float(j)) * sampleDirUV;
						vec3 sampleVS = reconstruct_pos(sampleUV);
						vec3 sampleDirVS = (sampleVS - originVS);
						
						// angle between fragment tangent and the sample
						float gamma = (PI / 2.0) - acos(dot(normalVS, normalize(sampleDirVS)));
						
						if (gamma > oldAngle) 
						{
							float value = sin(gamma) - sin(oldAngle);
							
							// distance between original and sample points
							float attenuation = clamp(1.0 - pow(length(sampleDirVS) / radiusWS, 2.0), 0.0, 1.0);
							occlusion += attenuation * value;
							
							//occlusion += value;

							oldAngle = gamma;
						}
					}
				}
				
				occlusion = 1.0 - occlusion / float(NUM_SAMPLE_DIRECTIONS);
				occlusion = clamp(pow(occlusion, 1.0 + uIntensity), 0.0, 1.0);
				return occlusion;
			}
			
			//
			//FOG
			//
			vec3 mix_fog(vec3 color, float depth, float fog_intensity, vec3 fog_color)
			{
				color = mix( 1 - fog_color, color, clamp(1.0 - (pow(depth, fog_intensity)), 0.0, 1.0));
				
				return color;
			}
									
			void main ()
			{			
				vec3 diffuse = texture(tex_diffuse, uv).rgb;
				
				out_color.rgb = diffuse;
				out_color.a = 1;
								
				out_color.rgb *= vec3(ssao());
				out_color.rgb *= texture(tex_light, uv).rgb;								
			}
		]]  
	}
}  


render.gbuffer = render.gbuffer or NULL
render.gbuffer_passes = render.gbuffer_passes or {}

do -- post process
	render.pp_shaders = render.pp_shaders or {}
	render.pp_disabled_shaders = render.pp_disabled_shaders or {}

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
		
		local width = render.GetWidth() / down_sample
		local height = render.GetHeight() / down_sample  
		
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
					cam_fov = {float = function() return math.rad(render.camera.fov) end},
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
				}
			},
		})
		
		shader.pvm_matrix = render.GetPVWMatrix2D
		shader.tex_last = buffer:GetTexture("tex_last")
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
			end),
		})
		
		table.sort(render.pp_shaders, function(a, b) return a.priority < b.priority end)
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
 
function render.InitializeGBuffer(width, height)
	width = width or render.GetWidth()
	height = height or render.GetHeight()
	
	if width == 0 or height == 0 then return end
	
	if render.debug then
		logn("[render] initializing gbuffer: ", width, " ", height)
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
					},
				})
			end
		end
	
		render.gbuffer = render.CreateFrameBuffer(width, height, render.gbuffer_buffers)  
		
		if not render.gbuffer:IsValid() then
			logn("[render] failed to initialize gbuffer")
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
		local w, h = surface.GetScreenSize()
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
				
				surface.SetTextPos(x, y + 5)
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
local deferred = console.CreateVariable("render_deferred", true, "whether or not deferred rendering is enabled.")
local gbuffer_enabled = true

function render.DrawDeferred(dt, w, h)

	if not gbuffer_enabled or not deferred:Get() then
		render.Clear(1,1,1,1)
		gl.DepthMask(gl.e.GL_TRUE)
		gl.Enable(gl.e.GL_DEPTH_TEST)
		gl.Disable(gl.e.GL_BLEND)
		event.Call("Draw3DGeometry", render.gbuffer_mesh_shader)
		
		gl.Disable(gl.e.GL_DEPTH_TEST)	
		gl.Enable(gl.e.GL_BLEND)
		render.SetBlendMode("alpha")	
		render.SetCullMode("back")
		gl.Disable(gl.e.GL_DEPTH_TEST)
		event.Call("Draw2D", dt)
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
		-- draw to the pp buffer		
		local effect = render.pp_shaders[1]
		
		local shader
		local quad
		
		if effect then		
			-- copy the gbuffer to the screen buffer
			surface.PushMatrix(0,0,w,h)
				render.screen_buffer:Begin()
					render.gbuffer_shader:Bind()
					render.gbuffer_screen_quad:Draw()
				render.screen_buffer:End()
			surface.PopMatrix()
		
			local max = #render.pp_shaders
			
			if max == 1 then
				effect.shader.tex_last = render.screen_buffer:GetTexture("screen_buffer")
			else
				for i = 0, max do 
					local next = render.pp_shaders[i+1]
					if not next then break end
					
					surface.PushMatrix()
					surface.Scale(next.w, next.h)						
				
						next.buffer:Begin()
							effect.shader:Bind()
							effect.quad:Draw()
						next.buffer:End()
					
					surface.PopMatrix()
					effect = next
					effect.shader.tex_last = effect.buffer:GetTexture("tex_last")
				end		
			end

			shader = effect.shader
			quad = effect.quad
		else
			shader = render.gbuffer_shader
			quad = render.gbuffer_screen_quad
		end	
		
		surface.PushMatrix()
			surface.Scale(w, h)
			shader:Bind()
			quad:Draw()
		surface.PopMatrix()
						
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
		logn("[render] failed to initialize gbuffer: ", err)
		render.ShutdownGBuffer()
	end
end)
