event.Delay(0.1, function()

	if SUN and SUN:IsValid() then SUN:Remove() end  

	local size = 2000
	
	local sun = entities.CreateEntity("light")
	sun:SetPosition(Vec3(-size/2, -size/2, size)) 
	sun:SetAngles(Ang3(44.95, 44.8, 0)) 
	sun:SetColor(Color(1,1,0.9)) 
	sun:SetSize(size)
	sun:SetDiffuseIntensity(1.75)
	sun:SetSpecularIntensity(0.1)
	
	sun:SetShadow(false) -- doesn't work yet
	sun:SetFOV(100)
	sun:SetNearZ(0.1)

	SUN = sun 
end) 