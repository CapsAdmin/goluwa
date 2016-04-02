local gl = require("libopengl") -- OpenGL
local render = (...) or _G.render

render.AddGlobalShaderCode([[
float random(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}]])

render.AddGlobalShaderCode([[
vec3 get_noise2(vec2 uv)
{
	return vec3(random(uv), random(uv*23.512), random(uv*6.53330));
}]])

render.AddGlobalShaderCode([[
vec3 get_noise3(vec2 uv)
{
	float x = random(uv);
	float y = random(uv*x);
	float z = random(uv*y);

	return vec3(x,y,z) * 2 - 1;
}]])

render.AddGlobalShaderCode([[
vec4 get_noise(vec2 uv)
{
	return texture(g_noise_texture, uv);
}]])

render.AddGlobalShaderCode([[
vec2 get_screen_uv()
{
	return gl_FragCoord.xy / g_screen_size;
}]])

render.gbuffer_size = Vec2(1,1)

function render.GetGBufferSize()
	return render.gbuffer_size
end

render.SetGlobalShaderVariable("g_screen_size", render.GetGBufferSize, "vec2")
render.SetGlobalShaderVariable("g_noise_texture", render.GetNoiseTexture, "sampler2D")
render.SetGlobalShaderVariable("g_hemisphere_normals_texture", render.GetHemisphereNormalsTexture, "sampler2D")
render.SetGlobalShaderVariable("g_time", system.GetElapsedTime, "float")

render.gbuffer = render.gbuffer or NULL
render.gbuffer_values = render.gbuffer_values or {}
render.gbuffer_shaders = render.gbuffer_shaders or {}

do -- mixer
	function render.SetGBufferValue(key, var)
		render.gbuffer_values[key] = var

		for _, pass in pairs(render.gbuffer_shaders) do
			if pass.init then
				for _, shader in pairs(pass.shaders) do
					if shader[key] then
						shader[key] = var
					end
				end
			end
		end
	end

	function render.GetGBufferValue(key)
		return render.gbuffer_values[key]
	end

	function render.GetGBufferValues()
		local out = {}
		for name, pass in pairs(render.gbuffer_shaders) do
			if pass.init then
				for _, shader in pairs(pass.shaders) do
					for k, v in pairs(shader.defaults) do
						if type(v) == "function" then
							v = v()
						end
						out[name .. "_" .. k] = {k = k, v = v}
					end
				end
			end
		end
		return out
	end

	render.gbuffer_shaders_sorted = render.gbuffer_shaders_sorted or {}

	function render.AddGBufferShader(PASS, init_now)
		render.gbuffer_shaders[PASS.Name] = PASS

		local stages = PASS.Source

		if type(stages) == "string" then
			stages = {{source = stages}}
		end

		for i, stage in ipairs(stages) do
			local shader = {
				name = "pp_" .. PASS.Name .. "_" .. i,
				vertex = {
					mesh_layout = {
						{pos = "vec3"},
						{uv = "vec2"},
					},
					source = "gl_Position = g_projection_view_world_2d * vec4(pos, 1);"
				},
				fragment = {
					variables = {
						self = {texture = function() return render.gbuffer_mixer_buffer:GetTexture() end},
					},
					mesh_layout = {
						{uv = "vec2"},
					},
					source = stage.source
				}
			}

			if PASS.Variables then
				table.merge(shader.fragment.variables, PASS.Variables)
			end

			stage.shader = shader
		end

		function PASS:__init()
			local shader = {}

			shader.textures = {}
			shader.shaders = {}

			for i, stage in ipairs(stages) do
				local size = render.gbuffer_size
				local fb

				if stage.buffer then
					if stage.buffer.size_divider then
						size = size / stage.buffer.size_divider
					else
						size = stage.buffer.size or size
					end

					if stage.buffer.max_size then
						size = size:Copy()
						size.x = math.min(size.x, stage.buffer.max_size.x)
						size.y = math.min(size.y, stage.buffer.max_size.y)
					end

					fb = render.CreateFrameBuffer(Vec2(size.x, size.y), stage.buffer or {internal_format = "rgba8"})
					for _, stage in ipairs(stages) do
						local tex = fb:GetTexture()
						stage.shader.fragment.variables["tex_stage_" .. i] = tex
						table.insert(shader.textures, tex)
					end
				end

				local obj = render.CreateShader(stage.shader)
				obj.size = size
				obj.fb = fb
				obj.blend_mode = stage.blend_mode
				shader.shaders[i] = obj
			end

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

			for k,v in ipairs(render.gbuffer_shaders_sorted) do
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
		end

		if not console.IsVariableAdded("render_pp_" .. PASS.Name) then
			local pass = table.copy(PASS)
			local default = PASS.Default

			if default == nil then
				default = true
			end

			console.CreateVariable("render_pp_" .. pass.Name, default, function(val)
				if val then
					if render.IsGBufferReady() then
						render.AddGBufferShader(pass)
						pass:__init()
					end
				else
					render.RemoveGBufferShader(pass.Name)
				end
			end)
		end

		if not console.GetVariable("render_pp_" .. PASS.Name) then
			render.RemoveGBufferShader(PASS.Name)
		end
	end

	function render.RemoveGBufferShader(name)
		render.gbuffer_shaders[name] = nil
		for k,v in ipairs(render.gbuffer_shaders_sorted) do
			if v.gbuffer_name == name then
				table.remove(render.gbuffer_shaders_sorted, k)
				break
			end
		end
	end

	function render.GetGBufferShaderTextures(name)
		local pass = render.gbuffer_shaders[name]
		if pass then
			return pass.textures
		end
	end
