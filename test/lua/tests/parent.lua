entities.Panic()

local parent = entities.CreateEntity("clientside")
		
parent:SetColor(Color(1,1,1))
parent:SetAlpha(1)
parent:SetModelPath("models/cube.obj")
parent:SetPosition(Vec3(0, 0, 0))
parent:SetAngles(Ang3(90,0,0)) 
parent:SetScale(Vec3(1,1,1))

local node = parent

for i = 1, 1 do 

	local child = entities.CreateEntity("clientside", node)
	child:SetPosition(Vec3(0, 3, 0))
	child:SetAngles(Ang3(0,0,0)) 
	child:SetScale(Vec3(1, 1, 1)) 
	child:SetModelPath("models/cube.obj")
	
	--child:SetColor(Color(500,100,500))
	
	-- shortcut this somehow but the argument needs to be transform not entity
	--child:GetComponent("transform"):SetParent(parent:GetComponent("transform"))
	
	node = child
end

local start = timer.GetSystemTime()

parent:BuildChildrenList()

event.AddListener("Update", "lol", function()			
	local t = timer.GetSystemTime() - start 
	for i, child in ipairs(parent:GetChildrenList()) do
		child:SetAngles(Ang3(t,t,t))
		t = t * 1.001
	end
	
end, {priority = -19})