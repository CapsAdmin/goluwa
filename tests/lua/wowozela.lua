window.Open()
window.SetMouseTrapped(true)

local size = 128
local buffer = ffi.new("ALshort[?]", size)
for i = 0, size-1 do
	buffer[i] = math.random(256)
end

--local sound = utilities.RemoveOldObject(Sound(buffer, size))
local sound = utilities.RemoveOldObject(Sound("sounds/wowozela/triangle_880.wav"))

sound:Play() 
sound:SetChannel(1)
sound:SetLooping(true)
 
local volume = 1
local pitch = 4 

window.Open(1024, 1024) 
  local sphere = Texture(64, 64):Fill(function(x, y) 
	x = x / 64
	y = y / 64
	
	x = x - 1
	y = y - 1.5
	
	x = x * math.pi
	y = y * math.pi
		
	local a = math.sin(x) * math.cos(y)
	
	a = a ^ 32
		
	return 255, 255, 255, a * 128
end)
 
local emitter = utilities.RemoveOldObject(Emitter())
--emitter:SetCenterAttractionForce(0.1) 
--emitter:SetPosAttractionForce(0.1) 
emitter:SetRate(-1)

local trail_tex = Texture(1, 255):Fill(function(x, y) return 255, 255, 255, y end)
    
local grid_size = 1000 

event.AddListener("OnDraw2D", "wowozela", function(dt)
	local size = window.GetSize()
	local pos = window.GetMousePos()
	 
	pitch = ((-pos.y + grid_size) / grid_size)
	pitch = 4 ^ pitch
	
	volume = math.clamp(pos.x / grid_size, 0, 1)

	emitter:SetPos(Vec3(pos:Unpack()))
	
	if input.IsMouseDown("button_1") or input.IsMouseDown("button_2") then
		local p = emitter:AddParticle()
		p:SetDrag(0.999)
		
		--p:SetStartLength(Vec2(0))
		--p:SetEndLength(Vec2(0, 30))
		
		p:SetAngle(90)
		 
		p:SetTexture(sphere)
		p:SetVelocity(Vec3((Vec2(-200,0)):Unpack()))
		
		p:SetLifeTime(5)
		
		p:SetStartSize((1/pitch) * 100)
		p:SetStartAlpha(1)
		p:SetEndAlpha(0)
		p:SetColor(HSVToColor(pitch, 0.5))	
		
		volume = 1
	else
		volume = -100
	end
		
	surface.Color(1,1,1,1)
	surface.SetTexture(sphere)
	surface.DrawRect(pos.x - 64, pos.y - 64, 128, 128)
		
	sound:SetPitch(pitch)
	sound:SetPosition(0,0,(-volume+1)^10*100)  
	
	render.SetupView2D(-pos + size*0.5, 0)
end) 