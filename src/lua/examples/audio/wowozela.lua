window.Open()
window.SetMouseTrapped(true)

--[[local size = 128
local buffer = ffi.new("ALshort[?]", size)
for i = 0, size-1 do
	buffer[i] = math.random(256)
end

local sound = utility.RemoveOldObject(Sound(buffer, size))
]]
local sound = utility.RemoveOldObject((Sound("sounds/wowozela/sine_880.wav")))

sound:Play()
sound:SetLooping(true)

local volume = 1
local pitch = 1

local sphere = render.CreateBlankTexture(Vec2(64, 64)):Fill(function(x, y)
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

local emitter = ParticleEmitter()
--emitter:SetCenterAttractionForce(0.1)
--emitter:SetPosAttractionForce(0.1)
emitter:SetRate(-1)
emitter:SetTexture(sphere)

local lol
local grid_size = 1000
local smooth_pitch = 0

event.AddListener("PostDrawMenu", "wowozela", function(dt)
	local size = window.GetSize()

	surface.SetColor(0,0,0,1)
	surface.SetWhiteTexture()
	surface.DrawRect(0,0,size.x, size.y)

	local pos = window.GetMousePosition()

	local y = (-(pos.y / size.y) + 1)

	if input.IsKeyDown("left_alt") then
		y = y - 1
	end

	local pitch = (4 ^ y)

	volume = math.clamp(pos.x / size.x, 0, 1)

	emitter:SetPosition(Vec3(pos.x, pos.y, 0))

	if input.IsMouseDown("button_1") or input.IsMouseDown("button_2") then
		local p = emitter:AddParticle()
		p:SetDrag(0.999)

		--p:SetStartLength(Vec2(0))
		--p:SetEndLength(Vec2(0, 30))

		p:SetAngle(90)

		p:SetVelocity(Vec3((Vec2(-200,0)):Unpack()))

		p:SetLifeTime(5)

		p:SetStartSize((1/pitch) * 100)
		p:SetStartAlpha(1)
		p:SetEndAlpha(0)
		p:SetColor(ColorHSV(pitch, 0.5))

		--volume = 1
		if not lol then
			--smooth_pitch = smooth_pitch + 1.51
			lol = true
			sound:SetSampleOffset(0)
		end
	else
		volume = -100
		lol = false
	end

	surface.SetColor(1,1,1,1)
	surface.SetTexture(sphere)
	surface.DrawRect(pos.x - 64, pos.y - 64, 128, 128)

	--sound:Play()

	smooth_pitch = pitch --smooth_pitch + ((pitch - smooth_pitch) * dt * 10)

	sound:SetPitch(smooth_pitch)
	sound:SetPosition(0,0,(-volume+1)^10*100)

--	render.SetupView2D(-pos + size*0.5, 0)

	emitter:Update(dt)
	emitter:Draw()
end)