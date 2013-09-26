window.Open(1280, 720)
  
entities.world_entity:RemoveChildren() 

local obj = Entity("model")
obj:SetPos(Vec3(5,0,0))
obj:SetModelPath("models/spider.obj")

window.SetMouseTrapped(true)