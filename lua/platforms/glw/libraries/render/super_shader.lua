render.active_super_shaders = render.active_super_shaders or {}


local function REMOVE_THE_NEED_FOR_THIS_FUNCTION(output)
	local found = {}

	for key, val in pairs(output[1]) do
		if hasindex(val) and val.Unpack then
			found[key] = true
		end
	end
	
	if next(found) then
		for index, struct in pairs(output) do
			for key, val in pairs(struct) do
				if found[key] then
					struct[key] = {val:Unpack()}
				end
			end
		end
	end
end

function render.CreateVertexBufferForSuperShader(mat, tbl)
	REMOVE_THE_NEED_FOR_THIS_FUNCTION(tbl)

	return ffi.new(mat.vtx_atrb_type.."["..#tbl.."]", tbl)
end

do
	local unrolled_lines = {
		number = "render.Uniform1f(%i, val)",
		
		vec2 = "render.Uniform2f(%i, val.x, val.y)",
		vec3 = "render.Uniform3f(%i, val.x, val.y, val.z)",
		
		color = "render.Uniform4f(%i, val.r, val.g, val.b, val.a)",
		
		mat4 = "render.UniformMatrix4fv(%i, 1, 0, val)",
		
		texture = "render.BindTexture(val, %i)", 
	}
	
	unrolled_lines.vec4 = unrolled_lines.color
	unrolled_lines.sampler2D = unrolled_lines.texture
	unrolled_lines.float = unrolled_lines.number
	
	local gl_enum_types = {
		float = e.GL_FLOAT,
	}

	local arg_names = {"x", "y", "z", "w"}

	local type_info =  {
		vec2 = {type = "float", arg_count = 2},
		vec3 = {type = "float", arg_count = 3},
		vec4 = {type = "float", arg_count = 4},
	}

	local type_translate = {
		color = "vec4",
		number = "float",
		texture = "sampler2D",
	}
	
	local reverse_type_translate = {
		number = "float",
		vec2 = "vec2",
		vec3 = "vec3",
		color = "vec4",
	}
	
	local template =
[[#version 330

@@SHARED UNIFORM@@
@@UNIFORM@@

@@IN@@

@@OUT@@

//__SOURCE_START
@@SOURCE@@
//__SOURCE_END
void main()
{
@@OUT2@@

	mainx();
}
]]

	-- add some extra information
	for k,v in pairs(type_info) do
		-- names like vec3 is very generic so prepend glw_glsl_
		-- to avoid collisions
		v.real_type = "glw_glsl_" ..k
		v.size = ffi.sizeof("float")

		if not gl_enum_types[v.type] then
			log("gl enum type for %q is unknown", v.type)
		else
			v.enum_type = gl_enum_types[v.type]
		end
	end
	-- declare the types
	for type, info in pairs(type_info) do
		local line = info.type .. " "
		for i = 1, info.arg_count do
			line = line .. string.char(64+i)

			if i ~= info.arg_count then
				line = line .. ", "
			end
		end

		local dec = ("struct %s { %s; };"):format(info.real_type, line)
		ffi.cdef(dec)
	end

	local function get_attribute_type(var)
		local t = typex(var)
		local def = var
		if t == "string" then
			t = var
			def = nil
		end
		t = type_translate[t] or t

		return t, def
	end

	local function translate_fields(attributes)
		local out = {}

		for k, v in pairs(attributes) do
			local type, default = get_attribute_type(v)
			out[k] = {type = type, default = default}
		end

		return out
	end

	local function get_variables(type, data, append, macro, layout_sort_ref)
		local temp = {}

		for key, data in pairs(translate_fields(data)) do
			local name = key

			if append then
				name = append .. key
			end

			local i = #temp+1
			
			if layout_sort_ref then
				for index, data in pairs(layout_sort_ref) do
					if data.name == key then
						i = index
						break
					end
				end
			end
			
			temp[i] = ("%s %s %s;"):format(type, data.type, name)

			if macro then
				temp[#temp+1] = ("#define %s %s"):format(key, name)
			end
		end
		
		local ok, str = pcall(table.concat, temp, "\n")
		
		if not ok then
			error("vertex_attributes fields do not match the attributes fields", 3)
		end
		
		return str
	end

	local function insert(str, key, val)
		return str:gsub("(@@.-@@)", function(str)
			if str:match("@@(.+)@@") == key then
				return val
			end
		end)
	end

	local reserve_prepend = "glw_out_"


	local META = {}
	META.__index = META

	META.Type = "super_shader"

	function META:__tostring()
		return ("super_shader[%s]"):format(self.shader_id)
	end

	function META:Remove()
		gl.DeleteProgram(self.program_id)
		utilities.MakeNULL(self)
	end
	
	local base = e.GL_TEXTURE0

	function META:Bind()
		render.UseProgram(self.program_id)

		-- unroll this?
		
		for key, data in pairs(self.uniforms) do
			local val = self[key]

			if val then
				if type(val) == "function" then
					val = val()
				end
				if data.info.type == "sampler2D" then
					gl.ActiveTexture(base + val.Channel)
					gl.BindTexture(val.format.type, val.id)
					data.func(data.id, val.Channel)
				elseif type(val) == "table" then
					data.func(data.id, unpack(val))
				elseif hasindex(val) and val.Unpack then
					data.func(data.id, val:Unpack())
				else
					
					data.func(data.id, val)
				end

			end
		end

		for location, data in pairs(self.attributes) do
			gl.EnableVertexAttribArray(location)
			gl.VertexAttribPointer(location, data.arg_count, data.enum, false, data.stride, data.type_stride)
		end
	end
		
	function META:CreateVertexBuffer(data, vbo_override)
		if not data and not vbo_override then
			return {Type = "VertexBuffer", id = gl.GenBuffer(), length = -1, IsValid = function() return true end, Draw = function() end}
		end
		
		local buffer = render.CreateVertexBufferForSuperShader(self, data)

		local id = vbo_override and vbo_override.id or gl.GenBuffer()
		local size = ffi.sizeof(buffer[0]) * #data

		gl.BindBuffer(e.GL_ARRAY_BUFFER, id) 
		gl.BufferData(e.GL_ARRAY_BUFFER, size, buffer, e.GL_DYNAMIC_DRAW)

		if false and gl.GetBufferParameterui64vNV then
			self.nvidia_buffer_address = ffi.new("GLuint64EXT[1]")
			gl.EnableClientState(e.GL_VERTEX_ATTRIB_ARRAY_UNIFIED_NV)
			gl.GetBufferParameterui64vNV(e.GL_ARRAY_BUFFER, e.GL_BUFFER_GPU_ADDRESS_NV, self.nvidia_buffer_address)
			gl.MakeBufferResidentNV(e.GL_ARRAY_BUFFER, e.GL_READ_ONLY)
		end
		
		local vao_id = gl.GenVertexArray()
		gl.BindVertexArray(vao_id)
		
		for location, data in pairs(self.attributes) do
			gl.EnableVertexAttribArray(location)
			gl.VertexAttribPointer(location, data.arg_count, data.enum, false, data.stride, data.type_stride)
		end
		
		gl.BindVertexArray(0)

		local vbo = vbo_override or {Type = "VertexBuffer", id = id, IsValid = function() return true end}
		vbo.length = #data

		vbo.Draw = function(vbo)
			render.UseProgram(self.program_id)
					
			if false and self.nvidia_buffer_address then 
				gl.BufferAddressRangeNV(e.GL_VERTEX_ATTRIB_ARRAY_ADDRESS_NV, 0, self.nvidia_buffer_address[1], size);
			else
				render.BindArrayBuffer(vbo.id)
				render.BindVertexArray(vao_id)
			end
			
			self.unrolled_bind_func()
			
			gl.DrawArrays(e.GL_TRIANGLES, 0, vbo.length)
		end
		
		function vbo:IsValid() return true end
		
		function vbo:Remove()
			gl.DeleteBuffers(1, ffi.new("GLuint[1]", vbo.id))
			utilities.MakeNULL(self)
		end
		
		function vbo.UpdateVertexBuffer(vbo, data)
			local buffer = render.CreateVertexBufferForSuperShader(self, data)
			local size = ffi.sizeof(buffer[0]) * #data
			
			gl.BindBuffer(e.GL_ARRAY_BUFFER, id) 
			gl.BufferData(e.GL_ARRAY_BUFFER, size, buffer, e.GL_DYNAMIC_DRAW)
			gl.BindBuffer(e.GL_ARRAY_BUFFER, 0) 
		end
		
		utilities.SetGCCallback(vbo)
		
		if vbo_override then
			for key, val in pairs(self.uniforms) do
				self[key] = vbo[key]
			end
		end

		-- so you can do vbo.time = 0
		setmetatable(vbo, { 
			__newindex = self,
			__index = self,
		})

		
		return vbo
	end
	
	local uniform_translate
	local shader_translate

	function render.CreateSuperShader(shader_id, data, base)
	
		if not shader_translate then
			-- do this when we try to create our first
			-- material to ensure we have all the enums
			uniform_translate =
			{
				float = render.Uniform1f,
				vec2 = render.Uniform2f,
				vec3 = render.Uniform3f,
				vec4 = render.Uniform4f,
				mat4 = function(location, ptr) render.UniformMatrix4fv(location, 1, 0, ptr) end,
				sampler2D = render.Uniform1i,
				not_implemented = function() end,
			}

			shader_translate = {
				vertex = e.GL_VERTEX_SHADER,
				fragment = e.GL_FRAGMENT_SHADER,
				geometry = e.GL_GEOMETRY_SHADER,
				tess_eval = e.GL_TESS_EVALUATION_SHADER,
				tess_control = e.GL_TESS_CONTROL_SHADER,
			}

			-- grab all valid shaders from enums
			for k,v in pairs(e) do
				local name = k:match("GL_(.+)_SHADER")

				if name then
					shader_translate[name] = v
					shader_translate[k] = v
					shader_translate[v] = v
				end

			end
		end
		
		if render.active_super_shaders[shader_id] then
			for key, val in pairs(render.active_super_shaders) do
				if val.base == shader_id then
					render.CreateSuperShader(key, val.original_data, val.base)
				end
			end
		end
	
		if base and render.active_super_shaders[base] then
			local temp = table.copy(render.active_super_shaders[base].original_data)
			
			table.merge(temp, data)
			data = temp
		end

		local build = {}
		local shared = data.shared

		data.shared = nil

		for shader in pairs(data) do
			build[shader] = {source = template, out = {}}
		end

		if data.vertex then
		
			-- if vertex.attributes is defined as vertex.vertex_attributes and 
			-- vertex.vertex_attributes doesn't exist swap them
			if not data.vertex.vertex_attributes and data.vertex.attributes then
				local k,v = next(data.vertex.attributes)
				if type(v) == "table" then
					data.vertex.vertex_attributes = data.vertex.attributes
					data.vertex.attributes = nil
				end
			end 
		
			if not data.vertex.attributes and data.vertex.vertex_attributes then
				data.vertex.attributes = {}
				for k,v in pairs(data.vertex.vertex_attributes) do
					local k,v = next(v)
					data.vertex.attributes[k] = v					
				end
			end
		
			for shader, info in pairs(data) do
				if shader ~= "vertex" then
					if info.attributes then
						for k, v in pairs(info.attributes) do
							build.vertex.out[k] = v
						end
					end
				end
			end

			local source = build.vertex.source

			source = insert(source, "OUT", get_variables("out", build.vertex.out, reserve_prepend))

			local vars = {}

			for key in pairs(build.vertex.out) do
				vars[#vars+1] = ("\t%s = %s;"):format(reserve_prepend .. key, key)
			end

			source = insert(source, "OUT2", table.concat(vars, "\n"))

			build.vertex.source = source

			-- check vertex_attributes
			if data.vertex.vertex_attributes then

				build.vertex.vtx_info = {}

				do -- build and define the struct information
					local id = shader_id
					local type = "glw_vtx_atrb_" .. id

					local declaration = {"struct "..type.." { "}

					for key, val in pairs(data.vertex.vertex_attributes) do
						local name, type = next(val)
						local info = type_info[type]

						if info then
							table.insert(declaration, ("struct %s %s; "):format(info.real_type, name))
							table.insert(build.vertex.vtx_info, {name = name, type = type, info = info})
						else
							errorf("undefined type %q in vertex_attributes", 2, type)
						end
					end

					table.insert(declaration, " };")
					declaration = table.concat(declaration, "")
					
					ffi.cdef(declaration)

					type = "struct " .. type

					build.vertex.vtx_atrb_dec = declaration
					build.vertex.vtx_atrb_size = ffi.sizeof(type)
					build.vertex.vtx_atrb_type = type
				end


			end
		else
			error("no vertex shader was found", 2)
		end

		for shader, info in pairs(data) do
			local source = build[shader].source

			if info.uniform then
				source = insert(source, "UNIFORM", get_variables("uniform", info.uniform, build[shader].default_vars))
				build[shader].uniform = translate_fields(info.uniform)
			end

			if info.attributes then
				-- remove _ from in variables and define them

				if shader == "vertex" then
					source = insert(source, "IN", get_variables("in", table.merge(build.vertex.out, info.attributes), nil,nil, build.vertex.vtx_info))
					build.vertex.out = nil
					build[shader].attributes = translate_fields(info.attributes)
				else
					source = insert(source, "IN", get_variables("in", info.attributes, reserve_prepend, true))
				end
			end

			if info.source then
				if info.source:find("\n") then
					-- replace void *main* () with mainx
					info.source = info.source:gsub("void%s+([main]-)%s-%(", function(str) if str == "main" then return "void mainx(" end end)

					source = insert(source, "SOURCE", info.source)
				else
					source = insert(source, "SOURCE", ("void mainx()\n{\n\t%s\n}\n"):format(info.source))
				end

				build[shader].line_start = select(2, source:match(".+__SOURCE_START"):gsub("\n", "")) + 2
				build[shader].line_end = select(2, source:match(".+__SOURCE_END"):gsub("\n", ""))
			end

			build[shader].source = source
		end

		-- create shared uniform
		if shared and shared.uniform then
			for shader in pairs(data) do
				if build[shader] then
					build[shader].source = insert(build[shader].source, "SHARED UNIFORM", get_variables("uniform", shared.uniform))
				end
			end

			-- kind of hacky but insert the shared uniforms
			-- in the vertex shader to avoid creating more code

			table.merge(build.vertex.uniform, translate_fields(shared.uniform))
		end

		local shaders = {}

		for shader, data in pairs(build) do
			local enum = shader_translate[shader]

			-- strip data that wasnt found from the template
			data.source = data.source:gsub("(@@.-@@)", "")

			if enum then
				local ok, shader = pcall(render.CreateShader, enum, data.source)

				if ok then
					table.insert(shaders, shader)
				else
					local err = shader
					err = err:gsub("0%((%d+)%) ", function(line)
						line = tonumber(line)
						return data.source:explode("\n")[line]:trim() .. (line - data.line_start + 1)
					end)
					error(err)
				end
			else
				errorf("shader %q is unknown", 2, shader)
			end
		end

		if #shaders > 0 then
			local ok, prog = pcall(render.CreateProgram, unpack(shaders))

			if not ok then
				error(prog, 2)
			else
				local self = setmetatable({}, META)

				self.vtx_atrb_type = build.vertex.vtx_atrb_type
				self.program_id = prog
				self.uniforms = {}
				self.shader_id = shader_id
				
				local temp = {}
				local lua = ""
												
				for shader, data in pairs(build) do
					if data.uniform then
						for key, val in pairs(data.uniform) do
							if uniform_translate[val.type] or val.type == "function" then
								local id = gl.GetUniformLocation(prog, key)
								if true or id > 0 then
									self.uniforms[key] = {
										id = id,
										func = uniform_translate[val.type],
										info = val,
									}
																	
									table.insert(temp, {id = id, key = key, val = val})
									
									self[key] = val.default
								end
							else
								errorf("%s: %s is an unknown uniform type", 2, key, val.type)
							end
						end
					end
				end
				
				table.sort(temp, function(a, b) return a.id < b.id end)
				
				for i, data in pairs(temp) do
					local line = tostring(unrolled_lines[data.val.type] or data.val.type)
					
					line = line:format(data.id)

					lua = lua .. "local val = self."..data.key.."\n" 
					lua = lua .. "if val then\n" 
					lua = lua .. "\tif type(val) == 'function' then val = val() end\n" 
					lua = lua .. "\t" .. line .. "\n"
					lua = lua .. "end\n\n"
				end
					
				self.attributes = {}
				local pos = 0
				for id, data in pairs(build.vertex.vtx_info) do
					gl.BindAttribLocation(prog, id-1, data.name)
					local type_stride = ffi.cast("void*", data.info.size * pos)
					
					self.attributes[id-1] = {
						arg_count = data.info.arg_count,
						enum = data.info.enum_type,
						stride = build.vertex.vtx_atrb_size,
						type_stride = type_stride,
					}
					
					pos = pos + data.info.arg_count
				end				
							
			--	lua = lua .. "if render.current_program ~= render.super_shader_last_program then\n"
		--		for location, data in pairs(self.attributes) do
					--lua = lua .. "\tgl.EnableVertexAttribArray("..location..") \n"
					--lua = lua .. "\tgl.VertexAttribPointer("..location..",".. data.arg_count..",".. data.enum..",false,".. data.stride..",self.attributes["..location.."].type_stride)\n\n"
					--lua = lua .. "\tgl.BindVertexArray(self.vao_id)"
			--	end
			--	lua = lua .. "\trender.super_shader_last_program = render.current_program\n"
			--	lua = lua .. "end\n"
				
								
				local func, err = loadstring(lua)
				if not func then error(err, 2) end
				self.unrolled_bind_func = func
				setfenv(func, {gl = gl, self = self, loc = prog, type = type, render = render, print = print})
				
				self.original_data = data
				self.base_shader = base
				self.prog = prog
				render.active_super_shaders[shader_id] = self
				
				utilities.SetGCCallback(self)
				
				if CAPSADMIN then
					luadata.WriteFile("super_shader_debug/" .. shader_id .. "_build.lua", build)
					vfs.Write("super_shader_debug/" .. shader_id .. "_lua_output.lua", lua)
				end
				
				return self
			end
		else
			error("no shaders to compile", 2)
		end

		return NULL
	end
end


include("platforms/glw/libraries/render/shaders/*")
include("shaders/*")