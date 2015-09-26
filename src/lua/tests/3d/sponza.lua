entities.Panic()

local center = Vec3(0,0,0)

local terrain = entities.CreateEntity("visual")
terrain:SetModelPath("models/skpfile.obj", nil, nil, 1)
terrain:SetAngles(Ang3(0,0,0))
terrain:SetPosition(Vec3(1000, -1000, -90))
terrain:SetScale(Vec3(30, 30, 30))

local sponza = entities.CreateEntity("visual")
sponza:SetModelPath("crytek-sponza.zip/crytek-sponza/sponza.obj")
sponza:SetPosition(center)
sponza:SetAngles(Ang3(0,0,0))
sponza:SetSize(0.1)


local sphere = entities.CreateEntity("visual")
sphere:SetModelPath("models/sphere.obj")
sphere:SetPosition(Vec3(0,0,20))
sphere:SetSize(1)
sphere:SetDiffuseTexture(render.GetBlackTexture())
sphere:SetSpecularTexture(render.GetBlackTexture())
sphere:SetBumpTexture(render.GetBlackTexture())

local sun = entities.CreateEntity("light")
sun:SetPosition(Vec3(1, 1, 1)*1000)
sun:SetColor(Color(1,1,0.9))
sun:SetSize(1000)
sun:SetIntensity(0.75)
SUN = sun

local sponza = entities.CreateEntity("visual")
sponza:SetModelPath("crytek-sponza.zip/crytek-sponza/sponza.obj")
sponza:SetPosition(center + Vec3(300,0,0))
sponza:SetAngles(Ang3(0,90,0))
sponza:SetSize(0.1)

for i=1,3 do
	for b=1,3 do
		local person = entities.CreateEntity("visual")
		person:SetModelPath("models/Citizen Extras_Female 02.dae")
		person:SetAngles(Ang3(-90,i*b*90,0))
		person:SetPosition(center + Vec3(36,0,0) + Vec3(-i*20,-b*20, 0))
		person:SetSize(0.1)

		local cube = entities.CreateEntity("visual")
		cube:SetModelPath("models/cube.obj")
		cube:SetAngles(Ang3(-90,i*b*90,0))
		cube:SetPosition(center + Vec3(36,60,0) + Vec3(-i*20,-b*20, 5))
		cube:SetSize(5)
	end
end

local mdl = entities.CreateEntity("visual")
mdl:SetModelPath("models/spider.obj")
mdl:SetPosition(center + Vec3(0,0,32))
mdl:SetSize(0.1)
--mdl:SetAngles(Ang3(0,0,0))
event.CreateTimer("lol",0,0,function() if mdl:IsValid() then mdl:SetAngles(Ang3(system.GetTime()*50,0,0)) end end)

do return end

local mdl = entities.CreateEntity("visual")
mdl:SetModelPath("models/sponza.obj")
mdl:SetPosition(Vec3(-50,0,0))

local mdl = entities.CreateEntity("visual")
mdl:SetModelPath("models/spider.obj")
mdl:SetPosition(Vec3(5000, -3000, 200))
mdl:SetAngles(Ang3(0,0,0))
event.CreateTimer("lol",0,0,function() mdl:SetAngles(Ang3(system.GetTime()*50,0,0)) end)
mdl:SetSize(10)


local mdl = entities.CreateEntity("visual")
mdl:SetModelPath("models/spider.obj")
mdl:SetPosition(Vec3(0, 0, 0))
mdl:SetAngles(Ang3(10,10,10))
mdl:SetSize(1)

local mdl = entities.CreateEntity("visual")
mdl:SetModelPath("models/face.obj")
mdl:SetAngles(Ang3(0,90,0))
mdl:SetSize(20)
mdl:SetPosition(Vec3(0,500, 200))

for i=1,15 do
	for b=1,15 do
		local mdl = entities.CreateEntity("visual")
		mdl:SetModelPath("models/Citizen Extras_Female 02.dae")
		mdl:SetAngles(Ang3(90,10,0)) --Original: mdl:SetAngles(Ang3(90,-b*70,0))
		--mdl:SetAngles(Ang3(90,0,0))
		mdl:SetPosition(Vec3(600,-100) + Vec3(-i*70,-b*70, 0))
		mdl:SetSize(1.2)
	end
end

local mdl = entities.CreateEntity("visual")
mdl:SetModelPath("models/skpfile.obj", nil, nil, 1)
mdl:SetAngles(Ang3(0,0,0))
mdl:SetPosition(Vec3(-5000,-150, -200))
mdl:SetSize(100)

local mdl = entities.CreateEntity("visual")
mdl:SetModelPath("models/skpfile.obj", nil, nil, 1)
mdl:SetAngles(Ang3(0,0,0))
mdl:SetPosition(Vec3(-5000,31900, -200))
mdl:SetSize(100)

