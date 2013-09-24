render.active_super_shaders = render.active_super_shaders or {}

function render.CreateVertexBufferForSuperShader(mat, tbl)
	return ffi.new(mat.vtx_atrb_type.."["..#tbl.."]", tbl)
end

do
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

	local uniform_translate

	-- see beginning of render.CreateSuperShader
	local shader_translate

	-- add some extra information
	for k,v in pairs(type_info) do
		-- names like vec3 is very generic so prepend glw_glsl_
		-- to avoid collisions
		v.real_type = "glw_glsl_" ..k
		v.size = ffi.sizeof("float")
		
		if not gl_enum_types[v.type] then
			logf("gl enum type for %q is unknown", v.type)
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

	local function get_variables(type, data, append, macro)
		local temp = {}
		
		for key, data in pairs(translate_fields(data)) do
			local name = key
			
			if append then
				name = append .. key
			end
			
			temp[#temp+1] = ("%s %s %s;"):format(type, data.type, name)
			
			if macro then
				temp[#temp+1] = ("#define %s %s"):format(key, name)
			end
		end
		
		return table.concat(temp, "\n")
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

	META.Type = "material"

	function META:__tostring()
		return ("material[%i]"):format(self.mat_id)
	end
	
	local base = e.GL_TEXTURE0
	   
	function META:Bind()
		gl.UseProgram(self.program_id)
		
		-- unroll this?
		for key, data in pairs(self.uniforms) do
			local val = self[key] 
						
			if val then
				if data.info.type == "sampler2D" then
					gl.ActiveTexture(base + val.Channel) 
					gl.BindTexture(val.format.type, val.id)
					data.func(data.id, val.Channel)
				elseif type(val) == "function" then
					data.func(data.id, func())
				elseif type(val) == "table" then
					data.func(data.id, unpack(val))
				elseif hasindex(val) and val.Unpack then 
					---print(self.program_id, val:Unpack())
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
	
	function META:CreateVertexBuffer(data)
		local buffer = render.CreateVertexBufferForSuperShader(self, data)
		
		local id = gl.GenBuffer()
		local size = ffi.sizeof(buffer[0]) * #data
		
		gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
		gl.BufferData(e.GL_ARRAY_BUFFER, size, buffer, e.GL_STATIC_DRAW)
		
		local self = {Type = "VertexBuffer", id = id, length = #data}
		
		self.Draw = function(s, mat) 
			gl.BindBuffer(e.GL_ARRAY_BUFFER, s.id)
			mat:Bind()
			gl.DrawArrays(e.GL_TRIANGLES, 0, s.length)
		end
		
		return self
	end
	
	function render.CreateSuperShader(mat_id, data)
		
		if not shader_translate then		
			-- do this when we try to create our first 
			-- material to ensure we have all the enums
			uniform_translate =
			{
				float = gl.Uniform1f,
				vec2 = gl.Uniform2f,
				vec3 = gl.Uniform3f,
				vec4 = gl.Uniform4f,
				mat4 = function(location, ptr) gl.UniformMatrix4fv(location, 1, 0, ptr) end,
				sampler2D = gl.Uniform1i,
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
		
			
		local build = {}
		local shared = data.shared
		
		data.shared = nil
		
		for shader in pairs(data) do
			build[shader] = {source = template, out = {}}
		end
		
		if data.vertex then
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
					local id = mat_id
					local type = "glw_vtx_atrb_" .. id
					
					local declaration = {"struct "..type.." { "}
							 
					for key, val in pairs(data.vertex.vertex_attributes) do
						local name, type = next(val)					
						local info = type_info[type]
						
						if info then
							table.insert(declaration, ("struct %s %s; "):format(info.real_type, name))
							table.insert(build.vertex.vtx_info, {name = name, type = type, info = info})
						else
							logf("undefined type %q in vertex_attributes", type)
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
			logn("no vertex shader was found")
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
					source = insert(source, "IN", get_variables("in", table.merge(build.vertex.out, info.attributes)))
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
				local obj, err = Shader(enum, data.source)
				
				if obj then
					table.insert(shaders, obj)
				else
					err = err:gsub("0%((%d+)%) ", function(line) 
						return line - data.line_start + 1
					end)
					logn(err)
				end
			else
				logf("shader %q is unknown", shader)
			end
		end
		 
		if #shaders > 0 then
			local prog, err = Program(unpack(shaders)) 
			
			if err then			
				logn(err)
			else
				local self = setmetatable({}, META)
				
				self.vtx_atrb_type = build.vertex.vtx_atrb_type
				self.program_id = prog 
				self.uniforms = {}
				self.mat_id = mat_id
				
				for shader, data in pairs(build) do
					if data.uniform then 
						for key, val in pairs(data.uniform) do
							if uniform_translate[val.type] or val.type == "function" then
								self.uniforms[key] = {
									id = gl.GetUniformLocation(prog, key), 
									func = uniform_translate[val.type],
									info = val,
								}
								
								self[key] = val.default
							else
								logf("%s: %s is an unknown uniform type", key, val.type)
							end
						end 
					end
				end
				
				self.attributes = {}
				
				local pos = 0
				for id, data in pairs(build.vertex.vtx_info) do
					gl.BindAttribLocation(prog, id-1, data.name)
																				
					self.attributes[id-1] = {
						arg_count = data.info.arg_count,
						enum = data.info.enum_type, 
						stride = build.vertex.vtx_atrb_size,
						type_stride = ffi.cast("void*", data.info.size * pos)
					}
					
					pos = pos + data.info.arg_count
				end
								
				render.active_super_shaders[mat_id] = self
				
				return self 
			end
		else
			logn("no shaders to compile")
		end	 
				
		return NULL
	end 
	
	SuperShader = render.CreateSuperShader
end