local render = (...) or _G.render

render.use_uniform_buffers = false

-- used to figure out how to upload types
local unrolled_lines = {
	bool = "render.current_program:UploadBoolean(%i, val)",
	number = "render.current_program:UploadNumber(%i, val)",
	int = "render.current_program:UploadInteger(%i, val)",
	vec2 = "render.current_program:UploadVec2(%i, val)",
	vec3 = "render.current_program:UploadVec3(%i, val)",
	color = "render.current_program:UploadColor(%i, val)",
	mat4 = "render.current_program:UploadMatrix44(%i, val)",
}

if system.IsOpenGLExtensionSupported("GL_ARB_bindless_texture") then
	unrolled_lines.texture = "render.current_program:UploadTexture(%i, val)"
else
	unrolled_lines.texture = "render.current_program:UploadTexture(%i, val, %i, %i)"
end

unrolled_lines.vec4 = unrolled_lines.color
unrolled_lines.sampler2D = unrolled_lines.texture
unrolled_lines.sampler2DMS = unrolled_lines.texture
unrolled_lines.samplerCube = unrolled_lines.texture
unrolled_lines.float = unrolled_lines.number
unrolled_lines.boolean = unrolled_lines.bool

-- used because of some reserved keywords
local reserve_prepend = "out_"

local source_template =
[[

@@VARIABLES@@

@@IN@@

@@OUT@@
@@GLOBAL VARIABLES VERTEX@@
@@GLOBAL VARIABLES FROM VERTEX@@
@@GLOBAL VARIABLES@@
@@GLOBAL CODE@@
//__SOURCE_START
@@SOURCE@@
//__SOURCE_END
void main()
{
@@OUT2@@
@@GLOBAL VARIABLES TO FRAGMENT@@
	mainx();
}
]]

local lazy_template = [[
	out vec4 out_color;

	vec4 shade()
	{
		%s
	}

	void main()
	{
		out_color = shade();
	}
]]

local type_translate = {
	boolean = "bool",
	color = "vec4",
	number = "float",
	texture = "sampler2D",
	matrix44 = "mat4",
}

local function type_of_attribute(var)
	local t = typex(var)
	local def = var
	local get

	if t == "string" then
		t = var
		def = nil
	elseif t == "table" then
		local k,v
		if var.type then
			k = var.type
			v = var.val
		else
			k, v = next(var)
		end
		if type(k) == "string" and type(v) == "function" then
			t = k
			get = v
			def = v
		end
	end

	t = type_translate[t] or t

	if typex(var) == "texture" and var.StorageType == "cube_map" then
		t = "samplerCube"
	end

	return t, def, get
end

local function translate_fields(data)
	local out = {}

	for k, v in pairs(data) do
		local params = {}

		if type(k) == "number" then
			params = v
			k, v = next(v)
		end
		local t, default, get = type_of_attribute(v)

		local bindless = system.IsOpenGLExtensionSupported("GL_ARB_bindless_texture")
		local is_texture = t:find("sampler")

		local precision = params.precision

		if t == "bool" or is_texture then
			precision = nil
		elseif not precision then
			precision = "highp"
		end

		table.insert(out, {
			name = k,
			type = t,
			is_texture = is_texture and not bindless,
			is_bindless_texture = is_texture and bindless,
			default = default,
			precision = precision,
			varying = params.varying and "varying" or nil,
			get = get,
		})
	end

	return out
end

