window.Open(1280, 720)
  
entities.world_entity:RemoveChildren() 

for i = 1, 4 do 
for i2 = 1, 4 do 
	local obj = Entity("model")
	obj:SetPos(Vec3(30*i,30*i2,0))
	obj:SetModelPath("models/volcano.obj") 
end
end

local obj = Entity("model")
obj:SetPos(Vec3(0,50,0))
obj:SetModelPath("models/bird_nest.obj") 

local obj = Entity("model")
obj:SetPos(Vec3(-50,-50,0))
obj:SetModelPath("models/spider.obj") 

window.SetMouseTrapped(true)  