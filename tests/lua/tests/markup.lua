-- due to the whole read speed thing this  will return bad sizes the first frame but proper sizes the frame after

local str = vfs.Read("lua/goluwa/libraries/markup.lua")--:sub(0,2000)
local sstr = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam vel eleifend libero, et placerat enim. Praesent faucibus purus sed tortor feugiat, ut varius sapien volutpat. Proin quis consequat leo. Nam sit amet adipiscing sem. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Donec libero turpis, aliquam eu lacus non, vehicula viverra dolor. Pellentesque laoreet nunc velit, et sodales orci mollis quis. Etiam egestas nunc vitae ultrices aliquam. Integer ornare ligula vestibulum nisi accumsan auctor. Fusce blandit nunc rhoncus leo pharetra, vitae malesuada odio pretium. Nunc viverra mi nec ante consequat, pharetra pretium arcu iaculis. Nullam auctor lectus tellus, a convallis ligula placerat vel. Donec dignissim non massa vitae mollis. Morbi lobortis ante nulla, eget tempus ipsum porttitor sed. Quisque a lectus semper, interdum risus eget, sagittis erat. Proin ut turpis et odio interdum egestas vehicula eu velit. Nunc ac urna nec justo imperdiet interdum id nec lorem. In convallis quis sapien nec faucibus. Mauris dictum imperdiet magna, non feugiat sapien tempus eget. Suspendisse ullamcorper justo at pharetra aliquam. Vestibulum convallis interdum urna sit amet sollicitudin. Duis in iaculis est, sit amet aliquet tortor. Curabitur luctus erat mollis dictum congue. Curabitur fermentum libero erat, vel faucibus ante tempor eget. Etiam eros nunc, ultrices at mollis a, placerat id erat. Etiam id tempus mi. Nullam vestibulum scelerisque odio, sed consectetur purus luctus sit amet. Nulla lacus libero, fringilla nec vehicula id, mattis id orci. Proin eu mauris tortor. Nullam placerat lectus eu mi imperdiet, placerat porttitor felis feugiat. Maecenas aliquet vestibulum metus, eu commodo tortor blandit eu. Integer vehicula imperdiet lectus, et vehicula nisi pulvinar ac. Maecenas consequat ipsum nisl, ac facilisis metus feugiat sit amet. Mauris ac arcu vulputate, aliquet felis et, condimentum elit. Mauris non imperdiet ligula, eu rhoncus metus. Vivamus vulputate, mi eu imperdiet ultrices, felis turpis lacinia purus, eu fermentum sapien ipsum laoreet tortor. Donec at nibh magna. Nullam mattis pellentesque placerat. Proin diam sem, consectetur et mauris vel, interdum aliquet metus. Nulla auctor dolor elementum blandit sagittis. Fusce sollicitudin tellus eget sem iaculis, in tincidunt odio volutpat. Integer sed odio fringilla, pretium turpis in, tincidunt nunc. Duis id interdum enim. Praesent dictum mauris sed aliquam dignissim. Proin vitae arcu at purus accumsan tempus. Phasellus lorem urna, gravida at iaculis eget, aliquam in tellus. Phasellus convallis justo nec nunc sagittis, tincidunt hendrerit justo hendrerit. Phasellus sodales sem ut est cursus interdum. Nulla at blandit dolor. Cras blandit commodo purus, ut auctor dui vehicula vel. Phasellus erat diam, commodo ut nulla at, suscipit vulputate risus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam nec libero consectetur, commodo nulla vitae, iaculis nisl. Fusce imperdiet elit massa, in euismod metus lacinia pretium. Suspendisse ac eros in quam tempor varius at ut sem. Vestibulum interdum libero ut lorem aliquam ornare.]]

local chinese = "此頁面必須發表評論。甚至或可抵扣自由，房地產，例如。這是一個純粹的，但對免疫系統的夾爪的溫度，以預先規劃的職業。這是一個發展的過程。事實上，這只是一個遊戲。一流的專業背景扭曲了我們的工會，由主動。只要游離鹼，有湖不，運送及卡通疼痛的一些足球。點擊此處法案現在希望它，當美國的成員柔軟的它。"
chinese = utf8.totable(chinese)
 
str = str:gsub("(%a+)", function(word)
	local c = HSVToColor(math.random(), 0.5, 1)
	
	if false then
	if math.random() > 0.5 then
		word = ("<texture=textures/debug/brain.jpg,%f>"):format(math.randomf(1, 4)) .. word 
	end
	
	
	if math.random() > 0.5 then
		word = ("<font=some_big_font>") .. word
	else
		word = ("<font=default>") .. word
	end
		
	if math.random() > 0.4 then
		local str = ""
		for i = 1, math.random(1, 3) do
			str = str .. table.random(chinese)
		end
		word = word .. "<font=chinese>" .. str .. "<font=default>"
	end
	
	end
	
	return ("<color=%f,%f,%f>%s"):format(c.r, c.g, c.b, word)
end) 
   
LOL = str 

local m = Markup()
m:SetTable({LOL:sub(0,10000)})
m:SetEditMode(true)

m:SetMaxWidth(500) 
M = m

event.AddListener("OnDraw2D", "markup", function()
	local x = window.GetMousePos().x
	
	if input.IsMouseDown("button_2") then
		m:SetMaxWidth(x) 
		
	surface.Color(1,1,1,1)
	surface.DrawLine(x, 0, x, 1000)
	end
	
	--surface.SetTextPos(0,0)
	---surface.DrawText("\t\t\t\tASDSADSAD")
	
	--surface.PushMatrix(50,50)
	m:Draw()
	
--	surface.PopMatrix()

end)     

event.AddListener("OnMouseInput", "markup", function(button, press)
	m:OnMouseInput(button, press, window.GetMousePos():Unpack())
end)