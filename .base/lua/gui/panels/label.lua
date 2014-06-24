local PANEL = {}

PANEL.ClassName = "label"

gui.GetSet(PANEL, "Text", "")

gui.GetSet(PANEL, "ShadowDir")
gui.GetSet(PANEL, "ShadowBlur")
gui.GetSet(PANEL, "ShadowSize")

gui.GetSet(PANEL, "TextOffset", Vec2(0,0))
gui.GetSet(PANEL, "AlignNormal", e.ALIGN_CENTERY)

gui.GetSet(PANEL, "ResizeTextWithPanel", true)
gui.GetSet(PANEL, "IgnoreMouse", true)

gui.GetSet(PANEL, "Font", "default")

function PANEL:SetFont(font)
	self.Font = font
	if self.ResizeTextWithPanel then
		self:SizeToText()
	end
end

function PANEL:SetText(str)
	self.Text = str
end

function PANEL:SizeToText()
	if self:HasParent() then
		self.Parent:RequestLayout()
	end
	self:LayoutHook("LabelLayout")
end

function PANEL:SetText(str)
	self.Text = str
	if self.ResizeTextWithPanel then
		self:SizeToText()
	end
end

function PANEL:OnDraw()
	self:DrawHook("LabelDraw")
end

function PANEL:OnRequestLayout()
	self:LayoutHook("LabelLayout")
end

event.AddListener("FontChanged", "aahh_font_change", function(name, info)
	for k,v in pairs(gui.active_panels) do
		if v.Font == name then
			gui.World:RequestLayout()
			break
		end
	end
end)

gui.RegisterPanel(PANEL)