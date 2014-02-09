local str = vfs.Read("lua/goluwa/libraries/markup.lua"):sub(0,2000)

str = str:gsub("(%a+)", function(word)
	local c = HSVToColor(math.random(), 0.5, 1)
	
	if math.random() > 0.5 then
		word = ("<texture=textures/debug/brain.jpg,%f>"):format(math.randomf(1, 4)) .. word 
	end
	
	return ("<color=%f,%f,%f>%s"):format(c.r, c.g, c.b, word)
end)
 
local m = Markup() 
m:SetTable({str})

event.AddListener("OnDraw2D", "markup", function()
	--surface.SetTextPos(0,0)
	---surface.DrawText("\t\t\t\tASDSADSAD")
	
	m:Draw()
	local x = window.GetMousePos().x or math.abs(math.sin(timer.GetTime()*0.25)) * surface.GetScreenSize()
	m:SetMaxWidth(x)
	surface.DrawLine(x, 0, x, 1000)
end)