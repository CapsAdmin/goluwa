local render = (...) or _G.render

local META = prototype.CreateTemplate("vertex_buffer")

prototype.StartStorable()
META:GetSet("UpdateIndices", true)
META:GetSet("Mode", "triangles")
META:GetSet("DrawHint", "dynamic")
META:GetSet("Shader")
META:GetSet("Vertices")
META:GetSet("Indices")
prototype.EndStorable()

function render.CreateVertexBuffer(shader, vertices, indices, is_valid_table)
	local self = META:CreateObject()
	self.mesh_layout = {
		attributes = {}
	}
	self:SetMode(self:GetMode())
	self:SetDrawHint(self:GetDrawHint())
	render._CreateVertexBuffer(self)

	for i, info in ipairs(shader:GetMeshLayout()) do
		self:SetAttribute(i, info.name, info.type, info.default)
	end

	self:SetupAttributes()

	if vertices then
		self:SetBuffersFromTables(vertices, indices, is_valid_table)
	end

	self:SetShader(shader)

	return self
end

do -- attributes
	local ffi = require("ffi")
	local type_info =  {
		int = {type = "int", arg_count = 1},
		float = {type = "float", arg_count = 1},
		number = {type = "float", arg_count = 1},
		vec2 = {type = "float", arg_count = 2},
		vec3 = {type = "float", arg_count = 3},
		vec4 = {type = "float", arg_count = 4},
	}

	do -- extend typeinfo
		-- declare the types
		for _, info in pairs(type_info) do
			if info.arg_count > 1 then
				local line = info.type .. " "
				for i = 1, info.arg_count do
					line = line .. string.char(64+i)

					if i ~= info.arg_count then
						line = line .. ", "
					end
				end

				info.ctype = ffi.typeof(("struct { %s; }"):format(line))
			else
				info.ctype = ffi.typeof(info.type)
			end
		end

		for _, v in pairs(type_info) do
			v.size = ffi.sizeof(v.type)
		end
	end

	local type_translate = {
		boolean = "bool",
		color = "vec4",
		number = "float",
		texture = "sampler2D",
		matrix44 = "mat4",
	}

	function META:SetAttribute(i, name, type, default)
		if name then
			if _G.type(type) ~= "string" then
				default = type
				type = typex(type)
				type = type_translate[type] or type
			end

			local info = type_info[type]

			if info then
				self.mesh_layout.attributes[i] = {
					name = name,
					type = type,
					default = default,
					type_info = info,
				}
			else
				print(i, name, type, default)
				error("undefined type " .. type, 2)
			end
		else
			self.mesh_layout.attributes[i] = nil
		end

		self.needs_setup = true
	end

	function META:SetupAttributes()
		local ctypes = {}

		local declaration = {"struct { "}

		for _, info in pairs(self.mesh_layout.attributes) do
			table.insert(declaration, ("$ %s;"):format(info.name))
			table.insert(ctypes, info.type_info.ctype)
		end

		table.insert(declaration, " }")
		declaration = table.concat(declaration, "")

		local ctype = ffi.typeof(declaration, unpack(ctypes))

		self.mesh_layout.size = ffi.sizeof(ctype)
		self.mesh_layout.ctype = ctype

		local pos = 0

		for i, info in pairs(self.mesh_layout.attributes) do
			info.location = i - 1
			info.row_length = info.type_info.arg_count
			info.row_offset = info.type_info.size * pos
			info.number_type = info.type_info.type

			if OPENGL then
				info.number_type = "GL_" .. info.number_type:upper()
			end

			pos = pos + info.type_info.arg_count
		end
	end

	local function unpack_structs(self, output)
		local found = {}

		-- only bother doing this if the first line has structs
		for _, info in pairs(self.mesh_layout.attributes) do
			local val = output[1][info.name]

			if val then
				if hasindex(val) and val.Unpack then
					found[info.name] = true
				end
			end
		end

		if next(found) then
			for _, struct in pairs(output) do
				for key, val in pairs(struct) do
					if found[key] then
						struct[key] = {val:Unpack()}
					else
						struct[key] = nil
					end
				end
			end
		end
	end

	function META:SetBuffersFromTables(vertices, indices, is_valid_table)
		if type(vertices) == "number" then
			local size = vertices

			local indices = Array("unsigned int", size)
			for i = 0, size - 1 do indices[i] = i end

			self:UpdateBuffer(Array(self.mesh_layout.ctype, size), indices)
		else
			if not is_valid_table then
				unpack_structs(self, vertices)

				if not indices then
					indices = {}
					for i in ipairs(vertices) do
						indices[i] = i-1
					end
				end
			end

			self:UpdateBuffer(Array(self.mesh_layout.ctype, #vertices, vertices), Array("unsigned int", #indices, indices))
		end
	end

	if RELOAD then
		surface.rect_mesh:SetAttribute(1, "pos", Vec2())
		surface.rect_mesh:SetAttribute(2, "uv", Vec2())
		surface.rect_mesh:SetAttribute(3, "color", Color(1,1,1,1))
		surface.rect_mesh:SetupAttributes()
		table.print(surface.rect_mesh.mesh_layout)
	end
end

if SSBO then
	function META:Draw(count)

		if render.current_shader_override then
			render.current_shader_override:Bind()
		elseif self.Shader then
			self.Shader:Bind()
		end

		render.update_globals2()

		self:_Draw(count)
	end
else
	function META:Draw(count)

		if render.current_shader_override then
			render.current_shader_override:Bind()
		elseif self.Shader then
			self.Shader:Bind()
		end

		self:_Draw(count)
	end
end

function META:UpdateBuffer(vertices, indices)
	vertices = vertices or self.Vertices
	indices = indices or self.Indices

	if vertices then
		self:SetVertices(vertices)
	end

	if indices then
		self:SetIndices(indices)
	end
end

function META:SetVertices(vertices)
	self.Vertices = vertices
	self.vertices_length = vertices:GetLength()
	self:_SetVertices(vertices)
end

function META:SetIndices(indices)
	self.Indices = indices
	self.indices_length = indices:GetLength() -- needed for drawing
	self:_SetIndices(indices)
end

function META:UnreferenceMesh()
	self.Vertices = nil
	self.Indices = nil
	collectgarbage("step")
end

include("opengl/vertex_buffer.lua", render, META)

prototype.Register(META)