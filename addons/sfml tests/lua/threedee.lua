local window = asdfml.OpenWindow()

local frame = 0

local cam_pos = Vec3(0, 0, 0)
local cam_ang = Ang3(0, 0, 0)
  
function decode_obj(str)
	local data = {}
	local vertexes = {}
	local normals = {}
	local polygons = {}

	local i = 1

	for t, x, y, z in str:gmatch("(%S+)%s-(%S+)%s-(%S+)%s-(%S+)%s-\n") do
		x, y, z = tonumber(x), tonumber(y), tonumber(z)

		if t == "v" then
			table.insert(vertexes, {x=x,y=y,z=z})
			i = i + 1
		elseif t == "vn" then
			table.insert(normals, {x=x,y=y,z=z})
		elseif t == "f" then
			table.insert(
				polygons,
				{
					[1] = vertexes[x],
					[2] = vertexes[y],
					[3] = vertexes[z],
				}
			)
		end
	end

	for k,v in pairs(normals) do
		polygons[k].n = v
	end

	data.polygons = polygons

	return data
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

	function META:Draw()
		if not self.obj then return end

		gl.PushMatrix()

		gl.Translated(self.pos.x, self.pos.y, self.pos.z)
		gl.Rotated(self.ang.p, 1, 0, 0)
		gl.Rotated(self.ang.y, 0, 1, 0)
		gl.Rotated(self.ang.r, 0, 0, 1)

		local s = self.size
		gl.Scaled(self.scale.x * s, self.scale.y * s, self.scale.z * s)

		for key, data in ipairs(self.obj.polygons) do
			gl.Begin(e.GL_TRIANGLES) 
				local c = HSVToColor(((key/#self.obj.polygons)+frame/100)*360, 1, 1 )
				
				gl.Color3d(
					c.r,
					c.g,
					c.b
				) 
				
				gl.Vertex3d(data[1].x, data[1].y, data[1].z)
				gl.Vertex3d(data[2].x, data[2].y, data[2].z)
				gl.Vertex3d(data[3].x, data[3].y, data[3].z)
			gl.End()
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
   
local function calc_camera(window)
	local pos = mouse.GetPosition(ffi.cast("sfWindow * ", window))
	
	local dx = pos.x - last_x
	local dy = pos.y - last_y
	
	cam_ang.p = math.clamp(cam_ang.p + dy * 0.01, -math.pi / 2, math.pi / 2)
	cam_ang.y = (cam_ang.y + dx * 0.01)%(math.pi*2)
		
	last_x = pos.x 
	last_y = pos.y
		
	--local size = window:GetSize()
	--mouse.SetPosition(Vector2i(size.x/2, size.y/2), ffi.cast("sfWindow * ", window))
	 

	if input.IsKeyDown("space") then
		cam_pos = cam_pos + cam_ang:GetUp()
	elseif input.IsKeyDown("l_control") then
		cam_pos = cam_pos - cam_ang:GetUp()
	end

	if input.IsKeyDown("w") then
		cam_pos = cam_pos + cam_ang:GetForward()
	elseif input.IsKeyDown("s") then
		cam_pos = cam_pos - cam_ang:GetForward()
	end

	if input.IsKeyDown("a") then
		cam_pos = cam_pos - cam_ang:GetRight()
	elseif input.IsKeyDown("d") then
		cam_pos = cam_pos + cam_ang:GetRight()
	end

	if input.IsKeyDown("up") then
		cam_ang.p = math.clamp(cam_ang.p + 0.1, -math.pi / 2, math.pi / 2)
	elseif input.IsKeyDown("down") then
		cam_ang.p = math.clamp(cam_ang.p - 0.1, -math.pi / 2, math.pi / 2)
	end

	if input.IsKeyDown("left") then
		cam_ang.y = (cam_ang.y + 0.1)%(math.pi*2)
	elseif input.IsKeyDown("right") then
		cam_ang.y = (cam_ang.y - 0.1)%(math.pi*2)
	end
	
	local a = cam_ang:GetDeg() 
	
	gl.Rotatef(a.p , 1.0, 0.0, 0.0);
	gl.Rotatef(a.y , 0.0, 1.0, 0.0);
	gl.Rotatef(a.r , 0.0, 0.0, 1.0);
	gl.Translatef(-cam_pos.x, -cam_pos.z, -cam_pos.y)
end 

gl.ClearColor(0.0, 0.25, 0.5, 1)
gl.Enable(e.GL_BLEND)
gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)
gl.Enable(e.GL_DEPTH_TEST)

event.AddListener("OnDraw", "gl", function(dt, window)
	local size = window:GetSize()
	frame = os.clock()*10
	
	gl.Viewport(0, 0, size.x, size.y)
	gl.Clear(e.GL_COLOR_BUFFER_BIT + e.GL_DEPTH_BUFFER_BIT)

	
	gl.LoadIdentity()
	calc_camera(window) 
 
	for key, obj in pairs(active_models) do
		obj:Draw()
	end

	gl.Flush()
end)

local obj = Model()
obj:SetModel("teapot.obj")
obj:SetSize(0.12)
