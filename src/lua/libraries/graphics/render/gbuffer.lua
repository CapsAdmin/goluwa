local gl = require("libopengl") -- OpenGL
local render = (...) or _G.render

local gbuffer_enabled = false

local w_cvar = pvars.Setup("render_width", 0, function(_, first) if not first and gbuffer_enabled then render.InitializeGBuffer() end end)
local h_cvar = pvars.Setup("render_height", 0, function(_, first) if not first and  gbuffer_enabled then render.InitializeGBuffer() end end)
local mult_cvar = pvars.Setup("render_ss_multiplier", 1, function(_, first) if not first and gbuffer_enabled then render.InitializeGBuffer() end end)

function render.GetGBufferSize()
	if not render.gbuffer_size then
		local size = render.GetScreenSize()

		if w_cvar:Get() > 0 then size.x = w_cvar:Get() end
		if h_cvar:Get() > 0 then size.y = h_cvar:Get() end

		size = size * mult_cvar:Get()

		if size.x == 0 or size.y == 0 then
			size = render.GetScreenSize()
		end

		render.gbuffer_size = size
	end

	return render.gbuffer_size
end

render.SetGlobalShaderVariable("g_gbuffer_size", render.GetGBufferSize, "vec2")
render.SetGlobalShaderVariable("g_screen_size", render.GetScreenSize, "vec2")
render.SetGlobalShaderVariable("g_noise_texture", render.GetNoiseTexture, "sampler2D")
render.SetGlobalShaderVariable("g_hemisphere_normals_texture", render.GetHemisphereNormalsTexture, "sampler2D")
render.SetGlobalShaderVariable("g_time", system.GetElapsedTime, "float")

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

	function render.AddGBufferShader(PASS)
		render.gbuffer_shaders[PASS.Name] = PASS

		local stages = PASS.Source

		if type(stages) == "string" then
			stages = {{source = stages}}
		end

		if stages[#stages].buffer then
			table.insert(stages, {
				source =  [[
					out vec3 out_color;

					void main()
					{
						out_color = texture(tex_stage_]]..#stages..[[, uv).rgb;
					}
				]]
			})
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
						tex_mixer = {texture = function() return render.gbuffer_mixer_buffer:GetTexture() end},
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
			local shaders = {}

			for i, stage in ipairs(stages) do
				local size = render.gbuffer_size:Copy()
				local fb

				if stage.buffer then
					if stage.buffer.size_divider then
						size = size / stage.buffer.size_divider
					else
						size = stage.buffer.size or size
					end

					if stage.buffer.max_size then
						size.x = math.min(size.x, stage.buffer.max_size.x)
						size.y = math.min(size.y, stage.buffer.max_size.y)
					end

					fb = render.CreateFrameBuffer(size, stage.buffer or {internal_format = "rgba8"})

					stage.shader.fragment.variables.self = fb:GetTexture()
					fb:GetTexture():Clear()

					for _, stage in ipairs(stages) do
						local tex = fb:GetTexture()
						stage.shader.fragment.variables["tex_stage_" .. i] = tex
					end
				end

				local shader = render.CreateShader(stage.shader)
				shader.size = size
				shader.fb = fb
				shader.blend_mode = stage.blend_mode
				shaders[i] = shader
			end

			PASS.gbuffer_position = tonumber(PASS.Position) or #render.gbuffer_shaders_sorted
			PASS.shaders = shaders

			if PASS.Initialize then
				local ok, err = pcall(function() PASS:Initialize() end)
				if not ok then
					logn("failed to initialize gbuffer pass ", PASS.Name, ": ", err)
					render.RemoveGBufferShader(PASS.Name)
				end
			end

			for i, pass in ipairs(render.gbuffer_shaders_sorted) do
				if pass.Name == PASS.Name then
					table.remove(render.gbuffer_shaders_sorted, i)
					break
				end
			end

			table.insert(render.gbuffer_shaders_sorted, PASS)

			table.sort(render.gbuffer_shaders_sorted, function(a, b)
				return a.gbuffer_position < b.gbuffer_position
			end)

			for k,v in pairs(render.gbuffer_values) do
				render.SetGBufferValue(k,v)
			end
		end

		if not pvars.IsSetup("render_pp_" .. PASS.Name) then
			local default = PASS.Default

			if default == nil then
				default = true
			end

			pvars.Setup("render_pp_" .. PASS.Name, default, function(b)
				if b then
					render.AddGBufferShader(PASS)
				else
					render.RemoveGBufferShader(PASS.Name)
				end
			end)
		end

		if pvars.Get("render_pp_" .. PASS.Name) then
			if render.gbuffer_data_pass then
				PASS:__init()
			end
		else
			render.RemoveGBufferShader(PASS.Name)
		end
	end

	function render.RemoveGBufferShader(name)
		render.gbuffer_shaders[name] = nil
		for k,v in ipairs(render.gbuffer_shaders_sorted) do
			if v.Name == name then
				table.remove(render.gbuffer_shaders_sorted, k)
				break
			end
		end
	end
