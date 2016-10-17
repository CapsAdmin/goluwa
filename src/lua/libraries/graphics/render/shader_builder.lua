local BUILD_OUTPUT = false
local render = (...) or _G.render

-- used to figure out how to upload types
local unrolled_lines = {
	bool = "render.current_program:UploadBoolean(%i, val)",
	number = "render.current_program:UploadNumber(%i, val)",
	int = "render.current_program:UploadInteger(%i, val)",
	vec2 = "render.current_program:UploadVec2(%i, val)",
	vec3 = "render.current_program:UploadVec3(%i, val)",
	color = "render.current_program:UploadColor(%i, val)",
	mat4 = "render.current_program:UploadMatrix44(%i, val)",
	texture = "render.current_program:UploadTexture(%i, val, %i, %i)",
}

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

@@SHARED VARIABLES@@
@@VARIABLES@@

@@IN@@

@@OUT@@
@@OUT3@@
@@GLOBAL CODE@@
//__SOURCE_START
@@SOURCE@@
//__SOURCE_END
void main()
{
@@OUT2@@
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

		if t == "bool" or t:find("sampler") or t == "texture" then
			params.precision = ""
		end

		table.insert(out, {
			name = k,
			type = t,
			default = default,
			precision = params.precision or "highp",
			varying = params.varying and "varying" or "",
			get = get,
		})
	end

	return out
end

local function variables_to_string(type, variables, prepend, macro, array)
	array = array or ""
	local texture_channel = 0
	local out = {}

	for _, data in ipairs(translate_fields(variables)) do
		local name = data.name

		if prepend then
			name = prepend .. name
		end

		if data.type:find("sampler") then
			local layout = ""

			if system.IsOpenGLExtensionSupported("GL_ARB_enhanced_layouts") or system.IsOpenGLExtensionSupported("GL_ARB_shading_language_420pack") then
				layout = ("layout(binding = %i)"):format(texture_channel)
			end

			table.insert(out, ("%s %s %s %s %s %s%s;"):format(layout, data.varying, type, data.precision, data.type, name, array):trim())
			texture_channel = texture_channel + 1
		else
			table.insert(out, ("%s %s %s %s %s%s;"):format(data.varying, type, data.precision, data.type, name, array):trim())
		end

		if macro then
			table.insert(out, ("#define %s %s"):format(data.name, name))
		end
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
				source = "#version " .. str.. "\n" .. source
			end
		end

		build_output[shader] = {source = source, original_source = info.source, out = {}}
	end

	-- figure out vertex mesh_layout other shaders need only if vertex and fragment is defined
	-- since tesselation and geometry requires specialized input and output
	if data.vertex and data.fragment and table.count(data) == 2 then
		for shader, info in pairs(data) do
			if shader ~= "vertex" then
				if info.mesh_layout then
					for i, v in ipairs(info.mesh_layout) do
						build_output.vertex.out[i] = v
					end
				end
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

		template = replace_field(template, "GLOBAL CODE", render.GetGlobalShaderCode(info.source))
		template = preprocess(template, info)

		if info.source then
			info.source = preprocess(info.source, info)
		end

		local variables = {}

		if info.variables then
			for k,v in pairs(info.variables) do
				variables[k] = v
			end
		end

		if info.source then
			for k,v in pairs(render.global_shader_variables) do
				if not SSBO or v.type:find("sampler") then
					local p = [==[[!"#$%&'%(%)*+,-./:;<=>?@%[\%]^`{|}~%s]]==]
					if info.source:find(p..k..p) or template:find(p..k..p) then
						variables[k] = v
					end
				end
			end
		end

--table.print(variables)

		template = replace_field(template, "VARIABLES", variables_to_string("uniform", variables, nil, nil, nil, shader .. "_Variables"))
		build_output[shader].variables = translate_fields(variables)

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

	-- shared variables across all shaders
	if shared and shared.variables then
		for shader in pairs(data) do
			if build_output[shader] then
				build_output[shader].source = replace_field(build_output[shader].source, "SHARED VARIABLES", variables_to_string("uniform", shared.variables))
			end
		end

		-- merge shared variables to vertex so they can be used
		for _, v in pairs(translate_fields(shared.variables)) do
			table.insert(build_output.vertex.variables, v)
		end
	end

	if BUILD_OUTPUT then
		serializer.WriteFile("luadata", "shader_builder_output/" .. shader_id .. "/build_output.lua", build_output)
	end

	local prog = assert(render.CreateShaderProgram())

	for shader_type, data in pairs(build_output) do
		-- strip data that wasnt found from the source_template
		data.source = data.source:gsub("(@@.-@@)", "")

		if BUILD_OUTPUT then
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
						lua_file = lua_file:gsub("[ %t\r]", "")

						local source = data.original_source:gsub("[ %t\r]", "")
						local start = lua_file:find(source, 0, true)
						local line_offset

						if start then
							line_offset = lua_file:sub(0, start):count("\n")

							local err = "\n" .. shader_id .. "\n" .. message

							if path then
								err = (path:match(".+/(.+)") or path) .. ":" .. err
							end

							local goto_line

							err = err:gsub("0%((%d+)%) ", function(line)
								line = tonumber(line)
								goto_line = line - data.line_start + 1 + line_offset
								return goto_line
							end)

							if path then
								debug.openscript(path, tonumber(goto_line))
							else
								debug.openfunction(info.func, tonumber(goto_line))
							end

							error(err, i)
						end
					else
						break
					end
				end
			end

			vfs.Write("data/logs/last_shader_error.c", data.source)
			debug.openscript("data/logs/last_shader_error.c", tonumber(message:match("0%((%d+)%) ")))

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
		local temp = {}

		self.defaults = {} -- default values for shaders

		for shader, data in pairs(build_output) do
			if data.variables then
				for _, val in pairs(data.variables) do
					local id = prog:GetUniformLocation(val.name)

					if id > -1 then
						self.defaults[val.name] = val.default
						self[val.name] = val.default

						if val.get then
							self[val.name] = val.get
						end

						variables[val.name] = {
							info = val,
						}

						table.insert(temp, {id = id, key = val.name, val = val})
					elseif render.debug and id < 0 and not val.type:find("sampler") then
						logf("%s: variables in %s %s %s is not being used (variables location < 0)\n", shader_id, shader, val.name, val.type)
					end
				end
			end
		end

		self.variables = variables

		table.sort(temp, function(a, b) return a.id < b.id end) -- sort the data by variables id

		local texture_channel = 0
		local lua = ""

		lua = lua .. "local ffi = require(\"ffi\")\n"
		lua = lua .. "local render = _G.render\n"
		lua = lua .. "local type = _G.type\n"
		lua = lua .. "local function update(self)\n"

		for _, data in ipairs(temp) do
			local line = tostring(unrolled_lines[data.val.type] or data.val.type)

			if data.val.type == "texture" or data.val.type:find("sampler") then
				line = line:format(data.id, texture_channel, texture_channel)
				texture_channel = texture_channel + 1
			else
				line = line:format(data.id)
			end

			lua = lua .. "\tif render.current_material and (not render.current_material.required_shader or render.current_material.required_shader == self or self.force_bind) and "
			lua = lua .. "render.current_material."..data.key.." ~= nil then\n \t\tlocal val = render.current_material." .. data.key .. "\n\t\t" .. line .. "\n\telse"
			lua = lua .. "if self." .. data.key .. " ~= nil then\n"
			lua = lua .. "\t\tlocal val = self."..data.key.."\n"
			lua = lua .. "\t\tif type(val) == 'function' then val = val() end\n"
			lua = lua .. "\t\t"..line.."\n\tend\n\n"
		end

		lua = lua .. "end\n"
		if BUILD_OUTPUT then
			lua = lua .. "if RELOAD then\n\trender.active_shaders[\""..shader_id.."\"].unrolled_bind_func = update\nend\n"
		end
		lua = lua .. "return update"

		if BUILD_OUTPUT then
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

	if SSBO then
		if not render.global_variables_ssbo then
			prog:BindShaderBlock(render.GetGlobalShaderBlockIndex(prog:GetProperties().shader_storage_block.global_variables))
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
	self.unrolled_bind_func(self)
end

function META:CreateMaterialTemplate(name)
	local META = render.CreateMaterialTemplate(name or self.shader_id, self)

	prototype.StartStorable()
		for k,v in pairs(self.variables) do
			if not render.global_shader_variables[k] then
				META:GetSet(v.info.name, v.info.default)
			end
		end
	prototype.EndStorable()

	return META
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