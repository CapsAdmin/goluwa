local gui = ... or _G.gui

do
	local PANEL = {}
	PANEL.ClassName = "menu"

	function PANEL:Initialize()
		self.sub_menu = NULL

		self:SetStyle("button_inactive")
		self:SetStack(true)
		self:SetStackRight(false)
		self:SetSizeStackToWidth(true)
	end

	function PANEL:AddEntry(text, on_click)
		local entry = self:CreatePanel("menu_entry")

		entry:SetText(text)
		entry.OnClick = on_click

		self:Layout()

		return entry
	end

	function PANEL:AddSubMenu(text, on_click)
		local menu, entry = self:AddEntry(text, on_click):CreateSubMenu()

		self:CallOnRemove(function() gui.RemovePanel(menu) end)
		self:CallOnHide(function() menu:SetVisible(false) end)

		self:Layout()

		return menu, entry
	end

	function PANEL:AddSeparator()
		local panel = self:CreatePanel("base")
		panel:SetStyle("button_active")
		panel:SetIgnoreMouse(true)
		panel.separator = true

		self:Layout()
	end

	function PANEL:OnLayout(S)
		self:SetMargin(Rect()+S*2)
		self:SetSize(Vec2()+500)
		self:SetLayoutSize(Vec2()+500)

		local w = 0

		for i,v in ipairs(self:GetChildren()) do
			if v.separator then
				v:SetHeight(S*2)
			else
				v:SetHeight(S*10)
				v:Layout(true)
				w = math.max(w, v.label:GetX() + v.label:GetWidth() + v.label:GetPadding():GetRight()*8)
			end
		end

		self:SetHeight(self:StackChildren().y + self:GetMargin():GetBottom())
		self:SetWidth(w + self:GetMargin():GetRight())
	end

	gui.RegisterPanel(PANEL)
end

do
	local PANEL = {}

	PANEL.ClassName = "menu_entry"

	function PANEL:Initialize()
		self.menu = NULL

		self:SetNoDraw(true)
		self:SetStyle("menu_select")

		local img = self:CreatePanel("base", "image")
		img:SetIgnoreMouse(true)
		img:SetVisible(false)
		img:SetupLayout("left", "center_y_simple")

		local label = self:CreatePanel("text", "label")
		label:SetupLayout("left", "center_y_simple")
		label:SetIgnoreMouse(true)
		self:SetWidth(100)
	end

	function PANEL:OnMouseEnter()
		self:SetNoDraw(false)

		-- close all parent menus
		for k,v in ipairs(self.Parent:GetChildren()) do
			if v ~= self and v.ClassName == "menu_entry" and v.menu and v.menu:IsValid() and v.menu.ClassName == "menu" then
				v.menu:SetVisible(false)
			end
		end

		if self.menu:IsValid() then
			self.menu:SetVisible(true)
			self.menu:SetPosition(self:GetWorldPosition() + Vec2(self:GetWidth(), 0))
			self.menu:Animate("DrawScaleOffset", {Vec2(0,1), Vec2(1,1)}, 0.25, "*", 0.25, true)
		end
	end

	function PANEL:OnLayout(S)
		self:SetMargin(Rect()+S*2)
		self.label:SetPadding(Rect()+S*2)
		self.image:SetPadding(Rect()+S*2)
		if self.image.Texture then
			self.image:SetLayoutSize(Vec2(math.min(S*8, self.image.Texture:GetSize().x), math.min(S*8, self.image.Texture:GetSize().y)))
		end
	end

	function PANEL:OnMouseExit()
		self:SetNoDraw(true)
	end

	function PANEL:SetText(str)
		self.label:SetText(str)
		self:Layout()
	end

	function PANEL:SetIcon(texture)
		if texture then
			self.image:SetTexture(texture)
			self.image:SetVisible(true)
		end
		self:Layout()
	end

	function PANEL:CreateSubMenu()

		local icon = self:CreatePanel("base")
		icon:SetIgnoreMouse(true)
		icon:SetStyle("menu_right_arrow")
		icon:SetupLayout("left", "right", "center_y_simple")

		self.menu = gui.CreatePanel("menu")
		self.menu:SetVisible(false)

		if self.Skin then self.menu:SetSkin(self:GetSkin()) end

		return self.menu, self
	end

	function PANEL:OnMouseInput(button, press)
		if button == "button_1" and press then
			self:OnClick()
		end
	end

	function PANEL:OnClick() gui.SetActiveMenu() end

	gui.RegisterPanel(PANEL)
end