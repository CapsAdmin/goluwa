local PANEL = {}

PANEL.ClassName = "checkbox"

gui.IsSet(PANEL, "Checked", false)

function PANEL:Initialize()
	self:SetCursor("hand")
end

function PANEL:OnMouseInput(key, press)	
	if not press then
		if key == "button_1" then
			self.Checked = not self.Checked
			return self:OnChecked(self.Checked)
		end
	end
end

function PANEL:OnChecked(b) 

end

function PANEL:OnDraw()
	self:DrawHook("CheckboxDraw")
end

function PANEL:OnRequestLayout()
	self:LayoutHook("ButtonLayout")
end

gui.RegisterPanel(PANEL)

do -- labeled checkbox
	local PANEL = {}
	
	PANEL.ClassName = "labeled_checkbox"
	
	gui.GetSet(PANEL, "Value", false)
		
	function PANEL:Initialize()
		local lbl = gui.Create("label", self)
		lbl:SetText("nothing")
		self.left_label = lbl
		
		local chk = gui.Create("checkbox", self)
		chk.OnChecked = self.OnValueChanged
		self.checkbox = chk
	end
	
	function PANEL:SetValue(bool)
		self.Value = bool
		
		self.checkbox:SetChecked(bool)
	end
	
	function PANEL:SetText(str)
		self.left_label:SetText(str)
	end
	
	function PANEL:OnRequestLayout(parent, size)
		local pad = self.NoPadding and 0 or self:GetSkinVar("Padding", 1)

		self.checkbox:SetPos(Vec2(0, 0))
		self.checkbox:SetSize(Vec2() + self:GetHeight())
				
		self.left_label:SetPos(Vec2(self.checkbox:GetPos().x + self.checkbox:GetWidth() + pad, 0))
		self.left_label:SizeToText()

		self.checkbox:CenterY()
		self.left_label:CenterY()
	end
	
	function PANEL:OnValueChanged(val)
	
	end
	
	gui.RegisterPanel(PANEL)
end