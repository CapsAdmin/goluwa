do
	local META = {}
	META.ClassName = "menu_bar"

	function META:AddEntry(what, options)
		local button = self:CreatePanel("text_button")
		button:SetText(what)
		button:SetMargin(Rect()+5)
		button:SizeToText()
		button:SetupLayout("center", "left")
		function button:OnRelease()
			local menu = gui.CreateMenu(options, self)
			menu:SetPosition(button:GetWorldPosition() + Vec2(0, self:GetHeight()))
		end
	end

	gui.RegisterPanel(META)
end


local frame = gui.CreatePanel("frame", nil, "imgui")
frame:SetSize(Vec2(500, 1000))

local bar = frame:CreatePanel("menu_bar")
bar:SetMargin(Rect()+3)
bar:SetStyle("frame")
bar:SetHeight(30)
bar:SetupLayout("top", "fill_x")
bar:AddEntry("Menu", {
	{"New"},
	{"Open"},
	{"Open Recent"},
})
