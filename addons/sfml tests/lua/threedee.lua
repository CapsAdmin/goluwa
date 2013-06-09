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

		gl.MatrixMode(e.GL_MODELVIEW)
		gl.LoadIdentity()

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
   
local function calc_camera()
	if input.IsKeyDown("space") then
		cam_pos = cam_pos - (cam_ang:GetUp() * 1)
	elseif input.IsKeyDown("lcontrol") then
		cam_pos = cam_pos + (cam_ang:GetUp() * 1)
	end

	if input.IsKeyDown("w") then
		cam_pos = cam_pos + (cam_ang:GetForward() * 1)
	elseif input.IsKeyDown("s") then
		cam_pos = cam_pos - (cam_ang:GetForward() * 1)
	end

	if input.IsKeyDown("a") then
		cam_pos = cam_pos + (cam_ang:GetRight() * 1)
	elseif input.IsKeyDown("d") then
		cam_pos = cam_pos - (cam_ang:GetRight() * 1)
	end

	if input.IsKeyDown("up") then
		cam_ang.p = math.clamp(cam_ang.p - 4, -90, 90)
	elseif input.IsKeyDown("down") then
		cam_ang.p = math.clamp(cam_ang.p + 4, -90, 90)
	end

	if input.IsKeyDown("left") then
		cam_ang.y = (cam_ang.y - 4)%360
	elseif input.IsKeyDown("right") then
		cam_ang.y = (cam_ang.y + 4)%360
	end
end

input.debug = false  

gl.ClearColor(0, 0.25, 0.5, 1)
gl.LineWidth(1.5)
gl.Enable(e.GL_LINE_SMOOTH)
gl.Enable(e.GL_POINT_SMOOTH)
gl.PointSize(10)
gl.Enable(e.GL_BLEND)
gl.BlendFunc(e.GL_SRC_ALPHA, e.GL_ONE_MINUS_SRC_ALPHA)

event.AddListener("OnDraw", "gl", function(dt, window)
	local size = window:GetSize()
	frame = os.clock()*10
	calc_camera()
 
	gl.Viewport(0, 0, size.x, size.y)

	gl.ClearColor(0, 0, 0, 1)
	gl.Clear(e.GL_COLOR_BUFFER_BIT)

	gl.MatrixMode(e.GL_PROJECTION)
	gl.LoadIdentity()
	glu.Perspective(70, size.x/size.y, 0.1, 10000)
	
	gl.Rotated(cam_ang.p, 1, 0, 0)
	gl.Rotated(cam_ang.y, 0, 1, 0)
	
	gl.Translated(cam_pos.x, cam_pos.y, cam_pos.z)

	for key, obj in pairs(active_models) do
		obj:Draw()
	end
end)

local obj = Model()
obj:SetModel("teapot.obj")
obj:SetSize(0.12)
obj:SetAngles(Ang3(10,0,0))