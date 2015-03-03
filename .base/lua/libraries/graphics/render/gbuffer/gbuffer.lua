local gl = require("lj-opengl") -- OpenGL
local render = (...) or _G.render

render.AddGlobalShaderCode([[
float random(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}]], "random")

render.AddGlobalShaderCode([[
vec4 get_noise(vec2 uv)
{
	return texture(lua[(sampler2D)render.GetNoiseTexture], uv);
}]], "get_noise")

render.AddGlobalShaderCode([[
vec2 get_screen_uv()
{
	return gl_FragCoord.xy / g_screen_size;
}]], "get_screen_uv")
 
render.AddGlobalShaderCode([[
vec2 g_poisson_disk[4] = vec2[](
	vec2( -0.94201624, -0.39906216 ),
	vec2( 0.94558609, -0.76890725 ),
	vec2( -0.094184101, -0.92938870 ),
	vec2( 0.34495938, 0.29387760 )
);]], "g_poisson_disk")

function render.GetGBufferSize()
	return Vec2(render.gbuffer_width or render.GetWidth(), render.gbuffer_height or render.GetHeight())
end

function render.CreateMesh(vertices, indices, is_valid_table)		
	return render.gbuffer_model_shader:CreateVertexBuffer(vertices, indices, is_valid_table)
end

render.gbuffer = render.gbuffer or NULL
render.gbuffer_passes = render.gbuffer_passes or {}
render.gbuffer_shaders_ = render.gbuffer_shaders_ or {}
render.gbuffer_values = render.gbuffer_values or {}
render.gbuffer_shaders = render.gbuffer_shaders or {}

function render.RegisterGBufferPass(PASS)
	for i, pass in ipairs(render.gbuffer_passes) do 
		if pass.Name == PASS.Name then 
			table.remove(render.gbuffer_passes, i) 
			break 
		end
	end
		
	PASS.Stage = tonumber(PASS.Stage) or 0
	PASS.Shader.name = PASS.Name
		
	table.insert(render.gbuffer_passes, PASS)
		
	table.sort(render.gbuffer_passes, function(a, b) return a.Stage < b.Stage end)
	
	if RELOAD then
		render.InitializeGBuffer()
	end
end

do -- mixer
	function render.SetGBufferValue(key, var)
		render.gbuffer_values[key] = var
		
		for k, shader in pairs(render.gbuffer_shaders) do
			if shader[key] then
				shader[key] = var
			end
		end
	end

	function render.GetGBufferValue(key)
		return render.gbuffer_values[key]
	end

	function render.DrawGBufferShader(name)
		local shader = render.gbuffer_shaders[name]
		if shader then	
			if shader.gbuffer_pass.Update then
				shader.gbuffer_pass:Update()
			end
			render.gbuffer_mixer_buffer:Begin()		
				surface.PushMatrix(0, 0, render.GetWidth(), render.GetHeight())
					shader:Bind()
					surface.rect_mesh:Draw()
				surface.PopMatrix()
			render.gbuffer_mixer_buffer:End()	
			if shader.gbuffer_pass.PostRender then
				shader.gbuffer_pass:PostRender()
			end
		end
	end
	
	render.gbuffer_shaders_sorted = render.gbuffer_shaders_sorted or {}

	function render.AddGBufferShader(PASS)
		local shader = {
			name = PASS.Name,
			vertex = {
				uniform = {
					pwm_matrix = {mat4 = render.GetProjectionViewWorld2DMatrix}
				},			
				attributes = {
					{pos = "vec2"},
					{uv = "vec2"},
				},	
				source = "gl_Position = pwm_matrix * vec4(pos, 0, 1);"
			},
			
			fragment = { 
				uniform = {
					cam_nearz = {float = function() return render.camera.nearz end},
					cam_farz = {float = function() return render.camera.farz end},
					self = {texture = function() return render.gbuffer_mixer_buffer:GetTexture() end},
				},
				attributes = {
					{uv = "vec2"},
				},			
				source = PASS.Source
			}
		}
		
		for i, info in ipairs(render.gbuffer_buffers) do
			local name = "tex_" .. info.name
			if PASS.Source:find(name) then
				shader.fragment.uniform[name] = {texture = function() return render.gbuffer:GetTexture(info.name) end}
			end
		end
			
		if PASS.Variables then
			table.merge(shader.fragment.uniform, PASS.Variables)
		end
		
		render.gbuffer_shaders_[PASS.Name] = PASS
		
		function PASS:__init()
			self.__init = nil
			
			local shader = render.CreateShader(shader)
			
			render.gbuffer_shaders[PASS.Name] = shader

			if PASS.Variables then
				shader.gbuffer_values = PASS.Variables
			end
			
			shader.gbuffer_pass = PASS
			shader.gbuffer_name = PASS.Name
			shader.gbuffer_position = tonumber(PASS.Position) or #render.gbuffer_shaders_sorted
			
			for k,v in pairs(render.gbuffer_values) do
				render.SetGBufferValue(k,v)
			end

			for k,v in pairs(render.gbuffer_shaders_sorted) do
				if v.gbuffer_name == PASS.Name then
					table.remove(render.gbuffer_shaders_sorted, k)
					break
				end
			end
			
			table.insert(render.gbuffer_shaders_sorted, shader)
			
			table.sort(render.gbuffer_shaders_sorted, function(a, b)
				return a.gbuffer_position < b.gbuffer_position
			end)
			
			PASS.shader = shader
			
			if PASS.Initialize then
				local ok, err = pcall(function() PASS:Initialize() end)
				if not ok then
					logn("failed to initialize gbuffer pass ", PASS.Name, ": ", err)
					render.RemoveGBufferShader(PASS.Name)
				end
			end

			if not console.IsVariableAdded("render_g_" .. PASS.Name) then			
				local pass = table.copy(PASS)
				local default = PASS.Default
				
				if default == nil then
					default = true
				end
						
				console.CreateVariable("render_g_" .. pass.Name, default, function(val)
					if val then
						render.AddGBufferShader(pass)
					else
						render.RemoveGBufferShader(pass.Name)
					end
				end)
			end
			
			if not console.GetVariable("render_g_" .. PASS.Name) then
				render.RemoveGBufferShader(PASS.Name)
			end
		end
		
		if RELOAD then PASS:__init() end
	end
	
	function render.RemoveGBufferShader(name)
		render.gbuffer_shaders[name] = nil
		for k,v in pairs(render.gbuffer_shaders_sorted) do
			if v.gbuffer_name == name then
				table.remove(render.gbuffer_shaders_sorted, k)
				break
			end
		end
	end
