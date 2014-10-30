local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "tab"
PANEL.tabs = {}

function PANEL:Initialize()
	self:SetNoDraw(true)

	local tab_bar =  gui2.CreatePanel("base", self)
	tab_bar:SetColor(ColorBytes(16,16,152,255))
	
	tab_bar:SetStack(true)
	tab_bar:SetStackDown(false)
	tab_bar:SetClipping(true)
	tab_bar:SetScrollable(true)
			
	self.tab_bar = tab_bar
end

function PANEL:AddTab(name)
	if self.tabs[name] then
		gui2.RemovePanel(self.tabs[name].button)
		gui2.RemovePanel(self.tabs[name].content)
	end

	local button = gui2.CreatePanel("text_button", self.tab_bar)
	button:SetMode("toggle")

	button:SetStyleTranslation("button_active", "tab_active")
	button:SetStyleTranslation("button_inactive", "tab_inactive")
	button:SetStyle("tab_inactive")
	
	button:SetSize(Vec2(22,14)*S)
	button:SetHeight(button:GetHeight() - S)
	button:SetTextColor(ColorBytes(168,168,224))
	button:SetText(name)
	button:SetMargin(Rect()+4*S)
	button:SizeToText()
	button:CenterText()

	button.text = name
	
	button.OnMouseInput = function(button, key, press)
		if press and key == "button_1" then
			button:SetTextColor(ColorBytes(160,160,0))
			button:SetText(button.text)
			button:CenterText()
			button:SetState(true)
			
			self.content = self.tabs[name].content
			self.content:SetVisible(true)
			
			for i, panel in ipairs(self.tab_bar:GetChildren()) do
				if button ~= panel then
					panel:SetTextColor(ColorBytes(168,168,224))
					panel:SetText(panel.text)
					panel:CenterText()
					panel:SetState(false)
					self.tabs[panel.text].content:SetVisible(false)
				end
			end
			
			self:Layout()
		end
	end
	
	local content = gui2.CreatePanel("base", self)
	content:SetStyle("frame")
	content:SetVisible(false)
	content:SetNoDraw(true)
	self.content = content
	
	self:Layout(true)
	
	self.tabs[name] = {button = button, content = content}
	
	return content
end

function PANEL:OnLayout()
	self.tab_bar:SetWidth(self:GetWidth())
	self.tab_bar:SetHeight(12*S)

	if self.content then
		self.content:SetPosition(Vec2(0, self.tab_bar:GetHeight()))
		self.content:SetHeight(self:GetHeight() - self.tab_bar:GetHeight())
		self.content:SetWidth(self:GetWidth())
	end
end

gui2.RegisterPanel(PANEL)