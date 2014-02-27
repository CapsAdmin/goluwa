local PANEL = {}

PANEL.ClassName = "label"

aahh.GetSet(PANEL, "Text", "")

aahh.GetSet(PANEL, "ShadowDir")
aahh.GetSet(PANEL, "ShadowBlur")
aahh.GetSet(PANEL, "ShadowSize")

aahh.GetSet(PANEL, "TextOffset", Vec2(0,0))
aahh.GetSet(PANEL, "AlignNormal", e.ALIGN_CENTERY)

aahh.GetSet(PANEL, "ResizeTextWithPanel", true)
aahh.GetSet(PANEL, "IgnoreMouse", true)

aahh.GetSet(PANEL, "Font", "default")

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
	for k,v in pairs(aahh.active_panels) do
		if v.Font == name then
			aahh.World:RequestLayout()
			print("huh") 
			break
		end
	end
end)

aahh.RegisterPanel(PANEL)