local gui = ... or _G.gui

local PANEL = {}

PANEL.ClassName = "sheep"

local animations = {
	sleep = {tiles = {Vec2(0,0), Vec2(1,0)}, speed = 1},
	walk = {tiles = {Vec2(2,0), Vec2(3,0)}, speed = 5},
	run = {tiles = {Vec2(4,0), Vec2(5,0)}, speed = 8},
	blink = {tiles = {Vec2(6,0), Vec2(7,0), Vec2(8,0)}, speed = 15},
	turn = {tiles = {Vec2(6,0), Vec2(9,0), Vec2(10,0), Vec2(11,0), Vec2(-7,0), Vec2(14, 0), Vec2(13, 0), Vec2(12, 0)}, speed = 15},
	comet = {tiles = {Vec2(6,8), Vec2(7,8), Vec2(8,8), Vec2(9,8), Vec2(10,8), Vec2(11,8),Vec2(12,8), Vec2(13,8),Vec2(14,8), Vec2(15,8), Vec2(0, 9), Vec2(1, 9)}, speed = 15},
}

local tile_size = Vec2() + 40

function PANEL:DrawTile(tile_x, tile_y, rot)
	tile_x = tile_x or 0
	tile_y = tile_y or 0
	tile_x = tile_x * tile_size.x
	tile_y = tile_y * tile_size.y
	
	local w, h = tile_size.x, tile_size.y
	
	if tile_x < 0 then tile_x = -tile_x w = -w end
	if tile_y < 0 then tile_y = -tile_y h = -h end
	
	surface.SetRectUV(tile_x, tile_y, w, h, surface.GetTexture().w, surface.GetTexture().h)
	surface.DrawRect(self.Size.x/2, self.Size.y/2, self.Size.x, self.Size.y, rot or 0, self.Size.x/2, self.Size.y/2)
end

