local bg = Color(64, 44, 128)

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

local emitter = utilities.RemoveOldObject(ParticleEmitter(800))
emitter:SetRate(-1)
emitter:SetPos(Vec3(50,50,0))
emitter:SetDrawManual(true) 
--emitter:SetTexture(sphere)  
--emitter:SetMoveResolution(0.5)  
emitter:SetAdditive(false)  

event.AddListener("PreDrawMenu", "zsnow", function()	
	surface.SetWhiteTexture()
	surface.SetColor(bg)
	surface.DrawRect(0, 0, render.GetWidth(), render.GetHeight())
	
	surface.SetColor(1,1,1,1)
	emitter:Draw()
end) 

event.CreateTimer("zsnow", 0.01, function()
	emitter:SetPos(Vec3(math.random(render.GetWidth() + 100) - 150, -50, 0))
		
	local p = emitter:AddParticle()
	p:SetDrag(1)

	--p:SetStartLength(Vec2(0))
	--p:SetEndLength(Vec2(30, 0))
	p:SetAngle(math.random(360)) 
	 
	p:SetVelocity(Vec3(math.random(100),math.random(40, 80)*2,0))

	p:SetLifeTime(20)

	p:SetStartSize(2 * (1 + math.random() ^ 50))
	p:SetEndSize(2 * (1 + math.random() ^ 50))
	p:SetColor(Color(1,1,1, math.randomf(0.5, 0.8)))
end)