end
 
local w_cvar = console.CreateVariable("render_width", 0, function() render.InitializeGBuffer() end)
local h_cvar = console.CreateVariable("render_height", 0, function() render.InitializeGBuffer() end)
 
function render.InitializeGBuffer(width, height)
	if not RELOAD then
		include("libraries/graphics/render/gbuffer/passes/*")
	end

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
		
		render.SetGlobalShaderVariable("tex_depth", function() return render.gbuffer:GetTexture("depth") end, "texture")
	
		for _, pass in ipairs(render.gbuffer_passes) do
			if pass.Buffers then
				for _, args in ipairs(pass.Buffers) do
					local name, format, attach = unpack(args)
					
					attach = attach or "color"
					format = format or "RGB16F"
					
					render.SetGlobalShaderVariable("tex_" .. name, function() return render.gbuffer:GetTexture(name) end, "texture")
					
					table.insert(render.gbuffer_buffers, #render.gbuffer_buffers, {
						name = name,
						attach = attach,
						texture_format = {
							internal_format = format,
							--mag_filter = "nearest",
							--min_filter = "nearest",
						},
					})
				end
			end
		end
	
		render.gbuffer = render.CreateFrameBuffer(width, height, render.gbuffer_buffers)  
		render.gbuffer_mixer_buffer = render.CreateFrameBuffer(width, height)  
		
		if not render.gbuffer:IsValid() then
			warning("failed to initialize gbuffer")
			return
		end
	end
	
	render.screen_buffer = render.CreateFrameBuffer(width, height, {
		{
			name = "screen_buffer",
			attach = "color",
			texture_format = {
				internal_format = "RGB32F",
				--mag_filter = "nearest",
				--min_filter = "nearest",
			}
		},
	})
	
	for k,v in pairs(render.gbuffer_shaders_) do
		if v.__init then
			v:__init()
		end
	end
	
	table.clear(render.gbuffer_shaders_)
		
	for _, pass in ipairs(render.gbuffer_passes) do
		local shader = render.CreateShader(pass.Shader)
		for i, info in ipairs(render.gbuffer_buffers) do
			shader["tex_" .. info.name] = render.gbuffer:GetTexture(info.name)
		end
		render["gbuffer_" .. pass.Name .. "_shader"] = shader
	end
				
	event.AddListener("WindowFramebufferResized", "gbuffer", function(window, w, h)
		render.InitializeGBuffer(w, h)
	end)
	
	do -- eww
		local size = 4
		local x,y,w,h,i
		
		local function draw_buffer(name, tex, bg)
			if name == "diffuse" or name == "normal" then surface.mesh_2d_shader.color_override.a = 1 end
			surface.SetColor(1,1,1,1)
			surface.SetTexture(tex)
			surface.DrawRect(x, y, w, h)
			if name == "diffuse" or name == "normal" then surface.mesh_2d_shader.color_override.a = 0 end
			
			surface.SetTextPosition(x, y + 5)
			surface.DrawText(name)
			
			if i%size == 0 then
				y = y + h
				x = 0
			else
				x = x + w
			end
			
			i = i  + 1
		end
		
		event.AddListener("DrawHUD", "gbuffer_debug", function()
			if render.debug then
				w, h = surface.GetSize()
				w = w / size
				h = h / size
				
				x= 0
				y = 0
				i = 1
				
				local grey = 0.5 + math.sin(os.clock() * 10) / 10
				surface.SetFont("default")
							
				for _, data in pairs(render.gbuffer_buffers) do
					draw_buffer(data.name, render.gbuffer:GetTexture(data.name))
				end
				
				
				surface.SetColor(0,0,0,1)
				surface.SetTexture(tex)
				surface.DrawRect(x, y, w, h)
				surface.mesh_2d_shader.color_override.r = 1
				surface.mesh_2d_shader.color_override.g = 1
				surface.mesh_2d_shader.color_override.b = 1				
				draw_buffer("roughness", render.gbuffer:GetTexture("diffuse"), true)
				surface.mesh_2d_shader.color_override.r = 0
				surface.mesh_2d_shader.color_override.g = 0
				surface.mesh_2d_shader.color_override.b = 0
				
				surface.SetColor(0,0,0,1)
				surface.SetTexture(tex)
				surface.DrawRect(x, y, w, h)
				surface.mesh_2d_shader.color_override.r = 1
				surface.mesh_2d_shader.color_override.g = 1
				surface.mesh_2d_shader.color_override.b = 1				
				draw_buffer("metallic", render.gbuffer:GetTexture("normal"), true)
				surface.mesh_2d_shader.color_override.r = 0
				surface.mesh_2d_shader.color_override.g = 0
				surface.mesh_2d_shader.color_override.b = 0
								
				for _, pass in ipairs(render.gbuffer_passes) do
					if pass.DrawDebug then 
						i,x,y,w,h = pass:DrawDebug(i,x,y,w,h,size) 
					end
				end
			end
		end)
	end
	
	if not RELOAD then
		include("libraries/graphics/render/gbuffer/post_process/*")
	end
	
	for k,v in pairs(render.gbuffer_values) do
		render.SetGBufferValue(k,v)
	end
	
	event.Call("GBufferInitialized")	
