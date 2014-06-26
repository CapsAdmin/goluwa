local panel = utilities.RemoveOldObject((gui.Create("frame")))
panel:SetSize(window.GetSize())    
panel:Center() 
panel:SetMargin(Rect(5,5,5,5))
panel:SetDockPadding(5) 

local function lol(base)	

	local size = base:GetSize() / 4
	
	base:SetDockPadding(5) 
	
	do
		local panel = base:CreatePanel("draggable")
		panel:SetSize(size)    
		panel:Dock("left")
	end

	do
		local panel = base:CreatePanel("draggable")
		panel:SetSize(size)    
		panel:Dock("right")
	end

	do
		local panel = base:CreatePanel("draggable")
		panel:SetSize(size)    
		panel:Dock("top")
	end

	do        
		local panel = base:CreatePanel("draggable")
		panel:SetSize(size)    
		panel:Dock("bottom")
	end

	do	
		local eye = base:CreatePanel("image")
		eye:SetResizePanelWithImage(false)
		eye:SetSize(size) 
		eye:SetTexture(Texture("textures/silkicons/eye.png"))
		eye:Dock("center") 
	end           

end  
  
lol(panel)  do return end 

for k,v in pairs(panel:GetChildren()) do
	if v.ClassName == "draggable" or v.ClassName == "image" then
		lol(v)
		for k,v in pairs(v:GetChildren()) do
			lol(v) 
		end   
	end
end   