local gui2 = ... or _G.gui2
local S = gui2.skin.scale

do
	local PANEL = {}
	PANEL.ClassName = "menu"
	PANEL.sub_menu = NULL
	
	function PANEL:Initialize()
		self:SetStyle("button_inactive")
	end
	
	function PANEL:AddEntry(text, on_click)
		local entry = gui2.CreatePanel("menu_entry", self)
		
		entry:SetText(text)
		entry.OnClick = on_click
		
		return entry
	end
	
	function PANEL:AddSubMenu(text, on_click)
		local menu = self:AddEntry(text, on_click):CreateSubMenu()
		
		self:CallOnRemove(function() gui2.RemovePanel(menu) end)
		self:CallOnHide(function() menu:SetVisible(false) end)
		
		return menu  
	end
	
	function PANEL:AddSeparator()
		local panel = gui2.CreatePanel("base", self)
		panel:SetStyle("button_active")
		panel:SetHeight(2*S)
		panel:SetIgnoreMouse(true)
	end
	
	function PANEL:OnLayout()
		local w = 0
		local y = S*2
		
		for k, v in ipairs(self:GetChildren()) do
			v:SetPosition(Vec2(2*S, y))
			if v.label then
				w = math.max(w, v.label:GetSize().w)
			end
			y = y + v:GetSize().h + S
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
		self:SetColor(Color(0,0,0,0))
		self:SetStyle("menu_select")
		self:SetPadding(Rect(S, S, S, S))
		
		self.label = gui2.CreatePanel("text", self)
		self.label:SetFont("snow_font") 
		self.label:SetTextColor(ColorBytes(200, 200, 200)) 
	end
	
	function PANEL:OnMouseEnter()
		self:SetColor(Color(1,1,1,1))
		
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
		self:SetColor(Color(1,1,1,0))
	end
	
	function PANEL:SetText(str)
		self.label:SetText(str)
		self:SetHeight(self.label:GetSize().h + 4*S)
		self.label:SetPosition(Vec2(2*S,0))
		self.label:CenterY()
	end
	
	function PANEL:CreateSubMenu()			
	
		local icon = gui2.CreatePanel("base", self)
		icon:Dock("right")
		icon:SetIgnoreMouse(true)
		icon:SetPadding(Rect(0,0,S*2,0))
		icon:SetColor(Color(0,0,0,0))
		
		local label = gui2.CreatePanel("text", icon)
		label:SetFont("snow_font") 
		label:SetTextColor(ColorBytes(200,200,200)) 
		label:SetText("▶")
		icon:SetSize(label:GetSize())

		self.menu = gui2.CreatePanel("menu")
		self.menu:SetVisible(false)
		
		return self.menu
	end
			 
	function PANEL:OnMouseInput(button, press)
		if button == "button_1" and press then
			self:OnClick()
		end
	end
	
	function PANEL:OnClick() gui2.SetActiveMenu() end 
	
	gui2.RegisterPanel(PANEL)
end