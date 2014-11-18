local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "tab"
PANEL.tabs = {}

function PANEL:Initialize()
	self:SetNoDraw(true)

	local tab_bar =  self:CreatePanel("base", "tab_bar")
	tab_bar:SetNoDraw(true)
	
	tab_bar:SetStack(true)
	tab_bar:SetStackDown(false)
	tab_bar:SetClipping(true)
	tab_bar:SetScrollable(true)
	tab_bar:SetMargin(Rect())
end

function PANEL:AddTab(name)
	if self.tabs[name] then
		gui2.RemovePanel(self.tabs[name].button)
		gui2.RemovePanel(self.tabs[name].content)
	end

	local button = self.tab_bar:CreatePanel("text_button")
	button:SetMode("toggle")

	button:SetStyleTranslation("button_active", "tab_active")
	button:SetStyleTranslation("button_inactive", "tab_inactive")
	button:SetStyle("tab_inactive")
	
	button:SetTextColor(gui2.skin.text_color_inactive)
	button:SetText(name)
	button:SetMargin(Rect()+2*S)
	button:SizeToText()
	button:SetHeight(S*10)
	button:CenterText()

	button.text = name
	
	button.OnMouseInput = function(button, key, press)
		if press and key == "button_1" then
			self:SelectTab(name)
		end
	end
	
	local content = self:CreatePanel("base")
	content:SetStyle("tab_frame")
	content:SetVisible(false)
	self.content = content
	
	self:Layout(true)
	
	self.tabs[name] = {button = button, content = content}
	
	return content
end

function PANEL:SelectTab(name)
	local button = self.tabs[name].button
	
	button:SetTextColor(gui2.skin.text_color)
	button:SetText(button.text)
	button:CenterText()
	button:SetState(true)
	
	self.content = self.tabs[name].content
	self.content:SetVisible(true)
	
	for i, panel in ipairs(self.tab_bar:GetChildren()) do
		if button ~= panel then
			panel:SetTextColor(gui2.skin.text_color_inactive)
			panel:SetText(panel.text)
			panel:CenterText()
			panel:SetState(false)
			self.tabs[panel.text].content:SetVisible(false)
		end
	end
	
	self:Layout()
end

function PANEL:GetSelectedPage(name)
	return self.content
end

function PANEL:OnLayout()
	self.tab_bar:SetWidth(self:GetWidth())
	self.tab_bar:SetHeight(10*S)
	self.tab_bar:SetY(1)

	if self.content then
		self.content:SetPosition(Vec2(0, self.tab_bar:GetHeight()))
		self.content:SetHeight(self:GetHeight() - self.tab_bar:GetHeight())
		self.content:SetWidth(self:GetWidth())
	end
end

gui2.RegisterPanel(PANEL)