end

local gbuffer_enabled = false
local w_cvar = console.CreateVariable("render_width", 0, function() if gbuffer_enabled then render.InitializeGBuffer() end end)
local h_cvar = console.CreateVariable("render_height", 0, function() if gbuffer_enabled then render.InitializeGBuffer() end end)
local mult_cvar = console.CreateVariable("render_ss_multiplier", 1, function() if gbuffer_enabled then render.InitializeGBuffer() end end)

function render.DrawGBuffer(what, dist)
	if not gbuffer_enabled then return end

	render.gbuffer:WriteThese("all")
	render.gbuffer:Clear("all", 0,0,0,0, 1)

	render.gbuffer_fill:Draw3D(what, dist)

	event.Call("GBufferPrePostProcess")

	surface.PushMatrix()

	-- gbuffer
	render.SetDepth(false)

	render.gbuffer_mixer_buffer:Begin()
	for i, shader in ipairs(render.gbuffer_shaders_sorted) do
		if shader.gbuffer_pass.Update then
			shader.gbuffer_pass:Update()
		end

		for i, shader in ipairs(shader.shaders) do
			render.SetBlendMode(shader.blend_mode)
			if shader.fb then shader.fb:Begin() end
			surface.PushMatrix(0, 0, shader.size.x, shader.size.y)
				render.SetShaderOverride(shader)
				surface.rect_mesh:Draw()
			surface.PopMatrix()
			if shader.fb then shader.fb:End() end
		end

		if window.IsExtensionSupported("GL_ARB_texture_barrier") then gl.TextureBarrier() end

		if shader.gbuffer_pass.PostRender then
			shader.gbuffer_pass:PostRender()
		end
	end
	render.gbuffer_mixer_buffer:End()

	surface.SetColor(1,1,1,1)
	surface.SetTexture(render.gbuffer_mixer_buffer:GetTexture())
	render.SetBlendMode()
	render.SetShaderOverride()
	surface.DrawRect(0, 0, surface.GetSize())

	surface.PopMatrix()

	render.SetBlendMode("alpha")
	if render.debug then
		render.DrawGBufferDebugOverlay()
	end
end

