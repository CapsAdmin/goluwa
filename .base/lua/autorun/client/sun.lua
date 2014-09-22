event.Delay(0.1, function()

	if SUN and SUN:IsValid() then SUN:Remove() end  

	local sun = entities.CreateEntity("light")
	sun:SetPosition(Vec3(-284.77694702148, -271.65432739258, 244.03981018066)) 
	sun:SetColor(Color(1,1,1)) 
	sun:SetSize(1000)
	sun:SetDiffuseIntensity(2)
	
	SUN = sun
end)