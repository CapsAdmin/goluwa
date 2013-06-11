local window = asdfml.OpenWindow()
  
local frame = 0  

local cam_pos = Vec3(0, 0, -10)

local cam_ang = Ang3(0, 0, 0)
  
local table_insert = table.insert

ffi.cdef[[
	struct vertex_attributes
	{
		float pos_x, pos_y, pos_z;
		float norm_x, norm_y, norm_z;
		float u, v;
 	};
]]
     
local function VertexBuffer(tbl, number_type)
	number_type = number_type or "float"
	
	-- determine how 
	local t = typex(tbl[1])
	local row_size
	
	if t == "number" then
		row_size = 1
	elseif t == "vec2" then		
		row_size = 2
	elseif t == "vec3" then
		row_size = 3
	end
	
	assert(row_size)
	
	local length = #tbl * row_size	
	local buffer = ffi.new(number_type .. " [?]", length)
	
	for i = 1, #tbl / row_size do
		i = i * row_size
		if row_size == 1 then
			buffer[i+0] = tbl[i]
		elseif row_size == 2 then
			buffer[i+0] = tbl[i].x
			buffer[i+1] = tbl[i].y
		elseif row_size == 3 then
			buffer[i+0] = tbl[i].x
			buffer[i+1] = tbl[i].y
			buffer[i+2] = tbl[i].z
		end
	end

	-- get an id from gl
	local id = ffi.new("int [1]") gl.GenBuffers(1, id) id = id[0]

	gl.BindBuffer(e.GL_ARRAY_BUFFER, id)	
	gl.BufferData(e.GL_ARRAY_BUFFER, ffi.sizeof(number_type) * length, buffer, e.GL_STATIC_DRAW)
	 	 
	return id
end 