function PANEL:DrawAnimation(animation, frame, rot, flip_x, relative)
	local time = system.GetElapsedTime()
	local data = animations[animation]
	
	local i = relative and math.clamp(math.round(frame), 1, #data.tiles) or math.floor((frame%#data.tiles) + 1)
	local pos = data.tiles[i]
	if pos then
		self:DrawTile(flip_x and -pos.x-1 or pos.x, pos.y, rot)
	end
end

function PANEL:Initialize()
	self:SetSize(tile_size)
	self.Position = Vec2():Random(0,500)  
	self:SetDraggable(true)
	self:SetResizable(true)
	self.Velocity = Vec2()
	self.sheep_texture = Texture("textures/esheep.png")
	self.sheep_texture:SetMinFilter("nearest")
	self.sheep_texture:SetMagFilter("nearest")
	self.frame = 0
end

function PANEL:OnParentLand(parent)
	self:SetParent(parent)
end

local faint_vel = 2
local bounce = 0.9 

function PANEL:CheckCollision()
	local w, h = self.Parent:GetSize():Unpack()
	local length = self.Velocity:GetLength()

	self.on_ground = false
	
	local pos, found = self.Parent:RayCast(self, self.Position.x, h - self.Size.y, self.Size.x, self.Size.y, true, true)
	
	if self.Position.y > pos.y - 2 then
		self.on_ground = true
	end
	
	if self.Position.y > pos.y then 
		if length> faint_vel then self.faint_time = length/5 self.faint = system.GetElapsedTime() + self.faint_time end
		self.Velocity = self.Velocity:GetReflected(Vec2(0,1)) * bounce
		self.Position.y = self.Position.y - 1
		if found and found.Velocity then found.Velocity.y = found.Velocity.y + (self.Velocity.y * -0.5) end
		return
	end
	
	local pos, found = self.Parent:RayCast(self, self.Position.x, 1, self.Size.x, self.Size.y, true, true)
	
	if self.Position.y < pos.y then
		if length> faint_vel then self.faint_time = length/5  self.faint = system.GetElapsedTime() + self.faint_time end
		self.Velocity = self.Velocity:GetReflected(Vec2(0,-1)) * bounce
		self.Position.y = self.Position.y + 1
		if found and found.Velocity then found.Velocity.y = found.Velocity.y + (self.Velocity.y * -0.5) end
		return
	end
	
	local pos, found = self.Parent:RayCast(self, w - self.Size.x, self.Position.y, self.Size.x, self.Size.y, true, true)
		
	if self.Position.x > pos.x - 4 then
		if length> faint_vel then self.faint_time = length/5 self.faint = system.GetElapsedTime() + self.faint_time end
		self.Velocity = self.Velocity:GetReflected(Vec2(1,0)) * bounce
		self.Position.x = self.Position.x - 1
		if found and found.Velocity then found.Velocity.x = found.Velocity.x + (self.Velocity.x * -0.5) end
		return 
	end
	
	local pos, found = self.Parent:RayCast(self, 1, self.Position.y, self.Size.x, self.Size.y, true, true)
	
	if self.Position.x < pos.x + 4 then
		if length> faint_vel then self.faint_time = length/5 self.faint = system.GetElapsedTime() + self.faint_time end
		self.Velocity = self.Velocity:GetReflected(Vec2(-1,0)) * bounce
		self.Position.x = self.Position.x + 1
		if found and found.Velocity then found.Velocity.x = found.Velocity.x + self.Velocity.x * -0.5 end
		return
	end
end

function PANEL:OnUpdate()	
	local dt = system.GetFrameTime() / 5
	local mpos = self:GetMousePosition()

	if self:IsDragging() then self.Velocity = Vec2(surface.GetMouseVel())/10 end 
	
	self.frame = self.frame + self.Velocity.x / 15
	self.Velocity = self.Velocity + Vec2(0, 10) * dt  

	if self.faint and self.faint > system.GetElapsedTime() then
		
	else
		if self.on_ground then
			if math.abs(mpos.x - self.Size.x/2) > self.Size:GetLength() then
				self.Velocity.x = self.Velocity.x + mpos.x * dt * 0.25
			else
				self.Velocity:Set(0,0)
			end
		end
		self.faint = nil
		self.faint_time = nil
	end
		
--	for i = 1, 3 do
		self:CheckCollision()
	--end
	

	if self.on_ground and not self.faint then
		self.Velocity = self.Velocity * 0.9
		self.Velocity = self.Velocity * 0.99
	end
	self:MarkCacheDirty()
	self.Position = self.Position + self.Velocity
	if not self.Position:IsValid() then self.Position:Zero() end
	if not self.Velocity:IsValid() then self.Velocity:Zero() end 
end

function PANEL:OnDraw()
	surface.SetTexture(self.sheep_texture)
	local length = self.Velocity:GetLength() 
	local w, h = self.Parent:GetSize():Unpack()

	if self.faint then
		if self.on_ground then 
			self:DrawAnimation("comet", (-(self.faint-system.GetElapsedTime()) / self.faint_time + 1)*#animations.comet.tiles, self.frame)
		else
			self:DrawAnimation("comet", (-(self.faint-system.GetElapsedTime()) / self.faint_time + 1)*#animations.comet.tiles, -self.Velocity:GetRad() - (math.pi / 3), false, true)
		end
	elseif not self.on_ground then
		self:DrawTile(6,8, -self.Velocity:GetRad() - (math.pi / 3), false, true)
	else
		if length < 0.01 then
			self:DrawTile(2,2)
		elseif length > 0.1 then
			self:DrawAnimation("run", self.frame/2, 0, self.Velocity.x > 0)
		else 
			self:DrawAnimation("walk", self.frame, 0, self.Velocity.x > 0) 
		end
	end
	surface.SetRectUV()
end
  
gui.RegisterPanel(PANEL)  

if RELOAD then
	local sheep = gui.CreatePanel("sheep")  

end 