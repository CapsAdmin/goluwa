local gl = require("graphics.ffi.opengl") -- OpenGL
local render = (...) or _G.render

render.AddGlobalShaderCode([[
float random(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}]])

render.AddGlobalShaderCode([[
vec4 get_noise(vec2 uv)
{
	return texture(lua[(sampler2D)render.GetNoiseTexture], uv);
}]])

render.AddGlobalShaderCode([[
vec2 get_screen_uv()
{
	return gl_FragCoord.xy / g_screen_size;
}]])
 
render.AddGlobalShaderCode([[
vec2 g_poisson_disk[4] = vec2[](
	vec2( -0.94201624, -0.39906216 ),
	vec2( 0.94558609, -0.76890725 ),
	vec2( -0.094184101, -0.92938870 ),
	vec2( 0.34495938, 0.29387760 )
);]])

render.gbuffer_size = Vec2(1,1)

function render.GetGBufferSize()	
	return render.gbuffer_size
end

render.SetGlobalShaderVariable("g_screen_size", render.GetGBufferSize, "vec2") 

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
	
	render.gbuffer_shaders_sorted = render.gbuffer_shaders_sorted or {}

	function render.AddGBufferShader(PASS, init_now)
		local shader = {
			name = "pp_" .. PASS.Name,
			vertex = {
				mesh_layout = {
					{pos = "vec3"},
					{uv = "vec2"},
				},	
				source = "gl_Position = g_projection_view_world_2d * vec4(pos, 1);"
			},
			
			fragment = { 
				variables = {
					cam_nearz = {float = function() return render.camera_3d.NearZ end},
					cam_farz = {float = function() return render.camera_3d.FarZ end},
					self = {texture = function() return render.gbuffer_mixer_buffer:GetTexture() end},
				},
				mesh_layout = {
					{uv = "vec2"},
				},			
				source = PASS.Source
			}
		}
		
		for i, info in ipairs(render.gbuffer_buffers) do
			local name = "tex_" .. info.name
			if PASS.Source:find(name) then
				shader.fragment.variables[name] = {texture = function() return render.gbuffer:GetTexture(info.name) end}
			end
		end
			
		if PASS.Variables then
			table.merge(shader.fragment.variables, PASS.Variables)
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

			if not console.IsVariableAdded("render_pp_" .. PASS.Name) then			
				local pass = table.copy(PASS)
				local default = PASS.Default
				
				if default == nil then
					default = true
				end
						
				console.CreateVariable("render_pp_" .. pass.Name, default, function(val)
					if val then
						render.AddGBufferShader(pass, true)
					else
						render.RemoveGBufferShader(pass.Name)
					end
				end)
			end
			
			if not console.GetVariable("render_pp_" .. PASS.Name) then
				render.RemoveGBufferShader(PASS.Name)
			end
		end
		
		if init_now or RELOAD then PASS:__init() end
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
 
local gbuffer_enabled = false
local w_cvar = console.CreateVariable("render_width", 0, function() if gbuffer_enabled then render.InitializeGBuffer() end end)
local h_cvar = console.CreateVariable("render_height", 0, function() if gbuffer_enabled then render.InitializeGBuffer() end end)
local mult_cvar = console.CreateVariable("render_ss_multiplier", 1, function() if gbuffer_enabled then render.InitializeGBuffer() end end)

function render.DrawGBuffer()
	if not gbuffer_enabled then return end

	render.gbuffer:WriteThese("all")
	
	for i, pass in ipairs(render.gbuffer_passes) do
		if pass.Draw3D then
			pass:Draw3D() 
		end
	end
		
	-- gbuffer	
	render.SetBlendMode("alpha")
	render.EnableDepth(false)	 
			
	for i, shader in ipairs(render.gbuffer_shaders_sorted) do
		if shader.gbuffer_pass.Update then
			shader.gbuffer_pass:Update()
		end
		
		render.gbuffer_mixer_buffer:Begin()
			surface.PushMatrix(0, 0, render.gbuffer_size.w, render.gbuffer_size.h)
				render.SetShaderOverride(shader)
				surface.rect_mesh:Draw()
			surface.PopMatrix()
		render.gbuffer_mixer_buffer:End()
		
		if shader.gbuffer_pass.PostRender then
			shader.gbuffer_pass:PostRender()
		end
	end
	
	render.SetShaderOverride()
	
	surface.SetTexture(render.gbuffer_mixer_buffer:GetTexture())
	surface.SetColor(1,1,1,1)
	surface.DrawRect(0, 0, surface.GetSize())
end

