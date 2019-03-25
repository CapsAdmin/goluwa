local render = ... or _G.render

if not render.IsExtensionSupported("ARB_shader_objects") then
	runfile("../null/shader_program.lua", render)
	return
end

local gl = require("opengl")
local ffi = require("ffi")

local META = prototype.CreateTemplate("shader_program")

function render.CreateShaderProgram()
	local self = META:CreateObject()
	self.shaders = {}
	return self
end

function META:CompileShader(type, source)
	local shader = gl.CreateShader2("GL_" .. type:upper() .. "_SHADER")

	local shader_strings = ffi.new("const GLchar * [1]", ffi.cast("const GLchar *", source))
	shader:Source(1, shader_strings, nil)
	shader:Compile()

	local log_length = ffi.new("GLint[1]", 0)
	shader:Getiv("GL_INFO_LOG_LENGTH", log_length)

	if log_length[0] > 0 then
		local log = ffi.new("GLchar[?]", log_length[0])
		local size = ffi.new("GLsizei[1]")
		shader:GetInfoLog(1024, size, log)
		shader:Delete()

		error(ffi.string(log, size[0]), 2)
	end

	table.insert(self.shaders, shader)
end

function META:Link()
	self.gl_program = gl.CreateProgram2()

	for _, shader in pairs(self.shaders) do
		self.gl_program:AttachShader(shader.id)
	end

	self.gl_program:Link()

	local status = ffi.new("GLint[1]", 1)
	self.gl_program:Getiv("GL_LINK_STATUS", status)

	if status[0] == 0 then
		local log = ffi.new("GLchar[1024]")
		local size = ffi.new("GLsizei[1]")
		self.gl_program:GetInfoLog(1024, size, log)
		self.gl_program:Delete()

		error(ffi.string(log, size[0]), 2)
	end

	for _, shader in pairs(self.shaders) do
		self.gl_program:DetachShader(shader.id)
		shader:Delete()
	end
end