local function init(width, height)
	if not RELOAD or not render.gbuffer_fill then
		include("lua/libraries/graphics/render/fill_gbuffer.lua", render)
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

	local noise_size = Vec2(width, height)
	if render.noise_texture:GetSize() ~= noise_size or RELOAD then
		render.noise_texture = render.CreateTexture("2d")
		render.noise_texture:SetSize(noise_size)
		--render.noise_texture:SetInternalFormat("rgba16f")
		render.noise_texture:SetupStorage()
		render.SetBlendMode()
		render.noise_texture:Shade("return vec4(random(uv), random(uv*23.512), random(uv*6.53330), random(uv*122.260));")
		render.noise_texture:SetMinFilter("nearest")
	end

	if render.debug then
		warning("initializing gbuffer: %sx%s", 2, width, height)
	end

	do -- gbuffer
		render.gbuffer_buffers = {
			{
				name = "depth",
				attach = "depth",
				internal_format = "depth_component32f",
				depth_texture_mode = "red",
			},
		}

		render.gbuffer_discard = render.CreateFrameBuffer(
			Vec2(width, height),
			{
				internal_format = "r8",
			}
		)

		render.SetGlobalShaderVariable("tex_depth", function() return render.gbuffer:GetTexture("depth") end, "texture")
		render.SetGlobalShaderVariable("tex_discard", function() return render.gbuffer_discard:GetTexture() end, "texture")

		if not render.gbuffer_fill.init then -- setup the gbuffer fill table
			local fill = render.gbuffer_fill

			function fill:BeginPass(name)
				render.gbuffer:WriteThese(self.buffers_write_these[name])
				render.gbuffer:Begin()
			end

			function fill:EndPass()
				render.gbuffer:End()
			end

			fill.buffers_write_these = {}

			local buffer_i = 1
			for _, pass_info in ipairs(fill.Buffers) do
				local write_these = ""
				for i, buffer in ipairs(pass_info.layout) do

					local name = "data" .. buffer_i
					render.SetGlobalShaderVariable("tex_" .. name, function() return render.gbuffer:GetTexture(name) end, "texture")

					table.insert(render.gbuffer_buffers, #render.gbuffer_buffers, {
						name = name,
						attach = "color",
						internal_format = buffer.format,
						filter = "linear",
					})

					for key, index in pairs(buffer) do
						if key ~= "format" then
							local channel_count = #index
							local glsl_type
							if channel_count == 1 then
								glsl_type = "float"
							else
								glsl_type = "vec" .. channel_count
							end

							render.AddGlobalShaderCode(glsl_type.." get_"..key.."(vec2 uv)\n"..
							"{\n"..
								"\treturn texture(tex_data"..buffer_i..", uv)."..index..";\n"..
							"}")
						end
					end

					write_these = write_these .. "data" .. buffer_i
					if i ~= #pass_info.layout then
						write_these = write_these .. "|"
					end

					buffer_i = buffer_i + 1
				end
				fill.buffers_write_these[pass_info.name] = write_these
			end

			for i,v in ipairs(fill.Stages) do
				local code = ""
				if fill.Buffers[i].write == "all" then
					local buffer_i = 1
					for _, pass_info in ipairs(fill.Buffers) do
						for _, buffer in ipairs(pass_info.layout) do
							local channel_count = #render.GetTextureFormatInfo(buffer.format).bits
							local glsl_type
							if channel_count == 1 then
								glsl_type = "float"
							else
								glsl_type = "vec" .. channel_count
							end

							code = code .. "out " .. glsl_type .. " data" .. buffer_i .. "_buffer;\n"

							for key, index in pairs(buffer) do
								if key ~= "format" then
									code = code .. "#define " .. key .. " data" .. buffer_i .. "_buffer." ..  index .. "\n"
								end
							end

							buffer_i = buffer_i + 1
						end
					end
				elseif fill.Buffers[i].write == "self" then
					local buffer_i = 1
					for _, buffer in ipairs(fill.Buffers[i].layout) do
						local channel_count = #render.GetTextureFormatInfo(buffer.format).bits
						local glsl_type
						if channel_count == 1 then
							glsl_type = "float"
						else
							glsl_type = "vec" .. channel_count
						end

						code = code .. "out " .. glsl_type .. " data" .. buffer_i .. "_buffer;\n"

						for key, index in pairs(buffer) do
							if key ~= "format" then
								code = code .. "#define " .. key .. " data" .. buffer_i .. "_buffer." ..  index .. "\n"
							end
						end

						buffer_i = buffer_i + 1
					end
				end

				v.fragment.source = code .. v.fragment.source
			end

			fill.init = true
		end

		render.gbuffer = render.CreateFrameBuffer(Vec2(width, height), render.gbuffer_buffers)
		render.gbuffer_mixer_buffer = render.CreateFrameBuffer(Vec2(width, height), {internal_format = "rgb16f"})

		if not render.gbuffer:IsValid() then
			warning("failed to initialize gbuffer")
			return
		end
	end

	if not RELOAD then
		include("lua/libraries/graphics/render/post_process/*")
	end

	for k,v in pairs(render.gbuffer_shaders) do
		if v.__init then
			v:__init()
		end
	end

	render.gbuffer_fill.shaders = {}

	for i, shader_info in ipairs(render.gbuffer_fill.Stages) do
		local shader = render.CreateShader(shader_info)
		for i, info in ipairs(render.gbuffer_buffers) do
			shader["tex_" .. info.name] = render.gbuffer:GetTexture(info.name)
		end
		render.gbuffer_fill.shaders[i] = shader
		render.gbuffer_fill[shader_info.name.."_shader"] = shader
	end

	render.gbuffer_fill:Initialize()

	event.AddListener("WindowFramebufferResized", "gbuffer", function(_, w, h)
		if render.GetGBufferSize() ~= Vec2(w,h) then
			render.InitializeGBuffer(w, h)
		end
	end)

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
		warning("failed to initialize gbuffer: ", 2, err)
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

event.AddListener("EntityRemove", "gbuffer", function()
	if gbuffer_enabled then return end

	if not console.GetVariable("render_deferred") then return end
	if table.count(entities.GetAll()) ~= 0 then return end

	render.ShutdownGBuffer()
end)

function render.CreateMesh(vertices, indices, is_valid_table)
	if render.IsGBufferReady() then
		return render.gbuffer_fill.model_shader:CreateVertexBuffer(vertices, indices, is_valid_table)
	end

	return nil, "gbuffer not ready"
end

if RELOAD then
	event.Delay(0.01, render.InitializeGBuffer)
end