local function init(width, height)
	if not RELOAD then
		include("lua/libraries/graphics/render/passes/*")
	end

	width = width or render.GetWidth()
	height = height or render.GetHeight()
	
	if w_cvar:Get() > 0 then width = w_cvar:Get() end
	if h_cvar:Get() > 0 then height = h_cvar:Get() end
	
	if width == 0 or height == 0 then return end
	
	width = width * mult_cvar:Get()
	height = height * mult_cvar:Get()
	
	render.camera_3d:SetViewport(Rect(0,0,width,height))
	
	render.gbuffer_size = Vec2(width, height)
		
	render.gbuffer_width = width
	render.gbuffer_height = height
	
	local noise_size = Vec2() + math.pow2floor(width)
	if render.noise_texture:GetSize() ~= noise_size then
		render.noise_texture = Texture(noise_size, "return vec4(random(uv*1), random(uv*2), random(uv*3), random(uv*4));")
		render.noise_texture:SetMinFilter("nearest")
	end
	
	if render.debug then
		warning("initializing gbuffer: ", width, " ", height)
	end 
	
	do -- gbuffer	  
		render.gbuffer_buffers = {
			{
				name = "depth",
				attach = "depth",
				internal_format = "depth_component24",	 
				depth_texture_mode = "red",
			},
		}
		
		render.gbuffer_discard = render.CreateFrameBuffer(
			width, 
			height, 
			{
				internal_format = "r8",
			}
		)
		
		render.SetGlobalShaderVariable("tex_depth", function() return render.gbuffer:GetTexture("depth") end, "texture")
		render.SetGlobalShaderVariable("tex_discard", function() return render.gbuffer_discard:GetTexture() end, "texture")
	
		for _, pass in ipairs(render.gbuffer_passes) do		
			if pass.Buffers then
				for _, args in ipairs(pass.Buffers) do
					local name, format, attach = unpack(args)
					
					attach = attach or "color"
					format = format or "rgb16f"
					
					render.SetGlobalShaderVariable("tex_" .. name, function() return render.gbuffer:GetTexture(name) end, "texture")
					
					table.insert(render.gbuffer_buffers, #render.gbuffer_buffers, {
						name = name,
						attach = attach,
						internal_format = format,
						filter = "nearest",
					})
				end
			end
		end
	
		render.gbuffer = render.CreateFrameBuffer(width, height, render.gbuffer_buffers)  
		render.gbuffer_mixer_buffer = render.CreateFrameBuffer(width, height, {
			filter = "nearest",
			internal_format = "rgba16f"
		})
		
		if not render.gbuffer:IsValid() then
			warning("failed to initialize gbuffer")
			return
		end
	end
	
	if not RELOAD then
		include("lua/libraries/graphics/render/post_process/*")
	end
	
	for k,v in pairs(render.gbuffer_shaders_) do
		if v.__init then
			v:__init()
		end
	end
	
	table.clear(render.gbuffer_shaders_)
		
	for _, pass in ipairs(render.gbuffer_passes) do
		local shader = render.CreateShader(pass.Shader)
		pass.shader = shader
		if pass.Initialize then pass:Initialize() end
		for i, info in ipairs(render.gbuffer_buffers) do
			shader["tex_" .. info.name] = render.gbuffer:GetTexture(info.name)
		end
		render["gbuffer_" .. pass.Name .. "_shader"] = shader
	end
				
	event.AddListener("WindowFramebufferResized", "gbuffer", function(window, w, h)
		if render.GetGBufferSize() ~= Vec2(w,h) then
			render.InitializeGBuffer(w, h)
		end
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
				
				x = 0
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
				
				draw_buffer("discard", render.gbuffer_discard:GetTexture())
								
				for _, pass in ipairs(render.gbuffer_passes) do
					if pass.DrawDebug then 
						i,x,y,w,h = pass:DrawDebug(i,x,y,w,h,size) 
					end
				end
			end
		end)
	end
	
	for k,v in pairs(render.gbuffer_values) do
		render.SetGBufferValue(k,v)
	end
	
	gbuffer_enabled = true
	
	event.Call("GBufferInitialized")
	
	logn("render: gbuffer initialized ", width, "x", height)
end

function render.InitializeGBuffer(width, height)
	local ok, err = system.pcall(init, width, height)
	if not ok then
		warning("failed to initialize gbuffer: ", err)
	end
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

function render.IsGBufferReady()
	return gbuffer_enabled
end

function render.EnableGBuffer(b)
	gbuffer_enabled = b
	if b then 
		render.InitializeGBuffer()
	else
		render.ShutdownGBuffer()
	end
end

event.AddListener("EntityCreate", "gbuffer", function()
	if gbuffer_enabled then return end

	if not console.GetVariable("render_deferred") then return end
	if table.count(entities.GetAll()) ~= 0 then return end
	
	render.InitializeGBuffer()
end)

event.AddListener("EntityRemove", "gbuffer", function(ent)
	if gbuffer_enabled then return end

	if not console.GetVariable("render_deferred") then return end
	if table.count(entities.GetAll()) ~= 0 then return end
	
	render.ShutdownGBuffer()
end)

if RELOAD then
	render.InitializeGBuffer()
end