local function VertexBuffer(data)  

	local buffer = ffi.new("struct vertex_attributes[?]", #data)

	for i = 1, #data do
		local vertex = data[i]
		local vertex_attributes = buffer[i - 1]

		if vertex.pos then
			vertex_attributes.pos_x = vertex.pos.x
			vertex_attributes.pos_y = vertex.pos.y
			vertex_attributes.pos_z = vertex.pos.z
		end

		if vertex.normal then
			vertex_attributes.norm_x = vertex.normal.x
			vertex_attributes.norm_y = vertex.normal.y
			vertex_attributes.norm_z = vertex.normal.z
		end

		if vertex.uv then
			vertex_attributes.u = vertex.uv.x
			vertex_attributes.v = vertex.uv.y
		end
	end

	local id = ffi.new("int [1]") gl.GenBuffers(1, id) id = id[0]

	gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
	gl.BufferData(e.GL_ARRAY_BUFFER, ffi.sizeof(buffer[0]) * #data, buffer, e.GL_STATIC_DRAW)

	return id
end
	 
function decode_obj(data, generate_normals)

	local positions = {}
	local texcoords = {}
	local normals = {}
	
	local output = {}
	
	local lines = {}
	
	for i in data:gmatch("(.-)\n") do
		local parts = i:gsub("%s+", " "):trim():explode(" ")

		table.insert(lines, parts)
	end
		
	for _, parts in pairs(lines) do		
		if parts[1] == "v" and #parts >= 4 then
			table_insert(positions, Vec3(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])))
		elseif parts[1] == "vt" and #parts >= 3 then
			table_insert(texcoords, Vec2(tonumber(parts[2]), tonumber(1 - parts[3])))
		elseif not generate_normals and parts[1] == "vn" and #parts >= 4 then
			table_insert(normals, Vec3(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])))
		end
	end
		
	for _, parts in pairs(lines) do
		if parts[1] == "f" and #parts > 3 then
			local first, previous

			for i = 2, #parts do
				local current = parts[i]:explode("/")

				if i == 2 then
					first = current
				end
				
				if i >= 4 then
					local v1, v2, v3 = {}, {}, {}

					v1.pos_index = tonumber(first[1])
					v2.pos_index = tonumber(current[1])
					v3.pos_index = tonumber(previous[1])
					
					v1.pos = positions[tonumber(first[1])]
					v2.pos = positions[tonumber(current[1])]
					v3.pos = positions[tonumber(previous[1])]
					
					if #texcoords > 0 then
						v1.uv = texcoords[tonumber(first[2])]
						v2.uv = texcoords[tonumber(current[2])]
						v3.uv = texcoords[tonumber(previous[2])]
					end
					
					if #normals > 0 then
						v1.normal = normals[tonumber(first[3])]
						v2.normal = normals[tonumber(current[3])]
						v3.normal = normals[tonumber(previous[3])]
					end				
					
					table_insert(output, v1)
					table_insert(output, v2)
					table_insert(output, v3)
				end

				previous = current
			end
		end
	end
	
	if generate_normals then
		local vertex_normals = {}

		for i = 1, #output/3 do
			local a, b, c = output[1+(i-1)*3+0], output[1+(i-1)*3+1], output[1+(i-1)*3+2] 
			local normal = (c.pos - a.pos):Cross(b.pos - a.pos):GetNormalized()

			vertex_normals[a.pos_index] = vertex_normals[a.pos_index] or Vec3()
			vertex_normals[a.pos_index] = (vertex_normals[a.pos_index] + normal)

			vertex_normals[b.pos_index] = vertex_normals[b.pos_index] or Vec3()
			vertex_normals[b.pos_index] = (vertex_normals[b.pos_index] + normal)

			vertex_normals[c.pos_index] = vertex_normals[c.pos_index] or Vec3()
			vertex_normals[c.pos_index] = (vertex_normals[c.pos_index] + normal)
		end

		local default_normal = Vec3(0, 0, -1)

		for i = 1, #output do
			local n = vertex_normals[output[i].pos_index] or default_normal
			n:Normalize()
			normals[i] = n
			output[i].normal = n
		end
	end
	
	print(output[1].uv)
	
	local id = VertexBuffer(output)

	local vertex_shader_source = [[
		uniform float time;

		attribute vec3 position;
		attribute vec3 normal;
		attribute vec2 uv;

		varying vec3 color;
		varying vec2 texcoords;
		varying vec3 normal_;

		void main()
		{
			texcoords = uv;
			color = gl_Color;
			normal_ = normal;
			gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * vec4(position + normal * (0.5 + sin(time) * 0.5) + vec3(sin(position.z + time * 10.0), 0.0, 0.0), 1.0);
		}
	]]

	
	local fragment_shader_source = [[
		uniform float time;
		uniform sampler2D texture;

		varying vec3 color;
		varying vec2 texcoords;
		varying vec3 normal_;

		void main()
		{
			//float lol = fract((floor(texcoords.s * 32.0) + floor(texcoords.t * 32.0)) / 2);
			vec3 final_color = tex2D(texture, texcoords) * color * clamp(dot(normal_, vec3(0.0, sin(time), cos(time))), 0.25, 1.0);
			gl_FragColor = vec4(final_color, 1.0);
		}
	]]

	local function CreateShader(type, source)
		local shader = gl.CreateShader(type)

		local ffisource = ffi.new("char[?]", #source)
		ffi.copy(ffisource, source)

		local grr = ffi.new("const char*[1]")
		grr[0] = ffisource
		local blah = ffi.new("GLint[1]")
		blah[0] = #source
		gl.ShaderSource(shader, 1, grr, blah)

		gl.CompileShader(shader)

		local compile_status = ffi.new("GLint[1]")
		gl.GetShaderiv(shader, e.GL_COMPILE_STATUS, compile_status)

		if compile_status[0] == 0 then
			local asdsaad = ffi.new("GLsizei[1]")
			local log = ffi.new("char[1024]")
			gl.GetShaderInfoLog(shader, 1024, asdsaad, log)
			print(ffi.string(log))
			gl.DeleteShader(shader)
			return nil
		end

		return shader
	end

	local function CreateProgram(vertex_shader_source, fragment_shader_source)
		local vertex = CreateShader(e.GL_VERTEX_SHADER, vertex_shader_source)
		local fragment = CreateShader(e.GL_FRAGMENT_SHADER, fragment_shader_source)

		if not vertex or not fragment then
			print("YEAH NO")
			return
		end

		local program = gl.CreateProgram()
		gl.AttachShader(program, vertex)
		gl.AttachShader(program, fragment)
		gl.BindAttribLocation(program, 0, "position")
		gl.BindAttribLocation(program, 1, "normal")
		gl.BindAttribLocation(program, 2, "uv")
		gl.LinkProgram(program)

		local link_status = ffi.new("GLint[1]")
		gl.GetProgramiv(program, e.GL_LINK_STATUS, link_status)

		
		if link_status[0] == 0 then
			local asdsaad = ffi.new("GLsizei[1]")
			local log = ffi.new("char[1024]")
			gl.GetProgramInfoLog(shader, 1024, asdsaad, log)
			print(ffi.string(log))
			gl.DeleteProgram(program)
			gl.DeleteShader(vertex)
			gl.DeleteShader(fragment)
			return nil
		end

		return program, vertex, fragment
	end

	local program = CreateProgram(vertex_shader_source, fragment_shader_source)
	local stride = ffi.sizeof("struct vertex_attributes")

	local tex = Texture("file", R"textures/face1.png")
	
	return function()
		gl.ActiveTexture(e.GL_TEXTURE0)
		tex:Bind()
		gl.Uniform1i(gl.GetUniformLocation(program, "texture"), 0);
		gl.Uniform1f(gl.GetUniformLocation(program, "time"), os.clock())
		
		gl.Color3f(1.0, 1.0, 1.0)
		gl.UseProgram(program)

		gl.EnableVertexAttribArray(0)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
		gl.VertexAttribPointer(0, 3, e.GL_FLOAT, false, stride, ffi.cast("void*", 0))

		gl.EnableVertexAttribArray(1)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
		gl.VertexAttribPointer(1, 3, e.GL_FLOAT, false, stride, ffi.cast("void*", 12))

		gl.EnableVertexAttribArray(2)
		gl.BindBuffer(e.GL_ARRAY_BUFFER, id)
		gl.VertexAttribPointer(2, 2, e.GL_FLOAT, false, stride, ffi.cast("void*", 24))

		gl.DrawArrays(e.GL_TRIANGLES, 0, #output - 1)
	end
	 		 
	--[[		
	local V = VertexBuffer(positions)
	local UV = VertexBuffer(texcoords)
	local N = VertexBuffer(normals)
			
	return function()
		gl.EnableClientState(e.GL_VERTEX_ARRAY)
		gl.EnableClientState(e.GL_TEXTURE_COORD_ARRAY)
		
		gl.Begin(e.GL_TRIANGLES)
		
			gl.BindBuffer(e.GL_ARRAY_BUFFER, V)
			gl.VertexPointer(3, e.GL_FLOAT, 0, nil)
			
			gl.BindBuffer(e.GL_ARRAY_BUFFER, UV) 
			gl.VertexPointer(2, e.GL_FLOAT, 0, nil)
				
			gl.BindBuffer(e.GL_ARRAY_BUFFER, N) 
			gl.VertexPointer(3, e.GL_FLOAT, 0, nil) 
			 
			gl.DrawArrays(e.GL_TRIANGLES, 0, #positions)
			
		gl.End()
		
		gl.DisableClientState(e.GL_VERTEX_ARRAY)
		gl.DisableClientState(e.GL_TEXTURE_COORD_ARRAY)			
		
		print(glu.GetLastError())
	end]]
end
  
local active_models = {}

do -- model
	local META = {}
	META.__index = META

	class.GetSet(META, "Pos", Vec3(0,0,0))
	class.GetSet(META, "Angles", Ang3(0,0,0))
	class.GetSet(META, "Scale", Vec3(1,1,1))
	class.GetSet(META, "Size", 1)
	class.GetSet(META, "Model", 1)

	function META:SetModel(path)
		self.obj = decode_obj(vfs.Read("models/" .. path), true)
		self.Model = path
	end
	
	function META:Draw(asdf)
		if not self.obj then return end

		
		gl.PushMatrix()

		gl.Rotated(self.Angles.p, 1, 0, 0)
		gl.Rotated(self.Angles.y, 0, 1, 0)
		gl.Rotated(self.Angles.r, 0, 0, 1)
		gl.Translated(self.Pos.x, self.Pos.y, self.Pos.z)

		local s = self.size
		gl.Scaled(self.scale.x * s, self.scale.y * s, self.scale.z * s)
	
		self.obj()
				
		--[[gl.Begin(e.GL_TRIANGLES)
			if asdf then gl.Color4f(0, 0, 0, 0.5) else gl.Color4f(1, 1, 1, 1) end
			for key, data in pairs(self.obj) do
				if data.normal then gl.Normal3f(data.normal:Unpack()) end
				if data.u then gl.TexCoord2f(data.u, data.v) end
				gl.Vertex3f(data.pos:Unpack())
			end 		
		gl.End()]]
		
				
		local err = ffi.string(glu.ErrorString(gl.GetError()))
		if err ~= "no error" then
			print(err)
		end
		
		gl.PopMatrix()
	end

	function Model(path)
		local self = setmetatable(
			{
				pos = Vec3(),
				ang = Ang3(),
				scale = Vec3(1,1,1),
				size = 1,
			}, META
		)
		table.insert(active_models, self)

		return self
	end
end
   
  
local last_x = 0
local last_y = 0
   
local function calc_camera(window, dt)

	cam_ang:Normalize()
	local speed = dt

		
	if input.IsKeyDown("l_control") then
		local pos = mouse.GetPosition(ffi.cast("sfWindow * ", window))
		
		local dx = (pos.x - last_x) * dt
		local dy = (pos.y - last_y) * dt
		
		cam_ang.p = cam_ang.p + dy
		cam_ang.y = cam_ang.y + dx
		cam_ang.p = math.clamp(cam_ang.p, -math.pi/2, math.pi/2)
			
		last_x = pos.x 
		last_y = pos.y
		
		--window:SetMouseCursorVisible(false)
		local size = window:GetSize()

		if pos.x > size.x then
			mouse.SetPosition(Vector2i(0, pos.y), ffi.cast("sfWindow * ", window))
			last_x = 0
		elseif pos.x < 0 then
			mouse.SetPosition(Vector2i(size.x, pos.y), ffi.cast("sfWindow * ", window))
			last_x = size.x
		end
		
		if pos.y > size.y then
			mouse.SetPosition(Vector2i(pos.x, 0), ffi.cast("sfWindow * ", window))
			last_y = 0
		elseif pos.y < 0 then
			mouse.SetPosition(Vector2i(pos.x, size.y), ffi.cast("sfWindow * ", window))
			last_y = size.y
		end	
	else
		window:SetMouseCursorVisible(true)
	end 
	
	if input.IsKeyDown("space") then
		cam_pos = cam_pos - cam_ang:GetForward() * speed
	end 
 
	if input.IsKeyDown("w") then
		cam_pos = cam_pos + cam_ang:GetUp() * speed
	elseif input.IsKeyDown("s") then
		cam_pos = cam_pos - cam_ang:GetUp() * speed
	end

	if input.IsKeyDown("a") then
		cam_pos = cam_pos + cam_ang:GetRight() * speed
	elseif input.IsKeyDown("d") then
		cam_pos = cam_pos - cam_ang:GetRight() * speed
	end  

	if input.IsKeyDown("up") then
		cam_ang.p = cam_ang.p - speed
	elseif input.IsKeyDown("down") then
		cam_ang.p = cam_ang.p + speed 
	end 

	if input.IsKeyDown("left") then
		cam_ang.y = cam_ang.y - speed
	elseif input.IsKeyDown("right") then
		cam_ang.y = cam_ang.y + speed
	end
	 	 
	local a = cam_ang:GetDeg()

	gl.Rotatef(a.p, 1, 0, 0)
	gl.Rotatef(a.y, 0, 1, 0)
	gl.Rotatef(a.r, 0, 0, 1)
	gl.Translatef(cam_pos.x, cam_pos.y, cam_pos.z)
end 

gl.ClearColor(1, 1, 1, 1)
gl.Enable(e.GL_BLEND)
gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)
gl.Enable(e.GL_DEPTH_TEST)

--local shader = Shader([[]])

gl.Enable(e.GL_LIGHTING) 
 
gl.Lightfv(e.GL_LIGHT0, e.GL_AMBIENT, ffi.new("float [4]", 0, 0, 0, 1))
gl.Lightfv(e.GL_LIGHT0, e.GL_DIFFUSE, ffi.new("float [4]", 0.5, 0.5, 0.5, 1))
gl.Lightfv(e.GL_LIGHT0, e.GL_SPECULAR, ffi.new("float [4]", 1, 1, 1, 1))

gl.Lightfv(e.GL_LIGHT0, e.GL_POSITION, ffi.new("float [4]", 0, 1, 1, 0))
  
gl.Enable(e.GL_LIGHT0)
gl.Enable(e.GL_CULL_FACE)
gl.CullFace(e.GL_FRONT) 
     
event.AddListener("OnDraw", "gl", function(dt, window)
	window:Clear(sfml.Color(100, 100, 100, 255))
	local size = window:GetSize() 
	frame = os.clock()*10
	
	gl.Viewport(0, 0, size.x, size.y) 
	gl.Clear( bit.bor(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT) );
		
	gl.MatrixMode(e.GL_PROJECTION)
	gl.LoadIdentity()
	glu.Perspective(75, size.x/size.y, 0.1, 100)
	
  	calc_camera(window, dt) 

	gl.MatrixMode(e.GL_MODELVIEW)
	gl.LoadIdentity()
 
 
	for key, obj in pairs(active_models) do
		--[[gl.Disable(e.GL_LIGHTING)
		gl.PolygonMode(e.GL_FRONT_AND_BACK, e.GL_LINE)
		obj:Draw(true)]]

		gl.Enable(e.GL_LIGHTING)
		gl.PolygonMode(e.GL_FRONT_AND_BACK, e.GL_FILL)
		obj:Draw()
	end

	gl.Flush() 
end)

for i = 1, 10 do 
	local obj = Model()
	obj:SetModel("face.obj")
	obj:SetSize(1)
	obj:SetPos(Vec3Rand() * 10)
end