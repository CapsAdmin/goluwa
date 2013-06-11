local window = asdfml.OpenWindow()
 
local cam_pos = Vec3(0, 0, -10)
local cam_ang = Ang3(0, 0, 0)     
 
local last_x = 0
local last_y = 0
   
local function calc_camera(window, dt)

	cam_ang:Normalize()
	local speed = dt * 10

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
		cam_pos = cam_pos - Vec3(0, speed, 0);
	end

	if (input.IsKeyDown("l_shift")) then
		cam_pos = cam_pos + Vec3(0, speed, 0);
	end;

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
		self.mesh = Mesh(vfs.Read("models/" .. path))
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
		
		render.PushMatrix(self.Pos, self.Ang, self.Scale)
			self.mesh:Draw()	
		render.PopMatrix()
	end
   
 
	function Model(path)
		local self = setmetatable({}, META)
		table.insert(active_models, self)

		return self
	end 
end

local size = window:GetSize()
render.Initialize(size.x, size.y)

local obj = Model()
obj:SetModel("face.obj")
obj:SetTexture("face1.png")

event.AddListener("OnDraw", "gl", function(dt, window)
	window:Clear(sfml.Color(100, 100, 100, 255))

	obj:SetSize(math.sin(os.clock() * 0.4) * 2);

  	calc_camera(window, dt) 
	render.Start()
		render.Clear(e.GL_COLOR_BUFFER_BIT, e.GL_DEPTH_BUFFER_BIT)
		
		render.SetMatrixMode(e.GL_PROJECTION)
			render.SetPerspective()
			
			local a = cam_ang:GetDeg()
			gl.Rotatef(a.p, 1, 0, 0)
			gl.Rotatef(a.y, 0, 1, 0)
			gl.Rotatef(a.r, 0, 0, 1)
			gl.Translatef(cam_pos.x, cam_pos.y, cam_pos.z)			
		
		render.SetMatrixMode(e.GL_MODELVIEW)				
			for key, obj in pairs(active_models) do
				obj:Draw()
			end				
	render.End()
 
end) 