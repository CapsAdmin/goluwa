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
 
local obj = Entity("base") 
obj:SetObj("teapot.obj")
obj:SetTexture("face1.png")

local obj = Entity("base")
obj:SetPos(Vec3(5,0,0))
obj:SetObj("face.obj")
obj:SetTexture("face1.png")

gl.ClearColor(0,0,0,1)   
input.SetMouseTrapped(true) 
 
local font = Font(R"fonts/arial.ttf")  
font:SetFaceSize(72, 72) 

event.AddListener("OnDraw", "gl", function(dt)
  	calc_camera(window, dt) 
	 
	render.Start(window)	
		
		render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
		
		render.Start3D(cam_pos, cam_ang:GetDeg())
			entities.world_entity:DrawModel()
		
			render.SetTexture(0)
			gl.UseProgram(0)
		
		render.Start2D()		
			gl.Color3f(1,1,1) 
			gl.Color4f(1,1,1,1) 
			
			font:Render(os.date())
			
			local w, h = 200, 200 
			local size = window:GetSize()		
				
			gl.Color4f(1, 1, 1, 0.5)
			render.PushMatrix(Vec3(size.w - w, size.h - h), Ang3(0), Vec3(w, h))			
				gl.Begin(e.GL_TRIANGLES)
					gl.Vertex2f(0, 0)
					gl.Vertex2f(0, 1)
					gl.Vertex2f(1, 1) 

					gl.Vertex2f(1, 1)
					gl.Vertex2f(1, 0)
					gl.Vertex2f(0, 0) 					
				gl.End()				
			render.PopMatrix()			
	render.End() 
end) 
