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
	self:SetStyle("frame2")
		
	local bar = self:CreatePanel("base", "bar")
	bar:SetObeyMargin(false)
	bar:SetStyle("frame_bar")
	bar:SetClipping(true)
	bar:SetSendMouseInputToPanel(self)
	bar:SetupLayoutChain("top", "fill_x")
	--bar:SetDrawScaleOffset(Vec2()+2)
		
	local close = bar:CreatePanel("button")
	close:SetStyle("close_inactive")
	close:SetStyleTranslation("button_active", "close_active")
	close:SetStyleTranslation("button_inactive", "close_inactive")
	close:SetupLayoutChain("right")
	close.OnRelease = function() 
		self:Remove()
	end
	self.close = close
		
	local max = bar:CreatePanel("button")
	max:SetStyle("maximize2_inactive")
	max:SetStyleTranslation("button_active", "maximize2_active")
	max:SetStyleTranslation("button_inactive", "maximize2_inactive")
	max:SetupLayoutChain("right")
	max.OnRelease = function() 
		self:Maximize()
	end
	self.max = max
	
	local min = bar:CreatePanel("text_button") 
	min:SetStyle("minimize_inactive")
	min:SetStyleTranslation("button_active", "minimize_active")
	min:SetStyleTranslation("button_inactive", "minimize_inactive")
	min:SetupLayoutChain("right")
	min.OnRelease = function()
		self:Minimize()
	end
	self.min = min

	self:SetMinimumSize(Vec2(bar:GetHeight(), bar:GetHeight()))
			
	self:SetTitle(self:GetTitle())
	
	self:CallOnRemove(function()
		if gui2.task_bar:IsValid() then
			gui2.task_bar:RemoveButton(self)
		end
	end)
end

function PANEL:OnLayout(S)
	self:SetMargin(Rect(S,S,S,S))
	
	self.bar:SetLayoutSize(Vec2()+12*S)
	self.bar:SetMargin(Rect()+S)
	self.bar:SetPadding(Rect()-S)
	
	self.min:SetPadding(Rect()+S)
	self.max:SetPadding(Rect()+S)
	self.close:SetPadding(Rect()+S)
	self.title:SetPadding(Rect()+S)
end

function PANEL:Maximize()
	local max = self.max
	
	if self.maximized then
		self:SetSize(self.maximized.size)
		self:SetPosition(self.maximized.pos)
		self:SetupLayoutChain()
		self.maximized = nil
		max:SetStyle("maximize2_inactive")
		max:SetStyleTranslation("button_active", "maximize2_active")
		max:SetStyleTranslation("button_inactive", "maximize2_inactive")
	else
		self.maximized = {size = self:GetSize():Copy(), pos = self:GetPosition():Copy()}
		self:SetupLayoutChain("fill_x", "fill_y")
		max:SetStyle("maximize_inactive")
		max:SetStyleTranslation("button_active", "maximize_active")
		max:SetStyleTranslation("button_inactive", "maximize_inactive")
	end
end

function PANEL:IsMaximized()
	return self.maximized
end

function PANEL:Minimize(b)
	if b ~= nil then
		self:SetVisible(b)
	else
		self:SetVisible(not self.Visible)
	end
end

function PANEL:IsMinimized()
	return self.Visible
end

function PANEL:SetTitle(str)
	self.Title = str
	
	gui2.RemovePanel(self.title)
	local title = self.bar:CreatePanel("text")
	title:SetText(str)
	title:SetNoDraw(true)
	title:SetupLayoutChain("left")
	self.title = title
	
	if gui2.task_bar:IsValid() then
		gui2.task_bar:AddButton(self:GetTitle(), self, function(button) 
			self:SetVisible(not self.Visible)
		end)
	end
end

function PANEL:OnMouseInput()
	self:MarkCacheDirty()
end

gui2.RegisterPanel(PANEL)

if RELOAD then
	local panel = gui2.CreatePanel(PANEL.ClassName)
	panel:SetSize(Vec2(300, 300))
end