local function variables_to_string(type, variables, prepend, macro, array)
	local texture_channel = 0
	local attribute_location = 0
	local out = {}

	for _, data in ipairs(translate_fields(variables)) do
		local name = data.name

		if prepend then
			name = prepend .. name
		end

		local line = ""

		if data.is_texture then
			if system.IsOpenGLExtensionSupported("GL_ARB_enhanced_layouts") or system.IsOpenGLExtensionSupported("GL_ARB_shading_language_420pack") then
				line = line .. "layout(binding = " .. texture_channel .. ") "
				texture_channel = texture_channel + 1
			end
		elseif data.is_bindless_texture then
			line = line .. "layout(bindless_sampler) "
		elseif not macro then
			if system.IsOpenGLExtensionSupported("GL_ARB_enhanced_layouts") or system.IsOpenGLExtensionSupported("GL_ARB_shading_language_420pack") then
				if type == "in" then
					line = line .. "layout(location = " .. attribute_location .. ") "
				end
				attribute_location = attribute_location + 1
			end
		end

		if data.varying then
			line = line .. data.varying .. " "
		end

		line = line .. type .. " "

		if data.precision then
			line = line .. data.precision .. " "
		end

		line = line .. data.type .. " "
		line = line .. name .. " "

		if array then
			line = line .. array
		end

		line = line .. ";"

		if macro then
			table.insert(out, "#define " .. data.name .. " " .. name)
		end

		table.insert(out, line)
	end

	return table.concat(out, "\n")
end

local function replace_field(str, key, val)
	return str:gsub("(@@.-@@)", function(str)
		if str:match("@@(.+)@@") == key then
			return val
		end
	end)
end

render.active_shaders = render.active_shaders or utility.CreateWeakTable()

function render.GetShaders()
	return render.active_shaders
end

local META = prototype.CreateTemplate("shader")

