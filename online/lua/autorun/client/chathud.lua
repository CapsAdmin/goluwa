chathud = chathud or {}
chathud.lines =  {}
chathud.life_time = 20

function chathud.AddText(...)
	local markup = Markup()
	
	markup:SetTable({...}, true)
	markup:SetEditable(false)
	markup.life_time = os.clock() + chathud.life_time
	markup:SetMaxWidth(surface.GetScreenSize() / 2)
	
	table.insert(chathud.lines, 1, markup)
end

function chathud.Draw()
	local w, h = surface.GetScreenSize()
	local x, y = 30, h/2
	for i, markup in pairs(chathud.lines) do
		local alpha = (markup.life_time - os.clock()) / chathud.life_time
		
		y = y - markup.height
		
		surface.SetAlphaMultiplier(0.5 + alpha ^ 0.25)		
			surface.PushMatrix(x, y)
				markup:Draw(x,y, w, h)
			surface.PopMatrix()		
		surface.SetAlphaMultiplier(1)
				
		if alpha < 0 then
			table.remove(chathud.lines, i)
		end
	end
end

event.AddListener("PreDrawMenu", "chathud", function()
	chathud.Draw()
end)

event.AddListener("OnMouseInput", "chathud", function(button, press)
	for _, markup in pairs(chathud.lines) do
		markup:OnMouseInput(button, press, window.GetMousePos():Unpack())
	end
end)