end

function render.DrawGBuffer(what, dist)
	if not gbuffer_enabled then return end

	render.gbuffer:WriteThese("all")
	render.gbuffer:ClearAll(0,0,0,0, 1)

	render.gbuffer_data_pass:Draw3D(what, dist)

	event.Call("GBufferPrePostProcess")

	surface.PushMatrix()

	-- gbuffer
	render.SetDepth(false)

	render.gbuffer_mixer_buffer:Begin()
	for _, pass in ipairs(render.gbuffer_shaders_sorted) do
		if pass.Update then
			pass:Update()
		end

		for _, shader in ipairs(pass.shaders) do
			render.SetBlendMode(shader.blend_mode)
			if shader.fb then shader.fb:Begin() end
			surface.PushMatrix(0, 0, shader.size.x, shader.size.y)
				render.SetShaderOverride(shader)
				surface.rect_mesh:Draw()
			surface.PopMatrix()
			if shader.fb then shader.fb:End() end
		end

		if system.IsOpenGLExtensionSupported("GL_ARB_texture_barrier") then gl.TextureBarrier() end

		if pass.PostRender then
			pass:PostRender()
		end
	end
	render.gbuffer_mixer_buffer:End()

	surface.PopMatrix()
end

local shader_cvar = pvars.Setup("render_gshader", "template", function(_, first) if not first and gbuffer_enabled then render.InitializeGBuffer() end end)

render.gbuffer = NULL