function render.CreateShader(data, vars)

	if type(data) == "string" then
		local fragment_source = data
		local name = "shader_lazy_" .. crypto.CRC32(fragment_source)

		data = {
			name = name,
			vertex = {
				mesh_layout = {
					{pos = "vec3"},
					{uv = "vec2"},
				},
				source = "gl_Position = g_projection_view_world_2d * vec4(pos, 1);"
			},

			fragment = {
				variables = vars,
				mesh_layout = {
					{uv = "vec2"},
				},
				source = fragment_source,
			}
		}
	end

	-- make a copy of the data since we're going to modify it
	local original_data = data
	local data = table.copy(data)

	-- these arent actually shaders
	local shader_id = data.name data.name = nil
	local force_bind = data.force data.force = nil
	local base = data.base data.base = nil
	local shared = data.shared data.shared = nil

	-- inherit from base shader provided
	if base and render.active_shaders[base] then
		local temp = table.copy(render.active_shaders[base].original_data)

		temp.name = nil
		temp.base = nil

		table.merge(temp, data)
		data = temp

		shared = data.shared shared = nil
	end

	if not data.vertex then
		data.vertex = {
			mesh_layout = {
				{pos = "vec3"},
				{uv = "vec2"},
			},
			source = "gl_Position = g_projection_view_world_2d * vec4(pos, 1);"
		}
	end

	-- shared is not a real step but merge it with all the other steps
	if shared then
		if shared.variables then
			for shader, info in pairs(data) do
				if info.variables then
					for k, v in pairs(shared.variables) do
						if not info.variables[k] then
							info.variables[k] = v
						end
					end
				end
			end
		end
	end

	local build_output = {}

	for shader, info in pairs(data) do
		local source = source_template

		if not info.source:find("\n") and info.source:find(".", nil, true) and vfs.IsFile(info.source) then
			info.source_path = info.source
			info.source = vfs.Read(info.source)
		end

		if info.source and info.source:find("#version") then
			info.source = info.source:gsub("(#version.-\n)", function(line)
				source = line .. source
				return ""
			end)
		else
			local str = render.GetShadingLanguageVersion():gsub("%p", ""):match("(%d+)")
			if str then
				source = "#version " .. str .. "\n" .. source
			end
		end

		build_output[shader] = {source = source, original_source = info.source, out = {}}
	end

	-- figure out vertex mesh_layout other shaders need only if vertex and fragment is defined
	-- since tesselation and geometry requires specialized input and output
	if data.vertex and data.fragment and table.count(data) == 2 then
		if data.fragment.mesh_layout then
			for i, v in ipairs(data.fragment.mesh_layout) do
				build_output.vertex.out[i] = v
			end
		end

		local source = build_output.vertex.source

		-- declare them as
		-- out highp vec3 glw_out_foo;
		source = replace_field(source, "OUT", variables_to_string("out", build_output.vertex.out, reserve_prepend))

		-- and then in main do
		-- glw_out_normal = normal;
		-- to avoid name conflicts
		local vars = {}

		for _, v in pairs(build_output.vertex.out) do
			local name = next(v)
			table.insert(vars, ("\t%s = %s;"):format(reserve_prepend .. name, name))
		end

		source = replace_field(source, "OUT2", table.concat(vars, "\n"))

		build_output.vertex.source = source
	end

	do
		local function preprocess(str, info)
			return str:gsub("lua(%b[])", function(code)
				if code:find("=", nil, true) then
					local key, default = code:sub(2, -2):match("(.-)=(.+)")
					key = key:trim()
					default = default:trim()
					local ok, default = pcall(loadstring("return " .. default))

					if not ok then
						error(default, 3)
					end

					info.variables = info.variables or {}
					info.variables[key] = default

					return key
				else
					local type, code = code:sub(2, -2):match("(%b())(.+)")
					type = type:sub(2, -2)
					local ok, var = pcall(loadstring("return " .. code))

					if not ok then
						error(var, 3)
					end

					local name = "auto_lua_variable_" .. tostring(crypto.CRC32(code .. os.clock()))

					info.variables = info.variables or {}
					info.variables[name] = {[type] = var}

					return name
				end
			end)
		end

		for shader, info in pairs(data) do
			local template = build_output[shader].source

			if shader == "vertex" then
				template = replace_field(template, "GLOBAL CODE", render.GetGlobalShaderCode(info.source))
				template = replace_field(template, "GLOBAL VARIABLES", render.GetGlobalShaderVariables(info.source))
			else
				template = replace_field(template, "GLOBAL CODE", (render.GetGlobalShaderCode(info.source)))
				template = replace_field(template, "GLOBAL VARIABLES", render.GetGlobalShaderVariables(template, true))
			end

			template = preprocess(template, info)

			if info.source then
				info.source = preprocess(info.source, info)
			end

			info.template = template
		end
	end

	if data.vertex and data.fragment and table.count(data) == 2 then
		local code, vars = render.GetGlobalShaderVariables(data.fragment.template, false)
		local code2, vars2 = render.GetGlobalShaderVariables(data.fragment.source, false)

		for k,v in pairs(vars2) do
			if not vars[k] then
				vars[k] = v
			end
		end

		local out_code = ""
		for k,v in pairs(vars) do
			out_code = out_code .. "out " .. v.type .. " " .. v.key .. "_out;\n"
		end

		data.vertex.template = replace_field(data.vertex.template, "GLOBAL VARIABLES VERTEX", code..code2..out_code)

		local code = ""
		for k,v in pairs(vars) do
			code = code .. "\t" .. v.key .. "_out = " .. v.key .. ";\n"
		end
		data.vertex.template = replace_field(data.vertex.template, "GLOBAL VARIABLES TO FRAGMENT", code)


		local code = ""
		for k,v in pairs(vars) do
			code = code .. "in " .. v.type .. " " .. v.key .. "_out;\n"
			code = code .. "#define " .. v.key .. " " .. v.key .. "_out\n"
		end

		data.fragment.template = replace_field(data.fragment.template, "GLOBAL VARIABLES FROM VERTEX", code)
	end

	for shader, info in pairs(data) do
		if info.source then
			for k,v in pairs(render.global_shader_variables) do
				if not v.is_texture then
					local p = [==[[!"#$%&'%(%)*+,-./:;<=>?@%[\%]^`{|}~%s]]==]
					if info.source:find(p..k..p) or info.template:find(p..k..p) then
						info.variables = info.variables or {}
						info.variables[k] = v
					end
				end
			end
		end
	end

	if render.use_uniform_buffers then
		local ubo_variables = {}

		local uniform_block = "uniform variables {\n"
		for shader, info in pairs(data) do
			if info.variables then
				local other_variables = {}
				for _, data in ipairs(translate_fields(info.variables)) do
					if not ubo_variables[data.name] then
						if not data.is_texture or data.is_bindless_texture then
							local p = [==[[!"#$%&'%(%)*+,-./:;<=>?@%[\%]^`{|}~%s]]==]
							if info.source:find(p..data.name..p) or info.template:find(p..data.name..p) then
								uniform_block = uniform_block .. "\t" .. data.type .. " " .. data.name .. ";\n"
								ubo_variables[data.name] = info.variables[data.name]
							end
						else
							other_variables[data.name] = info.variables[data.name]
						end
					end
				end
				info.other_variables = other_variables
			end
		end
		uniform_block = uniform_block .. "};\n"

		ubo_variables = translate_fields(ubo_variables)

		for shader, info in pairs(data) do
			local other = ""

			if info.other_variables then
				other = variables_to_string("uniform", info.other_variables)
				build_output[shader].other_variables = translate_fields(info.other_variables)
			end

			info.template = replace_field(info.template, "VARIABLES", uniform_block .. other)
			build_output[shader].ubo_variables = ubo_variables
		end
	else
		for shader, info in pairs(data) do
			if info.variables then
				info.template = replace_field(info.template, "VARIABLES", variables_to_string("uniform", info.variables))
				build_output[shader].variables = translate_fields(info.variables)
			end
		end
	end

	for shader, info in pairs(data) do
		local template = info.template

		if info.mesh_layout then
			if shader == "vertex" then
				-- in highp vec3 foo;
				template = replace_field(template, "IN", variables_to_string("in", info.mesh_layout))
				build_output[shader].mesh_layout = translate_fields(info.mesh_layout)
			else
				-- in highp vec3 glw_out_foo;
				-- #define foo glw_out_foo
				template = replace_field(template, "IN", variables_to_string("in", info.mesh_layout, reserve_prepend, true, shader == "tess_control" and "[]"))
			end
		end

		if info.source then
			if info.source:find("\n") then
				if not info.source:find("main", nil, true) and info.source:find("return", nil, true) then
					info.source = lazy_template:format(info.source)
				end

			--	source = replace_field(source, "SOURCE", ("void mainx()\n{\n\t%s\n}\n"):format(info.source))
				-- replace void *main* () with mainx
				info.source = info.source:gsub("void%s+([main]-)%s-%(", function(str) if str == "main" then return "void mainx(" end end)

				template = replace_field(template, "SOURCE", info.source)
			else
				-- if it's just a single line then wrap void mainx() {*line*} around it
				template = replace_field(template, "SOURCE", ("void mainx()\n{\n\t%s\n}\n"):format(info.source))
			end

			local extensions = {}

			if system.IsOpenGLExtensionSupported("GL_ARB_shading_language_420pack") then
				table.insert(extensions, "#extension GL_ARB_shading_language_420pack : enable")
			end

			if system.IsOpenGLExtensionSupported("GL_ARB_bindless_texture") then
				table.insert(extensions, "#extension GL_ARB_bindless_texture : enable")
			end

			template = template:gsub("(#extension%s-[%w_]+%s-:%s-%w+)", function(extension)
				table.insert(extensions, extension)
				return ""
			end)

			if #extensions > 0 then
				template = template:gsub("(#version.-\n)", function(str)
					return str .. table.concat(extensions, "\n")
				end)
			end

			-- get line numbers for errors
			build_output[shader].line_start = select(2, template:match(".+__SOURCE_START"):gsub("\n", "")) + 2
			build_output[shader].line_end = select(2, template:match(".+__SOURCE_END"):gsub("\n", ""))
		end

		build_output[shader].source = template
	end

	if BUILD_SHADER_OUTPUT then
		serializer.WriteFile("luadata", "shader_builder_output/" .. shader_id .. "/build_output.lua", build_output)
	end

	local prog = assert(render.CreateShaderProgram())

	for shader_type, data in pairs(build_output) do
		-- strip data that wasnt found from the source_template
		data.source = data.source:gsub("(@@.-@@)", "")

		if BUILD_SHADER_OUTPUT then
			vfs.Write("data/shader_builder_output/" .. shader_id .. "/" .. shader_type .. ".c", data.source)
		end

		local ok, message = pcall(prog.CompileShader, prog, shader_type, data.source)

		if not ok then
			local extensions = {}
			message:gsub("#extension ([%w_]+)", function(extension)
				table.insert(extensions, "#extension " .. extension .. ": enable")
			end)
			if #extensions > 0 then
				local source = data.source:gsub("(#version.-\n)", function(str)
					return str .. table.concat(extensions, "\n")
				end)
				local ok2, message2 = pcall(prog.CompileShader, prog, shader_type, source)
				if not ok2 then
					data.source = source
					message = message .. "\nshader_builder.lua attempted to add " .. table.concat(extensions, ", ") .. " but failed: \n" .. message2
				end
			end
		end

		if not ok then
			local error_depth = 2

			for i = error_depth, 20 do
				local info = debug.getinfo(i)

				if not info then break end
				local path = info.source

				if path then
					path = path:sub(2)

					local lua_file = vfs.Read(e.ROOT_FOLDER .. path)

					if lua_file then
						local source = data.original_source

						local start = lua_file:find(source, 0, true)

						local line_offset

						if start then
							line_offset = lua_file:sub(0, start):count("\n")

							local err = path .. ":" .. line_offset .. "\n" .. shader_id .. "\n" .. message

							local goto_line

							err = err:gsub("0%((%d+)%) ", function(line)
								line = tonumber(line)
								goto_line = line - data.line_start + line_offset
								return "\n" .. path .. ":" .. goto_line .. "\n\t"
							end)

							debug.openscript(path, tonumber(goto_line))

							error(err, i)
						end
					else
						break
					end
				end
			end

			vfs.Write("data/logs/last_shader_error.c", data.source)
			debug.openscript("data/logs/last_shader_error.c", tonumber(message:match("0%((%d+)%) ")))

			logn(message)
			error("\n" .. shader_id .. "\n" .. message, error_depth)
		end
	end

	local self = META:CreateObject()

	for _, info in pairs(data) do
		if info.source_path then
			vfs.MonitorFile(info.source_path, function()
				self:Rebuild()
			end)
		end
	end

	prog:Link()

	for i, val in pairs(build_output.vertex.mesh_layout) do
		prog:BindAttribLocation(i - 1, val.name)
	end

	self.mesh_layout = table.copy(build_output.vertex.mesh_layout)

	do -- build lua code from variables data
		local variables = {}
		local all_variables = {}
		local uniform_variables = {}
		local uniform_block_variables = {}

		self.defaults = {} -- default values for shaders

		for shader, data in pairs(build_output) do
			if data.ubo_variables then
				for key, val in pairs(data.ubo_variables) do
					self.defaults[val.name] = val.default
					self[val.name] = val.default

					if val.get then
						self[val.name] = val.get
					end

					variables[val.name] = val
					all_variables[val.name] = val
					table.insert(uniform_block_variables, {id = id, key = val.name, val = val})
				end
			end

			local vars = data.other_variables or data.variables

			if vars then
				for key, val in pairs(vars) do
					local id = prog:GetUniformLocation(val.name)

					if id > -1 then
						self.defaults[val.name] = val.default
						self[val.name] = val.default

						if val.get then
							self[val.name] = val.get
						end

						variables[val.name] = val
						table.insert(uniform_variables, {id = id, key = val.name, val = val})
					elseif render.debug and not val.is_texture then
						logf("%s: variables in %s %s %s is not being used (variables location < 0)\n", shader_id, shader, val.name, val.type)
					end

					all_variables[val.name] = val
				end
			end
		end

		self.variables = variables
		self.all_variables = all_variables

		table.sort(uniform_variables, function(a, b) return a.id < b.id end) -- sort the data by variables id

		local texture_channel = 0
		local lua = ""

		lua = lua .. "local ffi = require(\"ffi\")\n"
		lua = lua .. "local render = _G.render\n"
		lua = lua .. "local type = _G.type\n"
		lua = lua .. "local val = nil\n"
		lua = lua .. "local function update(self, mat)\n"

		for _, data in ipairs(uniform_variables) do
			local line = tostring(unrolled_lines[data.val.type] or data.val.type)

			if data.val.is_texture then
				line = line:format(data.id, texture_channel, texture_channel)
				texture_channel = texture_channel + 1
			else
				line = line:format(data.id)
			end

			lua = lua ..
[[
	val = mat and mat.]] .. data.key .. [[ or self.]]..data.key..[[

	if type(val) == 'function' then
		val = val()
	end

	if val ~= nil then
		]]..line..[[
	end
]]
		end

		for _, data in ipairs(uniform_block_variables) do
			local line = ""
			lua = lua ..
[[
	val = mat and mat.]] .. data.key .. [[ or self.]]..data.key..[[

	if type(val) == 'function' then
		val = val()
	end

	if val ~= nil then
		(mat and mat.ubo or self.ubo):UpdateVariable("]]..data.key..[[", val)
	end
]]
		end

		lua = lua .. "end\n"
		if BUILD_SHADER_OUTPUT then
			lua = lua .. "if RELOAD then\n\trender.active_shaders[\""..shader_id.."\"].unrolled_bind_func = update\nend\n"
		end
		lua = lua .. "return update"

		if BUILD_SHADER_OUTPUT then
			vfs.Write("data/shader_builder_output/" .. shader_id .. "/unrolled_lines.lua", lua)
			serializer.WriteFile("luadata", "shader_builder_output/" .. shader_id .. "/variables.lua", variables)

			local path = "data/shader_builder/" .. shader_id .. "_unrolled.lua"
			vfs.Write(path, lua)

			local RELOAD = _G.RELOAD
			if RELOAD then _G.RELOAD = nil end
			self.unrolled_bind_func = assert(vfs.dofile(path))
			if RELOAD then _G.RELOAD = RELOAD end
		else
			self.unrolled_bind_func = assert(loadstring(lua, shader_id))()
		end
	end

	self.original_data = original_data
	self.data = data
	self.base_shader = base

	self.vtx_atrb_type = build_output.vertex.vtx_atrb_type
	self.program = prog
	self.shader_id = shader_id
	self.build_output = build_output
	self.force_bind = force_bind

	if render.use_uniform_buffers then
		self.ubo = self:CreateUniformBuffer()
	end

	render.active_shaders[shader_id] = self

	for obj in pairs(prototype.GetCreated()) do
		if obj.Type == "vertex_buffer" and obj.Shader and obj.Shader.shader_id == shader_id then
			obj.Shader = self
		end
	end

	return self
end

function META:__tostring2()
	return self.shader_id
end

function META:Bind()
	if render.current_program ~= self.program then
		self.program:Bind()
		render.current_program = self.program
	end

	if render.use_uniform_buffers then
		if render.current_material and (not render.current_material.required_shader or render.current_material.required_shader == self.shader_id or self.force_bind) then
			--render.current_material.ubo:SetBindLocation(self, 0)
			render.current_material.ubo:Bind(0)
		else
			--self.ubo:SetBindLocation(self, 0)
			self.ubo:Bind(0)
		end
	end

	self.unrolled_bind_func(self, render.current_material and (not render.current_material.required_shader or render.current_material.required_shader == self.shader_id or self.force_bind) and render.current_material)
end

function META:CreateMaterialTemplate(name)
	local META = render.CreateMaterialTemplate(name or self.shader_id, self)

	prototype.StartStorable()
		for k,v in pairs(self.all_variables) do
			if not render.global_shader_variables[k] then
				META:GetSet(v.name, v.default)
			end
		end
	prototype.EndStorable()

	META.required_shader = self.shader_id

	return META
end

function META:CreateUniformBuffer()
	if render.use_uniform_buffers then
		local ubo = render.CreateShaderVariables("uniform", self, "variables")
		ubo:SetBindLocation(self, 0)
		return ubo
	end
end

function META:GetMeshLayout()
	return self.mesh_layout
end

function META:Rebuild()
	table.clear(self)
	prototype.OverrideCreateObjectTable(self)
	render.CreateShader(self.original_data)
	prototype.OverrideCreateObjectTable()
end

prototype.Register(META)

function render.RebuildShaders()
	for _, shader in pairs(render.active_shaders) do
		shader:Rebuild()
	end
end

if RELOAD then
	--render.RebuildShaders()
end