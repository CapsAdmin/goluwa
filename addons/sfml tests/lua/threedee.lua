local window = asdfml.OpenWindow()
  
local frame = 0  

local cam_pos = Vec3(0, 0, -10)
local cam_ang = Ang3(0, 0, 0)
  
local table_insert = table.insert
     
function decode_obj(data)
	
	local vertices = {}
	local normals = {}
	local uvs = {}
	
	-- get all the types
	for type, x, y, z in data:gmatch("(%S+)%s-(%S+)%s-(%S+)%s-(%S+)%s-\n") do
		if type == "v" then
			table.insert(vertices, Vec3(tonumber(x),tonumber(y),tonumber(z)))
		end
		
		if type == "vn" then
			table.insert(normals, Vec3(tonumber(x),tonumber(y),tonumber(z)))
		end
		
		if type == "vt" then
			table.insert(uvs, Vec2(tonumber(x),tonumber(y)))
		end
 	end
	
	local output = {} 
	
	-- assemble them
	
	-- find this
	-- f 5529/5456/5529 1402/4112/1402 5530/4111/5530
	for triangle_info in data:gmatch("f (.-)\n") do
	
		-- split it up into 3 parts 
		-- 5529/5456/5529, 1402/4112/1402, 5530/4111/5530
		for vertex_info in triangle_info:gmatch("(.-)%s+") do
			local data = {}
			local type = 1
			
			-- iterate each field
			-- 1 = 5529
			-- 2 = 5456
			-- 3 = 5529
			
			-- where index is the index position 
			-- in one of the 3 types, vertex, uv or normals
						
			for index in vertex_info:gmatch("(%d+)") do
				index = assert(tonumber(index))
				
				if type == 1 then
					data.pos = assert(vertices[index])
				elseif type == 2 then
					data.uv = uvs[index]
				elseif type == 3 then
					data.normal = normals[index]
				end
				 
				type = type + 1
			end
			
			assert(type >= 2 and type <= 4)
			
			table.insert(output, data) 
		end
	end
	 
	print(#vertices, #normals, #uvs, #output)
	
	return output
end

function decode_obj(data)

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
			table_insert(texcoords, tonumber(parts[2]))
			table_insert(texcoords, tonumber(1 - parts[3]))
		elseif parts[1] == "vn" and #parts >= 4 then
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

					if #normals > 0 then
						v1.normal = normals[tonumber(first[3])]
						v2.normal = normals[tonumber(current[3])]
						v3.normal = normals[tonumber(previous[3])]
					end
					
					if #texcoords > 0 then
						v1.u = texcoords[1 + (tonumber(first[2]) - 1) * 2 + 0]%1
						v1.v = texcoords[1 + (tonumber(first[2]) - 1) * 2 + 1]%1
						
						v2.u = texcoords[1 + (tonumber(current[2]) - 1) * 2 + 0]%1
						v2.v = texcoords[1 + (tonumber(current[2]) - 1) * 2 + 1]%1
						
						v3.u = texcoords[1 + (tonumber(previous[2]) - 1) * 2 + 0]%1
						v3.v = texcoords[1 + (tonumber(previous[2]) - 1) * 2 + 1]%1
					end
					
					table_insert(output, v1)
					table_insert(output, v2)
					table_insert(output, v3)
				end

				previous = current
			end
		end
	end

	local vertex_normals = {}

	for i = 1, #output/3 do
		local a, b, c = output[1+(i-1)*3+0], output[1+(i-1)*3+1], output[1+(i-1)*3+2] 
		local normal = (c.pos - a.pos):Cross(b.pos - a.pos):GetNormalized()

		vertex_normals[a.pos_index] = vertex_normals[a.pos_index] or Vec3()
		vertex_normals[a.pos_index] = (vertex_normals[a.pos_index] + normal):GetNormalized()

		vertex_normals[b.pos_index] = vertex_normals[b.pos_index] or Vec3()
		vertex_normals[b.pos_index] = (vertex_normals[b.pos_index] + normal):GetNormalized()

		vertex_normals[c.pos_index] = vertex_normals[c.pos_index] or Vec3()
		vertex_normals[c.pos_index] = (vertex_normals[c.pos_index] + normal):GetNormalized()
	end

	local default_normal = Vec3(0, 0, -1)

	for i = 1, #output do
		output[i].normal = vertex_normals[output[i].pos_index] or default_normal
	end

	return output
end
  
local active_models = {}

do -- model
	local META = {}
	META.__index = META

	class.GetSet(META, "Pos", Vec3(0,0,0))
	class.GetSet(META, "Angles", Vec3(0,0,0))
	class.GetSet(META, "Scale", Vec3(1,1,1))
	class.GetSet(META, "Size", 1)
	class.GetSet(META, "Model", 1)

	function META:SetModel(path)
		self.obj = decode_obj(vfs.Read("models/" .. path))
		self.Model = path
	end
	
	function META:Draw(asdf)
		if not self.obj then return end

		gl.PushMatrix()

		gl.Rotated(self.ang.p, 1, 0, 0)
		gl.Rotated(self.ang.y, 0, 1, 0)
		gl.Rotated(self.ang.r, 0, 0, 1)
		gl.Translated(self.pos.x, self.pos.y, self.pos.z)

		local s = self.size
		gl.Scaled(self.scale.x * s, self.scale.y * s, self.scale.z * s)
	
	
		gl.Begin(e.GL_TRIANGLES)
			if asdf then
				gl.Color4f(0, 0, 0, 0.5)
			else
				gl.Color4f(1, 1, 1, 1)
			end

			for key, data in pairs(self.obj) do
				if data.normal then gl.Normal3f(data.normal:Unpack()) end
				if data.u then gl.TexCoord2f(data.u, data.v) end
				gl.Vertex3f(data.pos:Unpack())
			end 		
		gl.End()
		
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
		gl.Disable(e.GL_LIGHTING)
		gl.PolygonMode(e.GL_FRONT_AND_BACK, e.GL_LINE)
		obj:Draw(true)

		gl.Enable(e.GL_LIGHTING)
		gl.PolygonMode(e.GL_FRONT_AND_BACK, e.GL_FILL)
		obj:Draw()
	end

	gl.Flush() 
end)

local obj = Model()
obj:SetModel("face.obj")
obj:SetSize(1 )