function render.InitializeGBuffer()
	render.gbuffer = NULL
	render.gbuffer_values = {}
	render.gbuffer_shaders = {}
	render.gbuffer_shaders_sorted = {}

	local size = render.GetGBufferSize()

	render.camera_3d:SetViewport(Rect(0,0,size.x,size.y))
	render.InitializeNoiseTexture(size)

	include("lua/libraries/graphics/render/gbuffer_shaders/"..shader_cvar:Get()..".lua")

	render.InitializeSky()

	local data_pass = include("lua/libraries/graphics/render/gbuffer_data_fill.lua", render)

	do -- init data pass
		local framebuffer_buffers = {}

		if data_pass.DepthFormat then
			table.insert(framebuffer_buffers, {
				name = "depth",
				attach = "depth",
				internal_format = data_pass.DepthFormat,
				depth_texture_mode = "red",
			})

			render.SetGlobalShaderVariable("tex_depth", function() return render.gbuffer:GetTexture("depth") end, "texture")
		end

		local buffer_i = 1
		for _, pass_info in ipairs(data_pass.Buffers) do
			local write_these = ""

			for i, val in ipairs(pass_info.layout) do
				local format, info = next(val)
				local name = "data" .. buffer_i

				table.insert(framebuffer_buffers, {
					name = name,
					attach = "color",
					internal_format = format,
					filter = "linear",
				})

				render.SetGlobalShaderVariable("tex_" .. name, function() return render.gbuffer:GetTexture(name) end, "texture")

				for index, key in pairs(info) do
					local channel_count = #index
					local glsl_type
					if channel_count == 1 then
						glsl_type = "float"
					else
						glsl_type = "vec" .. channel_count
					end

					if type(key) == "table" then
						local _, decode = key[3]:match("(%w+ encode%b()%s-%b{})%s-(%w+ decode%b()%s-%b{})")
						local glsl_type = key[2]
						key = key[1]
						decode = decode:replace("decode(", "_decode_" .. key .. "(") .. "\n\n"

						render.AddGlobalShaderCode(decode)

						render.AddGlobalShaderCode(glsl_type.." get_"..key.."(vec2 uv)\n"..
						"{\n"..
							"\treturn _decode_" .. key .. "(texture(tex_data"..buffer_i..", uv)."..index..");\n"..
						"}")
					else
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

			data_pass.buffers_write_these = data_pass.buffers_write_these or {}
			data_pass.buffers_write_these[pass_info.name] = write_these
		end

		local function gen_code(code, format, layout, buffer_i)
			local channel_count = #render.GetTextureFormatInfo(format).bits
			local glsl_type
			if channel_count == 1 then
				glsl_type = "float"
			else
				glsl_type = "vec" .. channel_count
			end

			code = code .. "out " .. glsl_type .. " data" .. buffer_i .. "_buffer;\n"

			for index, key in pairs(layout) do
				local channel_count = #index
				local glsl_type
				if channel_count == 1 then
					glsl_type = "float"
				else
					glsl_type = "vec" .. channel_count
				end


				if type(key) == "table" then
					local encode = key[3]:match("(%w+ encode%b()%s-%b{})%s-(%w+ decode%b()%s-%b{})")
					local glsl_type = key[2]
					key = key[1]
					encode = encode:replace("encode(", "_encode_" .. key .. "(") .. "\n\n"

					code = code .. encode
					code = code .. "void set_"..key.."("..glsl_type.." val){ data" .. buffer_i .. "_buffer." ..  index .. " = _encode_" .. key .. "(val); }\n"
				else
					code = code .. "void set_"..key.."("..glsl_type.." val){ data" .. buffer_i .. "_buffer." ..  index .. " = val; }\n"
				end
			end

			return code
		end

		for i, stage in ipairs(data_pass.Stages) do
			local code = ""

			if data_pass.Buffers[i].write == "all" then
				local buffer_i = 1
				for _, pass_info in ipairs(data_pass.Buffers) do
					for _, val in ipairs(pass_info.layout) do
						local format, layout = next(val)
						code = gen_code(code, format, layout, buffer_i)
						buffer_i = buffer_i + 1
					end
				end
			elseif data_pass.Buffers[i].write == "self" then
				local buffer_i = 1
				for _, val in ipairs(data_pass.Buffers[i].layout) do
					local format, layout = next(val)
					code = gen_code(code, format, layout, buffer_i)
					buffer_i = buffer_i + 1
				end
			end

			stage.fragment.source = code .. stage.fragment.source
		end

		render.gbuffer = render.CreateFrameBuffer(render.gbuffer_size, framebuffer_buffers)
		render.gbuffer_mixer_buffer = render.CreateFrameBuffer(render.gbuffer_size, {internal_format = "r11f_g11f_b10f"})

		data_pass.shaders = {}

		for i, shader_info in ipairs(data_pass.Stages) do
			local shader = render.CreateShader(shader_info)
			for _, info in ipairs(framebuffer_buffers) do
				shader["tex_" .. info.name] = render.gbuffer:GetTexture(info.name)
			end
			data_pass.shaders[i] = shader
			data_pass[shader_info.name.."_shader"] = shader
		end

		data_pass:Initialize()
	end

	render.gbuffer_data_pass = data_pass

	include("lua/libraries/graphics/render/post_process/*")

	event.AddListener("WindowResize", "gbuffer", function(_, w, h)
		local current = render.GetGBufferSize()
		render.gbuffer_size = nil
		if render.GetGBufferSize() ~= current then
			render.InitializeGBuffer()
		end
		render.camera_3d:SetViewport(Rect(0,0,w,h))
	end)

	for k,v in pairs(render.gbuffer_values) do
		render.SetGBufferValue(k,v)
	end

	event.Call("GBufferInitialized")

	logn("render: gbuffer initialized ", size.x, "x", size.y)

	gbuffer_enabled = true
end

function render.ShutdownGBuffer()
	event.RemoveListener("WindowResize", "gbuffer")

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

function render.GetFinalGBufferTexture()
	return render.gbuffer_mixer_buffer:GetTexture()
end

event.AddListener("EntityCreate", "gbuffer", function()
	if gbuffer_enabled then return end

	if table.count(entities.GetAll()) ~= 0 then return end

	render.InitializeGBuffer()
end)

event.AddListener("EntityRemove", "gbuffer", function()
	if gbuffer_enabled then return end

	if table.count(entities.GetAll()) ~= 0 then return end

	render.ShutdownGBuffer()
end)

function render.CreateMesh(vertices, indices, is_valid_table)
	return nil, "gbuffer not ready"
end

if RELOAD then
	render.InitializeGBuffer()
end