local GENERATE_BODY = 160
local MAX_SPEED = 1e-08

do -- circle body
	local META = {}
	
	META.__index = META
	
	META.updatable = true

	class.GetSet(META, "Position", Vec2())
	class.GetSet(META, "Velocity", Vec2())
	class.GetSet(META, "Radius", 32)
	class.GetSet(META, "Mass", 0)

	function META:Update(delta)
		self.Velocity = self.Velocity * 0.9
		self.Position = self.Position + self.Velocity * delta
		self.circle:SetPosition(self.Position - self.Radius)
	end

	local data = {}
	
	function META:CheckCollide(other)
		if other == self then return end
		
		local temp = other:GetPosition() - self.Position
		local dist = temp:GetLength()

		if dist >= (self.Radius + other:GetRadius()) then
			return false
		end

		if dist > MAX_SPEED then
			temp = temp / dist
		end
			
		data.normal = temp
		data.depth = self.Radius + other:GetRadius() - dist

		if data.depth < MAX_SPEED then
			data.depth = MAX_SPEED
		end
		
		self.collision_data = data

		return true
	end
	
	function META:Collide(other)
		if not self.updatable then return end
		
		local data = self.collision_data
		
		if other.updatable then	
			local move = data.normal * data.depth * 0.5
			
			self.Position = self.Position - move
			other:SetPosition(other:GetPosition() + move)
		else
			local move = data.normal * data.depth
			self.Position = self.Position - move
		end
	end
		
	function META:SetRadius(rad)
		self.Radius = rad
		self.circle:SetRadius(rad)		
	end
		
	function CircleBody(pos, radius)
		local self = setmetatable({}, META)
		
		self.Position = pos
		self.Radius = radius
		self.Mass = self.Radius * self.Radius
		
		self.Accelleration = Vec2()
		self.last_pos = Vec2()
		
		local circle = CircleShape()
				
		--circle:Rotate(math.randomf(360))
		--circle:SetPointCount(8)
		circle:SetRadius(self.Radius)
		circle:SetFillColor(Color(64,128,255,150))
		circle:SetOutlineColor(Color(255,255,255,128))
		circle:SetOutlineThickness(2)
				
		self.circle = circle
				
		return self
	end

end
	
local window = asdfml.OpenWindow()
window:SetFramerateLimit(60)

local zoom_factor = 1.0
local zoom_up = false
local zoom_down = false

local view = window:GetView()
view = ffi.cast("struct sfView *", view)
local bodies = {}

for i = 0, GENERATE_BODY / 2 do
	table.insert(bodies, CircleBody(Vec2(math.random(0, 800), math.random(0, 600)), math.randomf(1, 25))
	)
end


local ghost_radius = 15
local ghost_position = Vec2()
local ghost = CircleBody()
ghost:SetRadius(ghost_radius)
ghost.updatable = false
ghost.circle:SetFillColor(Color(255, 255, 255, 64))

local params = Event()

event.AddListener("OnMouseButtonReleased", "verlet_physics", function(params)
	if params.mouseButton.button == e.MOUSE_LEFT then
		local pos = window:MapPixelToCoords(ghost_position - ghost_radius, view)
		local body = CircleBody(pos, ghost_radius)
		table.insert(bodies, body)
	end
end)

event.AddListener("OnMouseWheelMoved", "verlet_physics", function(params)
	if params.mouseWheel.delta > 0 then
		ghost_radius = ghost_radius + 1
	else 
		ghost_radius = ghost_radius - 1
	end
end)

event.AddListener("OnDraw", "verlet_physics", function(dt, window)		
	ghost:SetRadius(ghost_radius)
		
	if keyboard.IsKeyPressed(e.KEY_LEFT) then
		view:Move(Vec2(-10, 0))
	elseif keyboard.IsKeyPressed(e.KEY_RIGHT) then
		view:Move(Vec2(10, 0))
	elseif keyboard.IsKeyPressed(e.KEY_UP) then
		view:Move(Vec2(0, -10))
	elseif keyboard.IsKeyPressed(e.KEY_DOWN) then
		view:Move(Vec2(0, 10))
	elseif keyboard.IsKeyPressed(e.KEY_PAGE_UP) then
		zoom_factor = zoom_factor + 0.01
		zoom_up = true
		zoom_down = false
	elseif keyboard.IsKeyPressed(e.KEY_PAGE_DOWN) then
		zoom_factor = zoom_factor - 0.01
		zoom_up = false
		zoom_down = true
	end
	
	if zoom_up == true and zoom_factor > 1 then
		zoom_factor = zoom_factor - 0.005
		
		if zoom_factor < 1 then
			zoom_factor = 1
			zoom_up = false
		end
	end
	
	if zoom_down == true and zoom_factor > 1 then
		zoom_factor = zoom_factor + 0.005
		
		if zoom_factor >= 1 then
			zoom_factor = 1
			zoom_down = false
		end
	end
		
	if zoom_factor > 1.2 then
		zoom_factor = 1.2
	end
	
	if zoom_factor < 0.8 then
		zoom_factor = 0.8
	end
	
	
	if keyboard.IsKeyPressed(e.KEY_ESCAPE) then
		window:Close()
	end
		
	for key, a in pairs(bodies) do
		local vel = Vec2()
		
		for key, b in pairs(bodies) do
			if a ~= b then					
				local temp = (b:GetPosition() - a:GetPosition())
				local dist = temp:GetLengthSquared()
				
				if dist > MAX_SPEED then
					temp = temp / dist
				end
				
				temp = temp * (a:GetMass() * b:GetMass() * 0.01 / dist)
				vel = vel + temp
				
				if a:CheckCollide(b) == true then
					a:Collide(b)
				end
			end
		end
		
		a:Update(dt * 100)
		a.Velocity = a.Velocity + vel	
	end	
	
	view:Zoom(zoom_factor)
	window:SetView(view)
				
	ghost_position = mouse.GetPosition(ffi.cast("struct sfWindow *", window))
	local pos = window:MapPixelToCoords(ghost_position - ghost_radius, view)
	ghost:SetPosition(pos)
	ghost.circle:SetPosition(pos)
		
    window:Clear(Color(2, 4, 8, 10))
	
	for key, body in pairs(bodies) do
		window:DrawCircleShape(body.circle, nil)
	end
	
	window:DrawCircleShape(ghost.circle, nil)
end)