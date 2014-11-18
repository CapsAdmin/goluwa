local gui2 = ... or _G.gui2
local S = gui2.skin.scale

do
	local PANEL = {}
	PANEL.ClassName = "menu"
	PANEL.sub_menu = NULL
	
	function PANEL:Initialize()
		self:SetStyle("frame")
	end
	
	function PANEL:AddEntry(text, on_click)
		local entry = self:CreatePanel("menu_entry")
		
		entry:SetText(text)
		entry.OnClick = on_click
		
		return entry
	end

	function PANEL:AddSubMenu(text, on_click)
		local menu, entry = self:AddEntry(text, on_click):CreateSubMenu()
		
		self:CallOnRemove(function() gui2.RemovePanel(menu) end)
		self:CallOnHide(function() menu:SetVisible(false) end)
		
		return menu, entry 
	end
	
	function PANEL:AddSeparator()
		local panel = self:CreatePanel("base")
		panel:SetStyle("button_active")
		panel:SetHeight(S*2)
		panel:SetIgnoreMouse(true)
	end
	
	function PANEL:OnLayout()
		local w = 0
		local y = S*2
		
		for k, v in ipairs(self:GetChildren()) do
			v:SetPosition(Vec2(2*S, y))
			if v.label then
				v.label:SetX(v.image:GetWidth() + 2*S)
				w = math.max(w, v.label:GetSize().w + v.image:GetWidth())
				v.label:CenterY()
				v.image:CenterY()
			end
			y = y + v:GetHeight() + S
		end
		
		for k, v in ipairs(self:GetChildren()) do
			v:SetWidth(w + 4*S)
		end
		
		self:SetSize(Vec2(w + 8*S, y + S))
	end
	
	gui2.RegisterPanel(PANEL)
end

do
	local PANEL = {}
	
	PANEL.ClassName = "menu_entry"
	PANEL.menu = NULL
	
	function PANEL:Initialize()
		self:SetNoDraw(true)
		self:SetStyle("frame")
		self:SetPadding(Rect(S, S, S, S))
				
		local img = self:CreatePanel("base", "image")
		img:SetIgnoreMouse(true)
		img:SetNoDraw(true)
		img:SetSize(Vec2()+S*8)
		
		local label = self:CreatePanel("text", "label")
		label:SetIgnoreMouse(true)
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
			self.menu:Layout(true)
			self.menu:SetPosition(self:GetWorldPosition() + Vec2(self:GetWidth() + S*2, 0))
			self.menu:Animate("DrawScaleOffset", {Vec2(0,1), Vec2(1,1)}, 0.25, "*", 0.25, true)
		end
	end
	
	function PANEL:OnMouseExit()
		self:SetNoDraw(true)
	end
	
	function PANEL:SetText(str)
		self.label:SetText(str)
		self:SetHeight(self.label:GetHeight() + 4*S)
		self.label:SetPosition(Vec2(2*S,0))
		self.label:CenterY()
	end
	
	function PANEL:SetIcon(texture)
		if texture then
			self.image:SetTexture(texture)
			self.image:SetNoDraw(false)
		else
			self.image:SetNoDraw(true)
		end
	end
	
	function PANEL:CreateSubMenu()			
	
		local icon = self:CreatePanel("base")
		icon:SetupLayoutChain("right")
		icon:SetIgnoreMouse(true)
		icon:SetStyle("menu_right_arrow")

		self.menu = gui2.CreatePanel("menu")
		self.menu:SetVisible(false)
		
		return self.menu, self
	end
			 
	function PANEL:OnMouseInput(button, press)
		if button == "button_1" and press then
			self:OnClick()
		end
	end
	
	function PANEL:OnClick() gui2.SetActiveMenu() end 
	
	gui2.RegisterPanel(PANEL)
end