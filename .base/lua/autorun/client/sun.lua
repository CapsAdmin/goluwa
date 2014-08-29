if SUN then return end

event.Delay(1, function()

local sun = entities.CreateEntity("light")
sun:SetPosition(Vec3(-284.77694702148, -271.65432739258, 244.03981018066)) 
sun:SetColor(Color(1,1,0.9)) 
sun:SetSize(1000)
sun:SetDiffuseIntensity(0.75)
SUN = sun
end)