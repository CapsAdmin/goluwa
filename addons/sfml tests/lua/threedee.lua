local window = asdfml.OpenWindow()
 
asdfml.SetMouseTrapped(true)
 
local cam_pos = Vec3(0, 0, -10)
local cam_ang = Ang3(0, 0, 0)     
 
local last_x
local last_y
   
local function calc_camera(window, dt)

	cam_ang:Normalize()
	local speed = dt * 10
	
	local delta = asdfml.GetMouseDelta() * dt / 2
	cam_ang.p = cam_ang.p + delta.y
	cam_ang.y = cam_ang.y + delta.x
	cam_ang.p = math.clamp(cam_ang.p, -math.pi/2, math.pi/2)

	if input.IsKeyDown("l_shift") then
		speed = speed * 4
	elseif input.IsKeyDown("l_control") then
		speed = speed / 4
	end

	if input.IsKeyDown("space") then
		cam_pos = cam_pos - Vec3(0, speed, 0);
	end

	local offset = cam_ang:GetUp() * speed;
	offset.x = -offset.x;
	offset.y = -offset.y

	if input.IsKeyDown("w") then

		cam_pos = cam_pos + offset
	elseif input.IsKeyDown("s") then
		cam_pos = cam_pos - offset
	end

	offset = cam_ang:GetRight() * speed
	offset.z = -offset.z

	if input.IsKeyDown("a") then
		cam_pos = cam_pos + offset
	elseif input.IsKeyDown("d") then
		cam_pos = cam_pos - offset
	end  

	speed = dt * 5

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
end  

              
local active_models = {}
 
do -- model 
	local META = {}
	META.__index = META

	class.GetSet(META, "Pos", Vec3(0,0,0))
	class.GetSet(META, "Angles", Ang3(0,0,0))
	class.GetSet(META, "Scale", Vec3(1,1,1))
	class.GetSet(META, "Size", 1)
	class.GetSet(META, "Model")
	class.GetSet(META, "Texture")

	function META:SetModel(path)
		self.Model = path
		
		local str = vfs.Read("models/" .. path)
		
		utilities.ParseObj(str, function(data)
			self.mesh = Mesh(data)
		end, true)
	end
	
	function META:SetTexture(path)
		render.SetTextureFiltering()
		self.tex = Texture("file", R("textures/" .. path))
		self.tex:Bind()
		self.Texture = path 
	end
	
	function META:Draw()
		if not self.mesh then return end
		
		if self.tex then
			render.SetTexture(self.tex)
		end
		
		render.PushMatrix(self.Pos, self.Angles, self.Scale * self.Size)
			self.mesh:Draw()	
		render.PopMatrix()
	end
   
 
	function Model(path)
		local self = setmetatable({}, META)
		table.insert(active_models, self)

		return self
	end 
end

local obj = Model()
obj:SetModel("teapot.obj")
obj:SetTexture("face1.png")

local obj = Model()
obj:SetPos(Vec3(5,0,0))
obj:SetModel("face.obj")
obj:SetTexture("face1.png")

gl.ClearColor(1,1,1,0)

event.AddListener("OnDraw", "gl", function(dt, window)
	--window:Clear(sfml.Color(100, 100, 100, 255))
	
  	calc_camera(window, dt) 
  	local angle = (cam_pos - obj:GetPos()):GetAng3():GetDeg();

 -- 	obj:SetAngles(angle)

	render.Start()
		render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
		
		render.SetMatrixMode(e.GL_PROJECTION)
			render.SetPerspective()
			
			local a = cam_ang:GetDeg()
			gl.Rotatef(a.p, 1, 0, 0)
			gl.Rotatef(a.y, 0, 1, 0)
			gl.Rotatef(a.r, 0, 0, 1)
			gl.Translatef(cam_pos.x, cam_pos.y, cam_pos.z)	
		
		render.SetCamera(cam_pos) 
		
		render.SetMatrixMode(e.GL_MODELVIEW)				
			for key, obj in pairs(active_models) do
				obj:Draw()
			end				
	render.End()
 
end) 