end

function render.ShutdownGBuffer()
	event.RemoveListener("PreDisplay", "gbuffer")
	event.RemoveListener("PostDisplay", "gbuffer")
	event.RemoveListener("WindowFramebufferResized", "gbuffer")
	
	if render.gbuffer:IsValid() then
		render.gbuffer:Remove()
	end
		
	warning("gbuffer shutdown")
end

local size = 4
local deferred = console.CreateVariable("render_deferred", true, "whether or not deferred rendering is enabled.")
local gbuffer_enabled = true

function render.DrawGBuffer(dt, w, h)

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
			
	--render.Clear(1,1,1,1)		
	
	-- gbuffer
	render.SetBlendMode("alpha")	
	render.SetCullMode("back")
	render.Start2D()
		for i, pass in ipairs(render.gbuffer_passes) do
			if pass.Draw2D then 
				pass:Draw2D() 
			end
		end
		
		for i, shader in ipairs(render.gbuffer_shaders_sorted) do
			render.DrawGBufferShader(shader.gbuffer_name)
		end

		surface.SetTexture(render.gbuffer_mixer_buffer:GetTexture())
		surface.SetColor(1,1,1,1)
		surface.DrawRect(0, 0, w, h)		
		
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

event.AddListener("RenderContextInitialized", nil, function() 
	local ok, err = xpcall(render.InitializeGBuffer, system.OnError)
	
	if not ok then
		warning("failed to initialize gbuffer: ", err)
		render.EnableGBuffer(false)
	end
end)
