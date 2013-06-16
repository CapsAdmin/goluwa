local window = glw.OpenWindow(1280, 720)
   
local cam_pos = Vec3(0, 0, -10)
local cam_ang = Ang3(0, 0, 0)     
    
local function calc_camera(window, dt)

	cam_ang:Normalize()
	local speed = dt * 10
	
	local delta = input.GetMouseDelta() * dt / 2
	cam_ang.p = cam_ang.p + delta.y
	cam_ang.y = cam_ang.y + delta.x
	cam_ang.p = math.clamp(cam_ang.p, -math.pi/2, math.pi/2)

	if input.IsKeyDown("left_shift") then
		speed = speed * 4
	elseif input.IsKeyDown("left_control") then
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

              
local active_models =  {}
 
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
		self.tex = render.CreateTexture("textures/" .. path)
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

gl.ClearColor(0,0,0,0)   
input.SetMouseTrapped(true) 
 
local font = Font(R"fonts/arial.ttf")  
font:SetFaceSize(72, 72) 

event.AddListener("OnDraw", "gl", function(dt)
  	calc_camera(window, dt) 
	 
	render.Start(window)	
		
		render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
		
		render.Start3D(cam_pos, cam_ang:GetDeg())
			for key, obj in pairs(active_models) do
				obj:Draw() 
			end		
		
		render.Start2D()
			local w, h = 200, 200 
			
			render.SetTexture(0)
			gl.UseProgram(0)
						
			local size = window:GetSize()		
				
			gl.Color4f(0, 1, 0, 0.5)
			render.PushMatrix(Vec3(size.w - w, size.h - h), Ang3(0), Vec3(w, h))			
				gl.Begin(e.GL_QUADS)
					gl.Vertex2f(0, 0)
					gl.Vertex2f(0, 1)
					gl.Vertex2f(1, 1) 
					gl.Vertex2f(1, 0) 			
				gl.End()				
			render.PopMatrix()
			
			gl.Scalef(1,1,1)
			gl.Translatef(100,100,0)
			gl.Color4f(1,1,1,1) 
			
			font:Render(os.date())
			
	render.End()
end) 
