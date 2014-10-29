local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}
PANEL.ClassName = "frame"

prototype.GetSet(PANEL, "Title", "no title")

function PANEL:Initialize()	
	self:SetDraggable(true)
	self:SetResizable(true) 
	self:SetBringToFrontOnClick(true)
	self:SetCachedRendering(true)
		
	self:SetMargin(Rect(S,10*S,S,S))  
	self:SetStyle("frame")
		
	local bar = gui2.CreatePanel("base", self)
	bar:SetObeyMargin(false)
	bar:Dock("fill_top") 
	bar:SetHeight(10*S)
	bar:SetSimpleTexture(true)
	bar:SetStyle("gradient")
	bar:SetColor(ColorBytes(120, 120, 160))
	bar:SetClipping(true)
	bar:SetSendMouseInputToPanel(self)
	
	local close = gui2.CreatePanel("text_button", bar)
	close:SetFont("snow_font_noshadow")
	close:SetTextColor(ColorBytes(50,50,50))
	close:SetText("X")
	close:SizeToText()
	close:SetStyle("button_rounded_inactive")
	close:SetStyleTranslation("button_active", "button_rounded_active")
	close:SetStyleTranslation("button_inactive", "button_rounded_inactive")
	close.OnPress = function() 
		self:Remove()
	end
	self.close = close
	
	local max = gui2.CreatePanel("text_button", bar)
	max:SetFont("snow_font_noshadow")
	max:SetTextColor(ColorBytes(50,50,50))
	max:SetText("⬜")
	max:SizeToText()
	max:SetStyle("button_rounded_inactive")
	max:SetStyleTranslation("button_active", "button_rounded_active")
	max:SetStyleTranslation("button_inactive", "button_rounded_inactive")
	max.OnPress = function() 
		if self.maximized then
			self:Dock()
			self:SetSize(self.maximized.size)
			self:SetPosition(self.maximized.pos)
			self.maximized = nil
		else
			self.maximized = {size = self:GetSize():Copy(), pos = self:GetPosition():Copy()}
			self:Dock("fill")
		end
	end
	self.max = max
	
	local min = gui2.CreatePanel("text_button", bar)
	min:SetFont("snow_font_noshadow")
	min:SetTextColor(ColorBytes(50,50,50))
	min:SetText("‾")
	min:SizeToText()
	min:SetStyle("button_rounded_inactive")
	min:SetStyleTranslation("button_active", "button_rounded_active")
	min:SetStyleTranslation("button_inactive", "button_rounded_inactive")
	min.OnPress = function() 
		self:SetVisible(not self.Visible)
	end
	self.min = min

	self:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))
	
	self.frame = self
	self.bar = bar
		
	self:SetTitle(self:GetTitle())
	
	self:CallOnRemove(function()
		gui2.task_bar:RemoveButton(self)
	end)
end

function PANEL:SetTitle(str)
	self.Title = str
	
	gui2.RemovePanel(self.title)
	local title = gui2.CreatePanel("text", self.bar)
	title:SetHeight(self.bar:GetHeight())
	title:SetFont("snow_font")  
	title:SetTextColor(ColorBytes(200, 200, 200))
	title:SetText(str)
	title:SetPosition(Vec2(2*S,0))
	title:CenterY()
	title:SetNoDraw(true)
	self.title = title
	
	gui2.task_bar:AddButton(self:GetTitle(), self, function(button) 
		self:SetVisible(not self.Visible)
	end)
end

function PANEL:OnMouseInput()
	self:MarkCacheDirty()
end

function PANEL:OnLayout()
	local p = self:GetMargin()
	self.close:SetX(self.bar:GetWidth() - self.close:GetWidth() - p.w)
	self.close:CenterY()
	
	self.max:SetX(self.bar:GetWidth() - self.close:GetWidth() - self.max:GetWidth() - p.w*2)
	self.max:CenterY()
	
	self.min:SetX(self.bar:GetWidth() - self.close:GetWidth() - self.max:GetWidth() - self.min:GetWidth() - p.w*3)
	self.min:CenterY()
end

gui2.RegisterPanel(PANEL)  