do
	local fill_info = {
		--[[GL_ATOMIC_COUNTER_SHADER = {
			GL_NAME_LENGTH = true,
			GL_REFERENCED_BY_FRAGMENT_SHADER = true,
			GL_REFERENCED_BY_GEOMETRY_SHADER = true,
			GL_REFERENCED_BY_VERTEX_SHADER = true,
			GL_REFERENCED_BY_TESS_CONTROL_SHADER = true,
			GL_REFERENCED_BY_TESS_EVALUATION_SHADER = true,
			GL_REFERENCED_BY_COMPUTE_SHADER = true,
		},]]
		GL_BUFFER_VARIABLE = {
			GL_NAME_LENGTH = true,
			GL_OFFSET = true,
			GL_REFERENCED_BY_FRAGMENT_SHADER = true,
			GL_BLOCK_INDEX = true,
			GL_TOP_LEVEL_ARRAY_SIZE = true,
			GL_REFERENCED_BY_VERTEX_SHADER = true,
			GL_MATRIX_STRIDE = true,
			GL_TOP_LEVEL_ARRAY_STRIDE = true,
			GL_ARRAY_STRIDE = true,
			GL_IS_ROW_MAJOR = true,
			GL_ARRAY_SIZE = true,
			GL_REFERENCED_BY_GEOMETRY_SHADER = true,
			GL_TYPE = true,
			GL_REFERENCED_BY_TESS_CONTROL_SHADER = true,
			GL_REFERENCED_BY_TESS_EVALUATION_SHADER = true,
			GL_REFERENCED_BY_COMPUTE_SHADER = true,
		},
		GL_TRANSFORM_FEEDBACK_VARYING = {
			GL_NAME_LENGTH = true,
			GL_OFFSET = true,
			GL_ARRAY_SIZE = true,
			GL_TYPE = true,
			GL_TRANSFORM_FEEDBACK_BUFFER_INDEX = true,
		},
		GL_UNIFORM = {
			GL_NAME_LENGTH = true,
			GL_OFFSET = true,
			GL_REFERENCED_BY_FRAGMENT_SHADER = true,
			GL_TYPE = true,
			GL_LOCATION = true,
			GL_REFERENCED_BY_VERTEX_SHADER = true,
			GL_MATRIX_STRIDE = true,
			GL_REFERENCED_BY_COMPUTE_SHADER = true,
			GL_IS_ROW_MAJOR = true,
			GL_REFERENCED_BY_GEOMETRY_SHADER = true,
			GL_ARRAY_SIZE = true,
			GL_ARRAY_STRIDE = true,
			GL_BLOCK_INDEX = true,
			GL_REFERENCED_BY_TESS_CONTROL_SHADER = true,
			GL_REFERENCED_BY_TESS_EVALUATION_SHADER = true,
			GL_ATOMIC_COUNTER_BUFFER_INDEX = true,
		},
		GL_UNIFORM_BLOCK = {
			GL_NAME_LENGTH = true,
			GL_REFERENCED_BY_FRAGMENT_SHADER = true,
			GL_BUFFER_BINDING = true,
			GL_REFERENCED_BY_VERTEX_SHADER = true,
			GL_NUM_ACTIVE_VARIABLES = true,
			GL_REFERENCED_BY_GEOMETRY_SHADER = true,
			GL_REFERENCED_BY_COMPUTE_SHADER = true,
			GL_REFERENCED_BY_TESS_CONTROL_SHADER = true,
			GL_REFERENCED_BY_TESS_EVALUATION_SHADER = true,
			GL_BUFFER_DATA_SIZE = true,
		},
		GL_PROGRAM_INPUT = {
			GL_NAME_LENGTH = true,
			GL_REFERENCED_BY_FRAGMENT_SHADER = true,
			GL_TYPE = true,
			GL_IS_PER_PATCH = true,
			GL_REFERENCED_BY_VERTEX_SHADER = true,
			GL_LOCATION = true,
			GL_REFERENCED_BY_GEOMETRY_SHADER = true,
			GL_LOCATION_COMPONENT = true,
			GL_ARRAY_SIZE = true,
			GL_REFERENCED_BY_TESS_CONTROL_SHADER = true,
			GL_REFERENCED_BY_TESS_EVALUATION_SHADER = true,
			GL_REFERENCED_BY_COMPUTE_SHADER = true,
		},
		GL_TRANSFORM_FEEDBACK_BUFFER = {
			GL_TRANSFORM_FEEDBACK_BUFFER_STRIDE = true,
		},
		GL_SHADER_STORAGE_BLOCK = {
			GL_NAME_LENGTH = true,
			GL_REFERENCED_BY_FRAGMENT_SHADER = true,
			GL_BUFFER_BINDING = true,
			GL_REFERENCED_BY_VERTEX_SHADER = true,
			GL_NUM_ACTIVE_VARIABLES = true,
			GL_REFERENCED_BY_GEOMETRY_SHADER = true,
			GL_REFERENCED_BY_COMPUTE_SHADER = true,
			GL_ACTIVE_VARIABLES = true,
			GL_REFERENCED_BY_TESS_CONTROL_SHADER = true,
			GL_REFERENCED_BY_TESS_EVALUATION_SHADER = true,
			GL_BUFFER_DATA_SIZE = true,
		},
		GL_ATOMIC_COUNTER_BUFFER = {
			GL_BUFFER_BINDING = true,
			GL_ACTIVE_VARIABLES = true,
			GL_NUM_ACTIVE_VARIABLES = true,
			GL_BUFFER_DATA_SIZE = true,
		},
		GL_PROGRAM_OUTPUT = {
			GL_NAME_LENGTH = true,
			GL_REFERENCED_BY_FRAGMENT_SHADER = true,
			GL_TYPE = true,
			GL_LOCATION_INDEX = true,
			GL_REFERENCED_BY_VERTEX_SHADER = true,
			GL_LOCATION = true,
			GL_IS_PER_PATCH = true,
			GL_REFERENCED_BY_GEOMETRY_SHADER = true,
			GL_LOCATION_COMPONENT = true,
			GL_ARRAY_SIZE = true,
			GL_REFERENCED_BY_TESS_CONTROL_SHADER = true,
			GL_REFERENCED_BY_TESS_EVALUATION_SHADER = true,
			GL_REFERENCED_BY_COMPUTE_SHADER = true,
		},
	}

	if render.IsExtensionSupported("ARB_tessellation_shader") then
		fill_info.GL_TESS_CONTROL_SUBROUTINE_UNIFORM = {
			GL_NAME_LENGTH = true,
			GL_COMPATIBLE_SUBROUTINES = true,
			GL_LOCATION = true,
			GL_ARRAY_SIZE = true,
			GL_NUM_COMPATIBLE_SUBROUTINES = true,
		}
		fill_info.GL_TESS_EVALUATION_SUBROUTINE_UNIFORM = {
			GL_NAME_LENGTH = true,
			GL_COMPATIBLE_SUBROUTINES = true,
			GL_LOCATION = true,
			GL_ARRAY_SIZE = true,
			GL_NUM_COMPATIBLE_SUBROUTINES = true,
		}
	end

	if render.IsExtensionSupported("ARB_shader_subroutine") then
		fill_info.GL_VERTEX_SUBROUTINE_UNIFORM = {
			GL_NAME_LENGTH = true,
			GL_ARRAY_SIZE = true,
		}
		fill_info.GL_FRAGMENT_SUBROUTINE_UNIFORM = {
			GL_NAME_LENGTH = true,
			GL_COMPATIBLE_SUBROUTINES = true,
			GL_LOCATION = true,
			GL_ARRAY_SIZE = true,
			GL_NUM_COMPATIBLE_SUBROUTINES = true,
		}
		fill_info.GL_VERTEX_SUBROUTINE_UNIFORM = {
			GL_NAME_LENGTH = true,
			GL_LOCATION = true,
			GL_COMPATIBLE_SUBROUTINES = true,
			GL_NUM_COMPATIBLE_SUBROUTINES = true,
		}
		fill_info.GL_COMPUTE_SUBROUTINE_UNIFORM = {
			GL_NAME_LENGTH = true,
			GL_COMPATIBLE_SUBROUTINES = true,
			GL_LOCATION = true,
			GL_ARRAY_SIZE = true,
			GL_NUM_COMPATIBLE_SUBROUTINES = true,
		}
		fill_info.GL_GEOMETRY_SUBROUTINE_UNIFORM = {
			GL_NAME_LENGTH = true,
			GL_COMPATIBLE_SUBROUTINES = true,
			GL_LOCATION = true,
			GL_ARRAY_SIZE = true,
			GL_NUM_COMPATIBLE_SUBROUTINES = true,
		}
	end

	if not render.IsExtensionSupported("ARB_compute_shader") then
		for k,v in pairs(fill_info) do
			for k in pairs(v) do
				if k:find("COMPUTE_SHADER") then
					v[k] = nil
				end
			end
		end
	end

	local type_translate = {
		float = {name = "float", size = 4},
		float_vec2 = {name = "vec2", size = 8},
		float_vec3 = {name = "vec3", size = 12},
		float_vec4 = {name = "vec4", size = 16},
		double = {name = "double", size = 8},
		double_vec2 = {name = "dvec2", size = 16},
		double_vec3 = {name = "dvec3", size = 24},
		double_vec4 = {name = "dvec4", size = 32},
		int = {name = "int", size = 4},
		int_vec2 = {name = "ivec2", size = 8},
		int_vec3 = {name = "ivec3", size = 12},
		int_vec4 = {name = "ivec4", size = 16},
		unsigned_int = {name = "unsigned int", size = 4},
		unsigned_int_vec2 = {name = "uvec2", size = 8},
		unsigned_int_vec3 = {name = "uvec3", size = 12},
		unsigned_int_vec4 = {name = "uvec4", size = 16},
		bool = {name = "bool", size = 4},
		bool_vec2 = {name = "bvec2", size = 8},
		bool_vec3 = {name = "bvec3", size = 12},
		bool_vec4 = {name = "bvec4", size = 16},

		float_mat2 = {name = "mat2", size = 16},
		float_mat3 = {name = "mat3", size = 36},
		float_mat4 = {name = "mat4", size = 64},
		float_mat2x3 = {name = "mat2x3", size = 24},
		float_mat3x2 = {name = "mat3x2", size = 24},
		float_mat2x4 = {name = "mat2x4", size = 32},
		float_mat4x2 = {name = "mat4x2", size = 32},
		float_mat3x4 = {name = "mat3x4", size = 48},
		float_mat4x3 = {name = "mat4x3", size = 48},


		double_mat2 = {name = "dmat2", size = 32},
		double_mat3 = {name = "dmat3", size = 72},
		double_mat4 = {name = "dmat4", size = 128},
		double_mat2x3 = {name = "dmat2x3", size = 48},
		double_mat3x2 = {name = "dmat3x2", size = 48},
		double_mat2x4 = {name = "dmat2x4", size = 64},
		double_mat4x2 = {name = "dmat4x2", size = 64},
		double_mat3x4 = {name = "dmat3x4", size = 96},
		double_mat4x3 = {name = "dmat4x3", size = 96},
		sampler_1d = {name = "sampler1d"},
		sampler_2d = {name = "sampler2d"},
		sampler_3d = {name = "sampler3d"},
		sampler_cube = {name = "samplercube"},
		sampler_1d_shadow = {name = "sampler1dshadow"},
		sampler_2d_shadow = {name = "sampler2dshadow"},
		sampler_1d_array = {name = "sampler1darray"},
		sampler_2d_array = {name = "sampler2darray"},
		sampler_1d_array_shadow = {name = "sampler1darrayshadow"},
		sampler_2d_array_shadow = {name = "sampler2darrayshadow"},
		sampler_2d_multisample = {name = "sampler2dms"},
		sampler_2d_multisample_array = {name = "sampler2dmsarray"},
		sampler_cube_shadow = {name = "samplercubeshadow"},
		sampler_buffer = {name = "samplerbuffer"},
		sampler_2d_rect = {name = "sampler2drect"},
		sampler_2d_rect_shadow = {name = "sampler2drectshadow"},
		int_sampler_1d = {name = "isampler1d"},
		int_sampler_2d = {name = "isampler2d"},
		int_sampler_3d = {name = "isampler3d"},
		int_sampler_cube = {name = "isamplercube"},
		int_sampler_1d_array = {name = "isampler1darray"},
		int_sampler_2d_array = {name = "isampler2darray"},
		int_sampler_2d_multisample = {name = "isampler2dms"},
		int_sampler_2d_multisample_array = {name = "isampler2dmsarray"},
		int_sampler_buffer = {name = "isamplerbuffer"},
		int_sampler_2d_rect = {name = "isampler2drect"},
		unsigned_int_sampler_1d = {name = "usampler1d"},
		unsigned_int_sampler_2d = {name = "usampler2d"},
		unsigned_int_sampler_3d = {name = "usampler3d"},
		unsigned_int_sampler_cube = {name = "usamplercube"},
		unsigned_int_sampler_1d_array = {name = "usampler2darray"},
		unsigned_int_sampler_2d_array = {name = "usampler2darray"},
		unsigned_int_sampler_2d_multisample = {name = "usampler2dms"},
		unsigned_int_sampler_2d_multisample_array = {name = "usampler2dmsarray"},
		unsigned_int_sampler_buffer = {name = "usamplerbuffer"},
		unsigned_int_sampler_2d_rect = {name = "usampler2drect"},
	}


	local temp

	temp = {}
	for what, properties in pairs(fill_info) do
		local property_enums = {}
		local property_enums_tbl = {}
		local names = {}
		for enum in pairs(properties) do
			table.insert(property_enums, gl.e[enum])
			table.insert(property_enums_tbl, enum)
			table.insert(names, enum:sub(4):lower())
		end

		temp[what] = {
			enums = ffi.new("const GLenum["..#names.."]", property_enums),
			enumstbl = property_enums_tbl,
			count = #names,
			names = names
		}
	end
	fill_info = temp

	temp = {}
	for k,v in pairs(type_translate) do
		pcall(function() temp[gl.e[("gl_" .. k):upper()]] = v end)
	end
	type_translate = temp

	if render.IsExtensionSupported("ARB_program_interface_query") then
		function META:GetProperties()
			local out = {}

			for what, property_info in pairs(fill_info) do
				local resource_count = ffi.new("GLint[1]")
				self.gl_program:GetInterface(what, "GL_ACTIVE_RESOURCES", resource_count)
				resource_count = resource_count[0]

				local properties = {}

				for resource_index = 0, resource_count - 1 do

					local res = ffi.new("GLint["..property_info.count.."]")
					local len = ffi.new("GLsizei[1]")
					self.gl_program:GetResource(what, resource_index, property_info.count, property_info.enums, property_info.count, len, res)

					local values = {}

					for i = 1, property_info.count do
						local key = property_info.names[i]
						local val = res[i - 1]

						if key == "name_length" then
							local bytes = val
							local str = ffi.new("GLchar[?]", bytes)
							self.gl_program:GetResourceName(what, resource_index, bytes, nil, str)
							val = ffi.string(str)
							key = "name"
						elseif key == "type" then
							val = type_translate[val] or val
						end

						values[key] = val
					end
					--[[
					if what == "GL_UNIFORM_BLOCK" then
						local res = ffi.new("GLint[1]")
						local props = ffi.new("const GLenum[?]", gl.e.GL_NUM_ACTIVE_VARIABLES)
						self.gl_program:GetResource(what, resource_index, 1, props, 1, len, res)
						local count = res[0]
						count = len[0]

						print("active variables: ", count, len[0])
						if count > 0 then
							local res = ffi.new("GLint[?]", count)
							local props = ffi.new("const GLenum[?]", gl.e.GL_ACTIVE_VARIABLES)
							self.gl_program:GetResource(what, resource_index, count, props, count, len, res)
							for i = 0, count - 1 do
								print(res[0])
							end
						end
					end
					]]

					table.insert(properties, values)
				end

				if next(properties) then
					out[what:sub(4):lower()] = properties
				end
			end


			if out.buffer_variable then
				for _, info in ipairs(out.buffer_variable) do
					local i = info.block_index + 1
					out.shader_storage_block[i].variables = out.shader_storage_block[i].variables or {}
					table.insert(out.shader_storage_block[i].variables, info)
				end
				out.buffer_variable = nil

				for _, info in pairs(out.shader_storage_block) do
					info.block_index = self.gl_program:GetResourceIndex("GL_SHADER_STORAGE_BLOCK", info.name)
					out.shader_storage_block[info.name] = info
				end
			end

			if out.uniform_block then
				for i2, info in ipairs(out.uniform) do
					if info.block_index >= 0 then
						local i = info.block_index + 1
						out.uniform_block[i].variables = out.uniform_block[i].variables or {}
						table.insert(out.uniform_block[i].variables, info)
						out.uniform[i2] = nil
					end
				end
				out.buffer_variable = nil

				for _, info in pairs(out.uniform_block) do
					info.block_index = self.gl_program:GetResourceIndex("GL_UNIFORM_BLOCK", info.name)
					out.uniform_block[info.name] = info
				end
			end

			return out
		end
	else
		function META:GetProperties()
			local out = {}

			return out
		end
	end

	function META:GetUniformData(key)
		local out = {}

		out.block_index = self:GetUniformBlockIndex(key)

		for _, v in ipairs({
			"GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER",
			"GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_CONTROL_SHADER",
			"GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_EVALUATION_SHADER",
			"GL_UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER",
			"GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER",
			"GL_UNIFORM_BLOCK_REFERENCED_BY_COMPUTE_SHADER",
		}) do

			local ptr = ffi.new("GLint[1]")
			self:GetActiveUniformBlock(out.block_index, v, ptr)
			out[v:sub(18):lower()] = ptr[0]
		end

		local ptr = ffi.new("GLint[1]")
		self:GetActiveUniformBlock(out.block_index, "GL_UNIFORM_BLOCK_NAME_LENGTH", ptr)
		local strptr = ffi.new("uint8_t[?]", ptr[0])
		self:GetActiveUniformBlockName(out.block_index, ptr[0], nil, strptr)
		out.name = ffi.string(strptr)

		local ptr = ffi.new("GLint[1]")
		self:GetActiveUniformBlock(out.block_index, "GL_UNIFORM_BLOCK_DATA_SIZE", ptr)
		out.buffer_data_size = ptr[0]

		local ptr = ffi.new("GLint[1]")
		self:GetActiveUniformBlock(out.block_index, "GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS", ptr)
		out.active_uniforms = ptr[0]

		out.variables = {}

		local ptr = ffi.new("GLint[?]", out.active_uniforms)
		self:GetActiveUniformBlock(out.block_index, "GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES", ptr)
		for i = 0, out.active_uniforms - 1 do
			local idx = ptr[i]

			local name, type = self:GetActiveUniform(idx)

			local tbl = {}

			tbl.location = idx
			tbl.name = name
			tbl.type = type
			tbl.offset = self:GetActiveUniforms({idx}, "GL_UNIFORM_OFFSET")[1]
			tbl.array_stride = self:GetActiveUniforms({idx}, "GL_UNIFORM_ARRAY_STRIDE")[1]
			tbl.matrix_stride = self:GetActiveUniforms({idx}, "GL_UNIFORM_MATRIX_STRIDE")[1]
			tbl.is_row_major = self:GetActiveUniforms({idx}, "GL_UNIFORM_IS_ROW_MAJOR")[1]
			tbl.atomic_counter_buffer_index = self:GetActiveUniforms({idx}, "GL_UNIFORM_ATOMIC_COUNTER_BUFFER_INDEX")[1]

			table.insert(out.variables, tbl)
		end

		return out
	end

	do -- GetProperties alternative
		function META:GetUniformBlockIndex(key)
			local location = self.gl_program:GetUniformBlockIndex(key)
			if location == gl.e.GL_INVALID_INDEX then
				return nil, "invalid index"
			end
			return location
		end

		function META:GetActiveUniformBlock(location, name, out)
			gl.GetActiveUniformBlockiv(self.gl_program.id, location, name, out)
		end

		function META:GetActiveUniformBlockName(location, bufsize, outlength, outname)
			gl.GetActiveUniformBlockName(self.gl_program.id, location, bufsize, outlength, outname)
		end

		function META:GetActiveUniform(idx)
			local enum_out = ffi.new("GLenum[1]")
			local name_out = ffi.new("uint8_t[256]")
			gl.GetActiveUniform(self.gl_program.id, idx, 256, nil, nil, enum_out, name_out)
			return ffi.string(name_out), type_translate[enum_out[0]] or enum_out[0]
		end

		function META:GetActiveUniforms(indices, pname)
			local out = ffi.new("GLint[?]", #indices)
			gl.GetActiveUniformsiv(self.gl_program.id, #indices, ffi.new("GLint[?]", unpack(indices)), pname, out)
			local tbl = {}
			for i = 1, #indices do
				tbl[i] = out[i-1]
			end
			return tbl
		end
	end
end

function META:BindShaderBlock(block_index, where)
	self.gl_program:ShaderStorageBlockBinding(block_index, where)
end

function META:BindUniformBuffer(block_index, where)
	self.gl_program:UniformBlockBinding(block_index, where)
end

function META:UploadBoolean(key, val)
	self.gl_program:Uniform1i(key, val and 1 or 0)
end

function META:UploadNumber(key, val)
	self.gl_program:Uniform1f(key, val)
end

function META:UploadInteger(key, val)
	self.gl_program:Uniform1i(key, val)
end

function META:UploadVec2(key, val)
	self.gl_program:Uniform2f(key, val.x, val.y)
end

function META:UploadVec3(key, val)
	self.gl_program:Uniform3f(key, val.x, val.y, val.z)
end

if SRGB then
	local linear2gamma = math.linear2gamma
	function META:UploadColor(key, val)
		self.gl_program:Uniform4f(key, linear2gamma(val.r), linear2gamma(val.g), linear2gamma(val.b), val.a)
	end
else
	function META:UploadColor(key, val)
		self.gl_program:Uniform4f(key, val.r, val.g, val.b, val.a)
	end
end

if render.IsExtensionSupported("ARB_bindless_texture") then
	function META:UploadTexture(key, val)
		if not val.gl_bindless_handle then
			val:SetBindless(true)
		end
		if val.Loading then val = render.GetLoadingTexture() end
		self.gl_program:UniformHandleui64(key, val.gl_bindless_handle)
	end
else
	function META:UploadTexture(key, val, a, location)
		self.gl_program:Uniform1i(key, a)
		val:Bind(location)
	end
end

function META:UploadMatrix44(key, val)
	self.gl_program:UniformMatrix4fv(key, 1, 0, val:GetFloatPointer())
end

function META:UploadMatrix33(key, val)
	self.gl_program:UniformMatrix3fv(key, 1, 0, val:GetFloatPointer())
end

function META:Bind()
	self.gl_program:Use()
end

function META:GetUniformLocation(key)
	return self.gl_program:GetUniformLocation(key)
end

function META:BindAttribLocation(i, name)
	self.gl_program:BindAttribLocation(i, name)
end

function META:OnRemove()
	if self.gl_program then
		self.gl_program:Delete()
	end
end

META:Register()
