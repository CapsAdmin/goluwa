window.Open(1000, 1000)

surface.CreateFont("lol", {
	path = "fonts/unifont.ttf",
	size = 13,
	smoothness = 0,
})

local frame = utilities.RemoveOldObject(aahh.Create("frame"), "lol")
	frame:SetSize(Vec2()+1000)
	frame:Center()
	frame:SetTitle("")

	local edit = aahh.Create("text_input", frame)
		edit:SetFont("lol")
		edit:SetText(vfs.Read("lua/textbox.lua"))
		edit:Dock("fill")
		edit:SetWrap(true)
		edit:SetLineNumbers(true)
		edit:MakeActivePanel()
	frame:RequestLayout(true)
	
	LOL = edit
